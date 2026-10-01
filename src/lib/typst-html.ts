// src/lib/typst-html.ts
import { parse } from 'parse5';

/**
 * `typst compile --format html` always emits a full standalone document
 * (<!DOCTYPE html><html><head>...<title>...</head><body>...</body></html>).
 * Astro's page component is itself a full document, so embedding that
 * output verbatim via <Content /> nests two <html>/<head>/<body> trees.
 *
 * We use parse5 (spec-compliant, handles SVG/MathML foreign-content
 * parsing correctly) only to *find* the <body> element's location in the
 * source text via sourceCodeLocationInfo. We then slice the *original*
 * string at those offsets instead of re-serializing anything parse5
 * produced. This guarantees embedded SVG (cetz diagrams), MathML, and
 * custom elements like <interactive-sine-plot> survive byte-for-byte -
 * no risk of a serializer lowercasing `viewBox` or otherwise "helpfully"
 * normalizing markup it doesn't need to touch.
 */

function findFirst(node: any, tagName: string): any | null {
  if (!node) return null;
  if (node.tagName === tagName) return node;
  for (const child of node.childNodes ?? []) {
    const found = findFirst(child, tagName);
    if (found) return found;
  }
  return null;
}

function textContent(node: any): string {
  if (!node) return '';
  if (node.nodeName === '#text') return node.value ?? '';
  return (node.childNodes ?? []).map(textContent).join('');
}

export interface SplitResult {
  title: string | null;
  bodyHtml: string;
}

export function splitTypstDocument(rawHtml: string): SplitResult {
  try {
    const document = parse(rawHtml, { sourceCodeLocationInfo: true });

    const titleNode = findFirst(document, 'title');
    const title = textContent(titleNode).trim() || null;

    const bodyNode = findFirst(document, 'body');
    const loc = bodyNode?.sourceCodeLocation;
    if (!loc) {
      // No <body> found for some reason - fail open rather than drop content.
      return { title, bodyHtml: rawHtml };
    }

    const start = loc.startTag?.endOffset ?? loc.startOffset;
    const end = loc.endTag?.startOffset ?? loc.endOffset;
    return { title, bodyHtml: rawHtml.slice(start, end) };
  } catch {
    return { title: null, bodyHtml: rawHtml };
  }
}
