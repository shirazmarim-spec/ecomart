import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import '../constants/color_constants.dart';
import '../constants/translation_constants.dart';
import '../providers/providers.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _picker = ImagePicker();
  File? _image;
  List<dynamic> categories = [];
  int? _selectedCategoryId;
  bool _isLoading = false;
  String _errorMessage = '';
  final ApiService api = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await api.client.get(
        Uri.parse('${ApiService.baseUrl}/categories'),
        headers: await api.getHeaders(),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          categories = data['data'] ?? [];
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _addProduct() async {
    if (!_formKey.currentState!.validate() || _selectedCategoryId == null) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiService.baseUrl}/products'),
      );
      request.headers.addAll(await api.getHeaders(withToken: true));
      request.fields['name'] = _nameController.text;
      request.fields['description'] = _descriptionController.text;
      request.fields['price'] = _priceController.text;
      request.fields['stock'] = _stockController.text;
      request.fields['category_id'] = _selectedCategoryId.toString();

      if (_image != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', _image!.path),
        );
      }

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final data = json.decode(responseData);

      if (response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                TranslationConstants.getString(context, 'productAdded'),
              ),
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage =
                data['message'] ??
                TranslationConstants.getString(context, 'addProductFailed');
          });
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

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
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
            TranslationConstants.getString(context, 'addProduct'),
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
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: TranslationConstants.getString(
                        context,
                        'name',
                      ),
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
                          'pleaseEnterName',
                        );
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: TranslationConstants.getString(
                        context,
                        'description',
                      ),
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
                    ),
                    maxLines: 3,
                    style: GoogleFonts.poppins(
                      color: isDark
                          ? ColorConstants.primaryDark
                          : ColorConstants.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _priceController,
                    decoration: InputDecoration(
                      labelText: TranslationConstants.getString(
                        context,
                        'price',
                      ),
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
                    ),
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.poppins(
                      color: isDark
                          ? ColorConstants.primaryDark
                          : ColorConstants.primaryColor,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return TranslationConstants.getString(
                          context,
                          'pleaseEnterPrice',
                        );
                      }
                      if (double.tryParse(value) == null) {
                        return TranslationConstants.getString(
                          context,
                          'invalidPrice',
                        );
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _stockController,
                    decoration: InputDecoration(
                      labelText: TranslationConstants.getString(
                        context,
                        'stock',
                      ),
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
                    ),
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.poppins(
                      color: isDark
                          ? ColorConstants.primaryDark
                          : ColorConstants.primaryColor,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return TranslationConstants.getString(
                          context,
                          'pleaseEnterStock',
                        );
                      }
                      if (int.tryParse(value) == null) {
                        return TranslationConstants.getString(
                          context,
                          'invalidStock',
                        );
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    initialValue: _selectedCategoryId,
                    decoration: InputDecoration(
                      labelText: TranslationConstants.getString(
                        context,
                        'category',
                      ),
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
                    ),
                    items: categories.map((category) {
                      return DropdownMenuItem<int>(
                        value: category['id'],
                        child: Text(
                          category['name'],
                          style: GoogleFonts.poppins(
                            color: isDark
                                ? ColorConstants.primaryDark
                                : ColorConstants.primaryColor,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategoryId = value;
                      });
                    },
                    validator: (value) => value == null
                        ? TranslationConstants.getString(
                            context,
                            'pleaseSelectCategory',
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _pickImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? ColorConstants.accentDark
                          : ColorConstants.accentColor,
                    ),
                    child: Text(
                      _image == null
                          ? TranslationConstants.getString(context, 'pickImage')
                          : TranslationConstants.getString(
                              context,
                              'imageSelected',
                            ),
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                  ),
                  if (_image != null) ...[
                    const SizedBox(height: 8),
                    Image.file(_image!, height: 100),
                  ],
                  const SizedBox(height: 24),
                  if (_errorMessage.isNotEmpty)
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
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _addProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark
                            ? ColorConstants.accentDark
                            : ColorConstants.accentColor,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              TranslationConstants.getString(
                                context,
                                'addProduct',
                              ),
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
