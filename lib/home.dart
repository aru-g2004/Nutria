import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nutria/services/ingredients.dart';
import 'package:nutria/services/meals.dart';
import 'package:nutria/services/utilities.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Gemini _gemini = Gemini.instance;
  late Box _fontSizeBox;
  late Box<Meals> _mealBox;
  late Box<Meals> _favoritesBox;
  Future<Meals?>? _mealFuture;
  List<Ingredients> _ingredients = [];
  TextEditingController _location = TextEditingController();

  @override
  void initState() {
    super.initState();
    _mealBox = Hive.box<Meals>('meals');
    _favoritesBox = Hive.box<Meals>('favorites');
    _mealFuture = getMealFromCache();
    _fontSizeBox = Hive.box('font_size');
    _ingredients = List<Ingredients>.from(
        Hive.box('form_data').get('list', defaultValue: <Ingredients>[]));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateIngredients();
  }

  void _updateIngredients() {
    List<dynamic> ingredientsDynamic = Hive.box('form_data').get('list');
    setState(() {
      _ingredients = ingredientsDynamic.cast<Ingredients>();
    });
  }

  void _showIngredientsDialog() {
    bool like = false;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController _ingredientController = TextEditingController();
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Center(
                child: Text('Ingredients',
                    style: GoogleFonts.dmSans(
                      fontSize: _fontSizeBox.get('large'),
                      color: primary,
                    )),
              ),
              content: Scaffold(
                body: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _ingredients.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: _ingredients[index].like
                          ? Icon(Icons.favorite, color: Colors.red)
                          : Icon(Icons.favorite_border),
                      title: Text(_ingredients[index].name,
                          style: GoogleFonts.dmSans(
                            fontSize: _fontSizeBox.get('medium'),
                          )),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            _ingredients.removeAt(index);
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              actions: <Widget>[
                TextField(
                  autocorrect: true,
                  controller: _ingredientController,
                  decoration: InputDecoration(
                    labelText: 'Add Ingredient',
                    labelStyle: GoogleFonts.dmSans(
                      fontSize: _fontSizeBox.get('medium'),
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                        onPressed: () {
                          setState(() {
                            like = !like;
                          });
                        },
                        icon: like
                            ? Icon(Icons.favorite, color: Colors.red)
                            : Icon(Icons.favorite_border)),
                    ElevatedButton(
                      onPressed: () {
                        String ingredient = _ingredientController.text;
                        if (ingredient.isNotEmpty) {
                          setState(() {
                            _ingredients
                                .add(Ingredients(name: ingredient, like: like));
                            _ingredientController.clear();
                            _updateIngredients();
                          });
                        }
                      },
                      child: Text('Submit',
                          style: GoogleFonts.dmSans(
                            fontSize: _fontSizeBox.get('medium'),
                            color: primary,
                          )),
                    ),
                    TextButton(
                      child: Text('Close',
                          style: GoogleFonts.dmSans(
                            fontSize: _fontSizeBox.get('medium'),
                            color: primary,
                          )),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  String timeOfDay() {
    if (Hive.box('form_data').get('snack_mode') &&
        Hive.box('form_data').get('dessert_mode')) {
      return 'Sweet Snack';
    }
    if (Hive.box('form_data').get('snack_mode')) {
      return 'Savoury Snack';
    }
    if (Hive.box('form_data').get('dessert_mode')) {
      return 'Dessert';
    }

    var now = DateTime.now();
    var hour = now.hour;
    if (hour < 12) {
      return 'Breakfast';
    } else if (hour < 17) {
      return 'Lunch';
    } else {
      return 'Dinner';
    }
  }

  Future<Meals?> getMealFromCache() async {
    Hive.box('form_data').put('meal_loaded', true);
    if (_mealBox.length > 1) {
      return _mealBox.getAt(_mealBox.length - 1);
    } else {
      return await getMealFromGeminiAI();
    }
  }

  Future<Meals> getMealFromGeminiAI() async {
    String meal_time = timeOfDay();
    String meal = 'No response';
    String? image = "No image";
    String? youtube = "No youtube";
    String? recipe = "No recipe";
    String tag1 = '';
    String tag2 = '';
    String tag3 = '';
    String cookingTime = '';
    String response = '';
    String restaurant = '';

    try {
      if (_mealBox.isEmpty) {
        String preferences = Hive.box('form_data').get("summary");
        String initialPrompt =
            "Hi, you are my Nutritionist, I want you to give me a new meal suggestion according to my preferences\nHere are my preferences: $preferences";
        await _gemini.text(initialPrompt);
        await _mealBox.add(Meals(
            name: initialPrompt,
            mealType: '',
            imageUrl: '',
            youtubeUrl: '',
            recipeUrl: '',
            tag1: '',
            tag2: '',
            tag3: '',
            cookingTime: '',
            restaurant: ''));
      }

      String convoHist =
          "\n user preferences: ${_mealBox.get(0)?.name} \nmeal history:\n";
      for (int i = 1; i < _mealBox.length; i++) {
        convoHist += (_mealBox.getAt(i)?.name ?? '') + "\n";
      }

      if (Hive.box('form_data').get('generate_using_list')) {
        String liked =
            _ingredients.where((i) => i.like).map((i) => i.name).join(",");
        String disliked =
            _ingredients.where((i) => !i.like).map((i) => i.name).join(",");
        convoHist +=
            "include user's preferred ingredients in meals: $liked \ndon't include user's disliked ingredients in meals: $disliked \n";
      }

      var value = await _gemini.text(convoHist +
          " Give a name of a new meal for " +
          meal_time +
          " that fits my specified preferences. " +
          "Also GIVE 3 nutrition tags (high-protein, low carb, gut-friendly etc.) AND 1 tag for estimated cooking time in numbers!. RESPONSES MUST LOOK LIKE THIS: Green Mung Bean Chaat with Pickled Onions #vegetarian #gut-friendly #highprotein #15-25.");

      response = value?.output ?? 'No response';

      if (!response.contains("#")) {
        throw Exception("Invalid response format");
      }

      meal = response.split("#").first.replaceAll(r'*', '').trim();

      var tags = response.split("#").sublist(1);
      if (tags.length >= 4) {
        tag1 = tags[0].trim();
        tag2 = tags[1].trim();
        tag3 = tags[2].trim();
        cookingTime = tags[3].trim();
      } else {
        throw Exception("Insufficient tags in response");
      }

      if (Hive.box('form_data').get('location_mode')) {
        String location = Hive.box('form_data').get('cur_location');
        String prompt =
            "Can you tell the NAME of a restaurant in $location that has $meal on the menu: Response should ONLY be the name of the restaurant. The restaurant must be REAL and must be in the specified location.";
        value = await _gemini.text(prompt,
            generationConfig: GenerationConfig(maxOutputTokens: 50));
        restaurant = value?.output ?? '';
      }

      var fetchTasks = await Future.wait([
        fetchImage(meal),
        fetchYouTubeVideo(meal),
        fetchRecipe("$meal recipe")
      ]);

      image = fetchTasks[0];
      youtube = fetchTasks[1];
      recipe = fetchTasks[2];

      await _mealBox.add(Meals(
          name: meal,
          mealType: meal_time,
          imageUrl: image!,
          youtubeUrl: youtube!,
          recipeUrl: recipe!,
          tag1: tag1,
          tag2: tag2,
          tag3: tag3,
          cookingTime: cookingTime,
          restaurant: restaurant));
    } catch (e) {
      meal = 'There was an error! Please try again';
      image = "No Response";
      youtube = "https://www.youtube.com/";
      recipe = "https://www.google.com/";
      tag1 = 'tag 1';
      tag2 = 'tag 2';
      tag3 = 'tag 3';
      cookingTime = 'n/a';
      restaurant = '';
    }

    return Meals(
        name: meal,
        mealType: meal_time,
        imageUrl: image!,
        youtubeUrl: youtube!,
        recipeUrl: recipe!,
        tag1: tag1,
        tag2: tag2,
        tag3: tag3,
        cookingTime: cookingTime,
        restaurant: restaurant);
  }

  bool clickLike = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: primary,
      appBar: AppBar(
        backgroundColor: primary,
        leading: logo(100, 100),
        title: Center(
          child: Text(
            "Home",
            style: GoogleFonts.dmSans(
                fontSize: _fontSizeBox.get('x-large') + 5,
                fontWeight: FontWeight.bold,
                color: bg),
          ),
        ),
        actions: [
          if (Hive.box('form_data').get('filledForm'))
            IconButton(
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
              icon: Icon(
                Icons.edit,
                size: _fontSizeBox.get('icon-large'),
                color: bg,
              ),
            ),
          if (!Hive.box('form_data').get('filledForm'))
            IconButton(
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
              icon: Icon(
                Icons.settings,
                size: _fontSizeBox.get('icon-large'),
                color: bg,
              ),
            ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("lib/assets/images/nutria_logo.png"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: <Widget>[
                  Positioned(
                    bottom: 8.0,
                    left: 16.0,
                    child: Text(
                      'Nutria',
                      style: GoogleFonts.pacifico(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              trailing: Icon(Icons.add),
              title: Text(
                'Increase Font Size',
              ),
              onTap: () {
                setState(() {
                  increaseFontSize(_fontSizeBox);
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              trailing: Icon(Icons.remove),
              title: Text('Decrease Font Size'),
              onTap: () {
                setState(() {
                  decreaseFontSize(_fontSizeBox);
                });
                Navigator.pop(context);
              },
            ),
            if (Hive.box('form_data').get('filledForm'))
              ListTile(
                trailing: Icon(
                  Icons.list,
                  size: _fontSizeBox.get('icon-large'),
                  color: Colors.black,
                ),
                title: Text('Edit Form'),
                onTap: () {
                  setState(() {
                    setState(() {
                      Navigator.pop(context);
                      Hive.box('form_data').put('filledForm', false);
                      _mealBox.clear();
                      Navigator.pushNamed(context, '/form');
                    });
                  });
                },
              ),
            if (Hive.box('form_data').get('filledForm'))
              ListTile(
                trailing: Icon(
                  Icons.shopping_bag,
                  size: _fontSizeBox.get('icon-large'),
                  color: Colors.black,
                ),
                title: Text('Edit List'),
                onTap: () {
                  setState(() {
                    setState(() {
                      Navigator.pop(context);
                      _showIngredientsDialog();
                    });
                  });
                },
              ),
            SwitchListTile(
              title: Text('Use list', style: GoogleFonts.dmSans()),
              value: Hive.box('form_data').get('generate_using_list'),
              onChanged: (value) {
                setState(() {
                  Hive.box('form_data').put('generate_using_list', value);
                });
              },
            ),
            SwitchListTile(
              title: Text('Dessert mode', style: GoogleFonts.dmSans()),
              value: Hive.box('form_data').get('dessert_mode'),
              onChanged: (value) {
                setState(() {
                  Hive.box('form_data').put('dessert_mode', value);
                });
              },
            ),
            SwitchListTile(
              title: Text('Snack mode', style: GoogleFonts.dmSans()),
              value: Hive.box('form_data').get('snack_mode'),
              onChanged: (value) {
                setState(() {
                  Hive.box('form_data').put('snack_mode', value);
                });
              },
            ),
            SwitchListTile(
              title: Text('Find restaurants mode', style: GoogleFonts.dmSans()),
              value: Hive.box('form_data').get('location_mode'),
              onChanged: (value) {
                setState(() {
                  if (value) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Enter Location',
                              style: GoogleFonts.dmSans()),
                          content: TextField(
                            controller: _location,
                            decoration: InputDecoration(
                              hintText: 'Enter preferred location',
                              hintStyle: GoogleFonts.dmSans(),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child:
                                  Text('Cancel', style: GoogleFonts.dmSans()),
                            ),
                            TextButton(
                              onPressed: () {
                                Hive.box('form_data')
                                    .put('cur_location', _location.text);
                                Navigator.of(context).pop();
                              },
                              child:
                                  Text('Submit', style: GoogleFonts.dmSans()),
                            ),
                          ],
                        );
                      },
                    );
                  }
                  if (_location.text.isEmpty) {
                    Hive.box('form_data').put('location_mode', false);
                  }
                  Hive.box('form_data').put('location_mode', value);
                });
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (Hive.box('form_data').get('filledForm')) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(5, 20.0, 5, 5),
                child: Card(
                  margin: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: FutureBuilder<Meals?>(
                          future: _mealFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else if (!snapshot.hasData ||
                                snapshot.data!.name.isEmpty &&
                                    snapshot.data!.imageUrl.isEmpty &&
                                    snapshot.data!.youtubeUrl.isEmpty) {
                              return Text('No image available',
                                  style: GoogleFonts.dmSans());
                            } else {
                              return Column(
                                children: [
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _mealFuture = getMealFromGeminiAI();
                                            clickLike = false;
                                          });
                                        },
                                        icon: Icon(Icons.cached,
                                            size:
                                                _fontSizeBox.get('icon-large') +
                                                    10),
                                        color: text,
                                      ),
                                      Center(
                                        child: Text(
                                          timeOfDay(),
                                          style: GoogleFonts.dmSans(
                                            fontWeight: FontWeight.bold,
                                            fontSize:
                                                _fontSizeBox.get('x-large'),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () async {
                                          final meal = _mealBox
                                              .getAt(_mealBox.length - 1);
                                          if (meal != null) {
                                            final newMeal = Meals(
                                              name: meal.name,
                                              mealType: meal.mealType,
                                              imageUrl: meal.imageUrl,
                                              youtubeUrl: meal.youtubeUrl,
                                              recipeUrl: meal.recipeUrl,
                                              tag1: meal.tag1,
                                              tag2: meal.tag2,
                                              tag3: meal.tag3,
                                              cookingTime: meal.cookingTime,
                                              restaurant: meal.restaurant,
                                            );
                                            await _favoritesBox.add(newMeal);
                                          }
                                          setState(() {
                                            clickLike = !clickLike;
                                          });
                                        },
                                        icon: Icon(
                                          clickLike
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          size: _fontSizeBox.get('icon-large') +
                                              10,
                                        ),
                                        color: clickLike ? Colors.red : text,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  if (snapshot.data?.imageUrl == "No Response")
                                    ClipOval(
                                      child: Container(
                                        height: 120,
                                        width: 120,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: AssetImage(
                                                'lib/assets/images/nutria_logo.png'),
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                    )
                                  else
                                    ClipOval(
                                        child: Container(
                                      height: 120,
                                      width: 120,
                                      decoration: BoxDecoration(
                                          image: DecorationImage(
                                        image: NetworkImage(
                                            snapshot.data?.imageUrl ?? ''),
                                        fit: BoxFit.fill,
                                      )),
                                    )),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Center(
                                      child: Text(
                                        textAlign: TextAlign.center,
                                        snapshot.data?.name ?? '',
                                        style: TextStyle(
                                          fontSize: _fontSizeBox.get('x-large'),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Chip(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        backgroundColor: secCol,
                                        label: Text(
                                          snapshot.data?.tag1 ?? '',
                                          style: GoogleFonts.dmSans(
                                              color: text,
                                              fontSize:
                                                  _fontSizeBox.get('small')),
                                        ),
                                      ),
                                      Chip(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        backgroundColor: secCol,
                                        label: Text(
                                          snapshot.data?.tag2 ?? '',
                                          style: GoogleFonts.dmSans(
                                              color: text,
                                              fontSize:
                                                  _fontSizeBox.get('small')),
                                        ),
                                      ),
                                      Chip(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        backgroundColor: secCol,
                                        label: Text(
                                          snapshot.data?.tag3 ?? '',
                                          style: GoogleFonts.dmSans(
                                              color: text,
                                              fontSize:
                                                  _fontSizeBox.get('small')),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                      "Cooking Time: ${snapshot.data?.cookingTime ?? ''} mins",
                                      style: GoogleFonts.dmSans(
                                        color: subtext,
                                        fontSize: _fontSizeBox.get('large'),
                                      )),
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Chip(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        backgroundColor: bg,
                                        label: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                launch(
                                                    snapshot.data?.youtubeUrl ??
                                                        '');
                                              },
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons
                                                        .video_collection_outlined,
                                                    size: _fontSizeBox
                                                        .get('icon-small'),
                                                  ),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    'video',
                                                    style: GoogleFonts.dmSans(
                                                      fontSize: _fontSizeBox
                                                          .get('small'),
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
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        backgroundColor: bg,
                                        label: Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                launch(
                                                    snapshot.data?.recipeUrl ??
                                                        '');
                                              },
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons
                                                        .restaurant_menu_outlined,
                                                    size: _fontSizeBox
                                                        .get('icon-small'),
                                                  ),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    'recipe',
                                                    style: GoogleFonts.dmSans(
                                                      fontSize: _fontSizeBox
                                                          .get('small'),
                                                      color: text,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (Hive.box('form_data')
                                          .get('location_mode'))
                                        Chip(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          backgroundColor: bg,
                                          label: Row(
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  if (snapshot.data
                                                              ?.restaurant !=
                                                          null &&
                                                      snapshot.data
                                                              ?.restaurant !=
                                                          'No such place exists') {
                                                    String restaurantName =
                                                        snapshot
                                                            .data!.restaurant;
                                                    String url = Uri.encodeFull(
                                                        "https://www.google.com/search?q=$restaurantName restaurant in ${Hive.box('form_data').get('cur_location')}");

                                                    canLaunch(url)
                                                        .then((isLaunchable) {
                                                      if (isLaunchable) {
                                                        launch(url);
                                                      } else {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(SnackBar(
                                                                content: Text(
                                                                    'Could not launch URL')));
                                                      }
                                                    }).catchError((error) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(SnackBar(
                                                              content: Text(
                                                                  'Error launching URL: $error')));
                                                    });
                                                  } else {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(SnackBar(
                                                            content: Text(
                                                                'No such place exists')));
                                                  }
                                                },
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.restaurant,
                                                      size: _fontSizeBox
                                                          .get('icon-small'),
                                                    ),
                                                    SizedBox(width: 4),
                                                    Text(
                                                      "restaurant",
                                                      style: GoogleFonts.dmSans(
                                                        fontSize: _fontSizeBox
                                                            .get('small'),
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
                              );
                            }
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MaterialButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: bg,
                    onPressed: () => Navigator.pushNamed(context, '/favorites'),
                    child: SizedBox(
                      height: 150,
                      width: 200,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.favorite_border,
                            size: _fontSizeBox.get('icon-large'),
                            color: text,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Liked Recipes',
                            style: GoogleFonts.dmSans(
                              fontSize: _fontSizeBox.get('medium'),
                              color: text,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  MaterialButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: bg,
                    onPressed: () => Navigator.pushNamed(context, '/chat'),
                    child: SizedBox(
                      height: 150,
                      width: 200,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat,
                            size: _fontSizeBox.get('icon-large'),
                            color: text,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Talk to Nutria',
                            style: GoogleFonts.dmSans(
                              fontSize: _fontSizeBox.get('medium'),
                              color: text,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            ],
            if (!Hive.box('form_data').get('filledForm')) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(5, 35.0, 5, 20),
                child: Card(
                  margin: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: text,
                                width: 2.0,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: ClipOval(
                                child: Icon(
                                  Icons.image_outlined,
                                  size: 45,
                                  color: text,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: Text(
                            textAlign: TextAlign.center,
                            'Help Nutria get to know you, and your personalized meal suggestions will pop up here',
                            style: TextStyle(
                              color: text,
                              fontSize: _fontSizeBox.get('large'),
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: MaterialButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/form');
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            color: primary,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Start Now',
                                style: GoogleFonts.dmSans(
                                  fontWeight: FontWeight.bold,
                                  fontSize: _fontSizeBox.get('medium'),
                                  color: bg,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
