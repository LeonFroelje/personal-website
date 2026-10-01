// src/content.config.ts
import { defineCollection, z } from 'astro:content';
import { glob } from 'astro/loaders';
import type { Loader, LoaderContext } from 'astro/loaders';
import { execFile as execFileCb } from 'node:child_process';
import { promisify } from 'node:util';
import path from 'node:path';
import fs from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import { splitTypstDocument } from './lib/typst-html';

const execFile = promisify(execFileCb);

interface TypstLoaderOptions {
  writingDir: string;
  libDir?: string;
  typstRoot: string;
  fontsDir?: string;
  pdfOutDir?: string; // if set, also emit <id>.pdf here (paged/print target)
}

async function evalFrontmatter(
  filePath: string,
  baseArgs: string[],
  cwd: string,
  logger: { warn: (msg: string) => void, error: (msg: string) => void },
  file: string
): Promise<Record<string, unknown>> {
  try {
    const { stdout } = await execFile(
      'typst',
      ['eval', 'query(<frontmatter>).first().value', '--in', filePath, ...baseArgs],
      { cwd, encoding: 'utf-8' }
    );
    return JSON.parse(stdout);
  } catch (e) {
    // `.first()` panics on an empty query result -- that's the expected
    // case for a doc that hasn't added a <frontmatter> label yet, not a
    // real error, so we fail open with empty metadata.
    logger.warn(`No <frontmatter> metadata block found in ${file} - using defaults.`);
    logger.error(`${e}`);
    return {};
  }
}
function typstCliLoader(options: TypstLoaderOptions): Loader {
  const timers = new Map<string, NodeJS.Timeout>();

  return {
    name: 'typst-cli-loader',
    load: async (context: LoaderContext) => {
      const { store, logger, watcher, generateDigest, parseData, config } = context;
      const root = fileURLToPath(config.root);
      const writingDir = path.resolve(root, options.writingDir);
      const libDir = options.libDir ? path.resolve(root, options.libDir) : null;
      const typstRoot = path.resolve(root, options.typstRoot);
      const fontsPath = options.fontsDir ? path.resolve(root, options.fontsDir) : null;

      const libDigestSeed = async () => {
        if (!libDir) return '';
        const files = (await fs.readdir(libDir, { recursive: true }).catch(() => [] as string[]))
          .filter((f) => f.endsWith('.typ'))
          .sort();
        const contents = await Promise.all(files.map((f) => fs.readFile(path.join(libDir, f), 'utf-8')));
        return contents.join('\0');
      };

      const compileFile = async (file: string, seed: string) => {
        const filePath = path.join(writingDir, file);
        const id = file.replace(/\.typ$/, '').replace(/\\/g, '/');
        const rawContent = await fs.readFile(filePath, 'utf-8');
        const digest = generateDigest(rawContent + seed);

        const existing = store.get(id);
        if (existing && existing.digest === digest) return id;

        logger.info(`Compiling Typst file: ${file}`);

        const baseArgs = ['--root', typstRoot];
        if (fontsPath) baseArgs.push('--font-path', fontsPath);
        const htmlArgs = ['--features', 'html', ...baseArgs];
        const tasks: Promise<unknown>[] = [
          execFile('typst', ['compile', '--format', 'html', ...htmlArgs, filePath, '-'], {
            cwd: typstRoot, encoding: 'utf-8', maxBuffer: 1024 * 1024 * 32,
          }),
          evalFrontmatter(filePath, htmlArgs, typstRoot, logger, file),
        ];
        if (options.pdfOutDir) {
          const pdfDir = path.resolve(root, options.pdfOutDir);
          const pdfPath = path.join(pdfDir, `${id}.pdf`);
          tasks.push(
            fs.mkdir(pdfDir, { recursive: true })
              .then(() => execFile('typst', ['compile', ...baseArgs, filePath, pdfPath], { cwd: typstRoot }))
          );
        }
        try {
          const [{ stdout: rawHtml }, frontmatter] =
            (await Promise.all(tasks)) as [{ stdout: string }, Record<string, unknown>];
          const { title: htmlTitle, bodyHtml } = splitTypstDocument(rawHtml);
          const fallbackTitle = id
            .split('/')
            .pop()!
            .replace(/-/g, ' ')
            .replace(/\b\w/g, (l) => l.toUpperCase());
          const data = await parseData({
            id,
            data: {
              title: htmlTitle ?? fallbackTitle,
              ...frontmatter,
            },
          });

          store.set({ id, data, rendered: { html: bodyHtml }, digest });
        } catch (err: any) {
          logger.error(`Typst compilation failed for ${file}:\n${err.stderr ?? err.message}`);
        }
        return id;
      };

      const recompileAll = async () => {
        const seed = await libDigestSeed();
        const entries = await fs.readdir(writingDir, { recursive: true });
        const typFiles = entries.filter((f) => f.endsWith('.typ'));
        const ids = new Set<string>();
        for (const file of typFiles) ids.add(await compileFile(file, seed));
        for (const key of store.keys()) if (!ids.has(key)) store.delete(key);
      };

      if (watcher) {
        watcher.add(path.join(writingDir, '**/*.typ'));
        if (libDir) watcher.add(path.join(libDir, '**/*.typ'));

        const schedule = () => {
          clearTimeout(timers.get('all'));
          timers.set('all', setTimeout(() => recompileAll().catch((e) => logger.error(String(e))), 150));
        };

        watcher.on('change', (p: string) => p.endsWith('.typ') && schedule());
        watcher.on('add', (p: string) => p.endsWith('.typ') && schedule());
        watcher.on('unlink', (p: string) => {
          if (!p.endsWith('.typ')) return;
          if (p.startsWith(writingDir)) {
            store.delete(path.relative(writingDir, p).replace(/\.typ$/, '').replace(/\\/g, '/'));
          } else {
            schedule();
          }
        });
      }

      await recompileAll();
    },
  };
}

const cv = defineCollection({
  loader: typstCliLoader({
    writingDir: './src/content/cv',
    libDir: './src/content/typst-lib',
    typstRoot: './src/content',
    fontsDir: './public/fonts',
    pdfOutDir: './public', // -> public/cv.pdf
  }),
  schema: z.object({ title: z.string() }),
});

const projects = defineCollection({
  loader: glob({ pattern: '**/*.yaml', base: './src/content/projects' }),
  schema: z.object({
    title: z.string(),
    summary: z.string(),
    year: z.number(),
    tags: z.array(z.string()).default([]),
    repoUrl: z.string().url().optional(),
    liveUrl: z.string().url().optional(),
    writeup: z.string().optional(), // id into the `writing` collection
    featured: z.boolean().default(false),
  }),
});

const writing = defineCollection({
  loader: typstCliLoader({
    writingDir: './src/content/writing',
    libDir: './src/content/typst-lib',
    typstRoot: './src/content',
    fontsDir: './public/fonts',
  }),
  schema: z.object({
    title: z.string(),
    description: z.string().optional(),
    date: z.coerce.date().optional(),
    draft: z.boolean().default(false),
    tags: z.array(z.string()).default([]),
  }),
});

export const collections = {
  writing, projects, cv
};



