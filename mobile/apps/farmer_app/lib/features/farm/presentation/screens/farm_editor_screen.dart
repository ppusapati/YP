import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:maplibre_gl/maplibre_gl.dart' as ml;
import 'package:uuid/uuid.dart';

import '../../domain/entities/farm_entity.dart';
import '../bloc/farm_bloc.dart';
import '../bloc/farm_event.dart';
import '../bloc/farm_state.dart';

/// Screen for creating or editing a farm with map-based polygon drawing.
class FarmEditorScreen extends StatefulWidget {
  const FarmEditorScreen({super.key, this.existingFarm});

  final FarmEntity? existingFarm;

  @override
  State<FarmEditorScreen> createState() => _FarmEditorScreenState();
}

class _FarmEditorScreenState extends State<FarmEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  final List<LatLng> _boundaryPoints = [];
  ml.MaplibreMapController? _mapController;
  bool _isDrawing = false;
  bool _isSaving = false;

  bool get _isEditing => widget.existingFarm != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.existingFarm?.name ?? '',
    );
    if (widget.existingFarm != null) {
      _boundaryPoints.addAll(widget.existingFarm!.boundaries);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  double _calculateArea(List<LatLng> points) {
    if (points.length < 3) return 0.0;
    // Shoelace formula for approximate area in hectares.
    double area = 0.0;
    for (int i = 0; i < points.length; i++) {
      final j = (i + 1) % points.length;
      area += points[i].longitude * points[j].latitude;
      area -= points[j].longitude * points[i].latitude;
    }
    area = area.abs() / 2.0;
    // Convert from degrees^2 to hectares (approximate at equator).
    // 1 degree lat ~= 111,320 m, 1 degree lng ~= 111,320 * cos(lat) m.
    final avgLat = points.fold(0.0, (s, p) => s + p.latitude) / points.length;
    final metersPerDegreeLat = 111320.0;
    final metersPerDegreeLng = 111320.0 * _cos(avgLat);
    final areaM2 = area * metersPerDegreeLat * metersPerDegreeLng;
    return areaM2 / 10000.0;
  }

  double _cos(double degrees) {
    return degrees * 3.141592653589793 / 180.0;
  }

  void _onMapTap(ml.Point point, ml.LatLng coordinates) {
    if (!_isDrawing) return;
    setState(() {
      _boundaryPoints.add(LatLng(coordinates.latitude, coordinates.longitude));
    });
    _updateMapPolygon();
  }

  void _updateMapPolygon() {
    // Map polygon rendering would be done here via the map controller.
    // This is a simplified version; in production, use GeoJSON sources.
  }

  void _undoLastPoint() {
    if (_boundaryPoints.isNotEmpty) {
      setState(() {
        _boundaryPoints.removeLast();
      });
      _updateMapPolygon();
    }
  }

  void _clearBoundary() {
    setState(() {
      _boundaryPoints.clear();
    });
    _updateMapPolygon();
  }

  void _saveFarm() {
    if (!_formKey.currentState!.validate()) return;
    if (_boundaryPoints.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please draw at least 3 boundary points on the map'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final now = DateTime.now();
    final area = _calculateArea(_boundaryPoints);

    if (_isEditing) {
      final updated = widget.existingFarm!.copyWith(
        name: _nameController.text.trim(),
        boundaries: List.of(_boundaryPoints),
        totalAreaHectares: area,
        updatedAt: now,
      );
      context.read<FarmBloc>().add(UpdateFarm(farm: updated));
    } else {
      final farm = FarmEntity(
        id: const Uuid().v4(),
        name: _nameController.text.trim(),
        ownerId: '',
        boundaries: List.of(_boundaryPoints),
        totalAreaHectares: area,
        fields: const [],
        createdAt: now,
        updatedAt: now,
      );
      context.read<FarmBloc>().add(CreateFarm(farm: farm));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocListener<FarmBloc, FarmState>(
      listener: (context, state) {
        if (state is FarmCreated || state is FarmUpdated) {
          setState(() => _isSaving = false);
          Navigator.of(context).pop();
        } else if (state is FarmError) {
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
          title: Text(_isEditing ? 'Edit Farm' : 'New Farm'),
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
                onPressed: _saveFarm,
                child: const Text('Save'),
              ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Form(
                key: _formKey,
                child: TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Farm Name',
                    hintText: 'Enter farm name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.agriculture),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a farm name';
                    }
                    return null;
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Text(
                    'Farm Boundary',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  if (_boundaryPoints.length >= 3)
                    Text(
                      '${_calculateArea(_boundaryPoints).toStringAsFixed(2)} ha',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  const SizedBox(width: 8),
                  Text(
                    '${_boundaryPoints.length} points',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  ml.MaplibreMap(
                    styleString:
                        'https://demotiles.maplibre.org/style.json',
                    initialCameraPosition: const ml.CameraPosition(
                      target: ml.LatLng(0, 0),
                      zoom: 3.0,
                    ),
                    onMapCreated: (controller) {
                      _mapController = controller;
                    },
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
                              _isDrawing ? 'Stop Drawing' : 'Draw Boundary',
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
                          onPressed: _boundaryPoints.isNotEmpty
                              ? _undoLastPoint
                              : null,
                          icon: const Icon(Icons.undo),
                          tooltip: 'Undo last point',
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          onPressed: _boundaryPoints.isNotEmpty
                              ? _clearBoundary
                              : null,
                          icon: const Icon(Icons.clear_all),
                          tooltip: 'Clear boundary',
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
