// src/components/elements/registry.ts
export const elementRegistry: Record<string, () => Promise<unknown>> = {
  'interactive-sine-plot': () => import('../InteractivePlot.element'),
  // 'mandelbrot-viewer': () => import('./MandelbrotViewer.element'),
};
