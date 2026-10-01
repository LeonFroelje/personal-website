// src/pages/rss.xml.ts
import rss from '@astrojs/rss';
import { getCollection } from 'astro:content';
import type { APIContext } from 'astro';

export async function GET(context: APIContext) {
  const docs = await getCollection('docs', ({ data }) => !data.draft);
  return rss({
    title: 'Leon Frölje — Writing',
    description: "Notes on math, computer science, and whatever else I'm currently interested in.",
    site: context.site!,
    items: docs
      .sort((a, b) => (b.data.date?.valueOf() ?? 0) - (a.data.date?.valueOf() ?? 0))
      .map((doc) => ({
        title: doc.data.title,
        description: doc.data.description,
        pubDate: doc.data.date,
        link: `/writing/${doc.id}/`,
      })),
  });
}
