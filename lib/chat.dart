import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nutria/services/message.dart';
import 'package:nutria/services/utilities.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  late Box<Message> _messageBox;
  bool _isWaitingForResponse = false;
  String _apiKey = dotenv.env['GEMINI_API_KEY'];
  late final GenerativeModel _model;
  late final ChatSession _chat;
  final ScrollController _scrollController = ScrollController();
  final FocusNode _textFieldFocus = FocusNode();
  final List<Message> _generatedContent = <Message>[];
  bool _loading = false;
  bool useLastChat = false;

  @override
  void initState() {
    super.initState();
    _initHive();
    _model = GenerativeModel(
        model: 'gemini-1.5-flash-latest',
        apiKey: _apiKey,
        systemInstruction: Content.text(getContext()),
        generationConfig: GenerationConfig(
          candidateCount: 1,
          maxOutputTokens: 300,
        ));
    _chat = _model.startChat();
  }

  Future<void> _initHive() async {
    try {
      await Hive.openBox<Message>('messages');
      await Hive.openBox('font_size');
      setState(() {
        _messageBox = Hive.box<Message>('messages');
      });
      if (_messageBox.isNotEmpty) {
        _showLoadChatDialog();
      }
    } catch (e) {
      _showErrorDialog('Internet Issues, try again later!');
    }
  }

  void _showLoadChatDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Load Last Chat', style: GoogleFonts.dmSans(color: text)),
          content: Text('Do you want to load your last chat?',
              style: GoogleFonts.dmSans(color: text)),
          actions: <Widget>[
            TextButton(
              child: Text('No', style: GoogleFonts.dmSans(color: text)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Yes', style: GoogleFonts.dmSans(color: text)),
              onPressed: () {
                setState(() {
                  useLastChat = true;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _clearMessageHistory() async {
    await _messageBox.clear();
    setState(() {
      _generatedContent.clear();
    });
  }

  Widget _buildMessageItem(Message message) {
    bool isUserMessage = message.isUserMessage;
    return ListTile(
      leading: isUserMessage
          ? null
          : CircleAvatar(
              child: Image.asset("lib/assets/images/nutria_logo.png"),
              backgroundColor: Colors.white,
            ),
      trailing: !isUserMessage
          ? null
          : CircleAvatar(
              child: Icon(
                Icons.person_outlined,
                color: bg,
              ),
              backgroundColor: subtext,
            ),
      title: Align(
        alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: isUserMessage ? secCol : primary,
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Text(
            message.text,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
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

  String con = "";

  String getContext() {
    String diet = _getSafeString(
        "dietary_preferences: ${Hive.box('form_data').get('dietary_preferences')}");
    String skin_type =
        _getSafeString("skin_type: ${Hive.box('form_data').get('skin_type')}");
    String other_skin = _getSafeString(
        "other skin type: ${Hive.box('form_data').get('other_skin_type')}");
    String weight_goal = _getSafeString(
        "weight goal: ${Hive.box('form_data').get('weight_goal')}");
    String other_goal = _getSafeString(
        "gut-health: ${Hive.box('form_data').get('other_goal')}");
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
    String allergies =
        _getSafeString("allergies: ${Hive.box('form_data').get('allergies')}");

    return "Hi, you are my Nutritionist called Nutria and you will help me with any food-related advice or general chatting, here is some info about me!: \n$diet\n$skin_type\n$other_skin\n$weight_goal\n$other_goal\n$stool\n$other_stool\n$kitchen\n$cooking_time\n$fav_cuisines\n$other_cuisines\n$allergies";
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildMessageList(bool loadLastChat) {
    if (loadLastChat) {
      return _messageBox.isEmpty
          ? Center(
              child: Text(
                'Start chatting with Nutria!',
                style: GoogleFonts.dmSans(color: text, fontSize: 16),
              ),
            )
          : ListView.builder(
              reverse: true,
              itemCount: _messageBox.length,
              itemBuilder: (context, index) {
                return _buildMessageItem(
                    _messageBox.getAt(_messageBox.length - index - 1)!);
              },
            );
    } else {
      return _generatedContent.isEmpty
          ? Center(
              child: Text(
                'Start chatting with Nutria!',
                style: GoogleFonts.dmSans(color: text, fontSize: 16),
              ),
            )
          : ListView.builder(
              reverse: true,
              itemCount: _generatedContent.length,
              itemBuilder: (context, index) {
                return _buildMessageItem(
                    _generatedContent[_generatedContent.length - index - 1]);
              },
            );
    }
  }

  String getConversationHistory() {
    StringBuffer conversationHistory = StringBuffer();

    for (var message in _messageBox.values) {
      if (message.isUserMessage) {
        conversationHistory.write('User: ${message.text}\n');
      } else {
        conversationHistory.write('Nutria: ${message.text}\n');
      }
    }

    return conversationHistory.toString();
  }

  Future<void> _sendMessage(String message) async {
    setState(() {
      _loading = true;
    });

    try {
      _generatedContent.add(Message(text: message, isUserMessage: true));
      Message newMessage = Message(text: message, isUserMessage: true);
      await _messageBox.add(newMessage);
      print(getConversationHistory());
      final response = await _chat.sendMessage(
        Content.text(
            "conversation_history: $getConversationHistory()\n\n$message"),
      );
      final text = response.text;
      _generatedContent.add(Message(text: text!, isUserMessage: false));
      newMessage = Message(text: text, isUserMessage: false);
      await _messageBox.add(newMessage);

      if (text == null) {
        _showErrorDialog('No response from API.');
        return;
      } else {
        setState(() {
          _loading = false;
        });
      }
    } catch (e) {
      _showErrorDialog(e.toString());
      setState(() {
        _loading = false;
      });
    } finally {
      _textController.clear();
      setState(() {
        _loading = false;
      });
      _textFieldFocus.requestFocus();
    }
  }

  Future<void> _sendImage(String message) async {
    setState(() {
      _loading = true;
    });
    try {
      if (kIsWeb) {
        PlatformFile? imageFile = await FilePicker.platform
            .pickFiles(
              type: FileType.image,
              allowCompression: true,
            )
            .then((value) => value?.files.first);

        String type = imageFile!.name.split('.').last;
        print(type);

        Uint8List bytes = imageFile.bytes!;

        Message newMessage = Message(text: message, isUserMessage: true);
        await _messageBox.add(newMessage);

        print(getConversationHistory());
        final content = [
          Content.multi([
            TextPart("conversation_history: " +
                getConversationHistory() +
                "\n" +
                message),
            DataPart("image/$type", bytes!),
          ])
        ];

        var response = await _model.generateContent(content);
        var text = response.text;
        _generatedContent.add(Message(text: text!, isUserMessage: false));
        newMessage = Message(text: text, isUserMessage: false);
        await _messageBox.add(newMessage);
      } else {
        final picker = ImagePicker();
        final pickedFile = await picker.pickImage(source: ImageSource.gallery);

        final bytes = await pickedFile!.readAsBytes();
        final type = pickedFile.path.split('.').last;

        Message newMessage = Message(text: message, isUserMessage: true);
        await _messageBox.add(newMessage);
        final content = [
          Content.multi([
            TextPart("conversation_history: " +
                getConversationHistory() +
                "\n" +
                message),
            DataPart("image/$type", bytes),
          ])
        ];

        var response = await _model.generateContent(content);
        var text = response.text;
        _generatedContent.add(Message(text: text!, isUserMessage: false));

        newMessage = Message(text: text, isUserMessage: false);
        await _messageBox.add(newMessage);
      }

      if (text == null) {
        _showErrorDialog('No response from API.');
        return;
      } else {
        setState(() {
          _loading = false;
        });
      }
    } catch (e) {
      print("hello: " + e.toString());
      _showErrorDialog("Try again!");

      setState(() {
        _loading = false;
      });
    } finally {
      _textController.clear();
      setState(() {
        _loading = false;
      });
      _textFieldFocus.requestFocus();
    }
  }

  void _showError(String message) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Something went wrong'),
          content: SingleChildScrollView(
            child: SelectableText(message),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            )
          ],
        );
      },
    );
  }

  void _settingsBar() {
    setState(() {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Center(
              child: Row(children: [
                Text('Welcome to Nutria Chat',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      color: text,
                      fontSize: 17,
                    )),
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.close,
                      color: text,
                      size: 20,
                    ))
              ]),
            ),
            content: Text(
              textAlign: TextAlign.center,
              'You can talk to Nutria here! \n\nYou can ask about anything related to food or health.\n\nAs long as you have good internet, Nutria will be responding promptly. \n\nEnjoy chatting with Nutria!',
              style: GoogleFonts.dmSans(color: text, fontSize: 16),
            ),
            actions: [
              ListTile(
                tileColor: primary,
                leading: Icon(
                  Icons.delete,
                  color: bg,
                ),
                title: Center(
                    child: Text('Clear Message History',
                        style: GoogleFonts.dmSans(color: bg))),
                onTap: () {
                  _clearMessageHistory();
                  Navigator.pop(context);
                },
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
      appBar: AppBar(
        backgroundColor: primary,
        title: Text('Chat with Nutria', style: GoogleFonts.dmSans(color: bg)),
        leading: IconButton(
          onPressed: () {
            Navigator.pushNamed(context, '/home');
          },
          icon: Icon(Icons.home_outlined, color: bg),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.more_vert, color: bg),
            onPressed: _settingsBar,
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(child: _buildMessageList(useLastChat)),
          Divider(height: 1.0),
          Padding(
            padding: EdgeInsets.all(15.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _textController,
                    onSubmitted: _sendMessage,
                    decoration: InputDecoration(
                      hintText: 'Enter message...',
                      hintStyle:
                          GoogleFonts.dmSans(color: subtext, fontSize: 16),
                      contentPadding: EdgeInsets.all(10.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.image),
                  onPressed: () {
                    setState(() {
                      _sendImage(_textController.text);
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
