import 'package:hive/hive.dart';
part 'ingredients.g.dart';

@HiveType(typeId: 2)
class Ingredients extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  bool like;

  Ingredients({
    required this.name,
    required this.like,
  });
}
