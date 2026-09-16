import { mount } from 'svelte';

// The design tokens, before anything else.
//
// Every utility the theme generates resolves to a CSS custom property —
// `.px-4` is `padding-left: var(--spacing-4)`, not `1rem` — and those
// properties are defined here. Without this import the stylesheet loads, every
// class matches, and every value resolves to nothing: padding 0, radius 0,
// colours at their browser defaults. The components look unstyled while
// looking, in the DOM, entirely correct. apps/shell imports the same file in
// its root layout.
import '@p9e.in/samavaya/css';
import 'uno.css';

import Gallery from './Gallery.svelte';

mount(Gallery, { target: document.getElementById('app')! });
