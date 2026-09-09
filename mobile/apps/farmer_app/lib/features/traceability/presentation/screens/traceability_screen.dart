import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

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
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );
  bool _hasScanned = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _onBarcodeDetected(BarcodeCapture capture) {
    if (_hasScanned) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final qrData = barcodes.first.rawValue;
    if (qrData == null || qrData.isEmpty) return;

    setState(() => _hasScanned = true);
    context.read<TraceabilityBloc>().add(ScanQRCode(qrData));
  }

  @override
  Widget build(BuildContext context) {
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
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => BlocProvider.value(
                  value: context.read<TraceabilityBloc>(),
                  child: ProduceDetailScreen(record: state.record),
                ),
              ),
            ).then((_) {
              setState(() => _hasScanned = false);
            });
          }
          if (state is TraceabilityError) {
            setState(() => _hasScanned = false);
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
              Positioned.fill(
                child: MobileScanner(
                  controller: _scannerController,
                  onDetect: _onBarcodeDetected,
                ),
              ),

              const Positioned.fill(
                child: QrScannerOverlay(),
              ),

              Positioned(
                bottom: 60,
                left: 0,
                right: 0,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _hasScanned
                            ? 'Processing...'
                            : 'Point camera at a QR code',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _showManualEntry,
                        style:
                            TextButton.styleFrom(foregroundColor: Colors.white),
                        child: const Text('Or enter batch ID manually'),
                      ),
                    ],
                  ),
                ),
              ),

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
