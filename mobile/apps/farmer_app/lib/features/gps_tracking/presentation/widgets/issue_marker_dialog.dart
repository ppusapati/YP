import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/entities/crop_issue_entity.dart';

/// Data holder for the result of the issue marker dialog.
class IssueMarkerResult {
  final CropIssueType type;
  final String description;
  final CropIssueSeverity severity;
  final List<String> photos;

  const IssueMarkerResult({
    required this.type,
    required this.description,
    required this.severity,
    this.photos = const [],
  });
}

class IssueMarkerDialog extends StatefulWidget {
  const IssueMarkerDialog({
    super.key,
    required this.location,
  });

  final LatLng location;

  static Future<IssueMarkerResult?> show(
    BuildContext context, {
    required LatLng location,
  }) {
    return showModalBottomSheet<IssueMarkerResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => IssueMarkerDialog(location: location),
    );
  }

  @override
  State<IssueMarkerDialog> createState() => _IssueMarkerDialogState();
}

class _IssueMarkerDialogState extends State<IssueMarkerDialog> {
  CropIssueType _selectedType = CropIssueType.pest;
  CropIssueSeverity _selectedSeverity = CropIssueSeverity.moderate;
  final _descriptionController = TextEditingController();
  final _photos = <String>[];
  final _picker = ImagePicker();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Mark Crop Issue',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Location: ${widget.location.latitude.toStringAsFixed(5)}, '
              '${widget.location.longitude.toStringAsFixed(5)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 20),
            Text(
              'Issue Type',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: CropIssueType.values.map((type) {
                final isSelected = _selectedType == type;
                return ChoiceChip(
                  label: Text(type.displayName),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedType = type);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Text(
              'Severity',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            SegmentedButton<CropIssueSeverity>(
              segments: CropIssueSeverity.values.map((s) {
                return ButtonSegment(
                  value: s,
                  label: Text(s.displayName),
                );
              }).toList(),
              selected: {_selectedSeverity},
              onSelectionChanged: (values) {
                setState(() => _selectedSeverity = values.first);
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Describe the issue...',
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Photos',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _addPhoto,
                  icon: const Icon(Icons.add_a_photo_outlined, size: 18),
                  label: const Text('Add Photo'),
                ),
              ],
            ),
            if (_photos.isNotEmpty)
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _photos.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 80,
                            height: 80,
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            child: const Icon(Icons.image, size: 32),
                          ),
                        ),
                        Positioned(
                          top: 2,
                          right: 2,
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _photos.removeAt(index));
                            },
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).pop(IssueMarkerResult(
                    type: _selectedType,
                    description: _descriptionController.text.trim(),
                    severity: _selectedSeverity,
                    photos: _photos,
                  ));
                },
                child: const Text('Save Issue'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addPhoto() async {
    final image = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (image != null) {
      setState(() => _photos.add(image.path));
    }
  }
}
