import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nutria/services/utilities.dart';
import 'package:google_fonts/google_fonts.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  late Box _fontSize;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 10), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
    _fontSize = Hive.box('font_size');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            logo(300, 250),
            const SizedBox(height: 20),
            CarouselSlider(
              items: [
                Text(
                  'Ready to take charge of your health!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    fontSize: _fontSize.get('large'),
                    color: text,
                  ),
                ),
                Text(
                  'GO GO GO...',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                      fontSize: _fontSize.get('large'), color: text),
                ),
                Text(
                  'Yummy meals are waiting for you ;)',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                      fontSize: _fontSize.get('large'), color: text),
                ),
                Text(
                  'Menu overwhelm? Nutria helps you choose the best dish.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                      fontSize: _fontSize.get('large'), color: text),
                ),
              ],
              options: CarouselOptions(
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 3),
                autoPlayAnimationDuration: Duration(milliseconds: 800),
                autoPlayCurve: Curves.fastOutSlowIn,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
