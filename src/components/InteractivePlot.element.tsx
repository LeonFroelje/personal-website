import { customElement } from 'solid-element';
import { createSignal, createEffect, onMount } from 'solid-js';

export function SinePlotWidget(props: { frequency?: number; amplitude?: number }) {
  // Read initial values from HTML attributes, defaulting if omitted
  const initialFreq = Number(props.frequency ?? 2);
  const initialAmp = Number(props.amplitude ?? 40);

  // Reactive signals for interactive user controls
  const [frequencySignal, setFrequencySignal] = createSignal(initialFreq);
  const [amplitudeSignal, setAmplitudeSignal] = createSignal(initialAmp);

  let canvasRef!: HTMLCanvasElement;

  onMount(() => {
    const ctx = canvasRef.getContext('2d');
    if (!ctx) return;

    // Re-draws automatically whenever frequencySignal() or amplitudeSignal() changes
    createEffect(() => {
      const freq = frequencySignal();
      const amp = amplitudeSignal();

      // Clear Canvas
      ctx.clearRect(0, 0, canvasRef.width, canvasRef.height);

      // Draw Grid / Axis line
      ctx.beginPath();
      ctx.strokeStyle = '#e2e8f0';
      ctx.moveTo(0, canvasRef.height / 2);
      ctx.lineTo(canvasRef.width, canvasRef.height / 2);
      ctx.stroke();

      // Draw Sine Wave
      ctx.beginPath();
      ctx.strokeStyle = '#2563eb';
      ctx.lineWidth = 2;

      const midY = canvasRef.height / 2;
      for (let x = 0; x < canvasRef.width; x++) {
        const y = midY + amp * Math.sin((x * freq * Math.PI) / 180);
        if (x === 0) ctx.moveTo(x, y);
        else ctx.lineTo(x, y);
      }
      ctx.stroke();
    });
  });

  return (
    <div style={{
      display: 'flex',
      'flex-direction': 'column',
      gap: '12px',
      margin: '1.5rem 0',
      padding: '1rem',
      border: '1px solid #e2e8f0',
      'border-radius': '8px',
      background: '#f8fafc',
      'max-width': '450px'
    }}>
      <canvas ref={canvasRef} width={400} height={150} style={{ background: '#ffffff', 'border-radius': '4px', border: '1px solid #cbd5e1' }} />

      <div style={{ display: 'flex', 'flex-direction': 'column', gap: '8px', 'font-family': 'sans-serif', 'font-size': '0.9rem' }}>
        <label style={{ display: 'flex', 'justify-content': 'space-between', 'align-items': 'center' }}>
          <span><strong>Frequency:</strong> {frequencySignal()} Hz</span>
          <input
            type="range"
            min="1"
            max="50"
            step="0.5"
            value={frequencySignal()}
            onInput={(e) => setFrequencySignal(Number(e.currentTarget.value))}
          />
        </label>

        <label style={{ display: 'flex', 'justify-content': 'space-between', 'align-items': 'center' }}>
          <span><strong>Amplitude:</strong> {amplitudeSignal()} px</span>
          <input
            type="range"
            min="10"
            max="60"
            step="1"
            value={amplitudeSignal()}
            onInput={(e) => setAmplitudeSignal(Number(e.currentTarget.value))}
          />
        </label>
      </div>
    </div>
  );
}

// Register as <interactive-sine-plot frequency="..." amplitude="...">
customElement(
  'interactive-sine-plot',
  { frequency: 2, amplitude: 40 },
  SinePlotWidget
);
