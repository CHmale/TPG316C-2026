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

  String? _selectedLevel;
  String? _selectedModule;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with count
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Selected Modules (${widget.selectedModules.length})',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (widget.selectedModules.isNotEmpty)
              TextButton.icon(
                onPressed: () {
                  widget.onModulesChanged([]);
                },
                icon: const Icon(Icons.clear_all, size: 16),
                label: const Text('Clear All'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
          ],
        ),
        const SizedBox(height: 8),

        // Display selected modules as chips
        if (widget.selectedModules.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(widget.selectedModules.length, (index) {
              final module = widget.selectedModules[index];
              return Chip(
                label: Text(module['name'] ?? ''),
                avatar: CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.blue,
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () {
                  final newList = List<Map<String, String>>.from(
                    widget.selectedModules,
                  );
                  newList.removeAt(index);
                  widget.onModulesChanged(newList);
                },
              );
            }),
          ),

        const SizedBox(height: 16),

        // Add module section
        const Text(
          'Add Module',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedLevel,
                decoration: const InputDecoration(
                  labelText: 'Academic Level',
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                items: _levels.map((level) {
                  return DropdownMenuItem(
                    value: level,
                    child: Text(level.replaceAll('-', ' ').toUpperCase()),
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
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedModule,
                decoration: const InputDecoration(
                  labelText: 'Module',
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                items: _selectedLevel != null
                    ? (_modulesByLevel[_selectedLevel] ?? []).map((module) {
                        return DropdownMenuItem(
                          value: module,
                          child: Text(module),
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
            const SizedBox(width: 8),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              child: const Text('Add'),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Helper text
        Text(
          'You can add up to 5 modules. Minimum 1 module required.',
          style: TextStyle(
            fontSize: 11,
            color: widget.selectedModules.length >= 5
                ? Colors.red
                : Colors.grey,
          ),
        ),

        if (widget.selectedModules.length >= 5)
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              'Maximum 5 modules reached',
              style: TextStyle(fontSize: 11, color: Colors.red),
            ),
          ),
      ],
    );
  }
}
