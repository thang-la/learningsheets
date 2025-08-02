import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/vocabulary_item.dart';

class VocabularyCard extends StatefulWidget {
  final VocabularyItem item;

  const VocabularyCard({super.key, required this.item});

  @override
  State<VocabularyCard> createState() => _VocabularyCardState();
}

class _VocabularyCardState extends State<VocabularyCard>
    with TickerProviderStateMixin {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;
  bool _isExpanded = false;
  bool _isHovered = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _speak() async {
    final text = widget.item.word;
    if (text.isNotEmpty) {
      setState(() => _isSpeaking = true);

      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setPitch(1.0);
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.speak(text);

      await Future.delayed(const Duration(seconds: 1));
      setState(() => _isSpeaking = false);
    }
  }

  void _onTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _onTapCancel() {
    _animationController.reverse();
  }

  Color get _cardGradientStart {
    if (_isSpeaking) return Colors.indigo.shade400;
    if (_isHovered) return Colors.blue.shade50;
    return Colors.white;
  }

  Color get _cardGradientEnd {
    if (_isSpeaking) return Colors.purple.shade400;
    if (_isHovered) return Colors.indigo.shade50;
    return Colors.grey.shade50;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_cardGradientStart, _cardGradientEnd],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: _isSpeaking
                          ? Colors.indigo.withOpacity(0.4)
                          : _isHovered
                          ? Colors.blue.withOpacity(0.2)
                          : Colors.black.withOpacity(0.1),
                      blurRadius: _isSpeaking ? 20 : _isHovered ? 15 : 10,
                      offset: Offset(0, _isSpeaking ? 8 : _isHovered ? 6 : 4),
                      spreadRadius: _isSpeaking ? 2 : 0,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _isSpeaking
                            ? Colors.indigo.withOpacity(0.3)
                            : Colors.transparent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 16),
                          _buildPronunciationSection(),
                          const SizedBox(height: 16),
                          _buildPartOfSpeechSection(),
                          const SizedBox(height: 20),
                          _buildMeaningSection(),
                          if (_isExpanded && widget.item.example.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            _buildExampleSection(),
                          ],
                          const SizedBox(height: 12),
                          _buildExpandButton(),
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
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: _isSpeaking ? 28 : 26,
                  fontWeight: FontWeight.w900,
                  color: _isSpeaking ? Colors.white : Colors.indigo.shade700,
                  letterSpacing: 0.5,
                ),
                child: Text(widget.item.word),
              ),
              const SizedBox(height: 4),
              Container(
                height: 3,
                width: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.indigo.shade400, Colors.purple.shade400],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => _speak(),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: _isSpeaking
                  ? LinearGradient(
                colors: [Colors.indigo.shade400, Colors.purple.shade400],
              )
                  : LinearGradient(
                colors: [Colors.blue.shade100, Colors.indigo.shade100],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _isSpeaking
                      ? Colors.indigo.withOpacity(0.4)
                      : Colors.blue.withOpacity(0.2),
                  blurRadius: _isSpeaking ? 12 : 6,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              _isSpeaking ? Icons.stop : Icons.volume_up,
              size: 24,
              color: _isSpeaking ? Colors.white : Colors.indigo.shade600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPronunciationSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.record_voice_over,
            size: 18,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.item.pronunciation.isNotEmpty
                  ? widget.item.pronunciation
                  : '/${widget.item.word}/',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartOfSpeechSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade400, Colors.teal.shade400],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.category,
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: 6),
          Text(
            widget.item.partOfSpeech.isNotEmpty
                ? widget.item.partOfSpeech
                : 'word',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeaningSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade50, Colors.indigo.shade50],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade400,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.lightbulb,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Meaning',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.item.meaning.isNotEmpty
                  ? widget.item.meaning
                  : 'No meaning provided',
              style: TextStyle(
                fontSize: 15,
                height: 1.4,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleSection() {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.amber.shade50, Colors.orange.shade50],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.amber.shade200, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade400,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.format_quote,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Example',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.amber.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                widget.item.example,
                style: TextStyle(
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandButton() {
    return Center(
      child: AnimatedRotation(
        duration: const Duration(milliseconds: 300),
        turns: _isExpanded ? 0.5 : 0,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.keyboard_arrow_down,
            size: 20,
            color: Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}