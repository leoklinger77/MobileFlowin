import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:first_app/configs/AppConfig.dart';
import 'package:http/http.dart' as http;

class AuthenticationServices {
  final String baseUrl = AppConfig.BaseUrl;
  final secureStorage = FlutterSecureStorage();
  Future<String> signin(String email, String password) async {
    final url = Uri.parse('$baseUrl/api/v1/Onboarding/signin');

    final headers = {
      'accept': 'application/json',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({'email': email, 'password': password});

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      final accessToken = json['data']['access_token'];
      final refreshToken = json['data']['access_token'];
      await secureStorage.write(key: 'access_token', value: accessToken);
      await secureStorage.write(key: 'refres_token', value: refreshToken);

      return accessToken;
    } else {
      throw Exception('Erro ao fazer login: ${response.statusCode}');
    }
  }

  Future<void> signup(String email, String password, String name) async {
    final url = Uri.parse('$baseUrl/api/v1/Onboarding/signup');

    final headers = {'accept': '*/*', 'Content-Type': 'application/json'};

    final body = jsonEncode({
      'email': email,
      'password': password,
      'name': name,
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Cadastro realizado com sucesso!');
    } else {
      throw Exception(
        'Erro ao cadastrar usuário: ${response.statusCode}\n${response.body}',
      );
    }
  }

  Future<void> refreshToken() async {
    final url = Uri.parse('$baseUrl/api/v1/Onboarding/refresh');
    final headers = {'accept': '*/*', 'Content-Type': 'application/json'};
    final code = await secureStorage.read(key: 'access_token');

    final body = jsonEncode({'code': code});

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      final accessToken = json['data']['access_token'];
      await secureStorage.delete(key: 'access_token');
      await secureStorage.write(key: 'access_token', value: accessToken);
      
      final refreshToken = json['data']['access_token'];
      await secureStorage.delete(key: 'refres_token');
      await secureStorage.write(key: 'refres_token', value: refreshToken);

      return accessToken;
    } else {
      throw Exception('Erro ao fazer login: ${response.statusCode}');
    }
  }
}
