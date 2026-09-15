<script lang="ts">
  import { page } from '$app/stores';
  import { onMount } from 'svelte';
  import { traceabilityClient } from '@samavāya/agriculture/services';

  /**
   * A batch record, read-only.
   *
   * This page used to submit `updateBatch` and `deleteBatch`. Neither exists on
   * traceability-service, and neither should: a batch record is the link
   * between a crate on a lorry and the field it grew in. Editing its quantity
   * or its production date after the fact, or removing it, breaks the chain the
   * whole service exists to keep — and it breaks it invisibly, because the
   * resulting record still looks complete.
   *
   * A batch that was entered wrongly is corrected by recording a new one and
   * leaving the first, the same way the certification page revokes rather than
   * deletes.
   */

  $: id = $page.params.id;

  type Batch = {
    id: string;
    recordId: string;
    batchNumber: string;
    quantity: number;
    unit: string;
    weightKg: number;
    qualityGrade: string;
    storageConditions: string;
    productionDate?: { seconds?: bigint };
    expiryDate?: { seconds?: bigint };
  };

  let batch: Batch | null = null;
  let isLoading = true;
  let error: string | null = null;

  onMount(async () => {
    try {
      const res = await traceabilityClient.getBatch({ id });
      batch = res.batch as unknown as Batch;
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load batch record';
    } finally {
      isLoading = false;
    }
  });

  /** Renders a protobuf timestamp, or says it is absent rather than showing an epoch. */
  function asDate(ts?: { seconds?: bigint }): string {
    if (!ts?.seconds) return 'Not recorded';
    return new Date(Number(ts.seconds) * 1000).toLocaleDateString();
  }
</script>

<svelte:head>
  <title>Batch - samavāya</title>
</svelte:head>

<div class="batch">
  <header>
    <h2>Batch {batch?.batchNumber ?? ''}</h2>
    <a href="/batches">Back to batches</a>
  </header>

  {#if error}
    <p class="error" role="alert">{error}</p>
  {/if}

  {#if isLoading}
    <p>Loading…</p>
  {:else if !batch}
    <p>This batch record could not be loaded.</p>
  {:else}
    <p class="note">
      Batch records are not edited. A record entered wrongly is corrected by
      adding a new one, so the chain of custody keeps what was originally
      claimed.
    </p>

    <dl>
      <dt>Batch number</dt>
      <dd>{batch.batchNumber}</dd>
      <dt>Quantity</dt>
      <dd>{batch.quantity} {batch.unit}</dd>
      <dt>Weight</dt>
      <dd>{batch.weightKg ? `${batch.weightKg} kg` : 'Not recorded'}</dd>
      <dt>Quality grade</dt>
      <dd>{batch.qualityGrade || 'Not graded'}</dd>
      <dt>Produced</dt>
      <dd>{asDate(batch.productionDate)}</dd>
      <dt>Expires</dt>
      <dd>{asDate(batch.expiryDate)}</dd>
      <dt>Storage</dt>
      <dd>{batch.storageConditions || 'Not recorded'}</dd>
      <dt>Traceability record</dt>
      <dd><a href="/traceability/{batch.recordId}">{batch.recordId}</a></dd>
    </dl>
  {/if}
</div>

<style>
  .batch {
    display: flex;
    flex-direction: column;
    gap: 1.5rem;
  }

  header {
    display: flex;
    align-items: baseline;
    justify-content: space-between;
  }

  h2 {
    margin: 0;
    font-size: 1.5rem;
  }

  .note {
    margin: 0;
    padding: 0.75rem 1rem;
    border-left: 3px solid var(--color-border, #ddd);
    color: var(--color-text-secondary, #666);
    font-size: 0.875rem;
  }

  dl {
    display: grid;
    grid-template-columns: max-content 1fr;
    gap: 0.5rem 1.5rem;
    margin: 0;
  }

  dt {
    font-size: 0.8125rem;
    color: var(--color-text-secondary, #666);
  }

  dd {
    margin: 0;
  }

  .error {
    color: #c0392b;
  }
</style>
