import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../constants/color_constants.dart';
import '../constants/translation_constants.dart';
import '../providers/providers.dart';
import 'package:provider/provider.dart';
import 'login_screen.dart';
import 'admin_dashboard.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService api = ApiService();
  Map<String, dynamic> userData = {};
  bool _isLoading = true;
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _telegramChatIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final data = await api.getUser();
      if (mounted) {
        setState(() {
          userData = data;
          _nameController.text = data['name'] ?? '';
          _emailController.text = data['email'] ?? '';
          _telegramChatIdController.text =
              data['telegram_chat_id']?.toString() ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading profile: $e')));
      }
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final data = await api.updateUser({
        'name': _nameController.text,
        'email': _emailController.text,
      });

      final apiService = ApiService();
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/profile/update-telegram'),
        headers: await apiService.getHeaders(withToken: true),
        body: jsonEncode({
          'telegram_chat_id': _telegramChatIdController.text.trim(),
        }),
      );

      if (response.statusCode != 200) {
        debugPrint('Failed to update Telegram ID: ${response.body}');
      }

      if (mounted) {
        setState(() {
          userData = data;
          userData['telegram_chat_id'] = _telegramChatIdController.text.trim();
          _isEditing = false;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile & Telegram linked successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Update failed: $e')));
      }
    }
  }

  Future<void> _logout() async {
    await api.logout();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _telegramChatIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkTheme;
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isArabic = localeProvider.locale.languageCode == 'ar';

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            TranslationConstants.getString(context, 'profile'),
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? ColorConstants.primaryDark
                  : ColorConstants.primaryColor,
            ),
          ),
          backgroundColor: isDark
              ? ColorConstants.backgroundDark
              : ColorConstants.backgroundLight,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: isDark
                            ? ColorConstants.accentDark
                            : ColorConstants.accentColor,
                        child: Text(
                          userData['name']?[0] ?? '?',
                          style: const TextStyle(
                            fontSize: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (_isEditing) ...[
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  labelText: TranslationConstants.getString(
                                    context,
                                    'name',
                                  ),
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) => value?.isEmpty ?? true
                                    ? 'Please enter name'
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  labelText: TranslationConstants.getString(
                                    context,
                                    'email',
                                  ),
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) => value?.isEmpty ?? true
                                    ? 'Invalid email'
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _telegramChatIdController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Telegram Chat ID',
                                  hintText: 'From @userinfobot',
                                  border: OutlineInputBorder(),
                                  prefixIcon: const Icon(Icons.telegram),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Enter your Telegram Chat ID';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: _updateProfile,
                                      child: Text(
                                        TranslationConstants.getString(
                                          context,
                                          'save',
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          setState(() => _isEditing = false),
                                      child: Text(
                                        TranslationConstants.getString(
                                          context,
                                          'cancel',
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _infoRow('Name', userData['name']),
                                _infoRow('Email', userData['email']),
                                _infoRow('Role', userData['role']),
                                _infoRow(
                                  'Telegram Chat ID',
                                  userData['telegram_chat_id'] ?? 'Not linked',
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        if (userData['role'] == 'admin')
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AdminDashboard(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.admin_panel_settings),
                            label: Text(
                              TranslationConstants.getString(
                                context,
                                'adminDashboard',
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                            ),
                          ),

                        if (userData['role'] == 'admin')
                          const SizedBox(height: 16),

                        ElevatedButton.icon(
                          onPressed: () => setState(() => _isEditing = true),
                          icon: const Icon(Icons.edit),
                          label: Text(
                            TranslationConstants.getString(
                              context,
                              'editProfile',
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _logout,
                          icon: const Icon(Icons.logout),
                          label: Text(
                            TranslationConstants.getString(context, 'logout'),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          Text(value ?? '-', style: GoogleFonts.poppins()),
        ],
      ),
    );
  }
}
