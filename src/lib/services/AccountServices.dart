import 'dart:convert';
import 'dart:ffi';

import 'package:first_app/configs/AppConfig.dart';
import 'package:first_app/services/base/ApiService.dart';

class AccountServices {
  final String baseUrl = AppConfig.BaseUrl;

  Future<List<dynamic>> getAccounts({String? month}) async {
    final uri = Uri.parse(
      '$baseUrl/api/v1/Account?page=1&size=10&isActive=true',
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

  Future<dynamic> getAccountById(String accountId) async {
    try {
      final response = await ApiService.http.get(
        Uri.parse('$baseUrl/api/v1/account/$accountId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];

        return data;
      } else {
        print('Erro ao buscar conta: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao buscar conta: $e');
    }
  }

  Future<void> createAccount({
    required String alias,
    required int type,
    required int bank,
    required double initialBalance, // Corrigido de Float para double
    required int color,
    required bool showBalanceOnHome,
  }) async {
    final url = Uri.parse('$baseUrl/api/v1/Account');

    final body = jsonEncode({
      'alias': alias,
      'type': type,
      'bank': bank,
      'initialBalance': initialBalance,
      'color': color,
      'showBalanceOnHome': showBalanceOnHome,
    });

    try {
      final response = await ApiService.http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Conta criada com sucesso!');
      } else {
        print('Erro ao criar conta: ${response.statusCode}');
        print('Resposta: ${response.body}');
        throw Exception('Erro ao criar conta: ${response.statusCode}');
      }
    } catch (e) {
      print('Exceção ao criar conta: $e');
      throw Exception('Erro ao criar conta');
    }
  }

  Future<void> updateAccount({
    required String id,
    required String alias,
    required int type,
    required int bank,
    required double initialBalance,
    required int color,
    required bool showBalanceOnHome,
  }) async {
    final url = Uri.parse('$baseUrl/api/v1/Account');
    final body = jsonEncode({
      'id': id,
      'alias': alias,
      'type': type,
      'bank': bank,
      'initialBalance': initialBalance,
      'color': color,
      'showBalanceOnHome': showBalanceOnHome,
    });

    try {
      final response = await ApiService.http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Conta criada com sucesso!');
      } else {
        print('Erro ao criar conta: ${response.statusCode}');
        print('Resposta: ${response.body}');
        throw Exception('Erro ao criar conta: ${response.statusCode}');
      }
    } catch (e) {
      print('Exceção ao criar conta: $e');
      throw Exception('Erro ao criar conta');
    }
  }
}
