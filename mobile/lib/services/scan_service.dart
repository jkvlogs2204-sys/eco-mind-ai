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
  late final ApiService apiService;
  BluetoothService? _bluetoothService;
  StreamSubscription<String>? _rfidSubscription;

  ScanState _state = ScanState.idle;
  ProductModel? _currentProduct;
  EcoScoreAnalysisModel? _currentAnalysis;
  GeminiInsightModel? _currentGeminiInsight;
  Map<String, dynamic>? _betterAlternative;
  String? _scannedUid;
  String? _errorMessage;

  List<dynamic> _history = [];
  List<dynamic> get history => _history;

  // Duplicate Scan Cooldown Protection
  String? _lastScannedUid;
  DateTime? _lastScanTime;
  final Duration _debounceCooldown = const Duration(milliseconds: 2500);

  ScanService([dynamic arg1, dynamic arg2]) {
    if (arg1 is ApiService) {
      apiService = arg1;
    } else if (arg1 is BluetoothService) {
      _bluetoothService = arg1;
      apiService = arg2 is ApiService ? arg2 : ApiService();
      attachBluetoothService(_bluetoothService!);
    } else {
      apiService = ApiService();
    }
  }

  ScanService.withApi({required this.apiService, BluetoothService? bluetoothService}) {
    if (bluetoothService != null) {
      attachBluetoothService(bluetoothService);
    }
  }

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

    final now = DateTime.now();
    if (_lastScannedUid == cleanUid && _lastScanTime != null) {
      if (now.difference(_lastScanTime!) < _debounceCooldown) {
        return;
      }
    }

    _lastScannedUid = cleanUid;
    _lastScanTime = now;
    processRfidScan(cleanUid);
  }

  Future<void> fetchHistory() async {
    try {
      _history = await apiService.getScanHistory();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> analyzeProductByRfid(String uid) => processRfidScan(uid);

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
