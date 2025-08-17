import 'package:flutter/material.dart';
import 'package:flutter_app/db/DBHelper.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class SignupPageUpdate extends StatefulWidget {
  const SignupPageUpdate({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPageUpdate> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final DBHelper _dbHelper = DBHelper();

  bool _obscurePassword = true;
  bool _isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _addressFocusNode = FocusNode();

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  bool _showContent = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _triggerAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
    ));
  }

  void _triggerAnimations() {
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _showContent = true;
      });
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _phoneFocusNode.dispose();
    _addressFocusNode.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final phone = _phoneController.text.trim();
      final address = _addressController.text.trim();
      final now = DateTime.now().toIso8601String();

      try {
        // Check if email already exists
        final existingUsers = await _dbHelper.getUserByEmail(email.trim());
        if (existingUsers != null && existingUsers.isNotEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('This email is already registered. Please use a different email or login.'),
                backgroundColor: Colors.red,
              ),
            );
          }
          setState(() {
            _isLoading = false;
          });
          return;
        }

        // Hash the password using bcrypt
        final hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());

        final userData = {
          'name': name,
          'email': email,
          'password': hashedPassword,
          'phone': phone,
          'address': address,
          'created_at': now,
          'updated_at': now,
          'profile_image': _imageFile?.path,
        };

        await _dbHelper.insert('users', userData);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Signup successful! Please login.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error during signup: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String labelText,
    required FocusNode focusNode,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    VoidCallback? onSubmitted,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: 'Enter your $labelText',
          prefixIcon: Icon(
            _getIconForField(labelText),
            color: Colors.blue,
          ),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        textInputAction: TextInputAction.next,
        onFieldSubmitted: (_) => onSubmitted?.call(),
      ),
    );
  }

  IconData _getIconForField(String labelText) {
    switch (labelText.toLowerCase()) {
      case 'name':
        return Icons.person_outline;
      case 'email':
        return Icons.email_outlined;
      case 'password':
        return Icons.lock_outline;
      case 'phone':
        return Icons.phone_outlined;
      case 'address':
        return Icons.location_on_outlined;
      default:
        return Icons.text_fields;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade50,
              Colors.blue.shade100,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(32.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              spreadRadius: 5,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 20),
                              AnimatedOpacity(
                                opacity: _showContent ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 600),
                                child: const Text(
                                  'Create Account',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              AnimatedOpacity(
                                opacity: _showContent ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 800),
                                child: Text(
                                  'Sign up to get started',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                              GestureDetector(
                                onTap: _pickImage,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey[300],
                                    border: Border.all(
                                      color: Colors.blue,
                                      width: 3,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: _imageFile != null
                                        ? Image.file(
                                            _imageFile!,
                                            fit: BoxFit.cover,
                                            width: 100,
                                            height: 100,
                                          )
                                        : const Icon(
                                            Icons.camera_alt,
                                            size: 40,
                                            color: Colors.white,
                                          ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              _buildAnimatedTextField(
                                controller: _nameController,
                                labelText: 'Name',
                                focusNode: _nameFocusNode,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your name';
                                  }
                                  return null;
                                },
                                onSubmitted: () {
                                  FocusScope.of(context).requestFocus(_emailFocusNode);
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildAnimatedTextField(
                                controller: _emailController,
                                labelText: 'Email',
                                focusNode: _emailFocusNode,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
                                    return 'Please enter a valid email address';
                                  }
                                  return null;
                                },
                                onSubmitted: () {
                                  FocusScope.of(context).requestFocus(_passwordFocusNode);
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildAnimatedTextField(
                                controller: _passwordController,
                                labelText: 'Password',
                                focusNode: _passwordFocusNode,
                                obscureText: _obscurePassword,
                                suffixIcon: IconButton(
                                  icon: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    child: Icon(
                                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                      key: ValueKey<bool>(_obscurePassword),
                                      color: _obscurePassword ? Colors.grey : Colors.blue,
                                    ),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~])[A-Za-z\d!@#\$&*~]{8,}$').hasMatch(value)) {
                                    return 'Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character';
                                  }
                                  return null;
                                },
                                onSubmitted: () {
                                  FocusScope.of(context).requestFocus(_phoneFocusNode);
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildAnimatedTextField(
                                controller: _phoneController,
                                labelText: 'Phone',
                                focusNode: _phoneFocusNode,
                                keyboardType: TextInputType.phone,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your phone number';
                                  }
                                  if (!RegExp(r'^\+?[0-9]{7,15}$').hasMatch(value)) {
                                    return 'Please enter a valid phone number';
                                  }
                                  return null;
                                },
                                onSubmitted: () {
                                  FocusScope.of(context).requestFocus(_addressFocusNode);
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildAnimatedTextField(
                                controller: _addressController,
                                labelText: 'Address',
                                focusNode: _addressFocusNode,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your address';
                                  }
                                  return null;
                                },
                                onSubmitted: () {
                                  _addressFocusNode.unfocus();
                                },
                              ),
                              const SizedBox(height: 32),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _signup,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    elevation: 5,
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : const Text(
                                          'Sign Up',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              AnimatedOpacity(
                                opacity: _showContent ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 1000),
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: RichText(
                                    text: const TextSpan(
                                      text: 'Already have an account? ',
                                      style: TextStyle(color: Colors.grey, fontSize: 14),
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: 'Login',
                                          style: TextStyle(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
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
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
