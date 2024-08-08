import 'dart:ui';

import 'package:hive/hive.dart';

part 'message.g.dart';

@HiveType(typeId: 0)
class Message {
  @HiveField(0)
  final String text;

  @HiveField(1)
  final bool isUserMessage;

  Message({
    required this.text,
    required this.isUserMessage,
  });
}
