import 'package:first_app/configs/AppConfig.dart';
import 'package:first_app/services/base/ApiService.dart' show ApiService;
import 'dart:convert';

class CategoryServices {
  final String baseUrl = AppConfig.BaseUrl;

  Future<List<dynamic>> fetchItems() async {
    final uri = Uri.parse(
      '$baseUrl/api/v1/Category?page=1&size=10&isActive=true',
    );

    final response = await ApiService.http.get(
      uri,
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      final List<dynamic> data = json['data'] ?? [];
      return data;
    } else {
      print('Erro ${response.statusCode}: ${response.body}');
      throw Exception('Erro ao buscar categorias: ${response.statusCode}');
    }
  }

  Future<String?> createCategory({
    required int type,
    required String name,
    required int color,
    required String icon,
  }) async {
    final url = Uri.parse('$baseUrl/api/v1/Category');
    final body = jsonEncode({
      'type': type,
      'name': name,
      'color': color,
      'icon': icon,
    });

    final response = await ApiService.http.post(
      url,
      headers: {'Content-Type': 'application/json', 'accept': '*/*'},
      body: body,
    );

    if (response.statusCode == 200) {
      try {
        final decoded = jsonDecode(response.body);
        final id = decoded['data']?['id'];
        return id?.toString();
      } catch (e) {
        print('Erro ao decodificar JSON: $e');
        return null;
      }
    } else {
      print('Erro ao criar categoria: ${response.statusCode}');
      print(response.body);
      return null;
    }
  }

  Future<void> updateCategory({
    required String id,
    required int type,
    required String name,
    required int color,
    required String icon,
  }) async {
    final url = Uri.parse('$baseUrl/api/v1/Category');
    final body = jsonEncode({
      'id': id,
      'type': type,
      'name': name,
      'color': color,
      'icon': icon,
    });

    final response = await ApiService.http.put(
      url,
      headers: {'Content-Type': 'application/json', 'accept': '*/*'},
      body: body,
    );

    if (response.statusCode == 200) {
      try {
        final decoded = jsonDecode(response.body);
        print(decoded);
      } catch (e) {
        print('Erro ao decodificar JSON: $e');
        return null;
      }
    } else {
      print('Erro ao criar categoria: ${response.statusCode}');
      print(response.body);
      return null;
    }
  }

  Future<String?> createSubCategory({
    required String id,
    required String name,
  }) async {
    final url = Uri.parse('$baseUrl/api/v1/Category/sub/$id');
    final body = jsonEncode({'name': name});

    final response = await ApiService.http.post(
      url,
      headers: {'Content-Type': 'application/json', 'accept': '*/*'},
      body: body,
    );

    if (response.statusCode == 200) {
      try {
        final decoded = jsonDecode(response.body);
        final id = decoded['data']?['id'];
        return id?.toString();
      } catch (e) {
        print('Erro ao decodificar JSON: $e');
        return null;
      }
    } else {
      print('Erro ao criar categoria: ${response.statusCode}');
      print(response.body);
      return null;
    }
  }

  Future<void> updateSubCategory({
    required String id,
    required String subId,
    required String name,
  }) async {
    final url = Uri.parse('$baseUrl/api/v1/Category/sub/$id');
    final body = jsonEncode({'id': subId, 'name': name});

    final response = await ApiService.http.put(
      url,
      headers: {'Content-Type': 'application/json', 'accept': '*/*'},
      body: body,
    );

    if (response.statusCode == 200) {
      try {
        final decoded = jsonDecode(response.body);
        print(decoded);
      } catch (e) {
        print('Erro ao decodificar JSON: $e');        
      }
    } else {
      print('Erro ao criar categoria: ${response.statusCode}');
      print(response.body);      
    }
  }
}
