import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nutria/services/meals.dart';
import 'package:nutria/services/utilities.dart';
import 'package:url_launcher/url_launcher.dart';

class FavoritesPage extends StatefulWidget {
  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late Future<Box<Meals>> _favoritesBoxFuture;
  late Box _fontSizeBox;

  @override
  void initState() {
    super.initState();
    _favoritesBoxFuture = Hive.openBox<Meals>('favorites');
    _fontSizeBox = Hive.box('font_size');
  }

  void _showFirstTimeNotification() {
    setState(() {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              'Welcome to Favorites ♡',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                color: text,
                fontSize: 20,
              ),
            ),
            content: Text(
              'You can surf through your favorites here! \n' +
                  'Double tap on any recipe to remove it from favorites.\n\n You can click on the recipe button, youtube button to view the recipe and video.\n\n For recipes that you used restaurant mode for, you can also view the restaurants that were generated!.',
              style: GoogleFonts.dmSans(color: text, fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primary,
      appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/home');
            },
            icon: Icon(Icons.home_outlined, color: text),
          ),
          actions: [
            IconButton(
              onPressed: _showFirstTimeNotification,
              icon: Icon(Icons.help_center_outlined, color: text),
            ),
          ],
          title: Text(
            'Favorites',
            style: GoogleFonts.dmSans(color: text),
          )),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(5, 10, 5, 5),
        child: FutureBuilder<Box<Meals>>(
          future: _favoritesBoxFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else {
                final favoritesBox = snapshot.data!;
                return ValueListenableBuilder(
                  valueListenable: favoritesBox.listenable(),
                  builder: (context, Box<Meals> box, _) {
                    if (box.values.isEmpty) {
                      return Center(
                        child: Text('No favorite meals added yet.',
                            style: GoogleFonts.dmSans(color: bg, fontSize: 16)),
                      );
                    } else {
                      return GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 1,
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 2,
                        ),
                        itemCount: box.values.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(20.0, 5, 20, 10),
                            child: RecipeCard(meal: box.getAt(index)!),
                          );
                        },
                      );
                    }
                  },
                );
              }
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }
}

class RecipeCard extends StatelessWidget {
  final Meals meal;
  const RecipeCard({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(
                'Remove from favorites?',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  color: text,
                  fontSize: 16,
                ),
              ),
              content:
                  Text('Do you want to remove ${meal.name} from favorites?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.dmSans(
                      color: text,
                      fontSize: 16,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    final favoritesBox = Hive.box<Meals>('favorites');
                    favoritesBox.delete(meal.key);
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Remove',
                    style: GoogleFonts.dmSans(
                      color: text,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(2, 50, 2, 15),
                  child: MaterialButton(
                    onPressed: () async {
                      if (await canLaunch(meal.youtubeUrl)) {
                        await launch(meal.youtubeUrl);
                      } else {
                        throw 'Could not launch ${meal.youtubeUrl}';
                      }
                    },
                    child: ClipOval(
                        child: Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                        image: NetworkImage(meal.imageUrl),
                        fit: BoxFit.fill,
                      )),
                    )),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Text(
                      textAlign: TextAlign.center,
                      meal.name,
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Chip(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        backgroundColor: secCol,
                        label: Text(
                          meal.tag1 ?? '',
                          style: GoogleFonts.dmSans(color: text, fontSize: 12),
                        ),
                      ),
                      Chip(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        backgroundColor: secCol,
                        label: Text(
                          meal.tag2 ?? '',
                          style: GoogleFonts.dmSans(color: text, fontSize: 12),
                        ),
                      ),
                      Chip(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        backgroundColor: secCol,
                        label: Text(
                          meal.tag3 ?? '',
                          style: GoogleFonts.dmSans(color: text, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Text("Cooking Time: ${meal.cookingTime ?? ''} mins",
                      style: GoogleFonts.dmSans(
                        color: subtext,
                        fontSize: 16,
                      )),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Chip(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        backgroundColor: bg,
                        label: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                launch(meal.youtubeUrl ?? '');
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.video_collection_outlined,
                                    size: 16,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'video',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 12,
                                      color: text,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Chip(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        backgroundColor: bg,
                        label: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                launch(meal.recipeUrl ?? '');
                              },
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.restaurant_menu_outlined,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'recipe',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 12,
                                      color: text,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (meal.restaurant.isNotEmpty)
                        Chip(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          backgroundColor: bg,
                          label: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  launch(meal.restaurant ?? '');
                                },
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.restaurant_outlined,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'restaurant',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 12,
                                        color: text,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
