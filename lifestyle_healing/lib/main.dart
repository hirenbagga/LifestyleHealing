import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food/Mood/Poop Journal',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const JournalHomePage(),
    );
  }
}

class JournalHomePage extends StatefulWidget {
  const JournalHomePage({super.key});

  @override
  State<JournalHomePage> createState() => _JournalHomePageState();
}

class _JournalHomePageState extends State<JournalHomePage> {
  final List<Map<String, dynamic>> foodLogs = [];
  final List<Map<String, dynamic>> moodLogs = [];
  final List<Map<String, dynamic>> poopLogs = [];

  final TextEditingController _foodController = TextEditingController();
  final TextEditingController _foodQuantityController = TextEditingController();
  final TextEditingController _moodController = TextEditingController();
  final TextEditingController _poopQualityController = TextEditingController();

  String? _selectedLogType;
  DateTime _selectedDateTime = DateTime.now();
  String? _selectedPoopType;

  final List<String> logTypes = ['Food', 'Mood', 'Poop'];
  final List<String> poopTypes = [
    'Normal',
    'Hard',
    'Loose',
    'Watery',
    'Pebble-like',
    'Other'
  ];

  // List of known food items for suggestions
  final List<String> knownFoods = [
    'Banana',
    'Chicken Breast',
    'Rice',
    'Apple',
    'Eggs',
    'Broccoli',
    'Salmon',
    'Oatmeal',
    'Almonds',
    'Yogurt',
    'Spinach',
    'Beef',
    'Potato',
    'Carrot',
    'Orange',
    'Tofu',
    'Milk',
    'Cheese',
    'Bread',
    'Pasta',
  ];

  void _submitLog() {
    if (_selectedLogType == 'Food' &&
        _foodController.text.isNotEmpty &&
        _foodQuantityController.text.isNotEmpty) {
      setState(() {
        foodLogs.add({
          'food': _foodController.text,
          'quantity': _foodQuantityController.text,
          'dateTime': _selectedDateTime,
        });
        _foodController.clear();
        _foodQuantityController.clear();
      });
    } else if (_selectedLogType == 'Mood' && _moodController.text.isNotEmpty) {
      setState(() {
        moodLogs.add({
          'mood': _moodController.text,
          'dateTime': _selectedDateTime,
        });
        _moodController.clear();
      });
    } else if (_selectedLogType == 'Poop' &&
        _selectedPoopType != null &&
        _poopQualityController.text.isNotEmpty) {
      setState(() {
        poopLogs.add({
          'type': _selectedPoopType,
          'quality': _poopQualityController.text,
          'dateTime': _selectedDateTime,
        });
        _selectedPoopType = null;
        _poopQualityController.clear();
      });
    }
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );
    if (time == null) return;
    setState(() {
      _selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food/Mood/Poop Journal'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedLogType,
                hint: const Text('Select log type'),
                items: logTypes
                    .map((type) =>
                        DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedLogType = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              if (_selectedLogType != null)
                Row(
                  children: [
                    Text(
                      'Date/Time: ${_selectedDateTime.toString().substring(0, 16)}',
                    ),
                    TextButton(
                      onPressed: _pickDateTime,
                      child: const Text('Change'),
                    ),
                  ],
                ),
              if (_selectedLogType == 'Food') ...[
                Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text == '') {
                      return const Iterable<String>.empty();
                    }
                    return knownFoods.where((String option) {
                      return option
                          .toLowerCase()
                          .contains(textEditingValue.text.toLowerCase());
                    });
                  },
                  fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                    _foodController.value = controller.value;
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        labelText: 'What did you eat/drink?',
                      ),
                      onEditingComplete: onEditingComplete,
                    );
                  },
                  onSelected: (String selection) {
                    _foodController.text = selection;
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _foodQuantityController,
                  decoration: const InputDecoration(
                    labelText: 'Quantity (e.g. 1 cup, 2 pieces, 150g)',
                  ),
                  keyboardType: TextInputType.text,
                ),
              ],
              if (_selectedLogType == 'Mood')
                TextField(
                  controller: _moodController,
                  decoration: const InputDecoration(
                    labelText: 'How do you feel?',
                  ),
                ),
              if (_selectedLogType == 'Poop') ...[
                DropdownButtonFormField<String>(
                  value: _selectedPoopType,
                  hint: const Text('Select poop type'),
                  items: poopTypes
                      .map((type) =>
                          DropdownMenuItem(value: type, child: Text(type)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPoopType = value;
                    });
                  },
                ),
                TextField(
                  controller: _poopQualityController,
                  decoration: const InputDecoration(
                    labelText: 'Quality/Notes',
                  ),
                ),
              ],
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _submitLog,
                child: const Text('Add Entry'),
              ),
              const Divider(height: 32),
              const Text('Food Logs', style: TextStyle(fontWeight: FontWeight.bold)),
              ...foodLogs.map((log) => ListTile(
                    title: Text('${log['food']} (${log['quantity']})'),
                    subtitle: Text(log['dateTime'].toString()),
                  )),
              const Divider(),
              const Text('Mood Logs', style: TextStyle(fontWeight: FontWeight.bold)),
              ...moodLogs.map((log) => ListTile(
                    title: Text(log['mood']),
                    subtitle: Text(log['dateTime'].toString()),
                  )),
              const Divider(),
              const Text('Poop Logs', style: TextStyle(fontWeight: FontWeight.bold)),
              ...poopLogs.map((log) => ListTile(
                    title: Text('${log['type']} - ${log['quality']}'),
                    subtitle: Text(log['dateTime'].toString()),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}