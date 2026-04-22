import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../../core/services/camera_service.dart';

class CameraCapturePage extends StatefulWidget {
  const CameraCapturePage({super.key});

  @override
  State<CameraCapturePage> createState() => _CameraCapturePageState();
}

class _CameraCapturePageState extends State<CameraCapturePage> {
  final CameraService _cameraService = CameraService();

  CameraController? _controller;
  bool _isInitializing = true;
  bool _isCapturing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      print('initializing camera');
      final hasPermission = await _cameraService.requestPermission();
      print('hasPermission: $hasPermission');
      if (!hasPermission) {
        if (!mounted) return;
        setState(() {
          _errorMessage = 'Camera permission is required to continue.';
          _isInitializing = false;
        });
        return;
      }

      final camera = await _cameraService.getPreferredCamera();
      print('camera: $camera');
      if (camera == null) {
        if (!mounted) return;
        print('not mounted');
        setState(() {
          _errorMessage = 'No camera found on this device.';
          _isInitializing = false;
        });
        return;
      }

      final controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _controller = controller;
        _isInitializing = false;
      });
    } catch (error) {
      print('error: $error');
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to initialize camera.';
        _isInitializing = false;
      });
    }
  }

  Future<void> _captureImage() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _isCapturing) {
      return;
    }

    try {
      setState(() => _isCapturing = true);
      final file = await controller.takePicture();
      if (!mounted) return;
      Navigator.of(context).pop(file.path);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not capture image. Try again.')),
      );
      setState(() => _isCapturing = false);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    return Scaffold(
      appBar: AppBar(title: const Text('Capture Image')),
      body: _isInitializing
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(_errorMessage!, textAlign: TextAlign.center),
              ),
            )
          : controller == null
          ? const SizedBox.shrink()
          : Stack(
              children: [
                Positioned.fill(child: CameraPreview(controller)),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 32,
                  child: Center(
                    child: FloatingActionButton.large(
                      onPressed: _isCapturing ? null : _captureImage,
                      child: _isCapturing
                          ? const CircularProgressIndicator()
                          : const Icon(Icons.camera_alt),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
