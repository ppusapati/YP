import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/listing_entity.dart';
import '../bloc/commerce_bloc.dart';
import '../bloc/commerce_event.dart';
import '../bloc/commerce_state.dart';

/// Detail view for a single marketplace listing.
class ListingDetailScreen extends StatefulWidget {
  const ListingDetailScreen({
    super.key,
    required this.listingId,
    this.listing,
  });

  /// Passed via path parameter.
  final String listingId;

  /// Optionally passed via `extra` to avoid a reload.
  final Listing? listing;

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  late Listing? _listing;

  @override
  void initState() {
    super.initState();
    _listing = widget.listing;
    if (_listing == null) {
      context
          .read<CommerceBloc>()
          .add(LoadListingDetail(widget.listingId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Listing Details')),
      body: BlocConsumer<CommerceBloc, CommerceState>(
        listener: (context, state) {
          if (state is ListingDetailLoaded) {
            setState(() => _listing = state.listing);
          }
          if (state is OrderPlaced) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Order placed successfully!'),
                behavior: SnackBarBehavior.floating,
              ),
            );
            Navigator.of(context).pop();
          }
          if (state is CommerceError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (_listing == null && state is CommerceLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final listing = _listing;
          if (listing == null) {
            return Center(
              child: Text(
                'Listing not found',
                style: theme.textTheme.bodyLarge,
              ),
            );
          }

          return _buildContent(context, listing, theme, state);
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    Listing listing,
    ThemeData theme,
    CommerceState state,
  ) {
    final statusColor = switch (listing.status) {
      ListingStatus.active => Colors.green,
      ListingStatus.draft => Colors.orange,
      ListingStatus.soldOut => Colors.red,
      ListingStatus.expired => Colors.grey,
      ListingStatus.cancelled => Colors.grey,
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product name and status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  listing.productName,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  listing.status.label,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (listing.productType.isNotEmpty)
            Text(
              listing.productType,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

          const SizedBox(height: 24),

          // Price
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Price',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        listing.formattedPrice,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Available',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${listing.quantityAvailable} ${listing.quantityUnit}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Description
          if (listing.description.isNotEmpty) ...[
            Text(
              'Description',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              listing.description,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
          ],

          // Details
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (listing.qualityGrade != null)
                    _DetailRow(
                      label: 'Quality Grade',
                      value: listing.qualityGrade!,
                    ),
                  if (listing.minOrderQuantity != null)
                    _DetailRow(
                      label: 'Min Order',
                      value:
                          '${listing.minOrderQuantity} ${listing.quantityUnit}',
                    ),
                  if (listing.location != null)
                    _DetailRow(
                      label: 'Location',
                      value: listing.location!,
                    ),
                  if (listing.region != null)
                    _DetailRow(
                      label: 'Region',
                      value: listing.region!,
                    ),
                  if (listing.createdAt != null)
                    _DetailRow(
                      label: 'Listed On',
                      value: _formatDate(listing.createdAt!),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Place order button
          if (listing.status == ListingStatus.active)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: state is CommerceLoading
                    ? null
                    : () => _showPlaceOrderDialog(context, listing),
                icon: const Icon(Icons.shopping_cart_outlined),
                label: const Text('Place Order'),
              ),
            ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showPlaceOrderDialog(BuildContext context, Listing listing) {
    final quantityController = TextEditingController();
    final addressController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Place Order'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: quantityController,
                decoration: InputDecoration(
                  labelText: 'Quantity (${listing.quantityUnit})',
                  border: const OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  final qty = double.tryParse(value ?? '');
                  if (qty == null || qty <= 0) {
                    return 'Enter a valid quantity';
                  }
                  if (qty > listing.quantityAvailable) {
                    return 'Max available: ${listing.quantityAvailable}';
                  }
                  if (listing.minOrderQuantity != null &&
                      qty < listing.minOrderQuantity!) {
                    return 'Min order: ${listing.minOrderQuantity}';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Delivery Address',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx);
                context.read<CommerceBloc>().add(
                      PlaceOrder(
                        listingId: listing.id,
                        quantity:
                            double.parse(quantityController.text.trim()),
                        deliveryAddress:
                            addressController.text.trim().isNotEmpty
                                ? addressController.text.trim()
                                : null,
                      ),
                    );
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
