import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _sheetsKey = 'sheets';
  static const _selectedSheetIndexKey = 'selected_sheet_index';

  static Future<List<Map<String, String>>> getSheets() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_sheetsKey);
    if (jsonString == null) return [];
    final List<dynamic> decoded = json.decode(jsonString);
    return decoded.map<Map<String, String>>((item) {
      return Map<String, String>.from(item as Map);
    }).toList();
  }

  static Future<void> saveSheets(List<Map<String, String>> sheets) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(sheets);
    await prefs.setString(_sheetsKey, jsonString);
  }

  static Future<int> getSelectedSheetIndex() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_selectedSheetIndexKey) ?? 0;
  }

  static Future<void> setSelectedSheetIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_selectedSheetIndexKey, index);
  }

  static Future<String?> getSelectedSheetUrl() async {
    final sheets = await getSheets();
    final index = await getSelectedSheetIndex();
    if (index < 0 || index >= sheets.length) return null;
    return sheets[index]['url'];
  }
}
