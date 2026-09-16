/**
 * Binds each catalog group to the component that renders it.
 *
 * This is the only file in the gallery that imports .svelte, which is what
 * lets catalog.ts be imported by the Playwright spec running under Node.
 */

import type { Component } from 'svelte';

import Alert from '../src/feedback/Alert.svelte';
import Avatar from '../src/display/Avatar.svelte';
import Badge from '../src/display/Badge.svelte';
import Button from '../src/actions/Button.svelte';
import Card from '../src/display/Card.svelte';
import EmptyState from '../src/feedback/EmptyState.svelte';
import ProgressBar from '../src/feedback/ProgressBar.svelte';
import Skeleton from '../src/feedback/Skeleton.svelte';
import Spinner from '../src/feedback/Spinner.svelte';
import StatusBadge from '../src/business/StatusBadge.svelte';

import { catalog, type StoryGroupSpec, type StorySpec } from './catalog';

export type { StorySpec, StoryGroupSpec };
export { catalog, allStories, stableStories } from './catalog';

/**
 * Group name to component.
 *
 * Keyed by the catalog's group name rather than by story id, so adding a
 * variant of an existing component is a line in catalog.ts and nothing here.
 */
const components: Record<string, Component<any>> = {
  Alert,
  Avatar,
  Badge,
  Button,
  Card,
  EmptyState,
  ProgressBar,
  Skeleton,
  Spinner,
  StatusBadge,
};

export interface ResolvedGroup {
  name: string;
  component: Component<any>;
  stories: StorySpec[];
}

/**
 * The catalog with components attached.
 *
 * A group whose name has no component throws here rather than rendering an
 * empty box. An empty box screenshots perfectly consistently for ever, so a
 * typo in a group name would otherwise be recorded as a passing baseline and
 * stay that way.
 */
export const groups: ResolvedGroup[] = catalog.map((group: StoryGroupSpec) => {
  const component = components[group.name];
  if (!component) {
    throw new Error(
      `gallery: catalog group "${group.name}" has no component in stories.ts. ` +
        `Known groups: ${Object.keys(components).join(', ')}`,
    );
  }
  return { name: group.name, component, stories: group.stories };
});
