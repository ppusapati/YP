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
   * Revoking asks for a reason and will not proceed without one. The proto
   * makes `reason` an ordinary field, so the service would accept a blank one —
   * but a revocation is read months later by someone asking why a batch lost
   * its certification, and "revoked" with no reason answers nothing. The
   * requirement belongs here, at the point where the person still knows.
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

  // Revoking is two steps rather than one. It cannot be undone from this UI,
  // and a single button next to Verify is a slip away from being pressed by
  // someone who meant the other one.
  let isRevoking = false;
  let revokeReason = '';

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

  async function revoke() {
    const reason = revokeReason.trim();
    if (!reason) {
      error = 'Give a reason for revoking this certification.';
      return;
    }

    isWorking = true;
    error = null;
    try {
      await traceabilityClient.revokeCertification({ id, reason });
      // Reloaded rather than patched locally. Revoking sets the status and
      // stamps the record on the service's side, and showing a locally-guessed
      // state would differ from what anyone else sees.
      await load();
      isRevoking = false;
      revokeReason = '';
    } catch (e) {
      error = e instanceof Error ? e.message : 'Failed to revoke certification';
    } finally {
      isWorking = false;
    }
  }

  function cancelRevoke() {
    isRevoking = false;
    revokeReason = '';
    error = null;
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
      <button type="button" onclick={verify} disabled={isWorking || isRevoking}>
        Verify
      </button>
      <button
        type="button"
        class="danger"
        onclick={() => (isRevoking = true)}
        disabled={isWorking || isRevoking}
      >
        Revoke
      </button>
    </div>

    {#if isRevoking}
      <form class="revoke" onsubmit={(event) => { event.preventDefault(); void revoke(); }}>
        <label for="revoke-reason">Reason for revoking</label>
        <input
          id="revoke-reason"
          type="text"
          bind:value={revokeReason}
          placeholder="Why is this certification no longer valid?"
          required
        />
        <p class="note">
          The certificate itself is kept. Revoking records that it is no longer
          valid, with this reason, so the audit trail still shows what was
          claimed and when it stopped being true.
        </p>
        <div class="actions">
          <button type="submit" class="danger" disabled={isWorking || !revokeReason.trim()}>
            {isWorking ? 'Revoking…' : 'Confirm revoke'}
          </button>
          <button type="button" onclick={cancelRevoke} disabled={isWorking}>Cancel</button>
        </div>
      </form>
    {/if}
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

  .revoke {
    display: flex;
    flex-direction: column;
    gap: 0.75rem;
    padding: 1rem;
    border: 1px solid #c0392b;
    border-radius: var(--radius-md, 6px);
  }

  .revoke label {
    font-size: 0.8125rem;
    color: var(--color-text-secondary, #666);
  }

  .revoke input {
    padding: 0.5rem;
    border: 1px solid var(--color-border, #ddd);
    border-radius: var(--radius-md, 6px);
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
