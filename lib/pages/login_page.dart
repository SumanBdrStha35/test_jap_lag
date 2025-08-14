import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_app/db/DBHelper.dart';
import 'package:flutter_app/pages/main_page.dart';
import 'package:flutter_app/pages/signup_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

class LoginApp extends StatelessWidget {

  const LoginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Page',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final DBHelper _dbHelper = DBHelper();
  final formkey = GlobalKey<FormState>();
  bool isloggedin = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  // Create a logger instance
  final logger = Logger();

  Future<void> _initializeDatabase() async {
    await _dbHelper.database;
  }

  void _login() async {
    if (formkey.currentState!.validate()) {
      String email = _emailController.text.trim();
      logger.d(email.length);
      logger.d(email);
      String password = _passwordController.text;

      if (email.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter email and password')),
        );
        return;
      }
      if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid email address')),
        );
        return;
      }

      // Get user by email only
      var user = await _dbHelper.getUserByEmail(email);
      if (user != null) {
        String storedHashedPassword = user['password'];
        // Verify password using bcrypt
        bool passwordMatches = false;
        try {
          passwordMatches = BCrypt.checkpw(password, storedHashedPassword);
        } catch (e) {
          passwordMatches = false;
        }
          if (passwordMatches) {
          isloggedin = true;
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('userId', user['id'].toString()); // Store userId in SharedPreferences
          if (mounted){
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Login successful')),
            );
            // Navigate to the home page on successful login
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MainPage(userID: user['id'].toString())),
            );
          }          
          return;
        }
      }
      isloggedin = false;
      if (mounted) {
        _emailController.clear();
        _passwordController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid credentials')),
        );
      }      
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: formkey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'example123@gmail.com',
                  ),
                  focusNode: _emailFocusNode,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: _obscurePassword ? Colors.grey : Colors.blue,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  }, 
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _login,
                  child: const Text('Login'),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                  //   Navigator.push( 
                  //     context,
                  //     MaterialPageRoute(builder: (context) => const SignupPage()),
                  //   );
                  },
                  child: RichText(
                    text: TextSpan(
                      text: 'Don\'t have an account?',
                      style: const TextStyle(color: Colors.blue, fontSize: 16),
                      children: <TextSpan>[
                        TextSpan(
                          text: ' Sign up',
                          style: const TextStyle(color: Colors.lightBlue, fontWeight: FontWeight.bold),
                           recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SignupPage()),
                          );
                        },
                        ),
                      ],
                    ),
                  )
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}