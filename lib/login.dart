import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nutria/home.dart';
import 'package:nutria/onboarding.dart';
import 'package:nutria/services/auth.dart';
import 'package:nutria/services/utilities.dart';
import 'package:nutria/sign_up.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  AuthService authService = AuthService();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _showPassword = false;
  late Box _fontSize;

  @override
  void initState() {
    super.initState();
    _fontSize = Hive.box('font_size');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: ListView(
          children: [
            const SizedBox(height: 60),
            logo(150, 150),
            questionWidget("Login with Nutria"),
            Padding(
              padding: const EdgeInsets.fromLTRB(40.0, 15, 40, 15),
              child: TextFormField(
                controller: emailController,
                style: GoogleFonts.dmSans(
                    fontSize: _fontSize.get('x-large'), color: subtext),
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 0, 40, 10.0),
              child: TextFormField(
                controller: passwordController,
                style: GoogleFonts.dmSans(
                    fontSize: _fontSize.get('x-large'), color: subtext),
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                obscureText: !_showPassword,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(50.0, 10, 25.0, 10),
              child: Row(
                children: [
                  Checkbox(
                    value: _showPassword,
                    onChanged: (value) {
                      setState(() {
                        _showPassword = value!;
                      });
                    },
                  ),
                  Text(
                    'Show Password',
                    style: GoogleFonts.dmSans(
                        fontSize: _fontSize.get('large'), color: text),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(50, 15, 50, 15),
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    await authService.signInWithEmailAndPassword(
                      emailController.text,
                      passwordController.text,
                    );
                    if (Hive.box('form_data').get('filledForm')) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage()),
                      );
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => Onboarding()),
                      );
                    }
                  } catch (e) {
                    if (kIsWeb) {
                      print('Error initializing Firebase on Web: $e');
                    } else {
                      if (e is FirebaseException) {
                        print(e.toString());
                      }
                    }
                    emailController.clear();
                    passwordController.clear();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: text,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Sign In",
                    style: GoogleFonts.dmSans(
                      fontSize: _fontSize.get('x-large'),
                      color: bg,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: Text(
                ' or ',
                style: GoogleFonts.dmSans(
                    decoration: TextDecoration.none,
                    fontSize: _fontSize.get('large')),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(50, 15, 50, 15),
              child: ElevatedButton.icon(
                onPressed: () async {
                  try {
                    await authService.signInWithGoogle();
                  } catch (e) {
                    AlertDialog(
                      title: const Text('Error'),
                      content: Text(
                          "Signing in with Google is available on laptops only\n Use Sign Up to create an account!"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  }
                  if (Hive.box('form_data').get('filledForm')) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => Onboarding()),
                    );
                  }
                },
                icon: Image.asset('lib/assets/images/google_logo.jpg',
                    height: 24, width: 24),
                label: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Sign in with Google',
                      style: GoogleFonts.dmSans(
                          fontSize: _fontSize.get('x-large'), color: primary)),
                ),
                style: ElevatedButton.styleFrom(
                  surfaceTintColor: text,
                  backgroundColor: bg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpPage()),
                );
              },
              child: Center(
                child: Text(
                  'New to Nutria? Sign Up',
                  style: GoogleFonts.dmSans(
                      decoration: TextDecoration.underline,
                      fontSize: _fontSize.get('large')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
