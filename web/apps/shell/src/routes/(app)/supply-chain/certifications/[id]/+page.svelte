<script lang="ts">
  import { page } from '$app/stores';
  import { onMount } from 'svelte';
  import { traceabilityClient } from '@samavāya/agriculture/services';

  /**
   * A certification, and the two things you can do to one.
   *
   * This page used to call `updateCertification` and `deleteCertification`.
   * traceability-service has neither, and that is deliberate rather than an
   * omission: a certification is an assertion made by an external body on a
   * date, so editing one would rewrite what the certifier said, and deleting
   * one would erase the audit record a compliance report is built from.
   *
   * What the service does offer is Verify — someone confirms the certificate
   * is genuine — and Revoke, which records that it is no longer valid together
   * with the reason, leaving the original in place.
   *
   * Only Verify is wired up. RevokeCertification is in traceability.proto and
   * missing from the generated TypeScript client, which is stale: the proto
   * declares twenty-one RPCs and the client has fourteen. Regenerating it needs
   * a decision about the buf workspace layout (see docs/proto-generation.md),
   * so the revoke control says it is unavailable rather than calling a method
   * that is not there.
   */

  $: id = $page.params.id;

  type Certification = {
    id: string;
    recordId: string;
    certType: string;
    certNumber: string;
    issuedBy: string;
    status: string;
    verifiedBy?: string;
  };

  let certification: Certification | null = null;
  let isLoading = true;
  let isWorking = false;
  let error: string | null = null;

  onMount(load);

  async function load() {
    isLoading = true;
    error = null;
    try {
      const res = await traceabilityClient.getCertification({ id });
      certification = res.certification as unknown as Certification;
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to load certification';
    } finally {
      isLoading = false;
    }
  }

  async function verify() {
    isWorking = true;
    error = null;
    try {
      await traceabilityClient.verifyCertification({ id, verifiedBy: '' });
      await load();
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to verify certification';
    } finally {
      isWorking = false;
    }
  }

</script>

<svelte:head>
  <title>Certification - samavāya</title>
</svelte:head>

<div class="cert">
  <header>
    <h2>Certification</h2>
    <a href="/certifications">Back to certifications</a>
  </header>

  {#if error}
    <p class="error" role="alert">{error}</p>
  {/if}

  {#if isLoading}
    <p>Loading…</p>
  {:else if !certification}
    <p>This certification could not be loaded.</p>
  {:else}
    <dl>
      <dt>Type</dt>
      <dd>{certification.certType}</dd>
      <dt>Number</dt>
      <dd>{certification.certNumber}</dd>
      <dt>Issued by</dt>
      <dd>{certification.issuedBy}</dd>
      <dt>Status</dt>
      <dd>{certification.status}</dd>
      <dt>Verified by</dt>
      <dd>{certification.verifiedBy || 'Not yet verified'}</dd>
      <dt>Traceability record</dt>
      <dd><a href="/traceability/{certification.recordId}">{certification.recordId}</a></dd>
    </dl>

    <div class="actions">
      <button type="button" onclick={verify} disabled={isWorking}>
        Verify
      </button>
      <button type="button" class="danger" disabled title="Revoking needs the regenerated client">
        Revoke
      </button>
    </div>

    <p class="note">
      Revoking is not available from here yet: the RPC exists on
      traceability-service and is missing from this app's generated client.
    </p>
  {/if}
</div>

<style>
  .cert {
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

  .actions {
    display: flex;
    gap: 0.75rem;
  }

  button {
    padding: 0.5rem 1rem;
    border: 1px solid var(--color-border, #ddd);
    border-radius: var(--radius-md, 6px);
    background: var(--color-surface, #fff);
    cursor: pointer;
  }

  button.danger {
    border-color: #c0392b;
    color: #c0392b;
  }

  button:disabled {
    opacity: 0.6;
    cursor: default;
  }

  .note {
    margin: 0;
    padding: 0.75rem 1rem;
    border-left: 3px solid var(--color-border, #ddd);
    color: var(--color-text-secondary, #666);
    font-size: 0.875rem;
  }

  .error {
    color: #c0392b;
  }
</style>
