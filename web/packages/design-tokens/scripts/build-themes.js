#!/usr/bin/env node

import StyleDictionary from 'style-dictionary'
import { fileURLToPath } from 'url'
import { dirname, join } from 'path'
import fs from 'fs'
import fse from 'fs-extra'

const __filename = fileURLToPath(import.meta.url)
const __dirname = dirname(__filename)
const rootDir = join(__dirname, '..')

// Register custom format for CSS variables
StyleDictionary.registerFormat({
  name: 'css/variables-custom',
  format: function({ dictionary, options = {} }) {
    const { selector = ':root', excludeKeys = [] } = options
    
    const tokens = dictionary.allTokens
      .filter(token => {
        // Skip keyframes
        if (token.type === 'keyframes') return false
        
        // Skip if in exclude list
        const tokenPath = token.path.join('.')
        return !excludeKeys.some(key => tokenPath.includes(key))
      })
      .map(token => `  --${token.name}: ${token.value};`)
      .join('\n')
    
    return `${selector} {\n${tokens}\n}`
  }
})

// Register format for keyframes
StyleDictionary.registerFormat({
  name: 'css/keyframes',
  format: function({ dictionary }) {
    const keyframeTokens = dictionary.allTokens
      .filter(token => token.type === 'keyframes')
    
    if (keyframeTokens.length === 0) return ''
    
    const keyframes = keyframeTokens.map(token => {
      const name = token.name.replace('animation-keyframes-', '')
      let keyframeCSS = ''
      
      if (Array.isArray(token.original.value)) {
        keyframeCSS = token.original.value.map(frame => {
          const { offset, ...properties } = frame
          const percentage = Math.round(offset * 100)
          const props = Object.entries(properties)
            .map(([key, value]) => `    ${key.replace(/([A-Z])/g, '-$1').toLowerCase()}: ${value};`)
            .join('\n')
          return `  ${percentage}% {\n${props}\n  }`
        }).join('\n')
      }
      
      return `@keyframes ${name} {\n${keyframeCSS}\n}`
    }).join('\n\n')
    
    return keyframes
  }
})

// Register the UnoCSS theme format
StyleDictionary.registerFormat({
  name: 'custom/uno-theme',
  format: function({ dictionary }) {
    // The CSS custom property a token path corresponds to.
    //
    // This has to agree exactly with what the `css/variables-custom` format
    // writes into tokens.css, and that format kebab-cases each path segment:
    // ['borderRadius','md'] becomes --border-radius-md, and
    // ['typography','fontSize','sm'] becomes --typography-font-size-sm.
    //
    // The blocks below used to build the name three different ways —
    // path.join('-') for spacing and typography, and Style Dictionary's
    // camelCase `token.name` for radius and shadow — so only the paths that
    // happen to be all-lowercase lined up. `spacing` and the colours worked;
    // fontSize, fontFamily, borderRadius and shadow all pointed at variables
    // that were never defined. UnoCSS still generated the rules, so
    // `.rounded-md` existed and read `var(--BorderRadiusMd)`, which resolves to
    // nothing: every component came out with square corners, no shadow and the
    // browser's default font size, with no error anywhere to say so.
    const cssVar = path =>
      path
        .join('-')
        .replace(/([a-z0-9])([A-Z])/g, '$1-$2')
        .replace(/\./g, '-')
        .toLowerCase()

    // Generate CSS variable references instead of static values
    const verboseColorTokens = dictionary.allTokens
      .filter(token => token.type === 'color')
      .map(token => {
        const path = token.path.join('-')
        return `    '${path}': 'var(--${cssVar(token.path)})'`
      })
      .join(',\n')

    // The same colours again without the leading `color-`.
    //
    // Every colour token is emitted above as `color-brand-primary-500`, so the
    // only utility that resolved was `bg-color-brand-primary-500`. The
    // component library has always written `bg-brand-primary-500` — 77 times
    // for that one class, plus brand-secondary, semantic-error/success/warning/
    // info and the whole neutral scale including `neutral-white`. None of them
    // matched anything, so UnoCSS generated no rule and those components
    // rendered with no background, no border colour and no ring: buttons came
    // out as the browser's default grey, in the apps as well as in the gallery.
    //
    // Nothing caught it because a missing utility is not an error anywhere —
    // the class sits on the element, the stylesheet loads, and there is simply
    // no rule. It was found by screenshotting the components.
    //
    // Derived from the token list rather than hand-listed, so a colour family
    // added to the tokens tomorrow works without anyone remembering to come
    // back here.
    //
    // Emitted as a *nested* tree — brand: { primary: { 500: … } } — rather than
    // as flat 'brand-primary-500' keys, because UnoCSS resolves the two
    // differently. `bg-` accepts either, but `border-` walks the colour object
    // segment by segment: with flat keys `border-neutral-200` worked (the
    // `neutral` alias below is nested) while `border-brand-primary-500` matched
    // nothing at all, so buttons kept a brand background and a black border.
    //
    // No family is excluded. An earlier version skipped families sharing a name
    // with an alias below, which silently dropped `neutral-white` — the second
    // most-used colour class in the library, 88 times.
    const colorTree = {}
    dictionary.allTokens
      .filter(token => token.type === 'color' && token.path[0] === 'color' && token.path.length > 1)
      .forEach(token => {
        const segments = token.path.slice(1)
        let node = colorTree
        segments.slice(0, -1).forEach(segment => {
          // A leaf already sitting where a branch needs to go means two tokens
          // disagree about the shape of the tree — `color.surface.primary` and
          // `color.surface.primary.hover`, say. The shallower one is kept as
          // DEFAULT so `bg-surface-primary` still resolves.
          if (typeof node[segment] === 'string') node[segment] = { DEFAULT: node[segment] }
          node[segment] = node[segment] || {}
          node = node[segment]
        })
        const leaf = segments[segments.length - 1]
        if (node[leaf] && typeof node[leaf] === 'object') {
          node[leaf].DEFAULT = `var(--${cssVar(token.path)})`
        } else {
          node[leaf] = `var(--${cssVar(token.path)})`
        }
      })

    const renderColorTree = (node, indent) =>
      Object.entries(node)
        .map(([key, value]) =>
          typeof value === 'string'
            ? `${indent}'${key}': '${value}'`
            : `${indent}'${key}': {\n${renderColorTree(value, indent + '  ')}\n${indent}}`,
        )
        .join(',\n')

    const unprefixedColorTokens = renderColorTree(colorTree, '    ')

    // Generate UnoCSS-compatible color aliases for standard usage
    const unoColorAliases = []

    // Map brand-primary to 'primary' color scale
    const primaryColors = dictionary.allTokens
      .filter(token => token.type === 'color' && token.path[0] === 'color' && token.path[1] === 'brand' && token.path[2] === 'primary')
      .map(token => {
        const shade = token.path[3]
        return `      '${shade}': 'var(--color-brand-primary-${shade})'`
      })
    if (primaryColors.length > 0) {
      unoColorAliases.push(`    'primary': {\n${primaryColors.join(',\n')}\n    }`)
    }

    // Map brand-secondary to 'secondary' color scale
    const secondaryColors = dictionary.allTokens
      .filter(token => token.type === 'color' && token.path[0] === 'color' && token.path[1] === 'brand' && token.path[2] === 'secondary')
      .map(token => {
        const shade = token.path[3]
        return `      '${shade}': 'var(--color-brand-secondary-${shade})'`
      })
    if (secondaryColors.length > 0) {
      unoColorAliases.push(`    'secondary': {\n${secondaryColors.join(',\n')}\n    }`)
    }

    // Map neutral colors to 'gray' color scale (UnoCSS standard)
    const grayColors = dictionary.allTokens
      .filter(token => token.type === 'color' && token.path[0] === 'color' && token.path[1] === 'neutral' && token.path[2] !== 'white' && token.path[2] !== 'black')
      .map(token => {
        const shade = token.path[2]
        return `      '${shade}': 'var(--color-neutral-${shade})'`
      })
    if (grayColors.length > 0) {
      unoColorAliases.push(`    'gray': {\n${grayColors.join(',\n')}\n    }`)
      unoColorAliases.push(`    'neutral': {\n${grayColors.join(',\n')}\n    }`)
    }

    // Map semantic colors to UnoCSS standard names
    const greenColors = dictionary.allTokens
      .filter(token => token.type === 'color' && token.path[0] === 'color' && token.path[1] === 'semantic' && token.path[2] === 'success')
      .map(token => {
        const shade = token.path[3]
        return `      '${shade}': 'var(--color-semantic-success-${shade})'`
      })
    if (greenColors.length > 0) {
      unoColorAliases.push(`    'green': {\n${greenColors.join(',\n')}\n    }`)
      unoColorAliases.push(`    'success': {\n${greenColors.join(',\n')}\n    }`)
    }

    const redColors = dictionary.allTokens
      .filter(token => token.type === 'color' && token.path[0] === 'color' && token.path[1] === 'semantic' && token.path[2] === 'error')
      .map(token => {
        const shade = token.path[3]
        return `      '${shade}': 'var(--color-semantic-error-${shade})'`
      })
    if (redColors.length > 0) {
      unoColorAliases.push(`    'red': {\n${redColors.join(',\n')}\n    }`)
      unoColorAliases.push(`    'error': {\n${redColors.join(',\n')}\n    }`)
    }

    const yellowColors = dictionary.allTokens
      .filter(token => token.type === 'color' && token.path[0] === 'color' && token.path[1] === 'semantic' && token.path[2] === 'warning')
      .map(token => {
        const shade = token.path[3]
        return `      '${shade}': 'var(--color-semantic-warning-${shade})'`
      })
    if (yellowColors.length > 0) {
      unoColorAliases.push(`    'yellow': {\n${yellowColors.join(',\n')}\n    }`)
      unoColorAliases.push(`    'warning': {\n${yellowColors.join(',\n')}\n    }`)
    }

    const blueColors = dictionary.allTokens
      .filter(token => token.type === 'color' && token.path[0] === 'color' && token.path[1] === 'semantic' && token.path[2] === 'info')
      .map(token => {
        const shade = token.path[3]
        return `      '${shade}': 'var(--color-semantic-info-${shade})'`
      })
    if (blueColors.length > 0) {
      unoColorAliases.push(`    'blue': {\n${blueColors.join(',\n')}\n    }`)
      unoColorAliases.push(`    'info': {\n${blueColors.join(',\n')}\n    }`)
    }

    // Add white and black mappings
    const whiteToken = dictionary.allTokens.find(token => token.path.join('-') === 'color-neutral-white')
    const blackToken = dictionary.allTokens.find(token => token.path.join('-') === 'color-neutral-black')
    if (whiteToken) unoColorAliases.push(`    'white': 'var(--color-neutral-white)'`)
    if (blackToken) unoColorAliases.push(`    'black': 'var(--color-neutral-black)'`)

    // Combine verbose tokens with UnoCSS aliases
    // The token tree goes last so it wins on a key clash.
    //
    // Only `neutral` actually clashes, and the tree's version is a superset:
    // the alias above is built from the numeric shades alone, while the tree
    // also carries `white` and `black`. Emitting the alias last would drop
    // `neutral-white` — the class this whole fix started from.
    const colorTokens = [verboseColorTokens, ...unoColorAliases, unprefixedColorTokens].filter(Boolean).join(',\n')
    

    const spacingTokens = dictionary.allTokens
      .filter(token => token.path[0] === 'spacing')
      .map(token => {
        const key = token.path.slice(1).join('-').replace(/\./g, '-')
        return `    '${key}': 'var(--${cssVar(token.path)})'`
      })
      .join(',\n')

    const fontSizeTokens = dictionary.allTokens
      .filter(token => token.path[0] === 'typography' && token.path[1] === 'fontSize')
      .map(token => {
        const key = token.path[2]
        return `    '${key}': 'var(--${cssVar(token.path)})'`
      })
      .join(',\n')

    const fontFamilyTokens = dictionary.allTokens
      .filter(token => token.path[0] === 'typography' && token.path[1] === 'fontFamily')
      .map(token => {
        const key = token.path[2]
        return `    '${key}': 'var(--${cssVar(token.path)})'`
      })
      .join(',\n')

    const borderRadiusTokens = dictionary.allTokens
      .filter(token => token.path[0] === 'borderRadius')
      .map(token => {
        const key = token.path[1]
        return `    '${key}': 'var(--${cssVar(token.path)})'`
      })
      .join(',\n')

    const shadowTokens = dictionary.allTokens
      .filter(token => token.path[0] === 'shadow')
      .map(token => {
        const key = token.path[1]
        return `    '${key}': 'var(--${cssVar(token.path)})'`
      })
      .join(',\n')

    // Animation utilities with static values (they don't change with theme)
    const animationDurations = dictionary.allTokens
      .filter(token => token.path[0] === 'animation' && token.path[1] === 'duration')
      .map(token => `  ${token.path[2]}: '${token.value}'`)
      .join(',\n')

    const animationEasings = dictionary.allTokens
      .filter(token => token.path[0] === 'animation' && token.path[1] === 'easing')
      .map(token => `  ${token.path[2]}: '${token.value}'`)
      .join(',\n')

    const animationKeyframes = dictionary.allTokens
      .filter(token => token.path[0] === 'animation' && token.path[1] === 'keyframes')
      .map(token => `  '${token.path[2]}': '${token.path[2]}'`)
      .join(',\n')

    return `import type { Theme } from '@unocss/preset-uno'

// This theme uses CSS variables defined in tokens.css
// Colors and other values will automatically switch with theme changes
export const designTokensTheme: Theme = {
  colors: {
${colorTokens}
  },
  spacing: {
${spacingTokens}
  },
  fontSize: {
${fontSizeTokens}
  },
  fontFamily: {
${fontFamilyTokens}
  },
  borderRadius: {
${borderRadiusTokens}
  },
  boxShadow: {
${shadowTokens}
  }
}

// Animation utilities (static values - don't change with theme)
export const animations = {
  // Durations
${animationDurations},
  
  // Easings  
${animationEasings},
  
  // Keyframes
${animationKeyframes}
}

// Component shortcuts using UnoCSS-compatible color names
export const componentShortcuts = {
  // Base component shortcuts (using new UnoCSS-compatible color names)
  'btn-primary': 'bg-primary-500 text-white border-primary-500 rounded-md px-4 py-2 text-sm font-medium shadow-sm transition-all duration-150 ease-out hover:bg-primary-600 hover:border-primary-600 hover:-translate-y-px active:bg-primary-700 active:border-primary-700 active:translate-y-0 disabled:bg-gray-300 disabled:border-gray-300 disabled:text-gray-500 disabled:cursor-not-allowed disabled:opacity-50',

  'btn-secondary': 'bg-white text-primary-600 border-gray-300 rounded-md px-4 py-2 text-sm font-medium shadow-sm transition-all duration-150 ease-out hover:bg-gray-50 hover:border-primary-300 hover:-translate-y-px',

  'input-base': 'bg-white border-gray-300 rounded-md border text-gray-900 text-sm px-3 py-2 h-10 transition-all duration-150 ease-out placeholder:text-gray-500 focus:border-primary-500 focus:outline-none',

  'card-base': 'bg-white border-gray-200 rounded-lg border shadow-sm p-6 transition-all duration-300 ease-out hover:shadow-md hover:-translate-y-0.5',

  // Legacy shortcuts (keep for backwards compatibility)
  'btn-primary-legacy': 'bg-color-brand-primary-500 text-color-neutral-white border-color-brand-primary-500 rounded-md px-4 py-2 text-sm font-medium shadow-sm transition-all duration-150 ease-out hover:bg-color-brand-primary-600 hover:border-color-brand-primary-600 hover:-translate-y-px active:bg-color-brand-primary-700 active:border-color-brand-primary-700 active:translate-y-0 disabled:bg-color-neutral-300 disabled:border-color-neutral-300 disabled:text-color-neutral-500 disabled:cursor-not-allowed disabled:opacity-50',

  'btn-secondary-legacy': 'bg-color-neutral-white text-color-brand-primary-600 border-color-neutral-300 rounded-md px-4 py-2 text-sm font-medium shadow-sm transition-all duration-150 ease-out hover:bg-color-neutral-50 hover:border-color-brand-primary-300 hover:-translate-y-px',

  'input-base-legacy': 'bg-color-neutral-white border-color-neutral-300 rounded-md border text-color-neutral-900 text-sm px-3 py-2 h-10 transition-all duration-150 ease-out placeholder:text-color-neutral-500 focus:border-color-brand-primary-500 focus:outline-none',

  'card-base-legacy': 'bg-color-neutral-white border-color-neutral-200 rounded-lg border shadow-sm p-6 transition-all duration-300 ease-out hover:shadow-md hover:-translate-y-0.5'
}

export default designTokensTheme
`
  }
})

async function buildTokens() {
  console.log('🎨 Building optimized design tokens...')
  
  // Ensure dist directories exist
  const distDirs = ['dist/css', 'dist/js', 'dist/uno', 'dist/types', 'dist/fonts']
  distDirs.forEach(dir => {
    const fullPath = join(rootDir, dir)
    if (!fs.existsSync(fullPath)) {
      fs.mkdirSync(fullPath, { recursive: true })
    }
  })

  // Copy fonts.css to dist directory if it exists
  const fontsCssPath = join(rootDir, 'src/fonts.css')
  const distFontsCssPath = join(rootDir, 'dist/css/fonts.css')
  
  if (fs.existsSync(fontsCssPath)) {
    try {
      await fse.ensureDir(join(rootDir, 'dist/css'))
      await fse.copy(fontsCssPath, distFontsCssPath)
      console.log('✅ Copied fonts.css to dist/css/')
    } catch (error) {
      console.error('❌ Error copying fonts.css:', error)
    }
  }

  try {
    // Build light theme (includes all tokens)
    console.log('☀️  Building light theme...')
    
    const lightConfig = {
      log: {
        verbosity: 'verbose'
      },
      source: [
        'tokens/global/**/*.json',
        'tokens/themes/light.json',
        'tokens/layout/**/*.json',
        'tokens/components/**/*.json'
      ],
      platforms: {
        css: {
          transformGroup: 'css',
          buildPath: 'dist/css/',
          files: [{
            destination: 'tokens-light.css',
            format: 'css/variables-custom'
          }]
        },
        'css-keyframes': {
          transformGroup: 'css',
          buildPath: 'dist/css/',
          files: [{
            destination: 'keyframes.css',
            format: 'css/keyframes'
          }]
        },
        js: {
          transformGroup: 'js',
          buildPath: 'dist/js/',
          files: [{
            destination: 'tokens.js',
            format: 'javascript/es6'
          }]
        },
        uno: {
          transformGroup: 'js',
          buildPath: 'dist/uno/',
          files: [{
            destination: 'theme.ts',
            format: 'custom/uno-theme'
          }]
        }
      }
    }

    const lightSD = new StyleDictionary(lightConfig)
    await lightSD.buildAllPlatforms()

    // Build dark theme
    console.log('🌙 Building dark theme...')
    
    const darkConfig = {
      log: {
        verbosity: 'verbose'
      },
      source: [
        'tokens/global/**/*.json',
        'tokens/themes/dark.json',
        'tokens/layout/**/*.json',
        'tokens/components/**/*.json'
      ],
      platforms: {
        css: {
          transformGroup: 'css',
          buildPath: 'dist/css/',
          files: [{
            destination: 'tokens-dark.css',
            format: 'css/variables-custom'
          }]
        }
      }
    }

    const darkSD = new StyleDictionary(darkConfig)
    await darkSD.buildAllPlatforms()

    // Create optimized combined CSS
    console.log('🔗 Creating optimized combined CSS...')
    
    const lightCSSPath = join(rootDir, 'dist/css/tokens-light.css')
    const darkCSSPath = join(rootDir, 'dist/css/tokens-dark.css')
    const keyframesPath = join(rootDir, 'dist/css/keyframes.css')

    const lightCSS = fs.readFileSync(lightCSSPath, 'utf8')
    const darkCSS = fs.readFileSync(darkCSSPath, 'utf8')
    const keyframesCSS = fs.existsSync(keyframesPath) ? fs.readFileSync(keyframesPath, 'utf8') : ''

    // Extract only the tokens that are different between themes
    const lightTokens = extractTokens(lightCSS)
    const darkTokens = extractTokens(darkCSS)
    
    // Find tokens that are different between themes
    const themeSpecificTokens = new Set()
    for (const [key, value] of lightTokens) {
      if (darkTokens.get(key) !== value) {
        themeSpecificTokens.add(key)
      }
    }
    
    // Build optimized CSS
    let baseTokens = []
    let lightThemeTokens = []
    let darkThemeTokens = []
    
    for (const [key, value] of lightTokens) {
      if (themeSpecificTokens.has(key)) {
        lightThemeTokens.push(`  ${key}: ${value};`)
      } else {
        baseTokens.push(`  ${key}: ${value};`)
      }
    }
    
    for (const [key, value] of darkTokens) {
      if (themeSpecificTokens.has(key)) {
        darkThemeTokens.push(`  ${key}: ${value};`)
      }
    }

    const combinedCSS = `/* 
 * Enterprise Design Tokens - Optimized
 * Base tokens + theme-specific overrides
 */

/* Keyframes */
${keyframesCSS}

/* Base tokens (shared between themes) */
:root {
${baseTokens.join('\n')}
}

/* Light theme (default) - only overrides */
:root {
${lightThemeTokens.join('\n')}
}

/* Dark theme - only overrides */
[data-theme="dark"] {
${darkThemeTokens.join('\n')}
}

/* Auto dark theme */
@media (prefers-color-scheme: dark) {
  :root:not([data-theme="light"]) {
${darkThemeTokens.join('\n')}
  }
}

/* Theme transitions */
* {
  transition: background-color 0.3s ease, color 0.3s ease, border-color 0.3s ease;
}
`

    fs.writeFileSync(join(rootDir, 'dist/css/tokens.css'), combinedCSS)
    console.log('✅ Created optimized tokens.css')

    // Create theme utilities
    console.log('🛠️ Creating theme utilities...')
    const themeUtils = `/**
 * Enterprise Theme Manager for MFE Applications (JS version)
 * @typedef {'light'|'dark'|'auto'} ThemeMode
 */
export class ThemeManager {
  constructor() {
    this.currentTheme = 'auto'
    this.initializeTheme()
    this.setupSystemThemeListener()
  }

  initializeTheme() {
    const savedTheme = /** @type {ThemeMode|null} */ (localStorage.getItem('theme'))
    if (savedTheme && ['light', 'dark', 'auto'].includes(savedTheme)) {
      this.setTheme(savedTheme, false)
    } else {
      this.setTheme('auto', false)
    }
  }

  setupSystemThemeListener() {
    const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)')
    mediaQuery.addEventListener('change', () => {
      if (this.currentTheme === 'auto') {
        this.applyTheme('auto')
        this.notifyThemeChange()
      }
    })
  }

  applyTheme(theme) {
    const root = document.documentElement
    // Add transitioning class to prevent flash
    root.setAttribute('data-theme-switching', '')
    requestAnimationFrame(() => {
      root.removeAttribute('data-theme-switching')
    })

    root.removeAttribute('data-theme')

    switch (theme) {
      case 'light':
        root.setAttribute('data-theme', 'light')
        break
      case 'dark':
        root.setAttribute('data-theme', 'dark')
        break
      case 'auto':
        {
          const systemDark = window.matchMedia('(prefers-color-scheme: dark)').matches
          root.setAttribute('data-theme', systemDark ? 'dark' : 'light')
        }
        break
    }
  }

  notifyThemeChange() {
    window.dispatchEvent(new CustomEvent('themechange', {
      detail: {
        theme: this.currentTheme,
        resolvedTheme: this.getResolvedTheme(),
        systemPreference: this.getSystemPreference()
      }
    }))
  }

  setTheme(theme, save = true) {
    this.currentTheme = theme
    this.applyTheme(theme)
    if (save) localStorage.setItem('theme', theme)
    this.notifyThemeChange()
  }

  getTheme() { return this.currentTheme }

  getResolvedTheme() {
    return this.currentTheme === 'auto' ? this.getSystemPreference() : this.currentTheme
  }

  getSystemPreference() {
    return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light'
  }

  toggleTheme() {
    const current = this.getResolvedTheme()
    this.setTheme(current === 'light' ? 'dark' : 'light')
  }

  isDark() { return this.getResolvedTheme() === 'dark' }

  getCSSVar(property) {
    return getComputedStyle(document.documentElement).getPropertyValue(property).trim()
  }
}

export const themeManager = new ThemeManager()

// Export utility functions
export const getThemeValue = (tokenPath) => {
  return themeManager.getCSSVar(\`--\${tokenPath.replace(/\\./g, '-')}\`)
}

export const isSystemDark = () => {
  return window.matchMedia('(prefers-color-scheme: dark)').matches
}
`

    fs.writeFileSync(join(rootDir, 'dist/js/theme-utils.js'), themeUtils)
    console.log('✅ Created theme-utils.js')

    // Write minimal TypeScript declarations for theme-utils
    const themeUtilsDts = `export type ThemeMode = 'light' | 'dark' | 'auto'

export declare class ThemeManager {
  constructor()
  initializeTheme(): void
  setupSystemThemeListener(): void
  applyTheme(theme: ThemeMode): void
  notifyThemeChange(): void
  setTheme(theme: ThemeMode, save?: boolean): void
  getTheme(): ThemeMode
  getResolvedTheme(): 'light' | 'dark'
  getSystemPreference(): 'light' | 'dark'
  toggleTheme(): void
  isDark(): boolean
  getCSSVar(property: string): string
}

export declare const themeManager: ThemeManager

export declare const getThemeValue: (tokenPath: string) => string
export declare const isSystemDark: () => boolean
`
    fs.writeFileSync(join(rootDir, 'dist/types/theme-utils.d.ts'), themeUtilsDts)
    console.log('✅ Created theme-utils.d.ts')

    // Create UnoCSS index
    const unoIndex = `import type { Theme } from '@unocss/preset-uno'
import { designTokensTheme, componentShortcuts, animations } from './theme'

export { designTokensTheme, componentShortcuts, animations }

// The theme already uses CSS variables, so we can export it directly
export const themeConfig: Theme = designTokensTheme

export default themeConfig
`
    fs.writeFileSync(join(rootDir, 'dist/uno/index.ts'), unoIndex)
    console.log('✅ Created dist/uno/index.ts')

    // Compile the P9E preset to JavaScript
    console.log('🏭 Compiling P9E Enterprise Preset...')
    await compilePresetP9E()

    // No dist/uno/index.js is written.
    //
    // There used to be one, and it imported './theme.js' — a file this build
    // has never produced, because the Style Dictionary platform above emits
    // theme.ts and nothing else. So the package's `./uno` export pointed at a
    // module that threw ERR_MODULE_NOT_FOUND the moment anything loaded it as
    // plain ESM. Nothing caught it because every consumer reaches it through a
    // bundler or through jiti, and both read the .ts happily.
    //
    // The honest fix is to stop claiming a JavaScript entry point that does not
    // exist rather than to generate a second copy of the theme to satisfy it:
    // package.json's exports map now points at the .ts files, which is what is
    // actually built and what every consumer was already resolving.

    // Generate TypeScript types
    console.log('📝 Generating TypeScript types...')
    generateTypes()

    console.log('✅ Design tokens built successfully!')
    console.log(`
📦 Generated files:
├── dist/css/
│   ├── tokens.css (🎯 MAIN FILE - combined themes + animations)
│   ├── tokens-light.css (light theme only)  
│   ├── tokens-dark.css (dark theme only)
│   └── keyframes.css (CSS animations)
├── dist/js/
│   ├── tokens.js (JavaScript tokens)
│   └── theme-utils.js (theme switching utilities)
└── dist/uno/
    ├── index.ts (🎯 MAIN FILE - UnoCSS config)
    └── theme.ts (light UnoCSS theme + shortcuts)

🎨 Ready for your MFEs! Use tokens.css and index.ts
`)

  } catch (error) {
    console.error('❌ Build failed:', error.message)
    console.error(error.stack)
  }
}

// Helper function to extract tokens from CSS
function extractTokens(css) {
  const tokens = new Map()
  const regex = /(--[^:]+):\s*([^;]+);/g
  let match
  while ((match = regex.exec(css)) !== null) {
    tokens.set(match[1], match[2])
  }
  return tokens
}

// Generate TypeScript types from tokens
function generateTypes() {
  const tokenFiles = ['dist/css/tokens-light.css']
  const allTokens = new Map()
  
  // Read all tokens from CSS files
  tokenFiles.forEach(file => {
    const cssPath = join(rootDir, file)
    if (fs.existsSync(cssPath)) {
      const css = fs.readFileSync(cssPath, 'utf8')
      const tokens = extractTokens(css)
      tokens.forEach((value, key) => {
        const tokenName = key.substring(2) // Remove --
        allTokens.set(tokenName, value)
      })
    }
  })
  
  // Group tokens by category
  const categories = new Map()
  allTokens.forEach((value, key) => {
    const parts = key.split('-')
    const category = parts[0]
    if (!categories.has(category)) {
      categories.set(category, [])
    }
    categories.get(category).push({ key, value })
  })
  
  // Generate type definitions
  let typeDefinitions = `// Auto-generated design token types
// Do not edit directly

export interface DesignTokens {
`
  
  categories.forEach((tokens, category) => {
    const categoryName = category.charAt(0).toUpperCase() + category.slice(1)
    typeDefinitions += `  ${category}: {\n`
    tokens.forEach(({ key }) => {
      const propertyName = key.replace(new RegExp(`^${category}-`), '').replace(/-([a-z])/g, (g) => g[1].toUpperCase())
      typeDefinitions += `    '${propertyName}': string\n`
    })
    typeDefinitions += `  }\n`
  })
  
  typeDefinitions += `}

// CSS Variable helper types
export type CSSVarFunction = (path: string) => string

// Token path helper
export type TokenPath<T extends keyof DesignTokens> = keyof DesignTokens[T]

// Export token names as const for type safety
`
  
  categories.forEach((tokens, category) => {
    const categoryConst = category.toUpperCase()
    typeDefinitions += `\nexport const ${categoryConst}_TOKENS = {\n`
    tokens.forEach(({ key }) => {
      const propertyName = key.replace(new RegExp(`^${category}-`), '').replace(/-([a-z])/g, (g) => g[1].toUpperCase())
      typeDefinitions += `  ${propertyName}: '--${key}',\n`
    })
    typeDefinitions += `} as const\n`
  })
  
  // Write types file
  fs.writeFileSync(join(rootDir, 'dist/types/tokens.d.ts'), typeDefinitions)
  console.log('✅ Generated TypeScript types')
}

// Compile P9E preset from TypeScript to JavaScript
async function compilePresetP9E() {
  const presetSrc = join(rootDir, 'src/preset-p9e.ts')
  const presetDist = join(rootDir, 'dist/preset-p9e.js')
  const presetTypes = join(rootDir, 'dist/preset-p9e.d.ts')

  if (!fs.existsSync(presetSrc)) {
    console.log('⚠️ P9E preset source not found, skipping compilation')
    return
  }

  // Read the TypeScript preset
  const presetContent = fs.readFileSync(presetSrc, 'utf8')

  // Simple TypeScript to JavaScript conversion (removing types and converting imports)
  const jsContent = presetContent
    .replace(/import type \{[^}]+\} from [^;]+;?\n?/g, '') // Remove type imports
    .replace(/: Preset\b/g, '') // Remove Preset type annotation
    .replace(/: Rule\b/g, '') // Remove Rule type annotation
    .replace(/: Shortcut\b/g, '') // Remove Shortcut type annotation
    .replace(/as const\b/g, '') // Remove as const
    .replace(/keyof typeof \w+/g, 'string') // Replace keyof typeof with string
    .replace(/from '\.\.\/dist\/uno\/theme'/g, "from './uno/theme.js'") // Fix import path
    .replace(/: string\[\]/g, '') // Remove string[] type annotations
    .replace(/: \w+\[\]/g, '') // Remove other array type annotations

  // Write JavaScript version
  fs.writeFileSync(presetDist, jsContent)
  console.log('✅ Created dist/preset-p9e.js')

  // Create TypeScript declarations
  const dtsContent = `import type { Preset } from '@unocss/core'

/**
 * P9E Enterprise UnoCSS Preset for SCADA, ERP, and IoT applications
 */
export declare function presetP9E(): Preset
`

  fs.writeFileSync(presetTypes, dtsContent)
  console.log('✅ Created dist/preset-p9e.d.ts')
}

buildTokens().catch(console.error)