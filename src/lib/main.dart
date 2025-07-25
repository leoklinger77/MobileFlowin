import 'package:first_app/screens/onbarding/signin/SignInPage.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // necessário para operações async antes do runApp
  await initializeDateFormatting(
    'pt_BR',
    null,
  ); // inicializa o suporte ao locale pt_BR
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        brightness: Brightness.light,
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: SignInPage(),
    );
  }
}
