import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import '../services/quality_analyzer.dart';
import '../models/quality_result.dart';
import '../models/analyzer_settings.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AnalyzerSettings _settings = AnalyzerSettings.defaults;
  late QualityAnalyzer _analyzer;
  final ImagePicker _picker = ImagePicker();

  bool _isAnalyzing = false;
  String? _analyzedImagePath;
  QualityResult? _result;

  @override
  void initState() {
    super.initState();
    _analyzer = QualityAnalyzer(settings: _settings);
  }

  Future<void> _takePhoto() async {
    try {
      // Get available cameras
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No camera found on this device')),
          );
        }
        return;
      }

      // Navigate to camera screen
      if (!mounted) return;

      final imagePath = await Navigator.push<String>(
        context,
        MaterialPageRoute(
          builder: (context) => _CameraViewScreen(cameras: cameras),
        ),
      );

      if (imagePath != null) {
        await _analyzeImage(imagePath);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to open camera: $e')),
        );
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        await _analyzeImage(image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  Future<void> _analyzeImage(String imagePath) async {
    setState(() {
      _isAnalyzing = true;
      _analyzedImagePath = null;
      _result = null;
    });

    try {
      final result = await _analyzer.analyzeImage(imagePath);

      if (mounted) {
        setState(() {
          _analyzedImagePath = imagePath;
          _result = result;
          _isAnalyzing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Analysis failed: $e')),
        );
      }
    }
  }

  void _reset() {
    setState(() {
      _analyzedImagePath = null;
      _result = null;
    });
  }

  Future<void> _openSettings() async {
    final newSettings = await Navigator.push<AnalyzerSettings>(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsScreen(currentSettings: _settings),
      ),
    );

    if (newSettings != null) {
      setState(() {
        _settings = newSettings;
        _analyzer = QualityAnalyzer(settings: _settings);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings updated successfully')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo Quality Check'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openSettings,
            tooltip: 'Settings',
          ),
        ],
      ),
      body: _isAnalyzing
          ? _buildAnalyzingView()
          : _result != null
              ? _buildResultView()
              : _buildInitialView(),
    );
  }

  Widget _buildAnalyzingView() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Analyzing photo quality...',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.photo_camera,
              size: 100,
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
            const Text(
              'Photo Quality Analyzer',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Analyze your photos for quality issues',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),

            // Take Photo Button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: _takePhoto,
                icon: const Icon(Icons.camera_alt, size: 28),
                label: const Text(
                  'Take Photo',
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Import from Gallery Button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: OutlinedButton.icon(
                onPressed: _pickFromGallery,
                icon: const Icon(Icons.photo_library, size: 28),
                label: const Text(
                  'Import from Gallery',
                  style: TextStyle(fontSize: 18),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue,
                  side: const BorderSide(color: Colors.blue, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultView() {
    if (_result == null || _analyzedImagePath == null) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Photo thumbnail
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.file(
                  File(_analyzedImagePath!),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Quality verdict icon and text
            Icon(
              _result!.isGood ? Icons.check_circle : Icons.cancel,
              size: 80,
              color: _result!.isGood ? Colors.green : Colors.red,
            ),

            const SizedBox(height: 16),

            Text(
              _result!.reason,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: _result!.isGood ? Colors.green : Colors.red,
              ),
            ),

            const SizedBox(height: 16),

            // Technical details
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMetricRow(
                    'Brightness',
                    _result!.brightnessScore.toStringAsFixed(1),
                    _result!.brightnessLevel,
                    _result!.brightnessLevel == 'Normal',
                  ),
                  const Divider(height: 16),
                  _buildMetricRow(
                    'Blur',
                    _result!.blurScore.toStringAsFixed(1),
                    _result!.blurLevel,
                    _result!.blurLevel == 'Normal',
                  ),
                  const Divider(height: 16),
                  _buildMetricRow(
                    'Color Variance',
                    _result!.colorVarianceScore.toStringAsFixed(1),
                    _result!.colorVarianceLevel,
                    _result!.colorVarianceLevel == 'Lots of colours',
                  ),
                  const Divider(height: 16),
                  _buildMetricRow(
                    'Faces Detected',
                    '${_result!.faceCount}',
                    _result!.faceCount == 0
                        ? 'No faces'
                        : _result!.faceCount == 1
                            ? '1 face'
                            : '${_result!.faceCount} faces',
                    _result!.faceCount > 0, // Yellow for no faces, green for faces detected
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Analyze Another Photo button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _reset,
                icon: const Icon(Icons.refresh),
                label: const Text(
                  'Analyze Another Photo',
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String score, String level, bool isGood) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                score,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isGood ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isGood ? Colors.green : Colors.orange,
                    width: 1,
                  ),
                ),
                child: Text(
                  level,
                  style: TextStyle(
                    fontSize: 12,
                    color: isGood ? Colors.green[700] : Colors.orange[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Simple camera view screen
class _CameraViewScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const _CameraViewScreen({required this.cameras});

  @override
  State<_CameraViewScreen> createState() => _CameraViewScreenState();
}

class _CameraViewScreenState extends State<_CameraViewScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  int _currentCameraIndex = 0;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera(_currentCameraIndex);
  }

  void _initializeCamera(int cameraIndex) {
    _controller = CameraController(
      widget.cameras[cameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  Future<void> _switchCamera() async {
    if (widget.cameras.length < 2) return;

    // Dispose current controller
    await _controller.dispose();

    // Switch to next camera
    setState(() {
      _currentCameraIndex = (_currentCameraIndex + 1) % widget.cameras.length;
      _initializeCamera(_currentCameraIndex);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (_isProcessing) return; // Prevent multiple clicks

    setState(() {
      _isProcessing = true;
    });

    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();

      if (mounted) {
        Navigator.pop(context, image.path);
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to take picture: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                // Camera preview with proper aspect ratio
                Center(
                  child: AspectRatio(
                    aspectRatio: 1 / _controller.value.aspectRatio,
                    child: CameraPreview(_controller),
                  ),
                ),

                // Top bar with close button
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: _isProcessing ? null : () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                            color: Colors.white,
                            iconSize: 32,
                          ),
                          if (widget.cameras.length > 1)
                            IconButton(
                              onPressed: _isProcessing ? null : _switchCamera,
                              icon: const Icon(Icons.flip_camera_ios),
                              color: Colors.white,
                              iconSize: 32,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Bottom bar with capture button
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.8),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Center(
                      child: GestureDetector(
                        onTap: _isProcessing ? null : _takePicture,
                        child: Opacity(
                          opacity: _isProcessing ? 0.5 : 1.0,
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(
                                color: Colors.blue,
                                width: 4,
                              ),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.blue,
                              size: 35,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Loading overlay when processing
                if (_isProcessing)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.7),
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Processing...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
        },
      ),
    );
  }
}
