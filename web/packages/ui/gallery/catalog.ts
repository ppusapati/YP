/**
 * The gallery's catalog: what to render, minus the components themselves.
 *
 * Split from stories.ts so the Playwright spec can import it. The spec runs in
 * Node, whose transpiler does not parse .svelte — importing the component
 * bindings there fails before a single test is collected, and it fails as a
 * syntax error inside a component file, which points nowhere near the cause.
 *
 * One entry per component variant worth looking at. A catalog rather than a
 * file per component on purpose: with 221 components, a convention that costs
 * a new file and a new import per story is one nobody keeps up with, and a
 * gallery covering a third of the library is worse than an honest small one,
 * because it looks complete.
 *
 * Every entry must be deterministic. These are screenshotted and compared
 * pixel for pixel, so anything that varies between runs — a date, a random id,
 * an animation mid-flight — is a test that fails on Tuesday for no reason, and
 * a suite that cries wolf is one people stop reading. `unstable` marks the
 * ones that cannot be made deterministic; they render in the gallery for a
 * human to look at and are skipped by the screenshot comparison.
 */

export interface StorySpec {
  /** Stable id. It becomes the screenshot filename, so renaming one orphans its baseline. */
  id: string;
  props?: Record<string, unknown>;
  /** Default-slot text, for the components that take children. */
  slot?: string;
  /**
   * Skipped by the screenshot comparison, still rendered in the gallery.
   * Set it only with a reason: "cannot be made deterministic" is a claim that
   * should have to be justified to whoever reads it next.
   */
  unstable?: string;
  /**
   * This story is *supposed* to render nothing, with the reason why.
   *
   * It is still screenshotted: an empty box is a perfectly good baseline, and
   * it is what catches the badge starting to render a "0" it should hide. What
   * this opts out of is the "every story rendered something" assertion, which
   * is otherwise the check that catches a component silently failing.
   */
  expectsEmpty?: string;
}

export interface StoryGroupSpec {
  /** Matches a key in stories.ts's component map. */
  name: string;
  stories: StorySpec[];
}

const buttonVariants = ['primary', 'secondary', 'outline', 'ghost', 'danger', 'success', 'warning'] as const;
const sizes = ['xs', 'sm', 'md', 'lg', 'xl'] as const;
const alertVariants = ['info', 'success', 'warning', 'error'] as const;

export const catalog: StoryGroupSpec[] = [
  {
    name: 'Button',
    stories: [
      ...buttonVariants.map((variant) => ({
        id: `button-${variant}`,
        props: { variant },
        slot: variant[0].toUpperCase() + variant.slice(1),
      })),
      ...sizes.map((size) => ({
        id: `button-size-${size}`,
        props: { size },
        slot: `Size ${size}`,
      })),
      { id: 'button-disabled', props: { disabled: true }, slot: 'Disabled' },
      {
        id: 'button-loading',
        props: { loading: true },
        slot: 'Loading',
        // The spinner inside a loading button is a CSS animation. Screenshotting
        // it captures whatever frame the compositor happened to be on.
        unstable: 'the loading spinner animates',
      },
      { id: 'button-full-width', props: { fullWidth: true }, slot: 'Full width' },
    ],
  },

  {
    name: 'Alert',
    stories: [
      ...alertVariants.map((variant) => ({
        id: `alert-${variant}`,
        props: { variant, title: variant[0].toUpperCase() + variant.slice(1) },
        slot: 'The monsoon arrived eleven days late at this field.',
      })),
      {
        id: 'alert-no-icon',
        props: { variant: 'info', showIcon: false, title: 'No icon' },
        slot: 'An alert with its icon turned off.',
      },
      {
        id: 'alert-dismissible',
        props: { variant: 'warning', dismissible: true, title: 'Dismissible' },
        slot: 'This one has a close button.',
      },
    ],
  },

  {
    name: 'Badge',
    stories: [
      { id: 'badge-default', props: {}, slot: 'Default' },
      { id: 'badge-pill', props: { pill: true }, slot: 'Pill' },
      { id: 'badge-dot', props: { dot: true } },
      { id: 'badge-count', props: { content: 8 } },
      // A count over its max is where the "99+" truncation shows, which is the
      // part of this component most likely to be broken by a style change.
      { id: 'badge-count-overflow', props: { content: 240, max: 99 } },
      {
        id: 'badge-zero-hidden',
        props: { content: 0 },
        expectsEmpty: 'a zero count is hidden unless showZero is set — that is the point of this story',
      },
      { id: 'badge-zero-shown', props: { content: 0, showZero: true } },
    ],
  },

  {
    name: 'StatusBadge',
    stories: [
      { id: 'status-active', props: { status: 'active', label: 'Active' } },
      { id: 'status-pending', props: { status: 'pending', label: 'Pending' } },
      { id: 'status-with-dot', props: { status: 'active', label: 'Irrigating', showDot: true } },
      { id: 'status-uppercase', props: { status: 'active', label: 'committed', uppercase: true } },
      {
        id: 'status-pulse',
        props: { status: 'active', label: 'Live', pulse: true },
        unstable: 'the pulse is a CSS animation',
      },
    ],
  },

  {
    name: 'ProgressBar',
    stories: [
      { id: 'progress-empty', props: { value: 0 } },
      { id: 'progress-partial', props: { value: 42 } },
      { id: 'progress-full', props: { value: 100 } },
      { id: 'progress-with-label', props: { value: 64, label: 'Sowing window', showLabel: true, showValue: true } },
      { id: 'progress-striped', props: { value: 55, striped: true } },
      {
        id: 'progress-indeterminate',
        props: { indeterminate: true },
        unstable: 'an indeterminate bar is an animation by definition',
      },
      {
        id: 'progress-animated',
        props: { value: 55, striped: true, animated: true },
        unstable: 'the stripes move',
      },
    ],
  },

  {
    name: 'Spinner',
    stories: sizes.map((size) => ({
      id: `spinner-${size}`,
      props: { size },
      unstable: 'a spinner spins',
    })),
  },

  {
    name: 'Skeleton',
    stories: [
      // Animation off. A skeleton's whole job is to shimmer, so the default is
      // untestable — but its *shape* is what regresses, and that is worth
      // screenshotting with the shimmer stopped.
      { id: 'skeleton-text', props: { variant: 'text', animation: 'none' } },
      { id: 'skeleton-text-lines', props: { variant: 'text', lines: 3, animation: 'none' } },
      { id: 'skeleton-circular', props: { variant: 'circular', width: '48px', height: '48px', animation: 'none' } },
      { id: 'skeleton-rectangular', props: { variant: 'rectangular', width: '240px', height: '96px', animation: 'none' } },
      { id: 'skeleton-rounded', props: { variant: 'rounded', width: '240px', height: '96px', animation: 'none' } },
    ],
  },

  {
    name: 'Card',
    stories: [
      { id: 'card-elevated', props: { variant: 'elevated' }, slot: 'Elevated card' },
      { id: 'card-outlined', props: { variant: 'outlined' }, slot: 'Outlined card' },
      { id: 'card-filled', props: { variant: 'filled' }, slot: 'Filled card' },
      { id: 'card-padding-none', props: { padding: 'none' }, slot: 'No padding' },
      { id: 'card-clickable', props: { clickable: true }, slot: 'Clickable card' },
    ],
  },

  {
    name: 'Avatar',
    stories: [
      // Initials, never a remote image. A story that loads a URL is a story
      // that fails when the network does, and it would fail as a *visual
      // regression* rather than as a network error.
      { id: 'avatar-initials', props: { name: 'Ramesh Kumar' } },
      ...sizes.map((size) => ({
        id: `avatar-${size}`,
        props: { name: 'Ramesh Kumar', size },
      })),
      { id: 'avatar-square', props: { name: 'Ramesh Kumar', shape: 'square' } },
      { id: 'avatar-status', props: { name: 'Ramesh Kumar', status: 'online', showBadge: true } },
    ],
  },

  {
    name: 'EmptyState',
    stories: [
      { id: 'empty-default', props: { title: 'No fields yet' } },
      {
        id: 'empty-with-description',
        props: {
          title: 'No fields yet',
          description: 'Add a field to start recording inspections against it.',
        },
      },
      {
        id: 'empty-with-action',
        props: {
          title: 'No fields yet',
          description: 'Add a field to start recording inspections against it.',
          actionLabel: 'Add a field',
        },
      },
    ],
  },
];

/** Every story, flattened, in the order the gallery renders them. */
export const allStories: StorySpec[] = catalog.flatMap((group) => group.stories);

/** The stories the screenshot comparison covers. */
export const stableStories: StorySpec[] = allStories.filter((story) => !story.unstable);
