import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:uuid/uuid.dart';

import '../../domain/entities/observation_entity.dart';
import '../bloc/observation_bloc.dart';
import '../bloc/observation_event.dart';
import '../bloc/observation_state.dart';
import '../widgets/map_pin_selector.dart';
import '../widgets/photo_gallery.dart';

/// Screen for creating a new field observation with camera, map pin, and notes.
class ObservationEditorScreen extends StatefulWidget {
  const ObservationEditorScreen({super.key, required this.fieldId});

  final String fieldId;

  @override
  State<ObservationEditorScreen> createState() =>
      _ObservationEditorScreenState();
}

class _ObservationEditorScreenState extends State<ObservationEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _imagePicker = ImagePicker();

  ObservationCategory _category = ObservationCategory.other;
  ll.LatLng? _selectedLocation;
  final List<String> _photos = [];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Observation'),
      ),
      body: BlocListener<ObservationBloc, ObservationState>(
        listener: (context, state) {
          if (state is ObservationPhotosUpdated) {
            setState(() {
              _photos
                ..clear()
                ..addAll(state.photos);
            });
          }
        },
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Category
              Text('Category', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: ObservationCategory.values.map((cat) {
                  return ChoiceChip(
                    label: Text(cat.label),
                    selected: _category == cat,
                    onSelected: (_) => setState(() => _category = cat),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Photos section
              Row(
                children: [
                  Text('Photos', style: theme.textTheme.labelLarge),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _takePhoto,
                    icon: const Icon(Icons.camera_alt_outlined, size: 18),
                    label: const Text('Camera'),
                  ),
                  TextButton.icon(
                    onPressed: _pickFromGallery,
                    icon: const Icon(Icons.photo_library_outlined, size: 18),
                    label: const Text('Gallery'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              PhotoGallery(
                photos: _photos,
                height: 140,
                onRemove: (index) {
                  setState(() => _photos.removeAt(index));
                },
              ),
              const SizedBox(height: 20),

              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  hintText: 'Describe what you observed...',
                  prefixIcon: Icon(Icons.notes_outlined),
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Please add some notes'
                    : null,
              ),
              const SizedBox(height: 20),

              // Location picker
              Text('Location', style: theme.textTheme.labelLarge),
              const SizedBox(height: 4),
              Text(
                'Tap on the map to drop a pin',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              MapPinSelector(
                initialLocation: _selectedLocation,
                onLocationSelected: (loc) {
                  setState(() => _selectedLocation = loc);
                },
                height: 220,
              ),
              if (_selectedLocation == null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Location is required',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
              const SizedBox(height: 32),

              // Submit
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Save Observation'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _takePhoto() async {
    final photo = await _imagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );
    if (photo != null) {
      setState(() => _photos.add(photo.path));
    }
  }

  Future<void> _pickFromGallery() async {
    final photos = await _imagePicker.pickMultiImage(
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );
    if (photos.isNotEmpty) {
      setState(() => _photos.addAll(photos.map((p) => p.path)));
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a location on the map'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final observation = FieldObservation(
      id: const Uuid().v4(),
      fieldId: widget.fieldId,
      location: _selectedLocation!,
      photos: List.unmodifiable(_photos),
      notes: _notesController.text.trim(),
      timestamp: DateTime.now(),
      category: _category,
    );

    context.read<ObservationBloc>().add(CreateObservation(observation));
    Navigator.pop(context);
  }
}
