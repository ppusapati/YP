<script lang="ts">
  import { page } from '$app/stores';

  /**
   * Adding a farm owner — which farm-service does not offer.
   *
   * This page rendered a form collecting a name, email, phone, percentage and
   * an "is primary" flag, then called `TransferOwnership` with them. That RPC
   * is the only one farm-service has for ownership and it is a different
   * operation: it requires the user the farm is moving *from* and the user it
   * is moving *to*, neither of which this form asked for, and it has nowhere to
   * put "is primary" at all. Every submission was rejected for a missing
   * from_user_id.
   *
   * A form that cannot succeed is worse than no form: someone fills it in,
   * reads an error about a field they were never shown, and tries again. So
   * this says what the platform can actually do and sends them to the page that
   * does it, rather than collecting five fields on the way to a guaranteed
   * failure.
   */

  const farmId = $page.url.searchParams.get('farm_id') ?? '';
  const transferHref = farmId
    ? `/farm-management/ownership-transfer?farm_id=${encodeURIComponent(farmId)}`
    : '/farm-management/ownership-transfer';
</script>

<svelte:head>
  <title>Add Farm Owner - samavāya</title>
</svelte:head>

<div class="notice">
  <h2>Ownership is transferred, not added</h2>

  <p>
    farm-service records ownership as a transfer from one user to another, so
    there is no operation that adds an owner on its own. Transferring names the
    current owner and the new one, and moves the stated share between them.
  </p>

  <div class="actions">
    <a class="primary" href={transferHref}>Transfer ownership</a>
    <a href="/farm-management/farm-owners">Back to owners</a>
  </div>
</div>

<style>
  .notice {
    display: flex;
    flex-direction: column;
    gap: 1rem;
    max-width: 44rem;
    padding: 1.5rem;
    border: 1px solid var(--color-border, #ddd);
    border-radius: var(--radius-md, 6px);
  }

  h2 {
    margin: 0;
    font-size: 1.25rem;
  }

  p {
    margin: 0;
    color: var(--color-text-secondary, #666);
  }

  .actions {
    display: flex;
    gap: 0.75rem;
    align-items: center;
  }

  a {
    padding: 0.5rem 1rem;
    border: 1px solid var(--color-border, #ddd);
    border-radius: var(--radius-md, 6px);
    text-decoration: none;
    color: inherit;
  }

  a.primary {
    border-color: var(--color-primary, #2f6f3e);
    color: var(--color-primary, #2f6f3e);
  }
</style>
