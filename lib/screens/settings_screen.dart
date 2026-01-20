import 'package:flutter/material.dart';
import '../models/analyzer_settings.dart';

class SettingsScreen extends StatefulWidget {
  final AnalyzerSettings currentSettings;

  const SettingsScreen({
    super.key,
    required this.currentSettings,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late double _tooDarkThreshold;
  late double _tooBrightThreshold;
  late double _blurThreshold;
  late double _colorVarianceThreshold;

  @override
  void initState() {
    super.initState();
    _tooDarkThreshold = widget.currentSettings.tooDarkThreshold;
    _tooBrightThreshold = widget.currentSettings.tooBrightThreshold;
    _blurThreshold = widget.currentSettings.blurThreshold;
    _colorVarianceThreshold = widget.currentSettings.colorVarianceThreshold;
  }

  void _resetToDefaults() {
    setState(() {
      _tooDarkThreshold = AnalyzerSettings.defaults.tooDarkThreshold;
      _tooBrightThreshold = AnalyzerSettings.defaults.tooBrightThreshold;
      _blurThreshold = AnalyzerSettings.defaults.blurThreshold;
      _colorVarianceThreshold = AnalyzerSettings.defaults.colorVarianceThreshold;
    });
  }

  void _saveSettings() {
    final newSettings = AnalyzerSettings(
      tooDarkThreshold: _tooDarkThreshold,
      tooBrightThreshold: _tooBrightThreshold,
      blurThreshold: _blurThreshold,
      colorVarianceThreshold: _colorVarianceThreshold,
    );
    Navigator.pop(context, newSettings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis Settings'),
        backgroundColor: Colors.blue,
        actions: [
          TextButton.icon(
            onPressed: _resetToDefaults,
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text(
              'Reset',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Brightness Thresholds',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Adjust when images are considered too dark or too bright (0-255 scale)',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 16),

          _buildSlider(
            label: 'Too Dark Threshold',
            value: _tooDarkThreshold,
            min: 0,
            max: 255,
            divisions: 255,
            onChanged: (value) => setState(() => _tooDarkThreshold = value),
            description: 'Below ${_tooDarkThreshold.toInt()} = Too dark',
          ),

          const SizedBox(height: 16),

          _buildSlider(
            label: 'Too Bright Threshold',
            value: _tooBrightThreshold,
            min: 0,
            max: 255,
            divisions: 255,
            onChanged: (value) => setState(() => _tooBrightThreshold = value),
            description: 'Above ${_tooBrightThreshold.toInt()} = Too bright',
          ),

          const Divider(height: 40),

          const Text(
            'Blur Threshold',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Adjust blur sensitivity (higher = more strict)',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 16),

          _buildSlider(
            label: 'Blur Detection',
            value: _blurThreshold,
            min: 0,
            max: 500,
            divisions: 100,
            onChanged: (value) => setState(() => _blurThreshold = value),
            description: 'Below ${_blurThreshold.toInt()} = Too blur',
          ),

          const Divider(height: 40),

          const Text(
            'Color Variance Threshold',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Adjust color diversity detection (higher = requires more colors)',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 16),

          _buildSlider(
            label: 'Color Diversity',
            value: _colorVarianceThreshold,
            min: 0,
            max: 100,
            divisions: 100,
            onChanged: (value) => setState(() => _colorVarianceThreshold = value),
            description: 'Below ${_colorVarianceThreshold.toInt()} = Less colours',
          ),

          const SizedBox(height: 40),

          // Save button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _saveSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Save Settings',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
    required String description,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                value.toInt().toString(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
          activeColor: Colors.blue,
        ),
        Text(
          description,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}
