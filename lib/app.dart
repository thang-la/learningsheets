import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/lesson_screen.dart';
import 'models/vocabulary_item.dart';

class VocabularyApp extends StatelessWidget {
  const VocabularyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vocabulary Learner',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
      onGenerateRoute: (RouteSettings settings) {
        if (settings.name == '/lessons') {
          final args = settings.arguments;
          if (args is List<VocabularyItem>) {
            return MaterialPageRoute(
              builder: (context) => LessonScreen(vocabularyList: args),
            );
          }
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: const Text('Error')),
              body: const Center(child: Text('Invalid arguments passed to Lessons')),
            ),
          );
        }
        return null;
      },
    );
  }
}