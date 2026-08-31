import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:maplibre_gl/maplibre_gl.dart' as ml;
import 'package:uuid/uuid.dart';

import '../../domain/entities/field_entity.dart';
import '../bloc/field_bloc.dart';
import '../bloc/field_event.dart';
import '../bloc/field_state.dart';

/// Screen for creating or editing a field polygon within a farm.
class FieldEditorScreen extends StatefulWidget {
  const FieldEditorScreen({
    super.key,
    required this.farmId,
    this.existingField,
  });

  final String farmId;
  final FieldEntity? existingField;

  @override
  State<FieldEditorScreen> createState() => _FieldEditorScreenState();
}

class _FieldEditorScreenState extends State<FieldEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  CropType _selectedCropType = CropType.none;
  SoilType _selectedSoilType = SoilType.unknown;
  FieldStatus _selectedStatus = FieldStatus.active;
  final List<LatLng> _polygonPoints = [];
  bool _isDrawing = false;
  bool _isSaving = false;

  bool get _isEditing => widget.existingField != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.existingField?.name ?? '',
    );
    if (widget.existingField != null) {
      _selectedCropType = widget.existingField!.cropType;
      _selectedSoilType = widget.existingField!.soilType;
      _selectedStatus = widget.existingField!.status;
      _polygonPoints.addAll(widget.existingField!.polygon);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  double _calculateArea(List<LatLng> points) {
    if (points.length < 3) return 0.0;
    double area = 0.0;
    for (int i = 0; i < points.length; i++) {
      final j = (i + 1) % points.length;
      area += points[i].longitude * points[j].latitude;
      area -= points[j].longitude * points[i].latitude;
    }
    area = area.abs() / 2.0;
    final avgLat = points.fold(0.0, (s, p) => s + p.latitude) / points.length;
    final metersPerDegreeLat = 111320.0;
    final metersPerDegreeLng =
        111320.0 * (avgLat * 3.141592653589793 / 180.0);
    final areaM2 = area * metersPerDegreeLat * metersPerDegreeLng;
    return areaM2 / 10000.0;
  }

  void _onMapTap(ml.Point point, ml.LatLng coordinates) {
    if (!_isDrawing) return;
    setState(() {
      _polygonPoints.add(LatLng(coordinates.latitude, coordinates.longitude));
    });
  }

  void _undoLastPoint() {
    if (_polygonPoints.isNotEmpty) {
      setState(() => _polygonPoints.removeLast());
    }
  }

  void _saveField() {
    if (!_formKey.currentState!.validate()) return;
    if (_polygonPoints.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please draw at least 3 polygon points'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final area = _calculateArea(_polygonPoints);

    if (_isEditing) {
      final updated = widget.existingField!.copyWith(
        name: _nameController.text.trim(),
        polygon: List.of(_polygonPoints),
        areaHectares: area,
        cropType: _selectedCropType,
        soilType: _selectedSoilType,
        status: _selectedStatus,
      );
      context.read<FieldBloc>().add(UpdateField(field: updated));
    } else {
      final field = FieldEntity(
        id: const Uuid().v4(),
        farmId: widget.farmId,
        name: _nameController.text.trim(),
        polygon: List.of(_polygonPoints),
        areaHectares: area,
        cropType: _selectedCropType,
        soilType: _selectedSoilType,
        status: _selectedStatus,
      );
      context.read<FieldBloc>().add(CreateField(field: field));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocListener<FieldBloc, FieldState>(
      listener: (context, state) {
        if (state is FieldCreated || state is FieldUpdated) {
          setState(() => _isSaving = false);
          Navigator.of(context).pop();
        } else if (state is FieldError) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              behavior: SnackBarBehavior.floating,
              backgroundColor: colorScheme.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Edit Field' : 'New Field'),
          actions: [
            if (_isSaving)
              const Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              TextButton(
                onPressed: _saveField,
                child: const Text('Save'),
              ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              flex: 0,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Field Name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.grid_view),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a field name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<CropType>(
                              value: _selectedCropType,
                              decoration: const InputDecoration(
                                labelText: 'Crop Type',
                                border: OutlineInputBorder(),
                              ),
                              items: CropType.values.map((type) {
                                return DropdownMenuItem(
                                  value: type,
                                  child: Text(type.displayName),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _selectedCropType = value);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<SoilType>(
                              value: _selectedSoilType,
                              decoration: const InputDecoration(
                                labelText: 'Soil Type',
                                border: OutlineInputBorder(),
                              ),
                              items: SoilType.values.map((type) {
                                return DropdownMenuItem(
                                  value: type,
                                  child: Text(type.displayName),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _selectedSoilType = value);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<FieldStatus>(
                        value: _selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                        ),
                        items: FieldStatus.values.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(status.displayName),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedStatus = value);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Text(
                    'Field Polygon',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  if (_polygonPoints.length >= 3)
                    Text(
                      '${_calculateArea(_polygonPoints).toStringAsFixed(2)} ha',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  const SizedBox(width: 8),
                  Text(
                    '${_polygonPoints.length} points',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Stack(
                children: [
                  ml.MaplibreMap(
                    styleString:
                        'https://demotiles.maplibre.org/style.json',
                    initialCameraPosition: const ml.CameraPosition(
                      target: ml.LatLng(0, 0),
                      zoom: 3.0,
                    ),
                    onMapClick: _onMapTap,
                    myLocationEnabled: true,
                    compassEnabled: true,
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () {
                              setState(() => _isDrawing = !_isDrawing);
                            },
                            icon: Icon(
                              _isDrawing ? Icons.stop : Icons.draw,
                            ),
                            label: Text(
                              _isDrawing ? 'Stop Drawing' : 'Draw Polygon',
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: _isDrawing
                                  ? colorScheme.error
                                  : colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          onPressed:
                              _polygonPoints.isNotEmpty ? _undoLastPoint : null,
                          icon: const Icon(Icons.undo),
                          tooltip: 'Undo',
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          onPressed: _polygonPoints.isNotEmpty
                              ? () => setState(() => _polygonPoints.clear())
                              : null,
                          icon: const Icon(Icons.clear_all),
                          tooltip: 'Clear',
                          style: IconButton.styleFrom(
                            backgroundColor: colorScheme.errorContainer,
                            foregroundColor: colorScheme.onErrorContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
