import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ params }) => {
  const { category } = params;

  if (!category) {
    throw new Error('Category is required');
  }

  return {
    category,
  };
};
