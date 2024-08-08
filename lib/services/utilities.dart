import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

Color primary = const Color.fromRGBO(96, 5, 31, 1);
Color text = const Color.fromRGBO(65, 65, 65, 1);
Color subtext = const Color.fromRGBO(162, 162, 162, 1);
Color secCol = const Color.fromRGBO(181, 166, 197, 1);
Color bg = const Color.fromRGBO(253, 251, 252, 1);
Color chat_screen = const Color.fromRGBO(224, 217, 230, 1);

Image logo(double h, double w) {
  return Image.asset(
    'lib/assets/images/nutria_logo.png',
    height: h,
    width: w,
  );
}

Widget questionWidget(String q) {
  return Padding(
    padding: const EdgeInsets.all(10.0),
    child: Text(q,
        textAlign: TextAlign.center,
        style: GoogleFonts.dmSans(
          fontSize: 25,
          color: primary,
          fontWeight: FontWeight.w600,
        )),
  );
}

Widget subtextWidget(String text) {
  return Padding(
    padding: const EdgeInsets.all(10.0),
    child: Text(
      textAlign: TextAlign.center,
      text,
      style: GoogleFonts.dmSans(
        fontSize: 18,
        color: subtext,
      ),
    ),
  );
}

Widget otherOption(String? other, String text) {
  return Padding(
    padding: const EdgeInsets.all(14.0),
    child: TextField(
      style: GoogleFonts.dmSans(
        fontSize: 14,
      ),
      onChanged: (value) {
        other = value;
      },
      decoration: InputDecoration(
        label: Text(text,
            style: GoogleFonts.dmSans(
              fontSize: 14,
            )),
        border: OutlineInputBorder(),
      ),
    ),
  );
}

Future<String?> fetchImage(String query) async {
  const imageApiKey = 'AIzaSyAoiqX76n3euGhi-6tBkK1oYjgFv5DNL14';
  const cx = '4411f5d931ae649ae';

  final url =
      'https://www.googleapis.com/customsearch/v1?q=$query&searchType=image&key=$imageApiKey&cx=$cx&num=1';
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['items'][0]['link'];
  } else {
    return "No response";
  }
}

Future<String?> fetchRecipe(String query) async {
  const recipeApiKey = 'AIzaSyAoiqX76n3euGhi-6tBkK1oYjgFv5DNL14';
  const cx = 'd09af147f4b9c4bc5';

  final url =
      'https://www.googleapis.com/customsearch/v1?q=$query&key=$recipeApiKey&cx=$cx&num=1';
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['items'][0]['link'];
  } else {
    return "No response";
  }
}

Future<String> fetchYouTubeVideo(String query) async {
  const youtubeApiKey = 'AIzaSyDvZU-gaf99sD5IxZJSPaUnVMuJy9T4Vno';

  final url =
      'https://www.googleapis.com/youtube/v3/search?part=snippet&type=video&q=$query&key=$youtubeApiKey&maxResults=1';
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final videoId = data['items'][0]['id']['videoId'];
    return 'https://www.youtube.com/watch?v=$videoId';
  } else {
    return "No response";
  }
}

void increaseFontSize(Box box) {
  final small = box.get('small', defaultValue: 12);
  final medium = box.get('medium', defaultValue: 14);
  final large = box.get('large', defaultValue: 16);
  final xLarge = box.get('x-large', defaultValue: 18);
  final icon_small = box.get('icon_small', defaultValue: 20);
  final icon_large = box.get('icon_large', defaultValue: 24);

  box.put('small', small + 2);
  box.put('medium', medium + 2);
  box.put('large', large + 2);
  box.put('x-large', xLarge + 2);
  box.put('icon_small', icon_small + 2);
  box.put('icon_large', icon_large + 2);
}

void decreaseFontSize(Box box) {
  final small = box.get('small', defaultValue: 12);
  final medium = box.get('medium', defaultValue: 14);
  final large = box.get('large', defaultValue: 16);
  final xLarge = box.get('x-large', defaultValue: 18);
  final icon_small = box.get('icon_small', defaultValue: 20);
  final icon_large = box.get('icon_large', defaultValue: 24);

  box.put('small', (small != null) ? small - 2 : 10);
  box.put('medium', (medium != null) ? medium - 2 : 12);
  box.put('large', (large != null) ? large - 2 : 14);
  box.put('x-large', (xLarge != null) ? xLarge - 2 : 16);
  box.put('icon_small', (icon_small != null) ? icon_small - 2 : 18);
  box.put('icon_large', (icon_large != null) ? icon_large - 2 : 22);
}

String _getSafeString(dynamic value) {
  if (value is String) {
    return value;
  } else if (value is List) {
    return value.join(', ');
  } else {
    return 'Unknown';
  }
}
