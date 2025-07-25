// api_service.dart
import 'package:first_app/services/base/Interceptor.dart';
import 'package:http_interceptor/http_interceptor.dart';

class ApiService {
  static final http = InterceptedClient.build(
    interceptors: [Interceptor()],
    requestTimeout: const Duration(seconds: 30),
  );
}
