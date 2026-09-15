import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_analytics/flutter_analytics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map_core/flutter_map_core.dart'
    show BoundaryRejection, BoundaryWalkTool, GpsPosition;
import 'package:geolocator/geolocator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:maplibre_gl/maplibre_gl.dart' as ml;
import 'package:uuid/uuid.dart';

import '../../../../core/di/providers.dart';
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

  /// Walking the perimeter, as an alternative to tapping the map.
  ///
  /// Tapping works when you can see the field on the map. Standing in it, at a
  /// zoom where the whole field fits, a fingertip covers several metres — and
  /// the satellite basemap is often months old. Walking the edge and dropping
  /// a point at each corner is how a boundary gets recorded accurately, and it
  /// is what this screen could not do.
  final BoundaryWalkTool _walk = BoundaryWalkTool();
  bool _isWalking = false;
  GpsPosition? _lastFix;
  StreamSubscription<Position>? _fixSubscription;
  StreamSubscription<BoundaryRejection>? _rejectionSubscription;
  String? _gpsMessage;

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
    _fixSubscription?.cancel();
    _rejectionSubscription?.cancel();
    _walk.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Walking the boundary
  // ---------------------------------------------------------------------------

  Future<void> _startWalking() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      setState(() => _gpsMessage =
          'Location is switched off. Turn it on to walk the boundary.');
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      // Named rather than left as a dead button: "denied forever" needs a trip
      // to system settings, and silence looks like a broken screen.
      setState(() => _gpsMessage = permission == LocationPermission.deniedForever
          ? 'Location permission is blocked for this app. Enable it in Settings.'
          : 'Location permission is needed to walk the boundary.');
      return;
    }

    // Any point already tapped is kept: switching to walking should not throw
    // away work.
    _rejectionSubscription ??= _walk.rejections.listen((reason) {
      if (!mounted) return;
      setState(() {
        _gpsMessage = switch (reason) {
          BoundaryRejection.poorAccuracy =>
            'That fix was too rough to use — wait for a better signal, '
                'or step clear of trees and buildings.',
          BoundaryRejection.tooClose => null,
        };
      });
    });

    _fixSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 1,
      ),
    ).listen((position) {
      if (!mounted) return;
      setState(() => _lastFix = GpsPosition.fromPosition(position));
    });

    setState(() {
      _isWalking = true;
      _isDrawing = false;
      _gpsMessage = 'Walk to each corner and tap "Drop corner".';
    });
  }

  Analytics get _analytics =>
      ProviderScope.containerOf(context, listen: false).read(analyticsProvider);

  void _stopWalking() {
    _fixSubscription?.cancel();
    _fixSubscription = null;
    if (_walk.hasUsablePolygon) {
      // The worst accuracy is what decides whether the boundary is worth
      // anything, so it is recorded with the walk rather than left to be
      // guessed at from a map screenshot later.
      _analytics.track('boundary_walked', properties: {
        'points': _walk.points.length,
        'hectares': double.parse(_walk.areaHectares.toStringAsFixed(2)),
        'worst_accuracy_m': _walk.worstAccuracyMeters.round(),
      });
    }
    setState(() {
      _isWalking = false;
      _lastFix = null;
      _gpsMessage = null;
    });
  }

  /// Green when the fix is good enough to record, amber while it is not.
  ///
  /// The threshold is the walker's own, so the colour and the refusal always
  /// agree — a green dot next to a refused corner would be worse than no dot.
  Color _fixQualityColor(ColorScheme scheme) {
    final fix = _lastFix;
    if (fix == null) return scheme.onSurfaceVariant;
    return fix.accuracyMeters <= _walk.accuracyThresholdMeters
        ? scheme.primary
        : scheme.error;
  }

  void _dropCorner() {
    final point = _walk.dropCorner(_lastFix);
    if (point == null) return;
    setState(() {
      _polygonPoints.add(LatLng(point.latLng.latitude, point.latLng.longitude));
      _gpsMessage = null;
    });
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
        111320.0 * math.cos(avgLat * math.pi / 180.0);
    final areaM2 = area * metersPerDegreeLat * metersPerDegreeLng;
    return areaM2 / 10000.0;
  }

  void _onMapTap(math.Point<double> point, ml.LatLng coordinates) {
    if (!_isDrawing) return;
    setState(() {
      _polygonPoints.add(LatLng(coordinates.latitude, coordinates.longitude));
    });
  }

  void _undoLastPoint() {
    if (_polygonPoints.isEmpty) return;
    // The walk is the source of truth for anything GPS-recorded, so undoing
    // has to happen in both or the two drift apart.
    _walk.undo();
    setState(() => _polygonPoints.removeLast());
  }

  void _clearPoints() {
    _walk.clear();
    setState(() => _polygonPoints.clear());
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
            if (_gpsMessage != null || _isWalking)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_isWalking)
                        Row(
                          children: [
                            Icon(
                              _lastFix == null
                                  ? Icons.gps_not_fixed
                                  : Icons.gps_fixed,
                              size: 18,
                              color: _fixQualityColor(colorScheme),
                            ),
                            const SizedBox(width: 8),
                            // The accuracy is shown because it decides whether
                            // the boundary is worth anything, and a farmer can
                            // act on it: step clear of the trees and wait.
                            Text(
                              _lastFix == null
                                  ? 'Waiting for a GPS fix…'
                                  : 'Accuracy ±${_lastFix!.accuracyMeters.round()} m',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: _fixQualityColor(colorScheme),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      if (_gpsMessage != null) ...[
                        if (_isWalking) const SizedBox(height: 6),
                        Text(
                          _gpsMessage!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
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
                    child: Column(
                      children: [
                        // Walking the perimeter, for when you are standing in
                        // the field rather than looking at it on a map.
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                onPressed:
                                    _isWalking ? _stopWalking : _startWalking,
                                icon: Icon(
                                  _isWalking
                                      ? Icons.stop
                                      : Icons.directions_walk,
                                ),
                                label: Text(
                                  _isWalking
                                      ? 'Stop walking'
                                      : 'Walk the boundary',
                                ),
                                style: FilledButton.styleFrom(
                                  backgroundColor: _isWalking
                                      ? colorScheme.error
                                      : colorScheme.secondary,
                                ),
                              ),
                            ),
                            if (_isWalking) ...[
                              const SizedBox(width: 8),
                              Expanded(
                                child: FilledButton.icon(
                                  // Disabled until there is a fix: a corner
                                  // dropped from no position is not a corner.
                                  onPressed:
                                      _lastFix == null ? null : _dropCorner,
                                  icon: const Icon(Icons.add_location_alt),
                                  label: const Text('Drop corner'),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _isWalking
                                ? null
                                : () {
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
                          onPressed:
                              _polygonPoints.isNotEmpty ? _clearPoints : null,
                          icon: const Icon(Icons.clear_all),
                          tooltip: 'Clear',
                          style: IconButton.styleFrom(
                            backgroundColor: colorScheme.errorContainer,
                            foregroundColor: colorScheme.onErrorContainer,
                          ),
                        ),
                      ],
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
