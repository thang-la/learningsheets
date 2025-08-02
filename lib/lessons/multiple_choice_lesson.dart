import 'package:flutter/material.dart';
import '../models/vocabulary_item.dart';

class MultipleChoiceLesson extends StatefulWidget {
  final List<VocabularyItem> vocabularyList;

  const MultipleChoiceLesson({
    super.key,
    required this.vocabularyList,
  });

  @override
  State<MultipleChoiceLesson> createState() => _MultipleChoiceLessonState();
}

class _MultipleChoiceLessonState extends State<MultipleChoiceLesson>
    with TickerProviderStateMixin {
  late List<VocabularyItem> _questions;
  late VocabularyItem _currentQuestion;
  late List<String> _choices;
  int _currentIndex = 0;
  int _score = 0;
  bool _answered = false;
  String? _selectedAnswer;

  late AnimationController _cardAnimationController;
  late AnimationController _progressAnimationController;
  late AnimationController _pulseController;
  late Animation<double> _cardAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _questions = [...widget.vocabularyList]..shuffle();

    // Initialize animations
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _cardAnimation = CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.elasticOut,
    );
    _progressAnimation = CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.easeInOut,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _loadQuestion();
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    _progressAnimationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _loadQuestion() {
    setState(() {
      _currentQuestion = _questions[_currentIndex];
      _choices = _generateChoices(_currentQuestion);
      _answered = false;
      _selectedAnswer = null;
    });

    // Animate card entrance
    _cardAnimationController.reset();
    _cardAnimationController.forward();

    // Update progress animation
    _progressAnimationController.animateTo((_currentIndex + 1) / _questions.length);
  }

  List<String> _generateChoices(VocabularyItem correct) {
    final allMeanings = widget.vocabularyList.map((v) => v.meaning).toSet().toList();
    allMeanings.remove(correct.meaning);
    allMeanings.shuffle();
    final wrongChoices = allMeanings.take(3).toList();
    final choices = [...wrongChoices, correct.meaning]..shuffle();
    return choices;
  }

  void _selectAnswer(String choice) {
    if (_answered) return;

    setState(() {
      _answered = true;
      _selectedAnswer = choice;
      if (choice == _currentQuestion.meaning) {
        _score++;
        _pulseController.repeat(reverse: true);
      }
    });

    Future.delayed(const Duration(seconds: 1), () {
      _pulseController.stop();
      _pulseController.reset();

      if (_currentIndex < _questions.length - 1) {
        setState(() {
          _currentIndex++;
        });
        _loadQuestion();
      } else {
        _showResultDialog();
      }
    });
  }

  void _showResultDialog() {
    final percentage = (_score / _questions.length * 100).round();
    String emoji = percentage >= 80 ? "🏆" : percentage >= 60 ? "🎉" : "💪";
    String message = percentage >= 80
        ? "Excellent work!"
        : percentage >= 60
        ? "Good job!"
        : "Keep practicing!";

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 16,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.purple.shade400,
                Colors.indigo.shade600,
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 60),
              ),
              const SizedBox(height: 16),
              Text(
                'Lesson Completed!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      '$_score / ${_questions.length}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '$percentage% Correct',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context)
                    ..pop()
                    ..pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.indigo.shade600,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getButtonColor(String choice) {
    if (!_answered) {
      return Colors.white;
    }
    if (choice == _currentQuestion.meaning) {
      return Colors.green.shade500;
    }
    if (choice == _selectedAnswer) {
      return Colors.red.shade500;
    }
    return Colors.grey.shade100;
  }

  Color _getTextColor(String choice) {
    if (!_answered) return Colors.indigo.shade700;
    if (choice == _currentQuestion.meaning) return Colors.white;
    if (choice == _selectedAnswer) return Colors.white;
    return Colors.grey.shade600;
  }

  Widget? _getAnswerIcon(String choice) {
    if (!_answered) return null;
    if (choice == _currentQuestion.meaning) {
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: const BoxDecoration(
          color: Colors.white24,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, color: Colors.white, size: 16),
      );
    } else if (choice == _selectedAnswer) {
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: const BoxDecoration(
          color: Colors.white24,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.close, color: Colors.white, size: 16),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bool isPortrait = mediaQuery.orientation == Orientation.portrait;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.indigo.shade300,
              Colors.purple.shade400,
              Colors.pink.shade300,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        '🧠 Multiple Choice',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // Progress Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_currentIndex + 1} of ${_questions.length}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.stars, color: Colors.white, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '$_score',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        return LinearProgressIndicator(
                          value: _progressAnimation.value,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                          minHeight: 6,
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // Word Card
                      AnimatedBuilder(
                        animation: _cardAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _cardAnimation.value,
                            child: AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _pulseAnimation.value,
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          'What does this word mean?',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey.shade600,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          _currentQuestion.word,
                                          style: TextStyle(
                                            fontSize: 42,
                                            fontWeight: FontWeight.w900,
                                            // background: Paint()
                                            //   ..shader = LinearGradient(
                                            //     colors: [
                                            //       Colors.indigo.shade300,
                                            //       Colors.purple.shade200,
                                            //     ],
                                            //   ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
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
                        },
                      ),

                      const SizedBox(height: 32),

                      // Choices
                      Expanded(
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _choices.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: isPortrait ? 1 : 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: isPortrait ? 6 : 4,
                          ),
                          itemBuilder: (context, index) {
                            final choice = _choices[index];
                            final bgColor = _getButtonColor(choice);
                            final txtColor = _getTextColor(choice);
                            final icon = _getAnswerIcon(choice);

                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              child: Material(
                                elevation: _answered && choice == _currentQuestion.meaning ? 8 : 4,
                                borderRadius: BorderRadius.circular(16),
                                shadowColor: _answered && choice == _currentQuestion.meaning
                                    ? Colors.green.withOpacity(0.4)
                                    : Colors.black.withOpacity(0.1),
                                child: InkWell(
                                  onTap: () => _selectAnswer(choice),
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: bgColor,
                                      borderRadius: BorderRadius.circular(16),
                                      border: !_answered
                                          ? Border.all(color: Colors.indigo.shade200, width: 2)
                                          : null,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                      child: Row(
                                        children: [
                                          if (icon != null) ...[
                                            icon,
                                            const SizedBox(width: 12),
                                          ],
                                          Expanded(
                                            child: Text(
                                              choice,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: txtColor,
                                              ),
                                              textAlign: TextAlign.left,
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
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}