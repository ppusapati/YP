<script lang="ts">
  import { page } from '$app/stores';
  import { FormRenderer } from '@samavāya/formrenderer';
  import { getCategoryName, getCategoryDescription } from '../categories';
  import type { PageData } from './$types';

  let { data }: { data: PageData } = $props();

  let isLoading = $state(false);
  let error = $state<string | null>(null);

  const category = $derived($page.params.category);
  const categoryName = $derived(getCategoryName(category));
  const categoryDescription = $derived(getCategoryDescription(category));

  async function handleSubmit(formData: Record<string, any>) {
    isLoading = true;
    error = null;

    try {
      // In a real application, this would send data to the backend
      console.log('Form submitted:', { category, data: formData });

      // Simulate API call
      await new Promise((resolve) => setTimeout(resolve, 1000));

      // Show success message
      alert(`${categoryName} form submitted successfully!`);
    } catch (err) {
      error = err instanceof Error ? err.message : 'An error occurred while submitting the form';
      console.error('Form submission error:', err);
    } finally {
      isLoading = false;
    }
  }

  function handleCancel() {
    history.back();
  }

  // Generate a simple schema based on category
  const schema = {
    id: category,
    name: category,
    title: categoryName,
    description: categoryDescription ? `Manage ${categoryDescription.toLowerCase()}` : undefined,
    sections: [
      {
        id: 'general',
        title: 'General Information',
        fields: [
          {
            id: 'name',
            name: 'name',
            type: 'text' as const,
            label: 'Name/Title',
            placeholder: 'Enter name',
            required: true,
          },
          {
            id: 'description',
            name: 'description',
            type: 'textarea' as const,
            label: 'Description',
            placeholder: 'Enter description',
            rows: 4,
          },
          {
            id: 'status',
            name: 'status',
            type: 'select' as const,
            label: 'Status',
            required: true,
            options: [
              { label: 'Active', value: 'active' },
              { label: 'Inactive', value: 'inactive' },
              { label: 'Pending', value: 'pending' },
            ],
          },
        ],
      },
      {
        id: 'details',
        title: 'Details',
        collapsible: true,
        collapsed: false,
        fields: [
          {
            id: 'reference',
            name: 'reference',
            type: 'text' as const,
            label: 'Reference ID',
            placeholder: 'Auto-generated reference',
          },
          {
            id: 'date',
            name: 'date',
            type: 'date' as const,
            label: 'Date',
          },
        ],
      },
    ],
    actions: [
      { id: 'submit', label: 'Submit', type: 'submit' as const, variant: 'primary' as const },
      { id: 'cancel', label: 'Cancel', type: 'cancel' as const, variant: 'secondary' as const },
    ],
  };
</script>

<div class="form-page">
  <div class="form-header">
    <div>
      <h1>{categoryName}</h1>
      <p class="breadcrumb">Land Acquisition &gt; {categoryName}</p>
    </div>
  </div>

  <div class="form-container">
    {#if error}
      <div class="error-alert">
        <strong>Error:</strong> {error}
      </div>
    {/if}

    <FormRenderer
      {schema}
      onSubmit={handleSubmit}
      onCancel={handleCancel}
      isLoading
    />
  </div>
</div>

<style>
  .form-page {
    padding: 2rem;
    max-width: 900px;
    margin: 0 auto;
    width: 100%;
  }

  .form-header {
    margin-bottom: 2rem;
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
  }

  .form-header h1 {
    margin: 0 0 0.5rem 0;
    font-size: 2rem;
    color: var(--color-text);
  }

  .breadcrumb {
    margin: 0;
    font-size: 0.9rem;
    color: var(--color-text-secondary);
  }

  .form-container {
    background-color: var(--color-bg);
    border: 1px solid var(--color-border);
    border-radius: 8px;
    padding: 2rem;
  }

  .error-alert {
    padding: 1rem;
    background-color: #fee;
    border: 1px solid #fcc;
    border-radius: 4px;
    color: #c33;
    margin-bottom: 1rem;
  }
</style>
