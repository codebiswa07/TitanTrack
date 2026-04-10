import 'package:camera/camera.dart';

class CameraService {
  CameraController? _controller;
  bool _isProcessing = false;

  CameraController? get controller => _controller;

  Future<void> initialize() async {
    final cameras = await availableCameras();
    _controller = CameraController(
      cameras[0], 
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420, // Best for AI processing
    );
    await _controller!.initialize();
  }

  void startStreaming(Function(CameraImage) onImage) {
    _controller?.startImageStream((image) {
      if (_isProcessing) return;
      _isProcessing = true;
      
      // Send image to AI logic
      onImage(image);
      
      // Control processing rate (e.g., 10 FPS) to save battery
      Future.delayed(Duration(milliseconds: 100), () => _isProcessing = false);
    });
  }

  void dispose() {
    _controller?.dispose();
  }
}