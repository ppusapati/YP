<script lang="ts">
  import { FORM_CATEGORIES, getCategoryPath } from './categories';
</script>

<div class="land-home">
  <div class="hero">
    <h1>Land Acquisition Management</h1>
    <p>Comprehensive land acquisition and management platform</p>
  </div>

  <div class="categories-grid">
    {#each FORM_CATEGORIES as category (category.id)}
      <a href={getCategoryPath(category.id)} class="category-card">
        <h3>{category.name}</h3>
        <p>{category.description}</p>
        <span class="arrow">→</span>
      </a>
    {/each}
  </div>
</div>

<style>
  .land-home {
    padding: 2rem;
    max-width: 1400px;
    margin: 0 auto;
    width: 100%;
  }

  .hero {
    margin-bottom: 3rem;
    text-align: center;
  }

  .hero h1 {
    margin: 0 0 0.5rem 0;
    font-size: 2.5rem;
    color: var(--color-text);
  }

  .hero p {
    margin: 0;
    font-size: 1.1rem;
    color: var(--color-text-secondary);
  }

  .categories-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
    gap: 1.5rem;
  }

  .category-card {
    display: flex;
    flex-direction: column;
    padding: 1.5rem;
    background-color: var(--color-bg);
    border: 1px solid var(--color-border);
    border-radius: 8px;
    text-decoration: none;
    color: inherit;
    transition: all 0.3s ease;
    position: relative;
    overflow: hidden;
  }

  .category-card::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-primary-dark) 100%);
    opacity: 0;
    transition: opacity 0.3s ease;
    z-index: -1;
  }

  .category-card:hover {
    border-color: var(--color-primary);
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
    transform: translateY(-2px);
  }

  .category-card:hover::before {
    opacity: 0.05;
  }

  .category-card h3 {
    margin: 0 0 0.5rem 0;
    font-size: 1.1rem;
    color: var(--color-text);
  }

  .category-card p {
    margin: 0 0 1rem 0;
    font-size: 0.9rem;
    color: var(--color-text-secondary);
    flex-grow: 1;
  }

  .arrow {
    color: var(--color-primary);
    font-weight: 600;
  }
</style>
