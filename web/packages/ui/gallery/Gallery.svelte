<script lang="ts">
  /**
   * Renders every story in the manifest, each in its own bounded box.
   *
   * The box matters more than it looks. Playwright screenshots the box, not
   * the page, so one component growing by a pixel changes one baseline instead
   * of shifting everything below it and failing every screenshot at once. A
   * suite where one change fails forty tests is one whose output nobody reads.
   */
  import { groups, type Story } from './stories';

  // Set by the screenshot run before it starts capturing. Everything that
  // moves is stopped by CSS below rather than by waiting, because waiting for
  // an animation to "settle" is a race that passes locally and fails on a
  // loaded CI runner.
  let frozen = $state(new URLSearchParams(location.search).has('freeze'));

  function slotText(story: Story): string | undefined {
    return story.slot;
  }
</script>

<svelte:head>
  <title>samavāya UI gallery</title>
</svelte:head>

{#if frozen}
  <!--
    Stop every animation and transition.

    `-0.01ms` rather than `0s`: a zero duration leaves some engines running the
    animation's first frame, while a tiny negative delay forces every animation
    to its end state immediately. Caret blinking is stopped too — a text cursor
    in an input is a two-state animation that flips a handful of pixels and is
    otherwise the single most common cause of a flaky visual test.
  -->
  <style>
    *, *::before, *::after {
      animation-duration: -0.01ms !important;
      animation-delay: -0.01ms !important;
      animation-iteration-count: 1 !important;
      transition-duration: -0.01ms !important;
      transition-delay: -0.01ms !important;
      caret-color: transparent !important;
    }
    html { scroll-behavior: auto !important; }
  </style>
{/if}

<main class="mx-auto max-w-5xl px-6 py-10">
  <header class="mb-10">
    <h1 class="text-2xl font-semibold text-neutral-900">samavāya UI gallery</h1>
    <p class="mt-2 max-w-2xl text-sm text-neutral-600">
      Every component rendered with fixed props and no backend. This is what the
      visual regression suite screenshots: a diff here means a component changed,
      not that a page's data did.
    </p>
  </header>

  {#each groups as group (group.name)}
    <section class="mb-12">
      <h2 class="mb-4 border-b border-neutral-200 pb-2 text-lg font-medium text-neutral-800">
        {group.name}
      </h2>

      <div class="flex flex-col gap-6">
        {#each group.stories as story (story.id)}
          <!--
            Capitalised local, not `<story.component>`.

            Svelte decides between a component and an HTML element by the
            *first character of the tag*. `<story.component>` is lowercase, so
            it is parsed as an unknown HTML element named "story.component" —
            which renders nothing, throws nothing and logs nothing. Every box
            was empty, and an empty box screenshots perfectly consistently, so
            57 baselines were captured of blank boxes and the suite passed a
            Button whose colour and shadow had been deliberately changed.

            {@const} has to be the immediate child of the block, which is why
            it sits here rather than beside the element it is for.
          -->
          {@const Story = group.component}
          <div>
            <div class="mb-1.5 flex items-center gap-2">
              <code class="text-xs text-neutral-500">{story.id}</code>
              {#if story.unstable}
                <span
                  class="rounded bg-amber-100 px-1.5 py-0.5 text-[10px] font-medium text-amber-800"
                  title={story.unstable}
                >
                  not screenshotted — {story.unstable}
                </span>
              {/if}
            </div>

            <!--
              data-story is what the screenshot run locates. An attribute rather
              than a CSS class so a styling change cannot silently stop the
              suite from finding anything — which would pass, having tested
              nothing.
            -->
            <div
              data-story={story.id}
              class="inline-block rounded border border-dashed border-neutral-300 bg-white p-4"
            >
              {#if slotText(story)}
                <Story {...story.props ?? {}}>
                  {slotText(story)}
                </Story>
              {:else}
                <Story {...story.props ?? {}} />
              {/if}
            </div>
          </div>
        {/each}
      </div>
    </section>
  {/each}
</main>
