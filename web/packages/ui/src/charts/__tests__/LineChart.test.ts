import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render } from '@testing-library/svelte';
import type { EChartsOption } from 'echarts';

// ECharts draws to a canvas, which jsdom does not have. Mocking the library
// rather than reaching for node-canvas is deliberate and not a shortcut: what
// is worth testing here is the option object the chart builds from its props —
// whether a stacked chart actually sets `stack`, whether an axis label reaches
// the axis — and that is a pure transformation. Asserting on rendered pixels
// would test ECharts, which is already tested.
const setOption = vi.fn();
const chartStub = {
  setOption,
  resize: vi.fn(),
  dispose: vi.fn(),
  showLoading: vi.fn(),
  hideLoading: vi.fn(),
  on: vi.fn(),
  off: vi.fn(),
  getDataURL: vi.fn(() => 'data:image/png;base64,'),
};

vi.mock('echarts', () => ({
  init: vi.fn(() => chartStub),
  registerTheme: vi.fn(),
  graphic: {
    LinearGradient: class {
      constructor(
        public x: number,
        public y: number,
        public x2: number,
        public y2: number,
        public colorStops: unknown
      ) {}
    },
    RadialGradient: class {
      constructor(
        public x: number,
        public y: number,
        public r: number,
        public colorStops: unknown
      ) {}
    },
  },
}));

const LineChart = (await import('../LineChart.svelte')).default;

/** The option most recently handed to ECharts. */
function lastOption(): EChartsOption {
  expect(setOption.mock.calls.length).toBeGreaterThan(0);
  return setOption.mock.calls[setOption.mock.calls.length - 1][0] as EChartsOption;
}

const categories = ['Jan', 'Feb', 'Mar'];
const series = [
  { name: 'Rainfall', data: [12, 40, 5] },
  { name: 'Irrigation', data: [30, 10, 25] },
];

describe('LineChart', () => {
  beforeEach(() => {
    setOption.mockClear();
  });

  it('puts the categories on the x axis and the series in the chart', () => {
    render(LineChart, { props: { categories, series } });

    const option = lastOption() as Record<string, any>;
    expect(option.xAxis.data).toEqual(categories);
    expect(option.series).toHaveLength(2);
    expect(option.series[0].name).toBe('Rainfall');
    expect(option.series[0].data).toEqual([12, 40, 5]);
  });

  it('marks every series as stacked when stacked is set', () => {
    // The failure this catches: a stacked chart that silently renders
    // overlapping lines reads as "these two measures are similar" rather than
    // as a sum, which is a different claim about the data.
    render(LineChart, { props: { categories, series, stacked: true } });

    const option = lastOption() as Record<string, any>;
    for (const s of option.series) {
      expect(s.stack).toBeTruthy();
    }
  });

  it('does not stack by default', () => {
    render(LineChart, { props: { categories, series } });

    const option = lastOption() as Record<string, any>;
    for (const s of option.series) {
      expect(s.stack).toBeFalsy();
    }
  });

  it('carries the title, subtitle and axis labels through', () => {
    render(LineChart, {
      props: {
        categories,
        series,
        title: 'Water applied',
        subtitle: 'per month, mm',
        xAxisLabel: 'Month',
        yAxisLabel: 'mm',
      },
    });

    const option = lastOption() as Record<string, any>;
    expect(option.title.text).toBe('Water applied');
    expect(option.title.subtext).toBe('per month, mm');
    expect(option.xAxis.name).toBe('Month');
    expect(option.yAxis.name).toBe('mm');
  });

  it('can turn the legend and tooltip off', () => {
    // showTooltip={false} used to do nothing: the condition was
    // `showTooltip || tooltip.show !== false`, so the tooltip survived unless
    // the detailed config ALSO said no. Seven charts had the same line.
    render(LineChart, {
      props: { categories, series, showLegend: false, showTooltip: false },
    });

    const option = lastOption() as Record<string, any>;
    expect(option.legend).toBeUndefined();
    expect(option.tooltip).toBeUndefined();
  });

  it('shows the legend and tooltip by default', () => {
    render(LineChart, { props: { categories, series } });

    const option = lastOption() as Record<string, any>;
    expect(option.legend).toBeDefined();
    expect(option.tooltip).toBeDefined();
  });

  it('lets the detailed tooltip config turn it off on its own', () => {
    render(LineChart, { props: { categories, series, tooltip: { show: false } } });

    expect((lastOption() as Record<string, any>).tooltip).toBeUndefined();
  });

  it('renders with no series at all', () => {
    // An empty chart is a normal state — a field with no readings yet — and
    // must not throw on the way to showing nothing.
    expect(() => render(LineChart, { props: { categories: [], series: [] } })).not.toThrow();

    const option = lastOption() as Record<string, any>;
    expect(option.series).toEqual([]);
  });
});
