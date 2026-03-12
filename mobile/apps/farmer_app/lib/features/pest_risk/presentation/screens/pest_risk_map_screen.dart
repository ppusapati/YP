import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ui_core/flutter_ui_core.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../../domain/entities/pest_risk_entity.dart';
import '../bloc/pest_bloc.dart';
import '../bloc/pest_event.dart';
import '../bloc/pest_state.dart';
import '../widgets/pest_alert_card.dart';
import '../widgets/pest_risk_legend.dart';
import 'pest_alert_detail_screen.dart';

/// Full-screen GIS map displaying pest risk zones color-coded by severity,
/// with an overlaid legend and a bottom sheet listing active alerts.
class PestRiskMapScreen extends StatefulWidget {
  const PestRiskMapScreen({super.key, this.fieldId});

  final String? fieldId;

  @override
  State<PestRiskMapScreen> createState() => _PestRiskMapScreenState();
}

class _PestRiskMapScreenState extends State<PestRiskMapScreen> {
  MapLibreMapController? _mapController;
  bool _showAlerts = false;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<PestBloc>();
    bloc.add(LoadPestRiskZones(fieldId: widget.fieldId));
    bloc.add(LoadPestAlerts(fieldId: widget.fieldId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pest Risk Map'),
        actions: [
          BlocBuilder<PestBloc, PestState>(
            builder: (context, state) {
              final unread = state is PestAlertsLoaded ? state.unreadCount : 0;
              return Badge(
                isLabelVisible: unread > 0,
                label: Text('$unread'),
                child: IconButton(
                  icon: Icon(
                    _showAlerts ? Icons.map_outlined : Icons.notifications_outlined,
                  ),
                  onPressed: () => setState(() => _showAlerts = !_showAlerts),
                  tooltip: _showAlerts ? 'Show map' : 'Show alerts',
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<PestBloc>()
                ..add(LoadPestRiskZones(fieldId: widget.fieldId))
                ..add(LoadPestAlerts(fieldId: widget.fieldId));
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: BlocConsumer<PestBloc, PestState>(
        listener: (context, state) {
          if (state is PestError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          if (state is PestZonesLoaded && _mapController != null) {
            _renderZonesOnMap(state.displayZones);
          }
        },
        builder: (context, state) {
          if (_showAlerts) {
            return _buildAlertsList(context, state);
          }
          return _buildMapView(context, state);
        },
      ),
    );
  }

  Widget _buildMapView(BuildContext context, PestState state) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        MapLibreMap(
          styleString:
              'https://api.maptiler.com/maps/basic-v2/style.json?key=placeholder',
          initialCameraPosition: const CameraPosition(
            target: LatLng(-1.286389, 36.817223),
            zoom: 10,
          ),
          onMapCreated: (controller) {
            _mapController = controller;
            if (state is PestZonesLoaded) {
              _renderZonesOnMap(state.displayZones);
            }
          },
          onStyleLoadedCallback: () {
            if (state is PestZonesLoaded) {
              _renderZonesOnMap(state.displayZones);
            }
          },
        ),
        if (state is PestLoading)
          const Center(child: CircularProgressIndicator()),
        // Legend overlay
        Positioned(
          top: 12,
          right: 12,
          child: BlocSelector<PestBloc, PestState, RiskLevel?>(
            selector: (state) =>
                state is PestZonesLoaded ? state.activeFilter : null,
            builder: (context, activeFilter) {
              return PestRiskLegend(
                activeFilter: activeFilter,
                onFilterTap: (level) {
                  context.read<PestBloc>().add(FilterByRiskLevel(level));
                },
              );
            },
          ),
        ),
        // Zone count chip
        if (state is PestZonesLoaded)
          Positioned(
            bottom: 16,
            left: 16,
            child: Chip(
              avatar: Icon(Icons.layers, size: 18, color: theme.colorScheme.primary),
              label: Text(
                '${state.displayZones.length} risk zone${state.displayZones.length == 1 ? '' : 's'}',
              ),
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
            ),
          ),
      ],
    );
  }

  Widget _buildAlertsList(BuildContext context, PestState state) {
    if (state is PestLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is PestAlertsLoaded) {
      if (state.alerts.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_outline,
                  size: 64, color: AppColors.pestLow),
              const SizedBox(height: 16),
              Text(
                'No active pest alerts',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Your fields are looking healthy!',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: state.alerts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final alert = state.alerts[index];
          return PestAlertCard(
            alert: alert,
            onTap: () => _navigateToAlertDetail(context, alert),
          );
        },
      );
    }

    // For zones loaded or other states, prompt to load alerts
    return Center(
      child: ElevatedButton.icon(
        onPressed: () {
          context.read<PestBloc>().add(LoadPestAlerts(fieldId: widget.fieldId));
        },
        icon: const Icon(Icons.refresh),
        label: const Text('Load Alerts'),
      ),
    );
  }

  void _renderZonesOnMap(List<PestRiskZone> zones) {
    if (_mapController == null) return;

    // Clear existing annotations
    _mapController!.clearLines();
    _mapController!.clearFills();

    for (final zone in zones) {
      if (zone.polygon.isEmpty) continue;

      final color = _riskLevelColor(zone.riskLevel);
      final points = zone.polygon
          .map((ll) => LatLng(ll.latitude, ll.longitude))
          .toList();

      // Close the polygon if needed.
      if (points.first != points.last) {
        points.add(points.first);
      }

      _mapController!.addFill(FillOptions(
        geometry: [points],
        fillColor: _colorToHex(color),
        fillOpacity: 0.3,
      ));

      _mapController!.addLine(LineOptions(
        geometry: points,
        lineColor: _colorToHex(color),
        lineWidth: 2.0,
        lineOpacity: 0.8,
      ));
    }
  }

  Color _riskLevelColor(RiskLevel level) => switch (level) {
        RiskLevel.low => AppColors.pestLow,
        RiskLevel.moderate => AppColors.pestModerate,
        RiskLevel.high => AppColors.pestHigh,
        RiskLevel.critical => AppColors.pestCritical,
      };

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2)}';
  }

  void _navigateToAlertDetail(BuildContext context, PestAlert alert) {
    context.read<PestBloc>().add(MarkAlertRead(alert.id));
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: context.read<PestBloc>(),
          child: PestAlertDetailScreen(alert: alert),
        ),
      ),
    );
  }
}
