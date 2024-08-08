import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nutria/home.dart';
import 'package:nutria/services/utilities.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class FormPage extends StatefulWidget {
  @override
  _FormPageState createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  late Box _fontSizeBox;

  @override
  void initState() {
    super.initState();
    _fontSizeBox = Hive.box('font_size');
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

  final PageController _pageController = PageController();
  final int _totalPages = 6;

  int _currentPage = 0;

  List<String> _dietaryPreferences = [];
  String? _skinType;
  String? _otherSkinType;
  String? _weightGoal;
  String? _otherGoal;
  String? _stoolType;
  String? _otherStoolType;
  double _kitchenComfort = 50;
  String? _cookingTime;
  List<String> _favoriteCuisines = [];
  String? _otherCuisine;
  String? _allergies;

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.animateToPage(
        _currentPage - 1,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.chevron_left, size: _fontSizeBox.get('icon-large')),
          onPressed: _previousPage,
        ),
        title: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SmoothPageIndicator(
              controller: _pageController,
              count: _totalPages,
              effect: const ScrollingDotsEffect(
                activeDotColor: Color.fromRGBO(181, 166, 197, 1),
                dotColor: Color.fromRGBO(65, 65, 65, 1),
                dotHeight: 12,
                dotWidth: 12,
              )),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              children: [
                _buildPage1(),
                _buildPage2(),
                _buildPage3(),
                _buildPage4(),
                _buildPage5(),
                _buildSummaryPage(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 45.0),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.75,
              child: ElevatedButton(
                onPressed: _currentPage == _totalPages - 1
                    ? () {
                        // Save the form data to the database
                        Hive.box('form_data')
                            .put('dietary_preferences', _dietaryPreferences);
                        Hive.box('form_data').put('skin_type', _skinType);
                        Hive.box('form_data')
                            .put('other_skin_type', _otherSkinType);
                        Hive.box('form_data').put('weight_goal', _weightGoal);
                        Hive.box('form_data').put('other_goal', _otherGoal);
                        Hive.box('form_data').put('stool_type', _stoolType);
                        Hive.box('form_data')
                            .put('other_stool_type', _otherStoolType);
                        Hive.box('form_data')
                            .put('kitchen_comfort', _kitchenComfort);
                        Hive.box('form_data').put('cooking_time', _cookingTime);
                        Hive.box('form_data')
                            .put('favorite_cuisines', _favoriteCuisines);
                        Hive.box('form_data')
                            .put('other_cuisine', _otherCuisine);
                        Hive.box('form_data').put('allergies', _allergies);
                        Hive.box('form_data').put('filledForm', true);

                        String diet = _getSafeString(
                            "dietary_preferences: ${Hive.box('form_data').get('dietary_preferences')}");
                        String skin_type = _getSafeString(
                            "skin_type: ${Hive.box('form_data').get('skin_type')}");
                        String other_skin = _getSafeString(
                            "other skin type: ${Hive.box('form_data').get('other_skin_type')}");
                        String weight_goal = _getSafeString(
                            "weight goal: ${Hive.box('form_data').get('weight_goal')}");
                        String other_goal = _getSafeString(
                            "other_goal: ${Hive.box('form_data').get('other_goal')}");
                        String stool = _getSafeString(
                            "stool_type: ${Hive.box('form_data').get('stool_type')}");
                        String other_stool = _getSafeString(
                            "other_stool_type: ${Hive.box('form_data').get('other_stool_type')}");
                        String kitchen = _getSafeString(
                            "kitchen_comfort: ${Hive.box('form_data').get('kitchen_comfort')}");
                        String cooking_time = _getSafeString(
                            "cooking_time: ${Hive.box('form_data').get('cooking_time')}");
                        String fav_cuisines = _getSafeString(
                            "favorite_cuisines: ${Hive.box('form_data').get('favorite_cuisines')}");
                        String other_cuisines = _getSafeString(
                            "other_cuisines: ${Hive.box('form_data').get('other_cuisine')}");
                        String allergies = _getSafeString(
                            "allergies: ${Hive.box('form_data').get('allergies')}");

                        Hive.box('form_data').put(
                            "summary",
                            diet +
                                "\n" +
                                skin_type +
                                "\n" +
                                other_skin +
                                "\n" +
                                weight_goal +
                                "\n" +
                                other_goal +
                                "\n" +
                                stool +
                                "\n" +
                                other_stool +
                                "\n" +
                                kitchen +
                                "\n" +
                                cooking_time +
                                "\n" +
                                fav_cuisines +
                                "\n" +
                                other_cuisines +
                                "\n" +
                                allergies);

                        print('Form data saved to database');
                        Future.delayed(Duration(seconds: 3), () {
                          print('Navigating to home page');
                          Navigator.pushNamed(context, '/home');
                        });

                        // Navigator.pushNamed(context, '/home');
                      }
                    : _nextPage,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text(_currentPage == _totalPages - 1
                    ? 'Go Explore Nutria'
                    : 'Next'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage1() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          questionWidget('What are your dietary preferences?'),
          SizedBox(height: 16),
          subtextWidget(
              'Select any dietary restrictions or preferences you have'),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 10.0,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ChoiceChip(
                      labelPadding: EdgeInsets.all(10),
                      label: Text('Vegan',
                          style: GoogleFonts.dmSans(
                            fontSize: _fontSizeBox.get('medium'),
                          )),
                      selected: _dietaryPreferences.contains('Vegan'),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _dietaryPreferences.add('Vegan');
                          } else {
                            _dietaryPreferences.remove('Vegan');
                          }
                        });
                      }),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ChoiceChip(
                      labelPadding: EdgeInsets.all(10),
                      label: Text('Vegetarian',
                          style: GoogleFonts.dmSans(
                            fontSize: _fontSizeBox.get('medium'),
                          )),
                      selected: _dietaryPreferences.contains('Vegetarian'),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _dietaryPreferences.add('Vegetarian');
                          } else {
                            _dietaryPreferences.remove('Vegetarian');
                          }
                        });
                      }),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ChoiceChip(
                      labelPadding: EdgeInsets.all(10),
                      label: Text('Gluten-Free',
                          style: GoogleFonts.dmSans(
                            fontSize: _fontSizeBox.get('medium'),
                          )),
                      selected: _dietaryPreferences.contains('Gluten-Free'),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _dietaryPreferences.add('Gluten-Free');
                          } else {
                            _dietaryPreferences.remove('Gluten-Free');
                          }
                        });
                      }),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ChoiceChip(
                      labelPadding: EdgeInsets.all(10),
                      label: Text('Non-Veg',
                          style: GoogleFonts.dmSans(
                            fontSize: _fontSizeBox.get('medium'),
                          )),
                      selected: _dietaryPreferences.contains('Non-Veg'),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _dietaryPreferences.add('Non-Veg');
                          } else {
                            _dietaryPreferences.remove('Non-Veg');
                          }
                        });
                      }),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ChoiceChip(
                      labelPadding: EdgeInsets.all(10),
                      label: Text('Dairy-Free',
                          style: GoogleFonts.dmSans(
                            fontSize: _fontSizeBox.get('medium'),
                          )),
                      selected: _dietaryPreferences.contains('Dairy-Free'),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _dietaryPreferences.add('Dairy-Free');
                          } else {
                            _dietaryPreferences.remove('Dairy-Free');
                          }
                        });
                      }),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ChoiceChip(
                      labelPadding: EdgeInsets.all(10),
                      label: Text('Nut-Free',
                          style: GoogleFonts.dmSans(
                            fontSize: _fontSizeBox.get('medium'),
                          )),
                      selected: _dietaryPreferences.contains('Nut-Free'),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _dietaryPreferences.add('Nut-Free');
                          } else {
                            _dietaryPreferences.remove('Nut-Free');
                          }
                        });
                      }),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ChoiceChip(
                      labelPadding: EdgeInsets.all(10),
                      label: Text('Halal',
                          style: GoogleFonts.dmSans(
                            fontSize: _fontSizeBox.get('medium'),
                          )),
                      selected: _dietaryPreferences.contains('Halal'),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _dietaryPreferences.add('Halal');
                          } else {
                            _dietaryPreferences.remove('Halal');
                          }
                        });
                      }),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ChoiceChip(
                      labelPadding: EdgeInsets.all(10),
                      label: Text('Keto',
                          style: GoogleFonts.dmSans(
                            fontSize: _fontSizeBox.get('medium'),
                          )),
                      selected: _dietaryPreferences.contains('Keto'),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _dietaryPreferences.add('Keto');
                          } else {
                            _dietaryPreferences.remove('Keto');
                          }
                        });
                      }),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ChoiceChip(
                      labelPadding: EdgeInsets.all(10),
                      label: Text('Low Carb',
                          style: GoogleFonts.dmSans(
                            fontSize: _fontSizeBox.get('medium'),
                          )),
                      selected: _dietaryPreferences.contains('Low Carb'),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _dietaryPreferences.add('Low Carb');
                          } else {
                            _dietaryPreferences.remove('Low Carb');
                          }
                        });
                      }),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          otherOption(_allergies, "Others (Allergies etc. - if any)"),
        ],
      ),
    );
  }

  Widget _buildPage2() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          questionWidget('What type of skin do you have?'),
          SizedBox(height: 16),
          subtextWidget('Select the type of skin you have'),
          Column(
            children: [
              RadioListTile(
                title: Text('Dry skin', style: GoogleFonts.dmSans()),
                value: 'Dry skin',
                groupValue: _skinType,
                onChanged: (value) {
                  setState(() {
                    _skinType = value as String?;
                    _otherSkinType = null; // Clear other skin type
                  });
                },
              ),
              RadioListTile(
                title: Text('Oily Skin', style: GoogleFonts.dmSans()),
                value: 'Oily Skin',
                groupValue: _skinType,
                onChanged: (value) {
                  setState(() {
                    _skinType = value as String?;
                    _otherSkinType = null; // Clear other skin type
                  });
                },
              ),
              RadioListTile(
                title: Text('Acne-Prone Skin', style: GoogleFonts.dmSans()),
                value: 'Acne-Prone Skin',
                groupValue: _skinType,
                onChanged: (value) {
                  setState(() {
                    _skinType = value as String?;
                    _otherSkinType = null; // Clear other skin type
                  });
                },
              ),
              otherOption(_otherSkinType, 'Other skin type'),
            ],
          ),
          SizedBox(height: 16),
          questionWidget('What are your weight goals?'),
          SizedBox(height: 16),
          subtextWidget('Select your primary weight goal'),
          Column(
            children: [
              RadioListTile(
                title: Text('Lose weight', style: GoogleFonts.dmSans()),
                value: 'Lose weight',
                groupValue: _weightGoal,
                onChanged: (value) {
                  setState(() {
                    _weightGoal = value as String?;
                    _otherGoal = null; // Clear other goal
                  });
                },
              ),
              RadioListTile(
                title: Text('Gain weight', style: GoogleFonts.dmSans()),
                value: 'Gain weight',
                groupValue: _weightGoal,
                onChanged: (value) {
                  setState(() {
                    _weightGoal = value as String?;
                    _otherGoal = null; // Clear other goal
                  });
                },
              ),
              RadioListTile(
                title: Text('Maintain weight', style: GoogleFonts.dmSans()),
                value: 'Maintain weight',
                groupValue: _weightGoal,
                onChanged: (value) {
                  setState(() {
                    _weightGoal = value as String?;
                    _otherGoal = null; // Clear other goal
                  });
                },
              ),
              otherOption(_otherGoal, 'Other goal'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPage3() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          questionWidget('How would you describe your recent gut health?'),
          SizedBox(height: 16),
          subtextWidget(
              'Select the description that best matches your gut health'),
          Column(
            children: [
              RadioListTile(
                title: Text('Normal', style: GoogleFonts.dmSans()),
                value: 'Normal',
                groupValue: _stoolType,
                onChanged: (value) {
                  setState(() {
                    _stoolType = value as String?;
                    _otherStoolType = null; // Clear other stool type
                  });
                },
              ),
              RadioListTile(
                title: Text('Constipated', style: GoogleFonts.dmSans()),
                value: 'Constipated',
                groupValue: _stoolType,
                onChanged: (value) {
                  setState(() {
                    _stoolType = value as String?;
                    _otherStoolType = null; // Clear other stool type
                  });
                },
              ),
              RadioListTile(
                title: Text('Bloated', style: GoogleFonts.dmSans()),
                value: 'Bloated',
                groupValue: _stoolType,
                onChanged: (value) {
                  setState(() {
                    _stoolType = value as String?;
                    _otherStoolType = null; // Clear other stool type
                  });
                },
              ),
              RadioListTile(
                title: Text('Frequent', style: GoogleFonts.dmSans()),
                value: 'Frequent',
                groupValue: _stoolType,
                onChanged: (value) {
                  setState(() {
                    _stoolType = value as String?;
                    _otherStoolType = null; // Clear other stool type
                  });
                },
              ),
              otherOption(_otherStoolType, 'Other type'),
            ],
          ),
          SizedBox(height: 16),
          Center(
            child: Text(
              'Note: If you are facing serious digestive issues, please consult a doctor.',
              style: GoogleFonts.dmSans(
                  fontSize: _fontSizeBox.get('medium'), color: primary),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage4() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          questionWidget('How comfortable are you in the kitchen?'),
          SizedBox(height: 16),
          subtextWidget('Slide to indicate your comfort level'),
          Row(
            children: [
              Expanded(
                child: Text('Not comfortable',
                    textAlign: TextAlign.left,
                    style: GoogleFonts.dmSans(
                      color: text,
                    )),
              ),
              Slider(
                min: 0,
                max: 100,
                value: _kitchenComfort,
                onChanged: (value) {
                  setState(() {
                    _kitchenComfort = value;
                  });
                },
                divisions: 10,
                label: _kitchenComfort.toStringAsFixed(0),
              ),
              Expanded(
                child: Text('Very comfortable',
                    textAlign: TextAlign.right,
                    style: GoogleFonts.dmSans(
                      color: text,
                    )),
              ),
            ],
          ),
          SizedBox(height: 16),
          questionWidget('How long can you spend on cooking daily?'),
          SizedBox(height: 16),
          subtextWidget('Select the time you can spend cooking each day'),
          Column(
            children: [
              RadioListTile(
                title: Text('Quick 10-20 mins', style: GoogleFonts.dmSans()),
                value: 'Quick 10-20 mins',
                groupValue: _cookingTime,
                onChanged: (value) {
                  setState(() {
                    _cookingTime = value as String?;
                  });
                },
              ),
              RadioListTile(
                title: Text('Moderate 30-40 mins', style: GoogleFonts.dmSans()),
                value: 'Moderate 30-40 mins',
                groupValue: _cookingTime,
                onChanged: (value) {
                  setState(() {
                    _cookingTime = value as String?;
                  });
                },
              ),
              RadioListTile(
                title: Text('High 50+ minutes', style: GoogleFonts.dmSans()),
                value: 'High 50+ minutes',
                groupValue: _cookingTime,
                onChanged: (value) {
                  setState(() {
                    _cookingTime = value as String?;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPage5() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          questionWidget('What cuisines do you like eating?'),
          SizedBox(height: 16),
          subtextWidget('Select any cuisines you enjoy eating'),
          Wrap(
            spacing: 10.0,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ChoiceChip(
                    labelPadding: EdgeInsets.all(10),
                    label: Text('American',
                        style: GoogleFonts.dmSans(
                          fontSize: _fontSizeBox.get('medium'),
                        )),
                    selected: _favoriteCuisines.contains('American'),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _favoriteCuisines.add('American');
                        } else {
                          _favoriteCuisines.remove('American');
                        }
                      });
                    }),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ChoiceChip(
                    labelPadding: EdgeInsets.all(10),
                    label: Text('Mexican',
                        style: GoogleFonts.dmSans(
                          fontSize: _fontSizeBox.get('medium'),
                        )),
                    selected: _favoriteCuisines.contains('Mexican'),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _favoriteCuisines.add('Mexican');
                        } else {
                          _favoriteCuisines.remove('Mexican');
                        }
                      });
                    }),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ChoiceChip(
                    labelPadding: EdgeInsets.all(10),
                    label: Text('Italian',
                        style: GoogleFonts.dmSans(
                          fontSize: _fontSizeBox.get('medium'),
                        )),
                    selected: _favoriteCuisines.contains('Italian'),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _favoriteCuisines.add('Italian');
                        } else {
                          _favoriteCuisines.remove('Italian');
                        }
                      });
                    }),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ChoiceChip(
                    labelPadding: EdgeInsets.all(10),
                    label: Text('Thai',
                        style: GoogleFonts.dmSans(
                          fontSize: _fontSizeBox.get('medium'),
                        )),
                    selected: _favoriteCuisines.contains('Thai'),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _favoriteCuisines.add('Thai');
                        } else {
                          _favoriteCuisines.remove('Thai');
                        }
                      });
                    }),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ChoiceChip(
                    labelPadding: EdgeInsets.all(10),
                    label: Text('North Indian',
                        style: GoogleFonts.dmSans(
                          fontSize: _fontSizeBox.get('medium'),
                        )),
                    selected: _favoriteCuisines.contains('North Indian'),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _favoriteCuisines.add('North Indian');
                        } else {
                          _favoriteCuisines.remove('North Indian');
                        }
                      });
                    }),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ChoiceChip(
                    labelPadding: EdgeInsets.all(10),
                    label: Text('South Indian',
                        style: GoogleFonts.dmSans(
                          fontSize: _fontSizeBox.get('medium'),
                        )),
                    selected: _favoriteCuisines.contains('South Indian'),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _favoriteCuisines.add('South Indian');
                        } else {
                          _favoriteCuisines.remove('South Indian');
                        }
                      });
                    }),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ChoiceChip(
                    labelPadding: EdgeInsets.all(10),
                    label: Text('South Korean',
                        style: GoogleFonts.dmSans(
                          fontSize: _fontSizeBox.get('medium'),
                        )),
                    selected: _favoriteCuisines.contains('South Korean'),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _favoriteCuisines.add('South Korean');
                        } else {
                          _favoriteCuisines.remove('South Korean');
                        }
                      });
                    }),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ChoiceChip(
                    labelPadding: EdgeInsets.all(10),
                    label: Text('Japanese',
                        style: GoogleFonts.dmSans(
                          fontSize: _fontSizeBox.get('medium'),
                        )),
                    selected: _favoriteCuisines.contains('Japanese'),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _favoriteCuisines.add('Japanese');
                        } else {
                          _favoriteCuisines.remove('Japanese');
                        }
                      });
                    }),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ChoiceChip(
                    labelPadding: EdgeInsets.all(10),
                    label: Text('Chinese',
                        style: GoogleFonts.dmSans(
                          fontSize: _fontSizeBox.get('medium'),
                        )),
                    selected: _favoriteCuisines.contains('Chinese'),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _favoriteCuisines.add('Chinese');
                        } else {
                          _favoriteCuisines.remove('Chinese');
                        }
                      });
                    }),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ChoiceChip(
                    labelPadding: EdgeInsets.all(10),
                    label: Text('Greek',
                        style: GoogleFonts.dmSans(
                          fontSize: _fontSizeBox.get('medium'),
                        )),
                    selected: _favoriteCuisines.contains('Greek'),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _favoriteCuisines.add('Greek');
                        } else {
                          _favoriteCuisines.remove('Greek');
                        }
                      });
                    }),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ChoiceChip(
                    labelPadding: EdgeInsets.all(10),
                    label: Text('French',
                        style: GoogleFonts.dmSans(
                          fontSize: _fontSizeBox.get('medium'),
                        )),
                    selected: _favoriteCuisines.contains('French'),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _favoriteCuisines.add('French');
                        } else {
                          _favoriteCuisines.remove('French');
                        }
                      });
                    }),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ChoiceChip(
                    labelPadding: EdgeInsets.all(10),
                    label: Text('Spanish',
                        style: GoogleFonts.dmSans(
                          fontSize: _fontSizeBox.get('medium'),
                        )),
                    selected: _favoriteCuisines.contains('Spanish'),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _favoriteCuisines.add('Spanish');
                        } else {
                          _favoriteCuisines.remove('Spanish');
                        }
                      });
                    }),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ChoiceChip(
                    labelPadding: EdgeInsets.all(10),
                    label: Text('Middle Eastern',
                        style: GoogleFonts.dmSans(
                          fontSize: _fontSizeBox.get('medium'),
                        )),
                    selected: _favoriteCuisines.contains('Middle Eastern'),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _favoriteCuisines.add('Middle Eastern');
                        } else {
                          _favoriteCuisines.remove('Middle Eastern');
                        }
                      });
                    }),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ChoiceChip(
                    labelPadding: EdgeInsets.all(10),
                    label: Text('Mediterranean',
                        style: GoogleFonts.dmSans(
                          fontSize: _fontSizeBox.get('medium'),
                        )),
                    selected: _favoriteCuisines.contains('Mediterranean'),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _favoriteCuisines.add('Mediterranean');
                        } else {
                          _favoriteCuisines.remove('Mediterranean');
                        }
                      });
                    }),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ChoiceChip(
                    labelPadding: EdgeInsets.all(10),
                    label: Text('All Cuisines',
                        style: GoogleFonts.dmSans(
                          fontSize: _fontSizeBox.get('medium'),
                        )),
                    selected: _favoriteCuisines.contains('All Cuisines'),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _favoriteCuisines.add('All Cuisines');
                        } else {
                          _favoriteCuisines.remove('All Cuisines');
                        }
                      });
                    }),
              ),
            ],
          ),
          SizedBox(height: 16),
          otherOption(_otherCuisine, 'Other cuisine'),
        ],
      ),
    );
  }

  Widget _buildSummaryPage() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 80, 16, 16),
      child: ListView(
        children: [
          Center(
              child: questionWidget(
                  'All Set! Here is a summary of your preferences')),
          SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
            decoration: BoxDecoration(
              border: Border.all(color: primary),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 10, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Dietary Preferences: ${_dietaryPreferences.join(', ')}',
                      style: GoogleFonts.dmSans(
                          fontSize: _fontSizeBox.get('large'), color: text)),
                  Text('Skin Type: ${_skinType ?? _otherSkinType}',
                      style: GoogleFonts.dmSans(
                          fontSize: _fontSizeBox.get('large'), color: text)),
                  Text('Weight Goal: ${_weightGoal ?? _otherGoal}',
                      style: GoogleFonts.dmSans(
                          fontSize: _fontSizeBox.get('large'), color: text)),
                  Text('Gut-Health: ${_stoolType ?? _otherStoolType}',
                      style: GoogleFonts.dmSans(
                          fontSize: _fontSizeBox.get('large'), color: text)),
                  Text('Kitchen Comfort: ${_kitchenComfort.toStringAsFixed(0)}',
                      style: GoogleFonts.dmSans(
                          fontSize: _fontSizeBox.get('large'), color: text)),
                  Text('Cooking Time: ${_cookingTime ?? 'Not Specified'}',
                      style: GoogleFonts.dmSans(
                          fontSize: _fontSizeBox.get('large'), color: text)),
                  Text('Favorite Cuisines: ${_favoriteCuisines.join(', ')}',
                      style: GoogleFonts.dmSans(
                          fontSize: _fontSizeBox.get('large'), color: text)),
                  Text('Other Cuisine: ${_otherCuisine ?? 'None'}',
                      style: GoogleFonts.dmSans(
                          fontSize: _fontSizeBox.get('large'), color: text)),
                  Text('Allergies: ${_allergies ?? 'None'}',
                      style: GoogleFonts.dmSans(
                          fontSize: _fontSizeBox.get('large'), color: text)),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: _fontSizeBox.get('large'),
                color: primary,
              ),
              "We take user privacy seriously. Your information is secure and will only be used to personalize your meal recommendations.")
        ],
      ),
    );
  }
}
