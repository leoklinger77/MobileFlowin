import 'package:first_app/services/ProfileServices.dart';
import 'package:first_app/services/UserSession.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:first_app/screens/onbarding/signup/SignUp.dart';
import 'package:first_app/screens/shared/MenuPage.dart';
import 'package:first_app/services/AuthenticationServices.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPagePageState();
}

class _SignInPagePageState extends State<SignInPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthenticationServices();
  final LocalAuthentication auth = LocalAuthentication();

  bool _isLoading = false;
  bool _useBiometrics = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricPreference();
  }

  Future<void> _checkBiometricPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('biometric_email');
    final enabled = prefs.getBool('use_biometrics') ?? false;

    if (email != null && enabled) {
      setState(() {
        _emailController.text = email;
        _useBiometrics = true;
      });
    }
  }

  Future<void> _handleSignin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showSnackbar('Por favor, preencha todos os campos');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Timeout de 10 segundos
      await _authService
          .signin(email, password)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Tempo de resposta esgotado'),
          );

      final profileService = ProfileServices();
      final user = await profileService.getUser();

      print('Usuário logado: ${user['firstName']} (${user['email']})');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', email);
      await prefs.setString('password', password);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login realizado com sucesso!')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MenuPage()),
      );
    } catch (e) {
      if (!mounted) return;
      _showSnackbar('Usuário ou senha inválida');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<bool> _askToEnableBiometrics() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Deseja usar biometria?'),
            content: const Text(
              'Na próxima vez você poderá entrar com sua digital ou rosto.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Não'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Sim'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _authenticateWithBiometrics() async {
    try {
      final available =
          await auth.canCheckBiometrics && await auth.isDeviceSupported();

      if (!available) {
        _showSnackbar('Biometria não disponível');
        return;
      }

      final authenticated = await auth.authenticate(
        localizedReason: 'Use biometria para entrar',
        options: const AuthenticationOptions(
          biometricOnly: false, // Permite fallback (PIN, padrão, etc.)
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        // Obter credenciais salvas
        final prefs = await SharedPreferences.getInstance();
        final email = prefs.getString('email');
        final password = prefs.getString('password');

        if (email != null && password != null) {
          await _authService.signin(
            email,
            password,
          ); // Aqui faz o request da API
          _goToMenu();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nenhum usuário salvo para login biométrico'),
            ),
          );
        }
      } else {
        _showSnackbar('Autenticação falhou');
      }
    } catch (e) {
      _showSnackbar('Erro: ${e.toString()}');
    }
  }

  void _goToMenu() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MenuPage()),
    );
  }

  void _showSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _resetBiometricPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('use_biometrics');
    await prefs.remove('biometric_email');
    setState(() => _useBiometrics = false);
    _passwordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 15),
              Text(
                'Bem-vindo de volta 👋',
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Gerencie suas finanças com facilidade.',
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.black45),
              ),
              const SizedBox(height: 30),
              _buildTextField(
                controller: _emailController,
                hint: 'Email',
                icon: Icons.email_outlined,
                isPassword: false,
                enabled: !_useBiometrics,
              ),
              const SizedBox(height: 20),
              if (!_useBiometrics)
                _buildTextField(
                  controller: _passwordController,
                  hint: 'Senha',
                  icon: Icons.lock_outline,
                  isPassword: true,
                ),
              if (!_useBiometrics) const SizedBox(height: 12),
              if (!_useBiometrics)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      'Esqueceu a senha?',
                      style: GoogleFonts.poppins(
                        color: Colors.blueGrey,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              if (_useBiometrics)
                ElevatedButton.icon(
                  icon: const Icon(Icons.fingerprint),
                  label: const Text("Entrar com biometria"),
                  onPressed: _authenticateWithBiometrics,
                  style: _buttonStyle(Colors.white, Colors.black),
                ),
              if (_useBiometrics)
                TextButton(
                  onPressed: _resetBiometricPrefs,
                  child: const Text('Trocar usuário'),
                ),
              if (!_useBiometrics)
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSignin,
                  style: _buttonStyle(const Color(0xFF3366FF), Colors.white),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          'Entrar',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text("ou"),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 24),
              SignInButton(
                Buttons.Google,
                text: "Entrar com o Google",
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onPressed: () {
                  // TODO: Implementar login com Google
                },
              ),
              const SizedBox(height: 32),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SignUpPage(),
                      ),
                    );
                  },
                  child: Text.rich(
                    TextSpan(
                      text: 'Não tem uma conta? ',
                      style: GoogleFonts.poppins(color: Colors.black54),
                      children: [
                        TextSpan(
                          text: 'Criar agora',
                          style: const TextStyle(
                            color: Color(0xFF3366FF),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isPassword,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      enabled: enabled,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black12),
        ),
      ),
      style: GoogleFonts.poppins(),
    );
  }

  ButtonStyle _buttonStyle(Color bgColor, Color fgColor) {
    return ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 16),
      backgroundColor: bgColor,
      foregroundColor: fgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
