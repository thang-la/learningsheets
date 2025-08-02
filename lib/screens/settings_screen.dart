import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<Map<String, String>> _sheets = [];
  int _selectedIndex = 0;

  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSheets();
  }

  Future<void> _loadSheets() async {
    final loadedSheets = await StorageService.getSheets();
    final index = await StorageService.getSelectedSheetIndex();
    setState(() {
      _sheets = loadedSheets;
      _selectedIndex = index;
    });
  }

  Future<void> _addSheet() async {
    final name = _nameController.text.trim();
    final url = _urlController.text.trim();
    if (name.isEmpty || url.isEmpty) return;

    setState(() {
      _sheets.add({'name': name, 'url': url});
      if (_sheets.length == 1) {
        _selectedIndex = 0;
      }
    });

    _nameController.clear();
    _urlController.clear();

    await StorageService.saveSheets(_sheets);
    await StorageService.setSelectedSheetIndex(_selectedIndex);
  }

  Future<void> _deleteSheet(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Sheet?'),
        content: const Text('Are you sure you want to remove this sheet?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _sheets.removeAt(index);
      if (_selectedIndex >= _sheets.length) {
        _selectedIndex = 0;
      }
    });
    await StorageService.saveSheets(_sheets);
    await StorageService.setSelectedSheetIndex(_selectedIndex);
  }

  Future<void> _selectSheet(int index) async {
    setState(() => _selectedIndex = index);
    await StorageService.setSelectedSheetIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        elevation: 4,
        shadowColor: theme.colorScheme.primary.withOpacity(0.3),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              // Input fields card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                shadowColor: theme.colorScheme.primary.withOpacity(0.2),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    children: [
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Sheet Name',
                          prefixIcon: const Icon(Icons.title),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _urlController,
                        decoration: InputDecoration(
                          labelText: 'Google Sheet Link',
                          hintText: 'Paste your Google Sheet URL here',
                          prefixIcon: const Icon(Icons.link),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                            shadowColor: theme.colorScheme.primary.withOpacity(0.5),
                          ),
                          icon: const Icon(Icons.add_circle_outline, size: 24),
                          label: const Text(
                            "Add Sheet",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          onPressed: _addSheet,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Title
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Available Sheets',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // List of sheets
              Expanded(
                child: _sheets.isEmpty
                    ? Center(
                  child: Text(
                    "No sheets added yet.",
                    style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey),
                  ),
                )
                    : ListView.separated(
                  itemCount: _sheets.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final sheet = _sheets[index];
                    final isSelected = _selectedIndex == index;

                    return Material(
                      color: isSelected
                          ? theme.colorScheme.primary.withOpacity(isDark ? 0.2 : 0.15)
                          : theme.cardColor,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => _selectSheet(index),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14),
                          child: Row(
                            children: [
                              Radio<int>(
                                value: index,
                                groupValue: _selectedIndex,
                                onChanged: (value) => _selectSheet(value!),
                                activeColor: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      sheet['name'] ?? 'Sheet ${index + 1}',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.w600,
                                        color: isSelected
                                            ? theme.colorScheme.primary
                                            : theme.textTheme.bodyLarge?.color,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      sheet['url'] ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded,
                                    color: Colors.redAccent, size: 28),
                                tooltip: 'Delete this sheet',
                                onPressed: () => _deleteSheet(index),
                                splashRadius: 24,
                              ),
                            ],
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
    );
  }
}
