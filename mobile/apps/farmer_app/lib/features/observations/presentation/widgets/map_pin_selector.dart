import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:maplibre_gl/maplibre_gl.dart';

/// A map widget that lets the user drop a pin to select a location.
class MapPinSelector extends StatefulWidget {
  const MapPinSelector({
    super.key,
    this.initialLocation,
    required this.onLocationSelected,
    this.height = 250,
  });

  /// Initial pin location, if any.
  final ll.LatLng? initialLocation;

  /// Called when the user taps the map to select a location.
  final ValueChanged<ll.LatLng> onLocationSelected;

  final double height;

  @override
  State<MapPinSelector> createState() => _MapPinSelectorState();
}

class _MapPinSelectorState extends State<MapPinSelector> {
  MapLibreMapController? _controller;
  ll.LatLng? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialLocation;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: widget.height,
            child: Stack(
              children: [
                MapLibreMap(
                  styleString:
                      'https://api.maptiler.com/maps/basic-v2/style.json?key=placeholder',
                  initialCameraPosition: CameraPosition(
                    target: _selected != null
                        ? LatLng(_selected!.latitude, _selected!.longitude)
                        : const LatLng(-1.286389, 36.817223),
                    zoom: 14,
                  ),
                  onMapCreated: (controller) {
                    _controller = controller;
                    if (_selected != null) _placeMarker();
                  },
                  onMapClick: (point, latLng) {
                    setState(() {
                      _selected =
                          ll.LatLng(latLng.latitude, latLng.longitude);
                    });
                    _placeMarker();
                    widget.onLocationSelected(_selected!);
                  },
                  myLocationEnabled: true,
                  myLocationTrackingMode: MyLocationTrackingMode.none,
                ),
                // Hint overlay
                if (_selected == null)
                  const Center(
                    child: Icon(
                      Icons.add_location_alt_outlined,
                      size: 40,
                      color: Colors.black45,
                    ),
                  ),
                // Coordinates display
                if (_selected != null)
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${_selected!.latitude.toStringAsFixed(5)}, '
                        '${_selected!.longitude.toStringAsFixed(5)}',
                        style: theme.textTheme.labelSmall,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (_selected != null)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                setState(() => _selected = null);
                _controller?.clearSymbols();
              },
              icon: const Icon(Icons.clear, size: 16),
              label: const Text('Clear pin'),
            ),
          ),
      ],
    );
  }

  void _placeMarker() {
    if (_controller == null || _selected == null) return;
    _controller!.clearSymbols();
    _controller!.addSymbol(SymbolOptions(
      geometry: LatLng(_selected!.latitude, _selected!.longitude),
      iconImage: 'marker-15',
      iconSize: 2.0,
    ));
  }
}
