/// Flutter Map Core - A reusable GIS engine for precision agriculture.
///
/// Provides map rendering, layer management, drawing tools, offline tile
/// support, and geometry utilities built on MapLibre GL.
library flutter_map_core;

// Engine
export 'src/engine/geo_utils.dart';
export 'src/engine/map_config.dart';
export 'src/engine/map_controller_wrapper.dart';
export 'src/engine/map_engine.dart';

// Layers
export 'src/layers/geojson_source.dart';
export 'src/layers/layer_manager.dart';
export 'src/layers/map_layer.dart';
export 'src/layers/raster_layer.dart';
export 'src/layers/vector_layer.dart';

// Tools
export 'src/tools/gps_location_tool.dart';
export 'src/tools/measurement_tool.dart';
export 'src/tools/polygon_draw_tool.dart';
export 'src/tools/polygon_edit_tool.dart';

// Tiles
export 'src/tiles/tile_manager.dart';

// Offline
export 'src/offline/offline_region.dart';
export 'src/offline/offline_tile_manager.dart';

// Interactions
export 'src/interactions/map_gesture_handler.dart';
