import 'dart:developer';
import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:mtra/firebase_options.dart';
import 'package:mtra/firefun/firbase_fun.dart';
import 'package:mtra/model/tramodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const TranslatorApp());
}

class TranslatorApp extends StatelessWidget {
  const TranslatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Malayalam Translator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const TranslatorScreen(),
    );
  }
}

class TranslationPair {
  final String malayalam;
  final String english;

  TranslationPair({required this.malayalam, required this.english});
}

class TranslatorScreen extends StatefulWidget {
  const TranslatorScreen({super.key});

  @override
  State<TranslatorScreen> createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends State<TranslatorScreen> {
  final TextEditingController _translationController = TextEditingController();
  String _feedbackMessage = '';
  Color _feedbackColor = Colors.black;
  final Random _random = Random();
  bool isbutt = false;

  // List<TranslationPair> _allSentences = [
  //   TranslationPair(
  //       malayalam: 'എനിക്ക് മലയാളം അറിയാം', english: 'I know Malayalam'),
  //   TranslationPair(malayalam: 'സുപ്രഭാതം', english: 'Good morning'),
  //   TranslationPair(malayalam: 'നന്ദി', english: 'Thank you')
  // ];

  late List<TranslationPairmodel> _remainingSentences;
  late TranslationPairmodel _currentSentence;

  @override
  void initState() {
    super.initState();
    _loadTranslations();
    _initializeRemainingList();
  }

  List<TranslationPairmodel> _translations = [];

  Future<void> _loadTranslations() async {
    final translations = await FirebaseFunctionfecth().fetchTranslationPairs();
    print('mm$translations');
    // translations
    setState(() {
      _translations = translations;
    });
    _initializeRemainingList();
  }

  void _initializeRemainingList() {
    _remainingSentences = List.from(_translations);
    _pickNewSentence();
  }

  void _pickNewSentence() {
    if (_remainingSentences.isEmpty) {
      setState(() {
        _feedbackMessage = 'All sentences completed! Starting new round. 🎉';
        _feedbackColor = Colors.green;
        _remainingSentences = List.from(_translations);
      });
    }
    if (!_remainingSentences.isEmpty) {
      final int randomIndex = _random.nextInt(_remainingSentences.length);
      setState(() {
        _currentSentence = _remainingSentences[randomIndex];
        _remainingSentences.removeAt(randomIndex);
      });
    }
  }

  void _checkTranslation() {
    String userTranslation = _translationController.text.trim().toLowerCase();
    String correctTranslation = _currentSentence.english.toLowerCase();

    setState(() {
      if (userTranslation == correctTranslation) {
        _feedbackMessage = 'Correct! Well done! 👏';
        _feedbackColor = Colors.green;
       isbutt=true;
        // _nextSentence();///timing
      } else {
        _feedbackMessage = 'Incorrect. Try again! 🤔';
        _feedbackColor = Colors.red;
      }
    });
  }

  void _nextSentence() {
    _translationController.clear();
    _feedbackMessage = '';
    _pickNewSentence();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
            onTap: () {
              setState(() {
                isbutt = !isbutt;
              });
            },
            child: Text('enable')),
        title: const Text('Malayalam Translator'),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AddSentenceScreen()));
                //     onSentenceAdded: (TranslationPairmodel newPair) {
                //   setState(() {
                //     _translations.add(newPair);
                //     // Add new sentence to remaining list if we're not at the end
                //     if (_remainingSentences.isNotEmpty) {
                //       _remainingSentences.add(newPair);
                //     }
                //   });
                // })));
              },
              icon: Icon(Icons.add))
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double fontSize = constraints.maxWidth > 600 ? 24 : 16;
          double padding = constraints.maxWidth > 600 ? 32 : 16;
          bool isLargeScreen = constraints.maxWidth > 600;

          return Padding(
            padding: EdgeInsets.all(padding),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: padding),
                    child: Text(
                      'Remaining sentences: ${_remainingSentences.length} / ${_translations.length}',
                      style: TextStyle(fontSize: fontSize),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: EdgeInsets.all(padding),
                      child: Text(
                        _currentSentence.malayalam,
                        style: TextStyle(
                          fontSize: fontSize * 1.5,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  SizedBox(height: padding),
                  TextField(
                    controller: _translationController,
                    decoration: const InputDecoration(
                      labelText: 'Enter English Translation',
                      border: OutlineInputBorder(),
                      hintText: 'Type your translation here...',
                    ),
                    maxLines: 2,
                  ),
                  SizedBox(height: padding),
                  ElevatedButton(
                    onPressed: _checkTranslation,
                    child: const Text('Check Translation'),
                  ),
                  SizedBox(height: padding / 2),
                  isbutt
                      ? ElevatedButton(
                          onPressed: _nextSentence,
                          child: const Text('Next Sentence'),
                        )
                      : SizedBox(),
                  SizedBox(height: padding),
                  if (_feedbackMessage.isNotEmpty)
                    Text(
                      _feedbackMessage,
                      style: TextStyle(
                        fontSize: fontSize * 1.2,
                        color: _feedbackColor,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _translationController.dispose();
    super.dispose();
  }
}

class AddSentenceScreen extends StatefulWidget {
  // final Function(TranslationPair) onSentenceAdded;

  const AddSentenceScreen({
    super.key,
  });

  @override
  State<AddSentenceScreen> createState() => _AddSentenceScreenState();
}

class _AddSentenceScreenState extends State<AddSentenceScreen> {
  final TextEditingController _malayalamController = TextEditingController();
  final TextEditingController _englishController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Sentence'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double padding = constraints.maxWidth > 600 ? 32 : 16;
          bool isLargeScreen = constraints.maxWidth > 600;

          return Padding(
            padding: EdgeInsets.all(padding),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _malayalamController,
                    decoration: const InputDecoration(
                      labelText: 'Malayalam Sentence',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a Malayalam sentence';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: padding),
                  TextFormField(
                    controller: _englishController,
                    decoration: const InputDecoration(
                      labelText: 'English Translation',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an English translation';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: padding),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // widget.onSentenceAdded(
                        //   TranslationPair(
                        //     malayalam: _malayalamController.text,
                        //     english: _englishController.text,
                        //   ),
                        // );
                        FirebaseFunctionfecth().addTranslationPair(
                          TranslationPairmodel(
                            malayalam: _malayalamController.text,
                            english: _englishController.text,
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Sentence added successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Add Sentence'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _malayalamController.dispose();
    _englishController.dispose();
    super.dispose();
  }
}
