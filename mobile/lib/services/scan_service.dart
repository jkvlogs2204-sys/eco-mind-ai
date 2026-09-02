import 'dart:async';
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/eco_score.dart';
import 'api_service.dart';
import 'bluetooth_service.dart';

enum ScanState {
  idle,
  scanning,
  analyzing,
  success,
  unregistered,
  error,
}

class ScanService extends ChangeNotifier {
  final ApiService apiService;
  BluetoothService? _bluetoothService;
  StreamSubscription<String>? _rfidSubscription;

  ScanState _state = ScanState.idle;
  ProductModel? _currentProduct;
  EcoScoreAnalysisModel? _currentAnalysis;
  GeminiInsightModel? _currentGeminiInsight;
  Map<String, dynamic>? _betterAlternative;
  String? _scannedUid;
  String? _errorMessage;

  // Duplicate Scan Cooldown Protection
  String? _lastScannedUid;
  DateTime? _lastScanTime;
  final Duration _debounceCooldown = const Duration(milliseconds: 2500);

  ScanService({required this.apiService});

  ScanState get state => _state;
  ProductModel? get currentProduct => _currentProduct;
  EcoScoreAnalysisModel? get currentAnalysis => _currentAnalysis;
  GeminiInsightModel? get currentGeminiInsight => _currentGeminiInsight;
  Map<String, dynamic>? get betterAlternative => _betterAlternative;
  String? get scannedUid => _scannedUid;
  String? get errorMessage => _errorMessage;

  void attachBluetoothService(BluetoothService btService) {
    _bluetoothService = btService;
    _rfidSubscription?.cancel();
    _rfidSubscription = _bluetoothService!.rfidStream.listen(_onRfidScannedFromBluetooth);
  }

  void _onRfidScannedFromBluetooth(String uid) {
    final cleanUid = uid.trim().toUpperCase().replaceAll(' ', '').replaceAll(':', '');
    if (cleanUid.isEmpty) return;

    // Check Duplicate Scan Cooldown
    final now = DateTime.now();
    if (_lastScannedUid == cleanUid && _lastScanTime != null) {
      if (now.difference(_lastScanTime!) < _debounceCooldown) {
        return; // Suppress duplicate scan within 2.5s cooldown window
      }
    }

    _lastScannedUid = cleanUid;
    _lastScanTime = now;

    // Trigger zero-tap automated analysis pipeline
    processRfidScan(cleanUid);
  }

  Future<void> processRfidScan(String rawRfidUid) async {
    final cleanUid = rawRfidUid.trim().toUpperCase().replaceAll(' ', '').replaceAll(':', '');
    _scannedUid = cleanUid;
    _state = ScanState.analyzing;
    _errorMessage = null;
    notifyListeners();

    final result = await apiService.getProductAnalysisByRfid(cleanUid);

    if (result == null) {
      _state = ScanState.error;
      _errorMessage = "Failed to connect to Eco Decision Engine.";
      notifyListeners();
      return;
    }

    if (result['error'] != null && result['registered'] != true) {
      if (result['registered'] == false) {
        _state = ScanState.unregistered;
        notifyListeners();
        return;
      }
      _state = ScanState.error;
      _errorMessage = result['error'];
      notifyListeners();
      return;
    }

    try {
      _currentProduct = ProductModel.fromJson(result['product']);
      _currentAnalysis = EcoScoreAnalysisModel.fromJson(result['eco_score']);
      
      final rawAiInsight = result['ai_insight'] ?? result['gemini_insight'];
      if (rawAiInsight != null) {
        _currentGeminiInsight = GeminiInsightModel.fromJson(rawAiInsight);
      }
      
      _betterAlternative = result['better_alternative'];
      _state = ScanState.success;

      // Automatically log scan history
      apiService.recordScan(cleanUid);

      notifyListeners();
    } catch (e) {
      _state = ScanState.error;
      _errorMessage = "Error parsing product analysis data: $e";
      notifyListeners();
    }
  }

  void resetScan() {
    _state = ScanState.idle;
    _currentProduct = null;
    _currentAnalysis = null;
    _currentGeminiInsight = null;
    _betterAlternative = null;
    _scannedUid = null;
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _rfidSubscription?.cancel();
    super.dispose();
  }
}
