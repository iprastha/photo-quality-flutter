import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' show Rect;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import '../models/face_match_result.dart';

class FaceRecognitionService {
  Interpreter? _interpreter;
  bool _isModelLoaded = false;

  static const String _embeddingKey = 'enrolled_face_embedding';
  static const String _imagePathKey = 'enrolled_face_image_path';
  static const String _enrolledDateKey = 'enrolled_date';

  static const int _embeddingDimensions = 512;
  static const int _inputSize = 160;
  static const double _matchThreshold = 0.65; // Cosine similarity threshold

  /// Initialize the TFLite model
  Future<void> _initializeModel() async {
    if (_isModelLoaded) return;

    try {
      _interpreter = await Interpreter.fromAsset('assets/models/facenet_512.tflite');
      _isModelLoaded = true;
      print('FaceNet-512 model loaded successfully');
    } catch (e) {
      print('Failed to load model: $e');
      rethrow;
    }
  }

  /// Enroll a face by extracting embeddings and storing in SharedPreferences
  Future<bool> enrollFace(Face face, String imagePath) async {
    try {
      final embedding = await _extractFaceEmbedding(imagePath, face);
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(_embeddingKey, jsonEncode(embedding));
      await prefs.setString(_imagePathKey, imagePath);
      await prefs.setString(_enrolledDateKey, DateTime.now().toIso8601String());

      return true;
    } catch (e) {
      print('Enrollment error: $e');
      return false;
    }
  }

  /// Check if there is an enrolled face profile
  Future<bool> hasEnrolledProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_embeddingKey);
  }

  /// Delete the enrolled profile
  Future<void> deleteProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_embeddingKey);
    await prefs.remove(_imagePathKey);
    await prefs.remove(_enrolledDateKey);
  }

  /// Recognize a face by comparing with enrolled profile
  Future<FaceMatchResult?> recognizeFace(Face detectedFace, String imagePath) async {
    final prefs = await SharedPreferences.getInstance();
    String? storedJson = prefs.getString(_embeddingKey);

    if (storedJson == null) return null;

    List<double> enrolledEmbedding = List<double>.from(jsonDecode(storedJson));
    List<double> detectedEmbedding = await _extractFaceEmbedding(imagePath, detectedFace);

    double similarity = _cosineSimilarity(enrolledEmbedding, detectedEmbedding);
    bool isMatch = similarity >= _matchThreshold;

    return FaceMatchResult(
      isMatch: isMatch,
      similarity: similarity,
      confidence: _getConfidenceLevel(similarity),
    );
  }

  /// Get the path to the enrolled face image
  Future<String?> getEnrolledImagePath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_imagePathKey);
  }

  /// Get the enrollment date
  Future<DateTime?> getEnrollmentDate() async {
    final prefs = await SharedPreferences.getInstance();
    String? dateStr = prefs.getString(_enrolledDateKey);
    if (dateStr == null) return null;
    return DateTime.parse(dateStr);
  }

  /// Extract face embedding using TFLite model
  Future<List<double>> _extractFaceEmbedding(String imagePath, Face face) async {
    await _initializeModel();

    // Step 1: Extract and preprocess face
    final croppedFace = await _extractFace(imagePath, face.boundingBox);
    final alignedFace = _alignFace(croppedFace, face);
    final resizedFace = _resizeForModel(alignedFace);
    final normalizedInput = _normalizeImage(resizedFace);

    // Step 2: Reshape input for TFLite [1, 160, 160, 3]
    final inputTensor = normalizedInput.reshape([1, _inputSize, _inputSize, 3]);

    // Step 3: Prepare output tensor [1, 512]
    final outputTensor = List.filled(_embeddingDimensions, 0.0).reshape([1, _embeddingDimensions]);

    // Step 4: Run inference
    _interpreter!.run(inputTensor, outputTensor);

    // Step 5: Extract and return embedding
    final embedding = List<double>.from(outputTensor[0]);
    return embedding;
  }

  /// Extract face region from full image using bounding box
  Future<img.Image> _extractFace(String imagePath, Rect boundingBox) async {
    final bytes = await File(imagePath).readAsBytes();
    final originalImage = img.decodeImage(bytes);

    if (originalImage == null) throw Exception('Failed to decode image');

    // Calculate crop region with 15% padding
    final padding = 0.15;
    final paddedWidth = boundingBox.width * (1 + 2 * padding);
    final paddedHeight = boundingBox.height * (1 + 2 * padding);
    final x = (boundingBox.left - boundingBox.width * padding).clamp(0.0, originalImage.width.toDouble());
    final y = (boundingBox.top - boundingBox.height * padding).clamp(0.0, originalImage.height.toDouble());

    // Crop face region
    final croppedFace = img.copyCrop(
      originalImage,
      x: x.toInt(),
      y: y.toInt(),
      width: paddedWidth.toInt().clamp(1, originalImage.width - x.toInt()),
      height: paddedHeight.toInt().clamp(1, originalImage.height - y.toInt()),
    );

    return croppedFace;
  }

  /// Align face using eye landmarks (basic rotation correction)
  img.Image _alignFace(img.Image croppedFace, Face mlKitFace) {
    // Get eye positions from ML Kit landmarks
    final leftEye = mlKitFace.landmarks[FaceLandmarkType.leftEye]?.position;
    final rightEye = mlKitFace.landmarks[FaceLandmarkType.rightEye]?.position;

    if (leftEye == null || rightEye == null) {
      return croppedFace; // Skip alignment if landmarks missing
    }

    // Calculate rotation angle
    final dy = rightEye.y - leftEye.y;
    final dx = rightEye.x - leftEye.x;
    final angle = math.atan2(dy, dx) * 180 / math.pi;

    // Rotate image to align eyes horizontally (only if angle > 2 degrees)
    if (angle.abs() > 2) {
      return img.copyRotate(croppedFace, angle: -angle);
    }

    return croppedFace;
  }

  /// Resize face image to model input size (160x160)
  img.Image _resizeForModel(img.Image croppedFace) {
    return img.copyResize(
      croppedFace,
      width: _inputSize,
      height: _inputSize,
      interpolation: img.Interpolation.linear,
    );
  }

  /// Normalize image to [-1, 1] range for FaceNet input
  Float32List _normalizeImage(img.Image resizedFace) {
    final inputSize = _inputSize * _inputSize * 3;
    final input = Float32List(inputSize);

    int pixelIndex = 0;
    for (int y = 0; y < _inputSize; y++) {
      for (int x = 0; x < _inputSize; x++) {
        final pixel = resizedFace.getPixel(x, y);

        // Extract RGB channels and normalize to [-1, 1]
        input[pixelIndex++] = (pixel.r / 127.5) - 1.0;
        input[pixelIndex++] = (pixel.g / 127.5) - 1.0;
        input[pixelIndex++] = (pixel.b / 127.5) - 1.0;
      }
    }

    return input;
  }

  /// Calculate cosine similarity between two embedding vectors
  double _cosineSimilarity(List<double> embedding1, List<double> embedding2) {
    if (embedding1.length != embedding2.length) {
      throw ArgumentError('Embeddings must have same length');
    }

    double dotProduct = 0.0;
    double norm1 = 0.0;
    double norm2 = 0.0;

    for (int i = 0; i < embedding1.length; i++) {
      dotProduct += embedding1[i] * embedding2[i];
      norm1 += embedding1[i] * embedding1[i];
      norm2 += embedding2[i] * embedding2[i];
    }

    if (norm1 == 0.0 || norm2 == 0.0) return 0.0;

    return dotProduct / (math.sqrt(norm1) * math.sqrt(norm2));
  }

  /// Get confidence level based on cosine similarity score
  String _getConfidenceLevel(double similarity) {
    if (similarity >= 0.75) return 'Very High';
    if (similarity >= 0.65) return 'High';
    if (similarity >= 0.55) return 'Medium';
    if (similarity >= 0.45) return 'Low';
    return 'Very Low';
  }

  /// Clean up resources
  void dispose() {
    _interpreter?.close();
    _isModelLoaded = false;
  }
}
