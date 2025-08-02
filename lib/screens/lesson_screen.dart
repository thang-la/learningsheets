import 'package:flutter/material.dart';
import '../lessons/multiple_choice_lesson.dart';
import '../lessons/spelling_lesson.dart';
import '../lessons/meaning_to_word_lesson.dart';
import '../models/vocabulary_item.dart';

class LessonScreen extends StatefulWidget {
  final List<VocabularyItem> vocabularyList;

  const LessonScreen({super.key, required this.vocabularyList});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen>
    with TickerProviderStateMixin {
  int selectedCount = 10;

  // Animation Controllers
  late AnimationController _slideController;
  late AnimationController _floatingController;
  late AnimationController _pulseController;

  // Animations
  late Animation<Offset> _slideAnimation;
  late Animation<double> _floatingAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Initialize animations
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _floatingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _slideController.forward();
    _floatingController.repeat(reverse: true);
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _slideController.dispose();
    _floatingController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Widget _buildFloatingElements() {
    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        return Stack(
          children: List.generate(8, (index) {
            final random = (index * 0.15) % 1.0;
            final size = 60.0 + (random * 40);
            final opacity = 0.1 + (random * 0.05);

            return Positioned(
              left: MediaQuery.of(context).size.width * random,
              top: 100 + (_floatingAnimation.value * 50) + (random * 300),
              child: Transform.rotate(
                angle: _floatingAnimation.value * 2 * 3.14159 * random,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        Colors.purple.withOpacity(opacity),
                        Colors.transparent,
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

    final lessonItems = [
      {
        'title': 'Multiple Choice',
        'subtitle': 'Pick the correct word based on its meaning',
        'icon': Icons.quiz_rounded,
        'color': [Colors.blue.shade400, Colors.indigo.shade600],
        'emoji': '🧠',
        'difficulty': 'Easy',
      },
      {
        'title': 'Spelling Challenge',
        'subtitle': 'Listen carefully and spell the word correctly',
        'icon': Icons.hearing_rounded,
        'color': [Colors.green.shade400, Colors.teal.shade600],
        'emoji': '🎧',
        'difficulty': 'Medium',
      },
      {
        'title': 'Meaning → Word',
        'subtitle': 'Find the word using its meaning and context',
        'icon': Icons.psychology_rounded,
        'color': [Colors.orange.shade400, Colors.red.shade600],
        'emoji': '🎯',
        'difficulty': 'Hard',
      },
    ];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.shade50,
              Colors.blue.shade50,
              Colors.indigo.shade50,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Floating background elements
            _buildFloatingElements(),

            SafeArea(
              child: Column(
                children: [
                  // Enhanced App Bar
                  Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.white, Colors.grey.shade50],
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.indigo.shade400, Colors.purple.shade500],
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const Expanded(
                          child: Column(
                            children: [
                              Text(
                                '📚 Choose Your Learning Path',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Select a lesson type to begin',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.indigo.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.school_rounded,
                            color: Colors.indigo.shade600,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Word Count Selector with enhanced design
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.white, Colors.grey.shade50],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.purple.shade400, Colors.indigo.shade500],
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.tune_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Words to Practice',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Enhanced Slider
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Select: $selectedCount words',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.indigo.shade700,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.indigo.shade100, Colors.purple.shade100],
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Text(
                                    'Max: ${widget.vocabularyList.length}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.indigo.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: Colors.indigo.shade400,
                                inactiveTrackColor: Colors.indigo.shade100,
                                thumbColor: Colors.indigo.shade600,
                                overlayColor: Colors.indigo.shade100,
                                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                                overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
                              ),
                              child: Slider(
                                value: selectedCount.toDouble(),
                                min: 5,
                                max: widget.vocabularyList.length.toDouble(),
                                divisions: (widget.vocabularyList.length - 4).clamp(1, double.infinity).toInt(),
                                label: selectedCount.toString(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedCount = value.toInt();
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Enhanced Lesson Cards
                  Expanded(
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: lessonItems.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 20),
                        itemBuilder: (context, index) {
                          final lesson = lessonItems[index];
                          final colors = lesson['color'] as List<Color>;

                          return AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _pulseAnimation.value,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: colors,
                                    ),
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: colors[1].withOpacity(0.3),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(24),
                                      onTap: () {
                                        final shuffledList = List<VocabularyItem>.from(widget.vocabularyList)..shuffle();
                                        final selectedWords = shuffledList.take(selectedCount).toList();

                                        final lessonWidget = () {
                                          switch (lesson['title']) {
                                            case 'Multiple Choice':
                                              return MultipleChoiceLesson(vocabularyList: selectedWords);
                                            case 'Spelling Challenge':
                                              return SpellingLesson(vocabularyList: selectedWords);
                                            case 'Meaning → Word':
                                              return MeaningToWordLesson(vocabularyList: selectedWords);
                                            default:
                                              return const SizedBox.shrink();
                                          }
                                        }();

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (_) => lessonWidget),
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(24),
                                        child: Row(
                                          children: [
                                            // Icon Container
                                            Container(
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(20),
                                                border: Border.all(
                                                  color: Colors.white.withOpacity(0.3),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Column(
                                                children: [
                                                  Text(
                                                    lesson['emoji'] as String,
                                                    style: const TextStyle(fontSize: 32),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Icon(
                                                    lesson['icon'] as IconData,
                                                    size: 24,
                                                    color: Colors.white,
                                                  ),
                                                ],
                                              ),
                                            ),

                                            const SizedBox(width: 20),

                                            // Content
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          lesson['title'] as String,
                                                          style: const TextStyle(
                                                            fontSize: 20,
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(
                                                          horizontal: 12,
                                                          vertical: 4,
                                                        ),
                                                        decoration: BoxDecoration(
                                                          color: Colors.white.withOpacity(0.2),
                                                          borderRadius: BorderRadius.circular(12),
                                                        ),
                                                        child: Text(
                                                          lesson['difficulty'] as String,
                                                          style: const TextStyle(
                                                            fontSize: 12,
                                                            fontWeight: FontWeight.w600,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    lesson['subtitle'] as String,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.white70,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 16),

                                                  // Progress indicator
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.timer_outlined,
                                                        size: 16,
                                                        color: Colors.white.withOpacity(0.8),
                                                      ),
                                                      const SizedBox(width: 6),
                                                      Text(
                                                        '~${(selectedCount * 0.5).ceil()} min',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.white.withOpacity(0.8),
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                      const Spacer(),
                                                      Container(
                                                        padding: const EdgeInsets.all(8),
                                                        decoration: BoxDecoration(
                                                          color: Colors.white.withOpacity(0.2),
                                                          shape: BoxShape.circle,
                                                        ),
                                                        child: const Icon(
                                                          Icons.arrow_forward_rounded,
                                                          size: 16,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),

                  // Bottom stats card
                  Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.white, Colors.grey.shade50],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                '${widget.vocabularyList.length}',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo.shade700,
                                ),
                              ),
                              const Text(
                                'Total Words',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.grey.shade300,
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                '$selectedCount',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple.shade700,
                                ),
                              ),
                              const Text(
                                'Selected',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.grey.shade300,
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                '3',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal.shade700,
                                ),
                              ),
                              const Text(
                                'Lesson Types',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}