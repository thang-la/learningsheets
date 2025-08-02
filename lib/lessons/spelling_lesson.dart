import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/vocabulary_item.dart';

class SpellingLesson extends StatefulWidget {
  final List<VocabularyItem> vocabularyList;

  const SpellingLesson({
    super.key,
    required this.vocabularyList,
  });

  @override
  State<SpellingLesson> createState() => _SpellingLessonState();
}

class _SpellingLessonState extends State<SpellingLesson>
    with TickerProviderStateMixin {
  final FlutterTts _flutterTts = FlutterTts();
  final TextEditingController _controller = TextEditingController();

  late List<VocabularyItem> _questions;
  late VocabularyItem _currentQuestion;
  int _currentIndex = 0;
  int _score = 0;
  bool _answered = false;
  bool _isSpeaking = false;
  String? _feedback;

  // Animation Controllers
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late AnimationController _shakeController;
  late AnimationController _confettiController;

  // Animations
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shakeAnimation;
  late Animation<double> _confettiAnimation;

  @override
  void initState() {
    super.initState();
    _questions = [...widget.vocabularyList]..shuffle();

    // Initialize animation controllers
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Initialize animations
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticInOut,
    ));

    _confettiAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _confettiController,
      curve: Curves.easeOut,
    ));

    _pulseController.repeat(reverse: true);
    _loadQuestion();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _controller.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _shakeController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _loadQuestion() {
    setState(() {
      _currentQuestion = _questions[_currentIndex];
      _controller.clear();
      _feedback = null;
      _answered = false;
    });

    _slideController.reset();
    _slideController.forward();
  }

  Future<void> _speak() async {
    setState(() {
      _isSpeaking = true;
    });
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(_currentQuestion.word);
    setState(() {
      _isSpeaking = false;
    });
  }

  void _checkAnswer() {
    final userInput = _controller.text.trim().toLowerCase();
    final correct = _currentQuestion.word.toLowerCase();

    setState(() {
      _answered = true;
      if (userInput == correct) {
        _score++;
        _feedback = '✅ Excellent! Perfect spelling!';
        _confettiController.forward();
      } else {
        _feedback = '❌ Almost there! Correct spelling: ${_currentQuestion.word}';
        _shakeController.forward().then((_) => _shakeController.reset());
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (_currentIndex < _questions.length - 1) {
        setState(() {
          _currentIndex++;
        });
        _confettiController.reset();
        _loadQuestion();
      } else {
        _showResultDialog();
      }
    });
  }

  void _showResultDialog() {
    final percentage = (_score / _questions.length * 100).round();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple.shade400, Colors.deepPurple.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const Icon(Icons.celebration, color: Colors.white, size: 48),
              const SizedBox(height: 8),
              const Text(
                'Lesson Completed!',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
        content: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Your Score',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$_score',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple.shade700,
                    ),
                  ),
                  Text(
                    ' / ${_questions.length}',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '$percentage%',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: percentage >= 80 ? Colors.green.shade600 :
                  percentage >= 60 ? Colors.orange.shade600 : Colors.red.shade600,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                percentage >= 80 ? '🌟 Outstanding!' :
                percentage >= 60 ? '👍 Good job!' : '💪 Keep practicing!',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        actions: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
              ),
              onPressed: () {
                Navigator.of(context)
                  ..pop()
                  ..pop();
              },
              child: const Text(
                'Continue Learning',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfetti() {
    return AnimatedBuilder(
      animation: _confettiAnimation,
      builder: (context, child) {
        return Stack(
          children: List.generate(20, (index) {
            final random = (index * 0.1) % 1.0;
            return Positioned(
              left: MediaQuery.of(context).size.width * random,
              top: -50 + (_confettiAnimation.value * 200),
              child: Transform.rotate(
                angle: _confettiAnimation.value * 6.28 * random,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: [Colors.yellow, Colors.pink, Colors.blue, Colors.green][index % 4],
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
    final progress = (_currentIndex + 1) / _questions.length;
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.purple.shade50,
              Colors.blue.shade50,
              Colors.white,
            ],
          ),
        ),
        child: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  // Custom App Bar
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.purple.shade400, Colors.deepPurple.shade600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.shade200,
                          blurRadius: 20,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                            ),
                            const Expanded(
                              child: Text(
                                '📝 Spelling Challenge',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '$_score pts',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Progress Bar
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.transparent,
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Question ${_currentIndex + 1} of ${_questions.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            const SizedBox(height: 40),

                            // Speaking Button Card
                            AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _pulseAnimation.value,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [Colors.indigo.shade400, Colors.purple.shade500],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(24),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.purple.shade300,
                                          blurRadius: 20,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(24),
                                        onTap: _isSpeaking ? null : _speak,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 32),
                                          child: Column(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(20),
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withOpacity(0.2),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: _isSpeaking
                                                    ? const SizedBox(
                                                  width: 32,
                                                  height: 32,
                                                  child: CircularProgressIndicator(
                                                    color: Colors.white,
                                                    strokeWidth: 4,
                                                  ),
                                                )
                                                    : const Icon(
                                                  Icons.volume_up_rounded,
                                                  size: 32,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              Text(
                                                _isSpeaking ? 'Playing...' : 'Tap to hear the word',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600,
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

                            const SizedBox(height: 48),

                            // Answer Input
                            AnimatedBuilder(
                              animation: _shakeAnimation,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(_shakeAnimation.value * 10 *
                                      (1 - _shakeAnimation.value), 0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.shade300,
                                          blurRadius: 15,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: TextField(
                                      controller: _controller,
                                      enabled: !_answered,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 28,
                                        letterSpacing: 4,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.deepPurple,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Spell the word here',
                                        hintStyle: TextStyle(
                                          color: Colors.grey.shade400,
                                          fontSize: 18,
                                          letterSpacing: 2,
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(
                                          vertical: 24,
                                          horizontal: 20,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(20),
                                          borderSide: BorderSide.none,
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(20),
                                          borderSide: BorderSide(
                                            color: Colors.purple.shade300,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 32),

                            // Check Answer Button
                            Container(
                              width: double.infinity,
                              height: 60,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: _answered
                                      ? [Colors.grey.shade400, Colors.grey.shade500]
                                      : [Colors.green.shade400, Colors.teal.shade500],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: _answered ? [] : [
                                  BoxShadow(
                                    color: Colors.green.shade300,
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: _answered ? null : _checkAnswer,
                                  child: const Center(
                                    child: Text(
                                      'Check My Answer',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Feedback
                            if (_feedback != null)
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 500),
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: _feedback!.contains('Excellent')
                                        ? [Colors.green.shade400, Colors.green.shade500]
                                        : [Colors.orange.shade400, Colors.red.shade500],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _feedback!.contains('Excellent')
                                          ? Colors.green.shade300
                                          : Colors.red.shade300,
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        _feedback!.contains('Excellent')
                                            ? Icons.star_rounded
                                            : Icons.lightbulb_outline_rounded,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        _feedback!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            const Spacer(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Confetti Effect
            if (_feedback?.contains('Excellent') == true)
              _buildConfetti(),
          ],
        ),
      ),
    );
  }
}