#!/usr/bin/env node
/**
 * Copy the shared configs into dist/.
 *
 * This replaces a build script written as three chained `xcopy` invocations.
 * xcopy is a Windows command, so `pnpm install` failed at the postinstall hook
 * on every Linux and macOS machine — including CI — before a single package
 * had been built. Node's own recursive copy works everywhere and needs no
 * dependency.
 *
 * The whole of src/ is copied rather than the three directories the xcopy
 * version named, because `src/qwik` is referenced from package.json's exports
 * map and was never copied: importing `@p9e.in/configs/qwik` resolved to a
 * path that did not exist.
 */
import { cp, mkdir, rm } from 'node:fs/promises';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const src = join(root, 'src');
const dist = join(root, 'dist');

// Cleared first so a file deleted from src/ does not survive in dist/ and go
// on being resolved by the exports map.
await rm(dist, { recursive: true, force: true });
await mkdir(dist, { recursive: true });
await cp(src, dist, { recursive: true });

console.log('@p9e.in/configs: copied src/ to dist/');
