// src/components/elements/load-elements.client.ts
import { elementRegistry } from './registry';

const loaded = new Set<string>();

function upgrade() {
  for (const tag of Object.keys(elementRegistry)) {
    if (loaded.has(tag)) continue;
    if (document.querySelector(tag)) {
      loaded.add(tag);
      elementRegistry[tag]().catch((err) => console.error(`Failed to load <${tag}>`, err));
    }
  }
}

upgrade();

// Catch elements added after initial load (e.g. future client-side nav).
new MutationObserver((muts) => {
  if (muts.some((m) => m.addedNodes.length)) upgrade();
}).observe(document.body, { childList: true, subtree: true });
