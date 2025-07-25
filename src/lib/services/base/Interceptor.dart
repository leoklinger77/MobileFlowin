import 'package:first_app/services/AuthenticationServices.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class Interceptor implements InterceptorContract {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  Future<RequestData> interceptRequest({required RequestData data}) async {
    final token = await _secureStorage.read(key: 'access_token');

    if (token != null) {
      data.headers['Authorization'] = 'Bearer $token';
    }
    return data;
  }

  @override
  Future<ResponseData> interceptResponse({required ResponseData data}) async {
    if (data.statusCode == 401) {
      await _handleRefreshToken();

      final newToken = await _secureStorage.read(key: 'access_token');
      final originalRequest = data.request!;

      // Convert Method enum to String
      final method = originalRequest.method.name;

      final updatedRequest =
          http.Request(method, Uri.parse(originalRequest.url))
            ..headers.addAll(originalRequest.headers)
            ..headers['Authorization'] = 'Bearer $newToken';

      if (originalRequest.body != null) {
        updatedRequest.body = originalRequest.body;
      }

      final streamedResponse = await http.Client().send(updatedRequest);
      final newResponse = await http.Response.fromStream(streamedResponse);

      return ResponseData.fromHttpResponse(newResponse);
    }
    return data; // Pode adicionar lógica de logging ou erro aqui, se quiser
  }

  Future<void> _handleRefreshToken() async {
    try {
      final service = AuthenticationServices();
      await service.refreshToken();
    } catch (e) {
      print("Erro ao tentar renovar token: $e");
    }
  }
}
