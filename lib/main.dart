import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:nutria/chat.dart';
import 'package:nutria/favorites.dart';
import 'package:nutria/home.dart';
import 'package:nutria/login.dart';
import 'package:nutria/onboarding.dart';
import 'package:nutria/services/ingredients.dart';
import 'package:nutria/services/meals.dart';
import 'package:nutria/services/message.dart';
import 'package:nutria/sign_up.dart';
import 'package:nutria/form.dart';
import 'package:nutria/splash.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  await dotenv.load();
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Hive.initFlutter();
    await Firebase.initializeApp(
        options: FirebaseOptions(
      apiKey: dotenv.env['FIREBASE_API_KEY']!,
      authDomain: dotenv.env['FIREBASE_AUTH_DOMAIN']!,
      projectId: dotenv.env['FIREBASE_PROJECT_ID']!,
      storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET']!,
      messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID']!,
      appId: dotenv.env['FIREBASE_APP_ID']!,
    ));
  } else {
    var dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    await Firebase.initializeApp();
  }

  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(MessageAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(MealsAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(IngredientsAdapter());
  }

  if (!Hive.isBoxOpen('font_size')) {
    await Hive.openBox('font_size');
    await Hive.openBox<Message>('messages');
    await Hive.openBox('form_data');
    await Hive.openBox<Meals>('favorites');
    await Hive.openBox<Meals>('meals');
  }

  if (Hive.box('form_data').get('list') == null) {
    Hive.box('form_data').put('list', <Ingredients>[]);
    Hive.box('form_data').put('filledForm', false);
    Hive.box('form_data').put('generate_using_list', false);
    Hive.box('form_data').put('dessert_mode', false);
    Hive.box('form_data').put('snack_mode', false);
    Hive.box('form_data').put('location_mode', false);
    Hive.box('form_data').put('cur_location', '');
    Hive.box('form_data').put('meal_loaded', false);
  }

  if (Hive.box('font_size').get('small') == null) {
    Hive.box('font_size').put('small', 12.0);
    Hive.box('font_size').put('medium', 14.0);
    Hive.box('font_size').put('large', 16.0);
    Hive.box('font_size').put('x-large', 20.0);
    Hive.box('font_size').put('icon-small', 16.0);
    Hive.box('font_size').put('icon-large', 30.0);
  }

  Gemini.init(apiKey: dotenv.env['GEMINI_API_KEY']!);

  runApp(
    _buildRunnableApp(
      isWeb: kIsWeb,
      webAppWidth: 500,
      app: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/splash',
        routes: {
          '/form': (context) => FormPage(),
          '/home': (context) => HomePage(),
          '/splash': (context) => Splash(),
          '/onboarding': (context) => Onboarding(),
          '/chat': (context) => ChatScreen(),
          '/login': (context) => LoginPage(),
          '/signup': (context) => SignUpPage(),
          '/favorites': (context) => FavoritesPage(),
        },
      ),
    ),
  );
}

Widget _buildRunnableApp({
  required bool isWeb,
  required double webAppWidth,
  required Widget app,
}) {
  if (!isWeb) {
    return app;
  }

  return Center(
    child: ClipRect(
      child: SizedBox(
        width: webAppWidth,
        child: app,
      ),
    ),
  );
}
