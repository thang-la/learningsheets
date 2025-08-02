import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';
import '../models/vocabulary_item.dart';

class SheetService {
  static Future<List<VocabularyItem>> fetchVocabulary(String url) async {
    final idRegex = RegExp(r'/spreadsheets/d/([a-zA-Z0-9-_]+)');
    final match = idRegex.firstMatch(url);
    if (match == null) throw Exception('Invalid Google Sheet URL');
    final id = match.group(1);
    final csvUrl =
        'https://docs.google.com/spreadsheets/d/$id/export?format=csv';

    final response = await http.get(Uri.parse(csvUrl));
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch Google Sheet content');
    }

    final decoded = utf8.decode(response.bodyBytes);
    final csv = const CsvToListConverter().convert(decoded);

    return csv.skip(1).map((e) {
      return VocabularyItem(
        word: e[0].toString(),
        meaning: e[1].toString(),
        pronunciation: e[2].toString(),
        partOfSpeech: e[3].toString(),
        example: e[4].toString(),
        group: e.length > 5 ? e[5].toString() : '',
      );
    }).toList();
  }
}
