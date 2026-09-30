// src/content.config.ts
import { defineCollection, z } from 'astro:content';
import { execFileSync } from 'node:child_process';
import path from 'node:path';
import fs from 'node:fs/promises';

const typstCliLoader = (options: { base: string; fontsDir?: string }) => {
  let isWatching = false;

  return {
    name: 'typst-cli-loader',
    load: async ({ store, logger, watcher, generateDigest }: any) => {
      const baseDir = path.resolve(options.base);
      const fontsPath = options.fontsDir ? path.resolve(options.fontsDir) : null;

      // Helper compilation function
      const compileFile = async (file: string) => {
        const filePath = path.join(baseDir, file);
        const id = file.replace(/\.typ$/, '').replace(/\\/g, '/');

        const rawContent = await fs.readFile(filePath, 'utf-8');
        const digest = generateDigest(rawContent);

        const existingEntry = store.get(id);
        if (existingEntry && existingEntry.digest === digest) {
          return id;
        }

        logger.info(`Compiling Typst file: ${file}`);

        try {
          const args = ['compile', '--features', 'html', '--format', 'html'];
          if (fontsPath) {
            args.push('--font-path', fontsPath);
          }
          args.push(filePath, '-');

          const htmlOutput = execFileSync('typst', args, {
            encoding: 'utf-8',
            cwd: baseDir,
          });

          store.set({
            id,
            data: {
              title: id
                .split('/')
                .pop()!
                .replace(/-/g, ' ')
                .replace(/\b\w/g, (l) => l.toUpperCase()),
            },
            rendered: {
              html: htmlOutput,
            },
            digest,
          });
        } catch (compileError: any) {
          logger.error(
            `Typst CLI compilation failed for ${file}:\n${compileError.stderr || compileError.message
            }`
          );
        }
        return id;
      };

      // Set up watcher for dev mode live-reloading
      if (watcher && !isWatching) {
        isWatching = true;
        const watchPattern = path.join(baseDir, '**/*.typ');
        watcher.add(watchPattern);

        watcher.on('change', async (filePath: string) => {
          if (filePath.endsWith('.typ')) {
            const relativePath = path.relative(baseDir, filePath).replace(/\\/g, '/');
            logger.info(`[typst-cli-loader] File changed: ${relativePath}`);
            await compileFile(relativePath);
          }
        });

        watcher.on('unlink', (filePath: string) => {
          if (filePath.endsWith('.typ')) {
            const relativePath = path.relative(baseDir, filePath).replace(/\\/g, '/');
            const id = relativePath.replace(/\.typ$/, '');
            logger.info(`[typst-cli-loader] File deleted: ${relativePath}`);
            store.delete(id);
          }
        });
      }

      // Initial scan on server start / build
      try {
        const entries = await fs.readdir(baseDir, { recursive: true });
        const typFiles = entries.filter((file) => file.endsWith('.typ'));
        const currentIds = new Set<string>();

        for (const file of typFiles) {
          const id = await compileFile(file);
          if (id) currentIds.add(id);
        }

        // Clean up deleted keys from store
        for (const key of store.keys()) {
          if (!currentIds.has(key)) {
            store.delete(key);
          }
        }
      } catch (error) {
        logger.error(`Failed reading Typst directory: ${error}`);
      }
    },
  };
};

export const collections = {
  docs: defineCollection({
    loader: typstCliLoader({
      base: './src/content/docs',
      fontsDir: './public/fonts',
    }),
    schema: z.object({
      title: z.string(),
    }),
  }),
};
