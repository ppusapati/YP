import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../farm/presentation/bloc/farm_bloc.dart';
import '../../../farm/presentation/bloc/farm_event.dart';
import '../../../farm/presentation/bloc/farm_state.dart';
import '../bloc/commerce_bloc.dart';
import '../bloc/commerce_event.dart';
import '../bloc/commerce_state.dart';

/// Form screen for creating a new marketplace listing.
class CreateListingScreen extends StatefulWidget {
  const CreateListingScreen({super.key});

  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();
  final _regionController = TextEditingController();
  final _gradeController = TextEditingController();

  String _productType = 'Grain';
  String _unit = 'kg';
  String _currency = 'INR';

  /// Which farm the produce came from.
  ///
  /// This used to be submitted as an empty string with a TODO next to it, so
  /// every listing a farmer created was attached to no farm — which is the one
  /// field a buyer uses to trace where the produce came from, and the link the
  /// traceability chain needs on the selling end.
  String? _farmId;

  static const _productTypes = [
    'Grain',
    'Vegetable',
    'Fruit',
    'Pulse',
    'Oilseed',
    'Spice',
    'Other',
  ];

  static const _units = ['kg', 'quintal', 'ton', 'piece', 'bunch', 'litre'];

  @override
  void initState() {
    super.initState();
    // Same call the dashboard and farm list make: the tenant comes from the
    // token, so the empty user id is the established convention here rather
    // than a missing argument.
    context.read<FarmBloc>().add(const LoadFarms(userId: ''));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _regionController.dispose();
    _gradeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Listing')),
      body: BlocListener<CommerceBloc, CommerceState>(
        listener: (context, state) {
          if (state is ListingCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Listing created successfully!'),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Farm
                BlocBuilder<FarmBloc, FarmState>(
                  builder: (context, state) {
                    if (state is FarmsLoaded) {
                      // One farm is the common case; choosing it for the farmer
                      // saves a tap and cannot be wrong.
                      if (state.farms.length == 1 && _farmId == null) {
                        _farmId = state.farms.first.id;
                      }
                      return DropdownButtonFormField<String>(
                        value: _farmId,
                        decoration: const InputDecoration(
                          labelText: 'Farm *',
                          border: OutlineInputBorder(),
                        ),
                        items: state.farms
                            .map(
                              (f) => DropdownMenuItem(
                                value: f.id,
                                child: Text(f.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) => setState(() => _farmId = value),
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Select the farm this produce came from'
                            : null,
                      );
                    }
                    if (state is FarmError) {
                      // Surfaced, not hidden behind a spinner. Without a farm
                      // the listing cannot be created, and the farmer should
                      // find that out here rather than on submit.
                      return InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Farm *',
                          border: OutlineInputBorder(),
                          errorText: 'Could not load your farms',
                        ),
                        child: Text(state.message),
                      );
                    }
                    return const InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Farm *',
                        border: OutlineInputBorder(),
                      ),
                      child: Text('Loading farms...'),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Product name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Product Name *',
                    hintText: 'e.g., Organic Basmati Rice',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Product name is required'
                      : null,
                ),
                const SizedBox(height: 16),

                // Product type
                DropdownButtonFormField<String>(
                  value: _productType,
                  decoration: const InputDecoration(
                    labelText: 'Product Type',
                    border: OutlineInputBorder(),
                  ),
                  items: _productTypes
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _productType = v);
                  },
                ),
                const SizedBox(height: 16),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Quality details, harvest info, etc.',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),

                // Quantity and unit
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _quantityController,
                        decoration: const InputDecoration(
                          labelText: 'Quantity *',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (v) {
                          final qty = double.tryParse(v ?? '');
                          if (qty == null || qty <= 0) {
                            return 'Enter a valid quantity';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _unit,
                        decoration: const InputDecoration(
                          labelText: 'Unit',
                          border: OutlineInputBorder(),
                        ),
                        items: _units
                            .map((u) =>
                                DropdownMenuItem(value: u, child: Text(u)))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _unit = v);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Price per unit (in rupees, converted to paise)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _priceController,
                        decoration: InputDecoration(
                          labelText: 'Price per $_unit *',
                          prefixText: _currency == 'INR' ? '₹ ' : '',
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (v) {
                          final price = double.tryParse(v ?? '');
                          if (price == null || price <= 0) {
                            return 'Enter a valid price';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _currency,
                        decoration: const InputDecoration(
                          labelText: 'Currency',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'INR', child: Text('INR')),
                          DropdownMenuItem(value: 'USD', child: Text('USD')),
                        ],
                        onChanged: (v) {
                          if (v != null) setState(() => _currency = v);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Quality grade
                TextFormField(
                  controller: _gradeController,
                  decoration: const InputDecoration(
                    labelText: 'Quality Grade',
                    hintText: 'e.g., A, Premium, Organic',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Location
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    hintText: 'Village or town name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                ),
                const SizedBox(height: 16),

                // Region
                TextFormField(
                  controller: _regionController,
                  decoration: const InputDecoration(
                    labelText: 'Region',
                    hintText: 'District or state',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),

                // Submit
                BlocBuilder<CommerceBloc, CommerceState>(
                  builder: (context, state) {
                    final isLoading = state is CommerceLoading;
                    return FilledButton.icon(
                      onPressed: isLoading ? null : _submit,
                      icon: isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.publish),
                      label: const Text('Create Listing'),
                    );
                  },
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final farmId = _farmId;
    if (farmId == null || farmId.isEmpty) {
      // Belt and braces with the dropdown's validator: a listing attached to no
      // farm is untraceable, and silently creating one is worse than refusing.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select the farm this produce came from'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final priceRupees = double.parse(_priceController.text.trim());
    final pricePerUnitPaise = (priceRupees * 100).round();

    context.read<CommerceBloc>().add(
          CreateListing(
            farmId: farmId,
            productName: _nameController.text.trim(),
            productType: _productType,
            description: _descriptionController.text.trim(),
            quantityAvailable:
                double.parse(_quantityController.text.trim()),
            quantityUnit: _unit,
            pricePerUnitPaise: pricePerUnitPaise,
            currency: _currency,
            qualityGrade: _gradeController.text.trim().isNotEmpty
                ? _gradeController.text.trim()
                : null,
            location: _locationController.text.trim().isNotEmpty
                ? _locationController.text.trim()
                : null,
            region: _regionController.text.trim().isNotEmpty
                ? _regionController.text.trim()
                : null,
          ),
        );
  }
}
