import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/vocabulary_item.dart';

class VocabularyTableView extends StatefulWidget {
  final List<VocabularyItem> vocabulary;

  const VocabularyTableView({super.key, required this.vocabulary});

  @override
  State<VocabularyTableView> createState() => _VocabularyTableViewState();
}

class _VocabularyTableViewState extends State<VocabularyTableView>
    with TickerProviderStateMixin {
  final FlutterTts _flutterTts = FlutterTts();
  String? _playingWord;
  int? _selectedRowIndex;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    setState(() {
      _playingWord = text;
    });
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(text);
    setState(() {
      _playingWord = null;
    });
  }

  void _showFullTextDialog(BuildContext context, String title, String content, VocabularyItem item) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 16,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.shade50,
                Colors.indigo.shade50,
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.indigo.shade400, Colors.blue.shade400],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        title == 'Meaning' ? Icons.lightbulb : Icons.format_quote,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.word,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            title,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.white),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (title == 'Meaning') ...[
                        _buildDetailRow('Part of Speech', item.partOfSpeech, Icons.category),
                        const SizedBox(height: 16),
                        _buildDetailRow('Pronunciation', item.pronunciation, Icons.record_voice_over),
                        const SizedBox(height: 16),
                      ],
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.indigo.shade100),
                        ),
                        child: Text(
                          content,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                      if (title == 'Meaning' && item.example.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Text(
                          'Example Usage',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.amber.shade200),
                          ),
                          child: Text(
                            item.example,
                            style: TextStyle(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: Colors.amber.shade800,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.indigo.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: Colors.indigo.shade600),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade400, Colors.blue.shade400],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.library_books, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          const Text(
            'Vocabulary Table',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${widget.vocabulary.length} words',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(
                children: [
                  _buildTableHeader(),
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columnSpacing: 28,
                            dataRowMinHeight: 72,
                            dataRowMaxHeight: 72,
                            showCheckboxColumn: false,
                            headingRowHeight: 60,
                            headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
                            headingTextStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo.shade700,
                              fontSize: 14,
                            ),
                            dataTextStyle: const TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                            columns: [
                              _buildDataColumn('Word', Icons.text_fields),
                              _buildDataColumn('Pronunciation', Icons.record_voice_over),
                              _buildDataColumn('Part of Speech', Icons.category),
                              _buildDataColumn('Meaning', Icons.lightbulb_outline),
                              _buildDataColumn('Example', Icons.format_quote),
                            ],
                            rows: widget.vocabulary.asMap().entries.map((entry) {
                              final index = entry.key;
                              final item = entry.value;
                              final isSelected = _selectedRowIndex == index;

                              return DataRow(
                                selected: isSelected,
                                onSelectChanged: (selected) {
                                  setState(() {
                                    _selectedRowIndex = selected == true ? index : null;
                                  });
                                },
                                color: WidgetStateProperty.resolveWith<Color>((states) {
                                  if (states.contains(WidgetState.selected)) {
                                    return Colors.indigo.shade50;
                                  }
                                  return index.isEven ? Colors.grey.shade50 : Colors.white;
                                }),
                                cells: [
                                  DataCell(
                                    Container(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            item.word,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.indigo.shade700,
                                              fontSize: 15,
                                            ),
                                          ),
                                          if (item.group.isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.shade100,
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                item.group,
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.blue.shade700,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    InkWell(
                                      onTap: () => _speak(item.word),
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: _playingWord == item.word
                                                    ? Colors.indigo.shade100
                                                    : Colors.grey.shade100,
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Icon(
                                                _playingWord == item.word
                                                    ? Icons.volume_up
                                                    : Icons.play_arrow,
                                                size: 16,
                                                color: _playingWord == item.word
                                                    ? Colors.indigo
                                                    : Colors.grey.shade600,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Flexible(
                                              child: Text(
                                                item.pronunciation,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: _playingWord == item.word
                                                      ? Colors.indigo
                                                      : Colors.black87,
                                                  fontWeight: _playingWord == item.word
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.green.shade200),
                                      ),
                                      child: Text(
                                        item.partOfSpeech,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.green.shade700,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    InkWell(
                                      onTap: () => _showFullTextDialog(context, 'Meaning', item.meaning, item),
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        constraints: const BoxConstraints(maxWidth: 200),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                item.meaning.length > 40
                                                    ? '${item.meaning.substring(0, 40)}...'
                                                    : item.meaning,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                              ),
                                            ),
                                            if (item.meaning.length > 40) ...[
                                              const SizedBox(width: 4),
                                              Icon(
                                                Icons.open_in_full,
                                                size: 14,
                                                color: Colors.grey.shade500,
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    InkWell(
                                      onTap: () => _showFullTextDialog(context, 'Example', item.example, item),
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        constraints: const BoxConstraints(maxWidth: 200),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                item.example.length > 40
                                                    ? '${item.example.substring(0, 40)}...'
                                                    : item.example,
                                                style: const TextStyle(
                                                  fontStyle: FontStyle.italic,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                              ),
                                            ),
                                            if (item.example.length > 40) ...[
                                              const SizedBox(width: 4),
                                              Icon(
                                                Icons.open_in_full,
                                                size: 14,
                                                color: Colors.grey.shade500,
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  DataColumn _buildDataColumn(String label, IconData icon) {
    return DataColumn(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.indigo.shade600),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}