import 'dart:convert';

import 'package:first_app/configs/AppConfig.dart';
import 'package:first_app/services/base/ApiService.dart';

class TransactionServices {
  final String baseUrl = AppConfig.BaseUrl;

  Future<Map<String, dynamic>> getListTransaction({
  required String accountId,
  required int type,
  required DateTime start,
  required DateTime end,
  int page = 1,
  int size = 100,
}) async {
  final queryParameters = {
    'page': page.toString(),
    'size': size.toString(),
    'accountId': accountId,
    'start': start.toIso8601String().substring(0, 10),
    'end': end.toIso8601String().substring(0, 10),
    'type': type.toString(),
  };

  final url = Uri.parse('$baseUrl/api/v1/Transaction')
      .replace(queryParameters: queryParameters);

  try {
    final response = await ApiService.http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final result = response.body;
      final data = jsonDecode(result);

      return {
        'transactions': data['data']['data'], // lista de transações
        'endOfMonthBalance': data['data']['endOfMonthBalance'],
        'balanceOfTheMonth': data['data']['balanceOfTheMonth'],
      };
    } else {
      throw Exception('Erro ao carregar transações: ${response.statusCode}');
    }
  } catch (e) {
    print('Erro ao buscar transações: $e');
    return {
      'transactions': [],
      'endOfMonthBalance': 0,
      'balanceOfTheMonth': 0,
    };
  }
}


  Future<String?> Deposit({
    required int type,
    required String name,
    required int color,
    required String icon,
  }) async {
    final url = Uri.parse('$baseUrl/api/v1/Transaction');
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

  Future<void> withdraw({
    required String accountId,
    required String categoryId,
    String? subCategoryId,
    required double value,
    required DateTime date,
    required String description,
    required String recurrence,
    required int totalOccurrences,
    required bool isFixed,
    required bool isEfetivado,
  }) async {
    final url = Uri.parse('$baseUrl/api/v1/Transaction/Withdraw');

    final body = jsonEncode({
      'accountId': accountId,
      'categoryId': categoryId,
      'subCategoryId': subCategoryId,
      'value': value,
      'date': date.toIso8601String(),
      'description': description,
      'recurrence': recurrence,
      'totalOccurrences': totalOccurrences,
      'isFixed': isFixed,
      'Situation': isEfetivado == false ? 0 : 1,
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
        print('Transação de retirada criada com sucesso!');
      } else {
        print('Erro ao criar retirada: ${response.statusCode}');
        print('Resposta: ${response.body}');
        throw Exception('Erro ao criar retirada: ${response.statusCode}');
      }
    } catch (e) {
      print('Exceção ao criar retirada: $e');
      throw Exception('Erro ao criar retirada');
    }
  }

  Future<void> deposit({
    required String accountId,
    required String categoryId,
    String? subCategoryId,
    required double value,
    required DateTime date,
    required String description,
    required String recurrence,
    required int totalOccurrences,
    required bool isFixed,
    required bool isEfetivado,
  }) async {
    final url = Uri.parse('$baseUrl/api/v1/Transaction/Deposit');

    final body = jsonEncode({
      'accountId': accountId,
      'categoryId': categoryId,
      'subCategoryId': subCategoryId,
      'value': value,
      'date': date.toIso8601String(),
      'description': description,
      'recurrence': recurrence,
      'totalOccurrences': totalOccurrences,
      'isFixed': isFixed,
      'Situation': isEfetivado == false ? 0 : 1,
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
        print('Transação de retirada criada com sucesso!');
      } else {
        print('Erro ao criar retirada: ${response.statusCode}');
        print('Resposta: ${response.body}');
        throw Exception('Erro ao criar retirada: ${response.statusCode}');
      }
    } catch (e) {
      print('Exceção ao criar retirada: $e');
      throw Exception('Erro ao criar retirada');
    }
  }
}
