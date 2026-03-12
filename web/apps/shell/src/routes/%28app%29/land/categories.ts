/**
 * Land Domain Forms Categories
 * Used for sidebar navigation and form listing
 */

export const FORM_CATEGORIES = [
  {
    id: 'land-parcel',
    name: 'Land Parcel',
    description: 'Manage land parcels and their properties',
    slug: 'land-parcel',
  },
  {
    id: 'gis-spatial',
    name: 'GIS & Spatial',
    description: 'GIS mapping and spatial data management',
    slug: 'gis-spatial',
  },
  {
    id: 'field-operations',
    name: 'Field Operations',
    description: 'Field-based operations and surveys',
    slug: 'field-operations',
  },
  {
    id: 'compliance',
    name: 'Compliance',
    description: 'Regulatory and compliance tracking',
    slug: 'compliance',
  },
  {
    id: 'due-diligence',
    name: 'Due Diligence',
    description: 'Due diligence investigations and assessments',
    slug: 'due-diligence',
  },
  {
    id: 'legal-case',
    name: 'Legal Cases',
    description: 'Legal cases and litigation management',
    slug: 'legal-case',
  },
  {
    id: 'negotiation',
    name: 'Negotiation',
    description: 'Land negotiation and acquisition',
    slug: 'negotiation',
  },
  {
    id: 'stakeholder',
    name: 'Stakeholders',
    description: 'Stakeholder management and communication',
    slug: 'stakeholder',
  },
  {
    id: 'land-finance',
    name: 'Land Finance',
    description: 'Financial management for land acquisition',
    slug: 'land-finance',
  },
  {
    id: 'risk-scoring',
    name: 'Risk Scoring',
    description: 'Risk assessment and scoring',
    slug: 'risk-scoring',
  },
  {
    id: 'land-insights',
    name: 'Land Insights',
    description: 'Data analytics and insights',
    slug: 'land-insights',
  },
  {
    id: 'govt-lease',
    name: 'Government Lease',
    description: 'Government lease management',
    slug: 'govt-lease',
  },
  {
    id: 'grid-interconnection',
    name: 'Grid Interconnection',
    description: 'Power grid interconnection agreements',
    slug: 'grid-interconnection',
  },
  {
    id: 'right-of-way',
    name: 'Right of Way',
    description: 'Right of way and easement management',
    slug: 'right-of-way',
  },
  {
    id: 'renewable-energy-finance',
    name: 'Renewable Energy Finance',
    description: 'Renewable energy financing and contracts',
    slug: 'renewable-energy-finance',
  },
];

export function getCategoryPath(slug: string): string {
  return `/land/${slug}`;
}

export function getCategoryName(slug: string): string {
  const category = FORM_CATEGORIES.find((c) => c.slug === slug);
  return category?.name || slug;
}

export function getCategoryDescription(slug: string): string {
  const category = FORM_CATEGORIES.find((c) => c.slug === slug);
  return category?.description || '';
}
