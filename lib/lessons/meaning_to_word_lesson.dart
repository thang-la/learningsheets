import 'package:flutter/material.dart';
import '../models/vocabulary_item.dart';

class MeaningToWordLesson extends StatefulWidget {
  final List<VocabularyItem> vocabularyList;

  const MeaningToWordLesson({super.key, required this.vocabularyList});

  @override
  State<MeaningToWordLesson> createState() => _MeaningToWordLessonState();
}

class _MeaningToWordLessonState extends State<MeaningToWordLesson>
    with TickerProviderStateMixin {
  late List<VocabularyItem> _questions;
  int _currentIndex = 0;
  int _score = 0;
  final TextEditingController _controller = TextEditingController();
  String? _feedback;
  bool _showNextButton = false;
  bool _isCorrect = false;

  late AnimationController _cardAnimationController;
  late AnimationController _feedbackAnimationController;
  late AnimationController _progressAnimationController;
  late AnimationController _pulseController;

  late Animation<double> _cardAnimation;
  late Animation<double> _feedbackAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _questions = [...widget.vocabularyList]..shuffle();

    // Initialize animations
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _feedbackAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _cardAnimation = CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.elasticOut,
    );
    _feedbackAnimation = CurvedAnimation(
      parent: _feedbackAnimationController,
      curve: Curves.bounceOut,
    );
    _progressAnimation = CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.easeInOut,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _cardAnimationController, curve: Curves.elasticOut));

    _loadQuestion();
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    _feedbackAnimationController.dispose();
    _progressAnimationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _loadQuestion() {
    _controller.clear();
    _feedback = null;
    _showNextButton = false;
    _isCorrect = false;

    // Reset and start animations
    _cardAnimationController.reset();
    _feedbackAnimationController.reset();
    _cardAnimationController.forward();

    // Update progress animation
    _progressAnimationController.animateTo((_currentIndex + 1) / _questions.length);
  }

  void _checkAnswer() {
    final correctWord = _questions[_currentIndex].word.trim().toLowerCase();
    final userAnswer = _controller.text.trim().toLowerCase();

    setState(() {
      _isCorrect = userAnswer == correctWord;
      if (_isCorrect) {
        _feedback = "🎉 Excellent!";
        _score++;
        _pulseController.repeat(reverse: true);
      } else {
        _feedback = "Try again! The answer is: ${_questions[_currentIndex].word}";
      }
      _showNextButton = true;
    });

    _feedbackAnimationController.forward();
  }

  void _nextQuestion() {
    _pulseController.stop();
    _pulseController.reset();

    setState(() {
      _currentIndex++;
      if (_currentIndex >= _questions.length) {
        _showCompletionDialog();
        return;
      }
      _loadQuestion();
    });
  }

  void _showCompletionDialog() {
    final percentage = (_score / _questions.length * 100).round();
    String emoji = percentage >= 80 ? "🏆" : percentage >= 60 ? "🎉" : "💪";
    String message = percentage >= 80
        ? "Outstanding performance!"
        : percentage >= 60
        ? "Well done!"
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
                Colors.indigo.shade400,
                Colors.purple.shade500,
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
              const Text(
                'Lesson Completed!',
                style: TextStyle(
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
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        setState(() {
                          _currentIndex = 0;
                          _score = 0;
                          _questions.shuffle();
                          _loadQuestion();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        'Try Again',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context)
                          ..pop()
                          ..pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.indigo.shade600,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        'Finish',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vocab = _questions[_currentIndex];

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
                        '🧩 Meaning to Word',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
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
              ),

              // Progress Section
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
                        Text(
                          '${((_currentIndex + 1) / _questions.length * 100).round()}%',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
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
                  child: AnimatedBuilder(
                    animation: _cardAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _cardAnimation.value,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _isCorrect ? _pulseAnimation.value : 1.0,
                                child: Column(
                                  children: [
                                    // Question Card
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(24),
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
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [Colors.blue.shade400, Colors.indigo.shade400],
                                              ),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: const Text(
                                              'What word has this meaning?',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 24),
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(20),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [Colors.blue.shade50, Colors.indigo.shade50],
                                              ),
                                              borderRadius: BorderRadius.circular(16),
                                              border: Border.all(color: Colors.blue.shade200),
                                            ),
                                            child: Text(
                                              vocab.meaning,
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey.shade800,
                                                height: 1.4,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: Colors.green.shade100,
                                              borderRadius: BorderRadius.circular(20),
                                              border: Border.all(color: Colors.green.shade300),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.category,
                                                  size: 16,
                                                  color: Colors.green.shade700,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  vocab.partOfSpeech,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.green.shade700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 32),

                                    // Input Field
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: TextField(
                                        controller: _controller,
                                        enabled: !_showNextButton,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 24,
                                          letterSpacing: 1.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'Type your answer here...',
                                          hintStyle: TextStyle(
                                            color: Colors.grey.shade400,
                                            fontSize: 16,
                                            fontWeight: FontWeight.normal,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(16),
                                            borderSide: BorderSide.none,
                                          ),
                                          filled: true,
                                          fillColor: Colors.grey.shade50,
                                          contentPadding: const EdgeInsets.all(20),
                                        ),
                                        onSubmitted: (_) => !_showNextButton ? _checkAnswer() : null,
                                      ),
                                    ),

                                    const SizedBox(height: 24),

                                    // Feedback Section
                                    if (_feedback != null)
                                      AnimatedBuilder(
                                        animation: _feedbackAnimation,
                                        builder: (context, child) {
                                          return Transform.scale(
                                            scale: _feedbackAnimation.value,
                                            child: Container(
                                              width: double.infinity,
                                              padding: const EdgeInsets.all(20),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: _isCorrect
                                                      ? [Colors.green.shade400, Colors.teal.shade400]
                                                      : [Colors.red.shade400, Colors.pink.shade400],
                                                ),
                                                borderRadius: BorderRadius.circular(16),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: _isCorrect
                                                        ? Colors.green.withOpacity(0.3)
                                                        : Colors.red.withOpacity(0.3),
                                                    blurRadius: 15,
                                                    offset: const Offset(0, 8),
                                                  ),
                                                ],
                                              ),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white.withOpacity(0.2),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Icon(
                                                      _isCorrect ? Icons.check : Icons.close,
                                                      color: Colors.white,
                                                      size: 24,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Expanded(
                                                    child: Text(
                                                      _feedback!,
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),

                                    const Spacer(),

                                    // Action Button
                                    AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 300),
                                      child: _showNextButton
                                          ? Container(
                                        key: const ValueKey('next'),
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [Colors.green.shade400, Colors.teal.shade400],
                                          ),
                                          borderRadius: BorderRadius.circular(16),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.green.withOpacity(0.4),
                                              blurRadius: 15,
                                              offset: const Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                        child: ElevatedButton.icon(
                                          onPressed: _nextQuestion,
                                          icon: const Icon(Icons.arrow_forward, color: Colors.white),
                                          label: const Text(
                                            'Next Question',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            padding: const EdgeInsets.symmetric(vertical: 16),
                                          ),
                                        ),
                                      )
                                          : Container(
                                        key: const ValueKey('check'),
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [Colors.indigo.shade400, Colors.purple.shade400],
                                          ),
                                          borderRadius: BorderRadius.circular(16),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.indigo.withOpacity(0.4),
                                              blurRadius: 15,
                                              offset: const Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                        child: ElevatedButton.icon(
                                          onPressed: _controller.text.trim().isNotEmpty ? _checkAnswer : null,
                                          icon: const Icon(Icons.check, color: Colors.white),
                                          label: const Text(
                                            'Check Answer',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            padding: const EdgeInsets.symmetric(vertical: 16),
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 20),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
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