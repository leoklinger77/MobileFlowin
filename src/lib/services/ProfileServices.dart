import 'dart:convert';
import 'package:first_app/configs/AppConfig.dart';
import 'package:first_app/services/UserSession.dart';
import 'package:first_app/services/base/ApiService.dart';

class ProfileServices {
  final String baseUrl = AppConfig.BaseUrl;

  Future<dynamic> getUser() async {
    final uri = Uri.parse('$baseUrl/api/v1/Profile');

    final response = await ApiService.http.get(
      uri,
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      UserSession().email = json['data']['email'];
      UserSession().firstName = json['data']['firstName'];      

      return json['data'] ?? [];
    } else {
      print('Erro ${response.statusCode}: ${response.body}');
      throw Exception('Erro ao buscar categorias: ${response.statusCode}');
    }
  }
}
