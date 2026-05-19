// lib/views/widgets/module_selector.dart
import 'package:flutter/material.dart';

class ModuleSelector extends StatefulWidget {
  final List<Map<String, String>> selectedModules;
  final Function(List<Map<String, String>>) onModulesChanged;

  const ModuleSelector({
    super.key,
    required this.selectedModules,
    required this.onModulesChanged,
  });

  @override
  State<ModuleSelector> createState() => _ModuleSelectorState();
}

class _ModuleSelectorState extends State<ModuleSelector> {
  final List<String> _levels = ['first-year', 'second-year', 'third-year'];

  final Map<String, List<String>> _modulesByLevel = {
    'first-year': [
      'TPG316C - Programming Fundamentals',
      'SOD316C - Software Development',
      'CMN316C - Communication Skills',
      'ITS316C - Information Systems',
    ],
    'second-year': [
      'PRG216C - Advanced Programming',
      'DBS216C - Database Systems',
      'WEB216C - Web Development',
      'SYS216C - Systems Analysis',
    ],
    'third-year': [
      'PRJ316C - Project Management',
      'ADV316C - Advanced Databases',
      'Mob316C - Mobile Development',
      'NWK316C - Networking',
    ],
  };

  final Map<String, String> _moduleCodes = {
    'TPG116C - Programming Fundamentals': 'TPG116C',
    'SOD116C - Software Development': 'SOD116C',
    'CMN116C - Communication Skills': 'CMN116C',
    'ITS116C - Information Systems': 'ITS116C',
    'PRG216C - Advanced Programming': 'PRG116C',
    'DBS216C - Database Systems': 'DBS216C',
    'WEB216C - Web Development': 'WEB216C',
    'SYS216C - Systems Analysis': 'SYS216C',
    'PRJ316C - Project Management': 'PRJ316C',
    'ADV316C - Advanced Databases': 'ADV316C',
    'Mob316C - Mobile Development': 'Mob316C',
    'NWK316C - Networking': 'NWK316C',
  };

  // 🎨 New color scheme
  final Color _primaryColor = const Color(0xFF6C63FF); // Modern purple
  final Color _secondaryColor = const Color(0xFFFF6584); // Coral pink
  final Color _accentColor = const Color(0xFF00D2FF); // Cyan
  final Color _backgroundColor = const Color(0xFFF8F9FA); // Light gray background
  final Color _cardColor = Colors.white;
  final Color _textPrimary = const Color(0xFF2D3436); // Dark gray
  final Color _textSecondary = const Color(0xFF636E72); // Medium gray

  String? _selectedLevel;
  String? _selectedModule;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with count - UPDATED STYLES
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_primaryColor, _secondaryColor],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Selected Modules (${widget.selectedModules.length})',
                    style: const TextStyle(
                      fontSize: 14, 
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (widget.selectedModules.isNotEmpty)
                  TextButton.icon(
                    onPressed: () {
                      widget.onModulesChanged([]);
                    },
                    icon: const Icon(Icons.clear_all, size: 16),
                    label: const Text('Clear All'),
                    style: TextButton.styleFrom(
                      foregroundColor: _secondaryColor,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Display selected modules as chips - UPDATED COLORS
            if (widget.selectedModules.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(widget.selectedModules.length, (index) {
                  final module = widget.selectedModules[index];
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: LinearGradient(
                        colors: [
                          _primaryColor.withOpacity(0.9),
                          _primaryColor,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _primaryColor.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Chip(
                      label: Text(
                        module['name'] ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      avatar: CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.white,
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _primaryColor,
                          ),
                        ),
                      ),
                      deleteIcon: const Icon(Icons.close, size: 16, color: Colors.white),
                      onDeleted: () {
                        final newList = List<Map<String, String>>.from(
                          widget.selectedModules,
                        );
                        newList.removeAt(index);
                        widget.onModulesChanged(newList);
                      },
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                    ),
                  );
                }),
              ),

            const SizedBox(height: 24),

            // Add module section - UPDATED STYLES
            Container(
              padding: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: _primaryColor.withOpacity(0.3),
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                'Add Module',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedLevel,
                    decoration: InputDecoration(
                      labelText: 'Academic Level',
                      labelStyle: TextStyle(color: _textSecondary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: _textSecondary.withOpacity(0.3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: _textSecondary.withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: _primaryColor, width: 2),
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    items: _levels.map((level) {
                      return DropdownMenuItem(
                        value: level,
                        child: Text(
                          level.replaceAll('-', ' ').toUpperCase(),
                          style: TextStyle(color: _textPrimary),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedLevel = value;
                        _selectedModule = null;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedModule,
                    decoration: InputDecoration(
                      labelText: 'Module',
                      labelStyle: TextStyle(color: _textSecondary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: _textSecondary.withOpacity(0.3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: _textSecondary.withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: _primaryColor, width: 2),
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    items: _selectedLevel != null
                        ? (_modulesByLevel[_selectedLevel] ?? []).map((module) {
                            return DropdownMenuItem(
                              value: module,
                              child: Text(
                                module,
                                style: TextStyle(color: _textPrimary),
                              ),
                            );
                          }).toList()
                        : [],
                    onChanged: (value) {
                      setState(() {
                        _selectedModule = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _selectedLevel != null && _selectedModule != null
                      ? () {
                          final moduleCode =
                              _moduleCodes[_selectedModule!] ?? _selectedModule!;
                          final newModule = {
                            'level': _selectedLevel!,
                            'name': moduleCode,
                            'full_name': _selectedModule!,
                          };

                          final newList = List<Map<String, String>>.from(
                            widget.selectedModules,
                          );
                          newList.add(newModule);
                          widget.onModulesChanged(newList);

                          setState(() {
                            _selectedLevel = null;
                            _selectedModule = null;
                          });
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    shadowColor: _primaryColor.withOpacity(0.5),
                  ),
                  child: const Text(
                    'Add',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Helper text - UPDATED COLORS
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: widget.selectedModules.length >= 5
                    ? _secondaryColor.withOpacity(0.1)
                    : _primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    widget.selectedModules.length >= 5 ? Icons.warning : Icons.info,
                    size: 14,
                    color: widget.selectedModules.length >= 5
                        ? _secondaryColor
                        : _primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You can add up to 5 modules. Minimum 1 module required.',
                      style: TextStyle(
                        fontSize: 11,
                        color: widget.selectedModules.length >= 5
                            ? _secondaryColor
                            : _textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (widget.selectedModules.length >= 5)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _secondaryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _secondaryColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 16, color: _secondaryColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Maximum 5 modules reached',
                          style: TextStyle(fontSize: 12, color: _secondaryColor, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
