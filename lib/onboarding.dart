import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:nutria/services/utilities.dart';

class Onboarding extends StatefulWidget {
  @override
  _OnboardingState createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  int _currentPage = 0;
  late Box _fontSize;

  @override
  void initState() {
    super.initState();
    _fontSize = Hive.box('font_size');
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      OnboardingPage(
        imagePath: "lib/assets/images/onboard_1.png",
        title: "Delicious Made Easy",
        description1:
            "Input your dietary needs, flavor palette, and gut health info",
        description2:
            "Receive delicious meal recommendations for every meal of the day.",
        fontSize: _fontSize,
      ),
      OnboardingPage(
        imagePath: "lib/assets/images/onboard_2.png",
        title: "Meal Confusion Solved",
        description1:
            "Take a picture of a menu or the ingredients in your fridge",
        description2: "Get the food options that fit your needs and taste.",
        fontSize: _fontSize,
      ),
      OnboardingPage(
        imagePath: "lib/assets/images/onboard_3.png",
        title: "Nutria Chat Access",
        description1: "Ask any questions that Nutria can help with!",
        description2: "There will be custom suggestions based on your info.",
        fontSize: _fontSize,
      ),
      WelcomePage(fontSize: _fontSize),
    ];

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: CarouselSlider(
              options: CarouselOptions(
                height: MediaQuery.of(context).size.height,
                viewportFraction: 1.0,
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentPage = index;
                  });
                },
              ),
              items: pages
                  .map((page) => Builder(
                        builder: (BuildContext context) {
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            child: page,
                          );
                        },
                      ))
                  .toList(),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(pages.length, (index) {
                    return Container(
                      width: 12.0,
                      height: 12.0,
                      margin:
                          EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPage == index ? primary : subtext,
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description1;
  final String description2;
  final Box fontSize;

  OnboardingPage({
    required this.imagePath,
    required this.title,
    required this.description1,
    required this.description2,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.fill,
        ),
      ),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: 300,
            child: Container(
              width: MediaQuery.of(context).size.height * 0.60,
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50.0),
                  topRight: Radius.circular(50.0),
                ),
                color: bg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(title,
                      style: GoogleFonts.dmSans(
                        fontSize: fontSize.get('x-large'),
                        decoration: TextDecoration.none,
                        color: primary,
                        fontWeight: FontWeight.bold,
                      )),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(60, 0, 60, 0),
                    child: Text(
                      description1,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        fontSize: fontSize.get('large'),
                        color: primary,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(60, 0, 60, 0),
                    child: Text(description2,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                          fontSize: fontSize.get('large'),
                          color: primary,
                          decoration: TextDecoration.none,
                        )),
                  ),
                  SizedBox(
                    height: 10,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WelcomePage extends StatelessWidget {
  final Box fontSize;

  WelcomePage({required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: primary,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.4),
          logo(250, 250),
          Positioned(
            top: 300,
            child: Container(
              width: MediaQuery.of(context).size.height * 0.6,
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50.0),
                  topRight: Radius.circular(50.0),
                ),
                color: bg,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text("Welcome to Nutria",
                      style: GoogleFonts.dmSans(
                        fontSize: fontSize.get('x-large'),
                        decoration: TextDecoration.none,
                        color: primary,
                        fontWeight: FontWeight.bold,
                      )),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(60, 0, 60, 0),
                    child: Text(
                      "We help you find delicious recipes based on your gut health and dietary needs.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        fontSize: fontSize.get('large'),
                        color: primary,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(60, 0, 60, 0),
                    child: Text(
                        "Get started by letting us know a little about you!",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                          fontSize: fontSize.get('large'),
                          color: primary,
                          decoration: TextDecoration.none,
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: MaterialButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/home');
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                        side: BorderSide(color: primary),
                      ),
                      color: primary,
                      textColor: bg,
                      child: Text(
                        "Let's Get Started",
                        style: GoogleFonts.dmSans(
                          fontSize: fontSize.get('large'),
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
