import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nutria/home.dart';
import 'package:nutria/onboarding.dart';
import 'package:nutria/services/auth.dart';
import 'package:nutria/services/utilities.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  AuthService authService = AuthService();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
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
        child: Column(
          children: [
            SizedBox(height: 70),
            logo(150, 150),
            // "Sign Up with Nutria" text
            questionWidget("Sign Up with Nutria"),
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
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(50, 15, 50, 15),
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    await authService.signUpWithEmailAndPassword(
                      emailController.text,
                      passwordController.text,
                    );
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => Onboarding()),
                    );
                  } catch (e) {
                    print(e.toString());
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
                    "Sign Up",
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
                  await authService.signInWithGoogle();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Onboarding()),
                  );
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
                Navigator.pop(context);
              },
              child: Center(
                child: Text(
                  'Already have an account? Sign In',
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
