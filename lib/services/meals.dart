import 'package:hive/hive.dart';
part 'meals.g.dart';

@HiveType(typeId: 1)
class Meals extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String mealType;

  @HiveField(2)
  String imageUrl;

  @HiveField(3)
  String youtubeUrl;

  @HiveField(4)
  String recipeUrl;

  @HiveField(5)
  String tag1;

  @HiveField(6)
  String tag2;

  @HiveField(7)
  String tag3;

  @HiveField(8)
  String cookingTime;

  @HiveField(9)
  String restaurant;

  Meals({
    required this.name,
    required this.mealType,
    required this.imageUrl,
    required this.youtubeUrl,
    required this.recipeUrl,
    required this.tag1,
    required this.tag2,
    required this.tag3,
    required this.cookingTime,
    required this.restaurant,
  });
}
