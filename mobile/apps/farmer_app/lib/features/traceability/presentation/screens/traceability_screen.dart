import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/traceability_bloc.dart';
import '../bloc/traceability_event.dart';
import '../bloc/traceability_state.dart';
import '../widgets/qr_scanner_overlay.dart';
import 'produce_detail_screen.dart';

/// Main traceability screen with QR code scanner.
class TraceabilityScreen extends StatefulWidget {
  const TraceabilityScreen({super.key});

  @override
  State<TraceabilityScreen> createState() => _TraceabilityScreenState();
}

class _TraceabilityScreenState extends State<TraceabilityScreen> {
  CameraController? _cameraController;
  bool _isCameraReady = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      final backCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        backCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      if (mounted) {
        setState(() => _isCameraReady = true);
      }
    } catch (e) {
      debugPrint('Camera initialization failed: $e');
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Traceability'),
        actions: [
          IconButton(
            icon: const Icon(Icons.text_fields_outlined),
            onPressed: _showManualEntry,
            tooltip: 'Enter code manually',
          ),
        ],
      ),
      body: BlocConsumer<TraceabilityBloc, TraceabilityState>(
        listener: (context, state) {
          if (state is RecordLoaded) {
            _isProcessing = false;
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => BlocProvider.value(
                  value: context.read<TraceabilityBloc>(),
                  child: ProduceDetailScreen(record: state.record),
                ),
              ),
            );
          }
          if (state is TraceabilityError) {
            _isProcessing = false;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                behavior: SnackBarBehavior.floating,
                action: SnackBarAction(
                  label: 'Retry',
                  onPressed: () {},
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              // Camera preview
              if (_isCameraReady && _cameraController != null)
                Positioned.fill(
                  child: CameraPreview(_cameraController!),
                )
              else
                Container(
                  color: Colors.black,
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),

              // Scanner overlay
              const Positioned.fill(
                child: QrScannerOverlay(),
              ),

              // Scan button
              Positioned(
                bottom: 60,
                left: 0,
                right: 0,
                child: Center(
                  child: _buildScanButton(context, state, theme),
                ),
              ),

              // Loading indicator
              if (state is Scanning || state is TraceabilityLoading)
                Positioned.fill(
                  child: Container(
                    color: Colors.black38,
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(height: 16),
                          Text(
                            'Looking up produce record...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildScanButton(
    BuildContext context,
    TraceabilityState state,
    ThemeData theme,
  ) {
    final isActive =
        state is! Scanning && state is! TraceabilityLoading && !_isProcessing;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FilledButton.icon(
          onPressed: isActive ? _captureAndScan : null,
          icon: const Icon(Icons.qr_code_scanner, size: 28),
          label: const Text('Scan QR Code', style: TextStyle(fontSize: 16)),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: _showManualEntry,
          style: TextButton.styleFrom(foregroundColor: Colors.white),
          child: const Text('Or enter batch ID manually'),
        ),
      ],
    );
  }

  Future<void> _captureAndScan() async {
    if (_cameraController == null || !_isCameraReady || _isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final image = await _cameraController!.takePicture();
      // In production, decode the QR code from the image using a QR decoding
      // library. For now, we pass the image path as a placeholder.
      // A real implementation would use `mobile_scanner` or `google_mlkit_barcode_scanning`.
      if (mounted) {
        context.read<TraceabilityBloc>().add(ScanQRCode(image.path));
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to capture image: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showManualEntry() {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Enter Batch ID'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'e.g., BATCH-2024-001',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.qr_code),
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final code = controller.text.trim();
              if (code.isNotEmpty) {
                Navigator.pop(ctx);
                context.read<TraceabilityBloc>().add(ScanQRCode(code));
              }
            },
            child: const Text('Look Up'),
          ),
        ],
      ),
    );
  }
}
