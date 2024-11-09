import 'package:flutter/material.dart';
import 'dart:math';

void main() {
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
  
  // Main list of all sentences
  List<TranslationPair> _allSentences = [
    TranslationPair(
      malayalam: 'എനിക്ക് മലയാളം അറിയാം',
      english: 'I know Malayalam'
    ),
    TranslationPair(
      malayalam: 'സുപ്രഭാതം',
      english: 'Good morning'
    ),
    TranslationPair(
      malayalam: 'നന്ദി',
      english: 'Thank you'
    )
  ];
  
  // List of remaining sentences to be shown
  late List<TranslationPair> _remainingSentences;
  late TranslationPair _currentSentence;

  @override
  void initState() {
    super.initState();
    _initializeRemainingList();
  }

  void _initializeRemainingList() {
    // Create a new list with all sentences
    _remainingSentences = List.from(_allSentences);
    _pickNewSentence();
  }

  void _pickNewSentence() {
    if (_remainingSentences.isEmpty) {
      // If all sentences have been shown, reset the list
      setState(() {
        _feedbackMessage = 'All sentences completed! Starting new round. 🎉';
        _feedbackColor = Colors.green;
        _remainingSentences = List.from(_allSentences);
      });
    }
    
    // Pick a random sentence from remaining ones
    final int randomIndex = _random.nextInt(_remainingSentences.length);
    setState(() {
      _currentSentence = _remainingSentences[randomIndex];
      // Remove the picked sentence from remaining list
      _remainingSentences.removeAt(randomIndex);
    });
  }

  void _checkTranslation() {
    String userTranslation = _translationController.text.trim().toLowerCase();
    String correctTranslation = _currentSentence.english.toLowerCase();

    setState(() {
      if (userTranslation == correctTranslation) {
        _feedbackMessage = 'Correct! Well done! 👏';
        _feedbackColor = Colors.green;
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
        title: const Text('Malayalam Translator'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddSentenceScreen(
                    onSentenceAdded: (TranslationPair newPair) {
                      setState(() {
                        _allSentences.add(newPair);
                        // Add new sentence to remaining list if we're not at the end
                        if (_remainingSentences.isNotEmpty) {
                          _remainingSentences.add(newPair);
                        }
                      });
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                'Remaining sentences: ${_remainingSentences.length} / ${_allSentences.length}',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _currentSentence.malayalam,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _translationController,
              decoration: const InputDecoration(
                labelText: 'Enter English Translation',
                border: OutlineInputBorder(),
                hintText: 'Type your translation here...',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkTranslation,
              child: const Text('Check Translation'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _nextSentence,
              child: const Text('Next Sentence'),
            ),
            const SizedBox(height: 20),
            if (_feedbackMessage.isNotEmpty)
              Text(
                _feedbackMessage,
                style: TextStyle(
                  fontSize: 18,
                  color: _feedbackColor,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
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
  final Function(TranslationPair) onSentenceAdded;

  const AddSentenceScreen({super.key, required this.onSentenceAdded});

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
              const SizedBox(height: 20),
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
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    widget.onSentenceAdded(
                      TranslationPair(
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