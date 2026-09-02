import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/eco_score.dart';
import '../models/scan_history.dart';
import '../models/rfid_tag.dart';

class ApiService {
  String baseUrl;

  ApiService({this.baseUrl = "http://10.0.2.2:8000"});

  void updateBaseUrl(String newUrl) {
    if (newUrl.endsWith("/")) {
      baseUrl = newUrl.substring(0, newUrl.length - 1);
    } else {
      baseUrl = newUrl;
    }
  }

  // --- Product & Scan Analysis ---

  Future<Map<String, dynamic>?> getProductAnalysisByRfid(String rfidUid) async {
    final cleanUid = rfidUid.trim().toUpperCase().replaceAll(' ', '').replaceAll(':', '');
    final url = Uri.parse('$baseUrl/api/products/rfid/$cleanUid');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 404) {
        final errJson = json.decode(response.body);
        return {
          'registered': false,
          'error': 'Product Not Found',
          'rfid_uid': cleanUid,
          'message': errJson['detail']?['message'] ?? 'RFID tag is not registered.'
        };
      } else {
        return {'error': 'Server Error (${response.statusCode})'};
      }
    } catch (e) {
      return {'error': 'Connection Failed', 'details': e.toString()};
    }
  }

  // --- RFID Tag Management ---

  Future<List<RFIDTagModel>> getRFIDTags({String? query}) async {
    final uri = Uri.parse('$baseUrl/api/rfid${query != null ? '?query=$query' : ''}');
    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        final List<dynamic> list = json.decode(res.body);
        return list.map((item) => RFIDTagModel.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> registerRFIDTag(String uid, {int? productId}) async {
    final uri = Uri.parse('$baseUrl/api/rfid');
    try {
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'rfid_uid': uid, 'product_id': productId}),
      );
      if (res.statusCode == 201) {
        return {'success': true, 'data': json.decode(res.body)};
      } else {
        final err = json.decode(res.body);
        return {'success': false, 'error': err['detail']?['error'] ?? 'Registration failed'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<bool> assignRFIDTag(String uid, int productId) async {
    final uri = Uri.parse('$baseUrl/api/rfid/$uid/assign');
    try {
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'product_id': productId}),
      );
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> unassignRFIDTag(String uid) async {
    final uri = Uri.parse('$baseUrl/api/rfid/$uid/unassign');
    try {
      final res = await http.post(uri);
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteRFIDTag(String uid) async {
    final uri = Uri.parse('$baseUrl/api/rfid/$uid');
    try {
      final res = await http.delete(uri);
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // --- Product Management ---

  Future<List<ProductModel>> getProducts({String? query}) async {
    final uri = Uri.parse('$baseUrl/api/products${query != null ? '?query=$query' : ''}');
    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        final List<dynamic> list = json.decode(res.body);
        return list.map((item) => ProductModel.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> createProduct(Map<String, dynamic> data) async {
    final uri = Uri.parse('$baseUrl/api/products');
    try {
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      return res.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateProduct(int id, Map<String, dynamic> data) async {
    final uri = Uri.parse('$baseUrl/api/products/$id');
    try {
      final res = await http.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteProduct(int id) async {
    final uri = Uri.parse('$baseUrl/api/products/$id');
    try {
      final res = await http.delete(uri);
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // --- Scan History ---

  Future<bool> recordScan(String rfidUid, {String userId = "default_user"}) async {
    final url = Uri.parse('$baseUrl/api/scan');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'rfid_uid': rfidUid,
          'user_id': userId,
        }),
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<List<ScanHistoryItem>> getScanHistory({String userId = "default_user"}) async {
    final url = Uri.parse('$baseUrl/api/history/$userId');
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => ScanHistoryItem.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
