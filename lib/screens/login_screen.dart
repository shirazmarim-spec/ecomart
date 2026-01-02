import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../constants/color_constants.dart';
import '../constants/translation_constants.dart';
import '../providers/providers.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import 'signup_screen.dart';
import 'admin_dashboard.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final ApiService api = ApiService();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';
  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSavedEmail();
  }

  Future<void> _loadSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('email');
    if (savedEmail != null && savedEmail.isNotEmpty) {
      setState(() {
        _emailController.text = savedEmail;
        _rememberMe = true;
      });
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await api.login(_emailController.text, _passwordController.text);

      final apiService = ApiService();
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/notifications/send'),
        headers: await apiService.getHeaders(withToken: true),
        body: jsonEncode({'message': 'Login successful! Welcome back!'}),
      );

      if (response.statusCode != 200) {
        debugPrint('Failed to send Telegram notification: ${response.body}');
      }

      if (_rememberMe) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', _emailController.text);
      }

      if (mounted) {
        final adminProvider = Provider.of<AdminProvider>(
          context,
          listen: false,
        );
        await adminProvider.checkAdmin();
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => adminProvider.isAdmin
                  ? const AdminDashboard()
                  : const HomeScreen(),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void _toggleRememberMe(bool? value) {
    setState(() {
      _rememberMe = value ?? false;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkTheme;
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isArabic = localeProvider.locale.languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          TranslationConstants.getString(context, 'login'),
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark
                ? ColorConstants.primaryDark
                : ColorConstants.primaryColor,
          ),
        ),
        backgroundColor: isDark
            ? ColorConstants.backgroundDark
            : ColorConstants.backgroundLight,
        actions: [
          IconButton(
            icon: Image.asset(
              isArabic
                  ? 'assets/images/united-arab-emirates.png'
                  : 'assets/images/united-states-of-america.png',
              width: 24,
              height: 24,
            ),
            onPressed: () => localeProvider.toggleLocale(),
          ),
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: isDark
                  ? ColorConstants.accentDark
                  : ColorConstants.accentColor,
            ),
            onPressed: themeProvider.toggleTheme,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                TranslationConstants.getString(context, 'login'),
                style: GoogleFonts.poppins(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? ColorConstants.primaryDark
                      : ColorConstants.primaryColor,
                ),
              ),
              Image.asset(
                'assets/animations/splash.jpg',
                height: 150,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: isDark
                          ? ColorConstants.greyDark
                          : ColorConstants.greyColor2,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: isDark
                          ? ColorConstants.greyDark
                          : ColorConstants.greyColor2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: isDark
                          ? ColorConstants.accentDark
                          : ColorConstants.accentColor,
                    ),
                  ),
                  hintText: TranslationConstants.getString(context, 'email'),
                  hintStyle: GoogleFonts.poppins(
                    color: isDark
                        ? ColorConstants.primaryDark
                        : ColorConstants.greyColor,
                  ),
                ),
                style: GoogleFonts.poppins(
                  color: isDark
                      ? ColorConstants.primaryDark
                      : ColorConstants.primaryColor,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return TranslationConstants.getString(
                      context,
                      'errorEmailPassword',
                    );
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return 'Invalid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: isDark
                          ? ColorConstants.greyDark
                          : ColorConstants.greyColor2,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: isDark
                          ? ColorConstants.greyDark
                          : ColorConstants.greyColor2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: isDark
                          ? ColorConstants.accentDark
                          : ColorConstants.accentColor,
                    ),
                  ),
                  hintText: TranslationConstants.getString(context, 'password'),
                  hintStyle: GoogleFonts.poppins(
                    color: isDark
                        ? ColorConstants.primaryDark
                        : ColorConstants.greyColor,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: isDark
                          ? ColorConstants.primaryDark
                          : ColorConstants.greyColor,
                    ),
                    onPressed: _togglePasswordVisibility,
                  ),
                ),
                style: GoogleFonts.poppins(
                  color: isDark
                      ? ColorConstants.primaryDark
                      : ColorConstants.primaryColor,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return TranslationConstants.getString(
                      context,
                      'errorEmailPassword',
                    );
                  }
                  if (value.length < 8) {
                    return 'Password must be at least 8 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    onChanged: _toggleRememberMe,
                    activeColor: isDark
                        ? ColorConstants.accentDark
                        : ColorConstants.accentColor,
                  ),
                  Text(
                    TranslationConstants.getString(context, 'rememberMe'),
                    style: GoogleFonts.poppins(
                      color: isDark
                          ? ColorConstants.primaryDark
                          : ColorConstants.greyColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? ColorConstants.accentDark
                        : ColorConstants.accentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          TranslationConstants.getString(
                            context,
                            'login',
                          ).toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignupScreen(),
                    ),
                  );
                },
                child: Text(
                  TranslationConstants.getString(context, 'newUserSignUp'),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? ColorConstants.primaryDark
                        : ColorConstants.greyColor,
                  ),
                ),
              ),
              if (_errorMessage.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? ColorConstants.errorDark.withValues(alpha: 0.1)
                        : ColorConstants.errorColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark
                          ? ColorConstants.errorDark
                          : ColorConstants.errorColor,
                    ),
                  ),
                  child: Text(
                    _errorMessage,
                    style: GoogleFonts.poppins(
                      color: isDark
                          ? ColorConstants.errorDark
                          : ColorConstants.errorColor,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
