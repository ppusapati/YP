import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maplibre_gl/maplibre_gl.dart' as ml;

import '../../domain/entities/satellite_entity.dart';
import '../bloc/satellite_bloc.dart';
import '../bloc/satellite_event.dart';
import '../bloc/satellite_state.dart';
import '../widgets/ndvi_legend.dart';
import '../widgets/satellite_layer_controls.dart';
import 'crop_health_dashboard_screen.dart';

/// Screen displaying satellite overlays on a map with NDVI toggle and date picker.
class SatelliteMonitoringScreen extends StatefulWidget {
  const SatelliteMonitoringScreen({
    super.key,
    required this.fieldId,
    this.fieldName,
  });

  final String fieldId;
  final String? fieldName;

  static const String routePath = '/satellite/:fieldId';

  @override
  State<SatelliteMonitoringScreen> createState() =>
      _SatelliteMonitoringScreenState();
}

class _SatelliteMonitoringScreenState extends State<SatelliteMonitoringScreen> {
  ml.MaplibreMapController? _mapController;
  SatelliteLayerType _selectedLayer = SatelliteLayerType.ndvi;
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );
  bool _showNdviLegend = true;

  @override
  void initState() {
    super.initState();
    _loadTiles();
  }

  void _loadTiles() {
    context.read<SatelliteBloc>().add(LoadSatelliteTiles(
          fieldId: widget.fieldId,
          layerType: _selectedLayer,
        ));
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );
    if (picked != null) {
      setState(() => _dateRange = picked);
      context.read<SatelliteBloc>().add(SelectDateRange(
            from: picked.start,
            to: picked.end,
          ));
      _loadTiles();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dateFormat = DateFormat('MMM d');

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fieldName ?? 'Satellite Monitoring'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            tooltip: 'Select date range',
            onPressed: _selectDateRange,
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Crop Health Dashboard',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => BlocProvider.value(
                    value: context.read<SatelliteBloc>(),
                    child: CropHealthDashboardScreen(
                      fieldId: widget.fieldId,
                      fieldName: widget.fieldName,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          BlocBuilder<SatelliteBloc, SatelliteState>(
            builder: (context, state) {
              return ml.MaplibreMap(
                styleString: 'https://demotiles.maplibre.org/style.json',
                initialCameraPosition: const ml.CameraPosition(
                  target: ml.LatLng(0, 0),
                  zoom: 14.0,
                ),
                onMapCreated: (controller) {
                  _mapController = controller;
                },
                myLocationEnabled: true,
                compassEnabled: true,
              );
            },
          ),
          // Date range badge.
          Positioned(
            top: 16,
            left: 16,
            child: Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: _selectDateRange,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.date_range,
                          size: 16, color: colorScheme.primary),
                      const SizedBox(width: 6),
                      Text(
                        '${dateFormat.format(_dateRange.start)} - ${dateFormat.format(_dateRange.end)}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Loading indicator.
          BlocBuilder<SatelliteBloc, SatelliteState>(
            builder: (context, state) {
              if (state is SatelliteLoading) {
                return Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          // Layer controls.
          Positioned(
            right: 16,
            bottom: 120,
            child: SatelliteLayerControls(
              selectedLayer: _selectedLayer,
              onLayerChanged: (layer) {
                setState(() => _selectedLayer = layer);
                _loadTiles();
              },
            ),
          ),
          // NDVI toggle and legend.
          if (_showNdviLegend &&
              (_selectedLayer == SatelliteLayerType.ndvi ||
                  _selectedLayer == SatelliteLayerType.evi))
            Positioned(
              left: 16,
              bottom: 32,
              child: NdviLegend(
                indexType: _selectedLayer == SatelliteLayerType.evi
                    ? 'EVI'
                    : 'NDVI',
                onClose: () => setState(() => _showNdviLegend = false),
              ),
            ),
          // Toggle legend button.
          if (!_showNdviLegend)
            Positioned(
              left: 16,
              bottom: 32,
              child: FloatingActionButton.small(
                heroTag: 'legend_toggle',
                onPressed: () => setState(() => _showNdviLegend = true),
                child: const Icon(Icons.legend_toggle),
              ),
            ),
          // Error message.
          BlocBuilder<SatelliteBloc, SatelliteState>(
            builder: (context, state) {
              if (state is SatelliteError) {
                return Positioned(
                  bottom: 32,
                  left: 16,
                  right: 16,
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(12),
                    color: colorScheme.errorContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline,
                              color: colorScheme.onErrorContainer),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              state.message,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.refresh,
                                color: colorScheme.onErrorContainer),
                            onPressed: _loadTiles,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}
