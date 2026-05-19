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
  
  final Map<String, List<Map<String, String>>> _modulesByLevel = {
    'first-year': [
      {'code': 'TPG316C', 'name': 'Programming Fundamentals'},
      {'code': 'SOD316C', 'name': 'Software Development'},
      {'code': 'CMN316C', 'name': 'Communication Skills'},
      {'code': 'ITS316C', 'name': 'Information Systems'},
    ],
    'second-year': [
      {'code': 'PRG216C', 'name': 'Advanced Programming'},
      {'code': 'DBS216C', 'name': 'Database Systems'},
      {'code': 'WEB216C', 'name': 'Web Development'},
      {'code': 'SYS216C', 'name': 'Systems Analysis'},
    ],
    'third-year': [
      {'code': 'PRJ316C', 'name': 'Project Management'},
      {'code': 'ADV316C', 'name': 'Advanced Databases'},
      {'code': 'Mob316C', 'name': 'Mobile Development'},
      {'code': 'NWK316C', 'name': 'Networking'},
    ],
  };

  String? _selectedLevel;
  Map<String, String>? _selectedModule;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Selected Modules (${widget.selectedModules.length})',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (widget.selectedModules.isNotEmpty)
              TextButton(
                onPressed: () => widget.onModulesChanged([]),
                child: const Text('Clear All', style: TextStyle(color: Colors.red)),
              ),
          ],
        ),
        const SizedBox(height: 12),

        // Selected modules chips
        if (widget.selectedModules.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _buildModuleChips(), // This returns List<Widget>
          ),
        
        const SizedBox(height: 16),
        
        // Add module section
        const Divider(),
        const SizedBox(height: 8),
        const Text('Add More Modules', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedLevel,
                decoration: const InputDecoration(
                  labelText: 'Academic Level',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<Map<String, String>>(
                value: _selectedModule,
                decoration: const InputDecoration(
                  labelText: 'Module',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                items: _selectedLevel != null
                    ? (_modulesByLevel[_selectedLevel] ?? []).map((module) {
                        return DropdownMenuItem(
                          value: module,
                          child: Text('${module['code']} - ${module['name']}'),
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
                      final isDuplicate = widget.selectedModules.any(
                        (m) => m['code'] == _selectedModule!['code']
                      );
                      
                      if (isDuplicate) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('This module is already selected'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }
                      
                      final newModule = {
                        'level': _selectedLevel!,
                        'code': _selectedModule!['code']!,
                        'name': _selectedModule!['name']!,
                      };
                      
                      final newList = List<Map<String, String>>.from(widget.selectedModules);
                      newList.add(newModule);
                      widget.onModulesChanged(newList);
                      
                      setState(() {
                        _selectedLevel = null;
                        _selectedModule = null;
                      });
                    }
                  : null,
              child: const Text('Add'),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Validation message
        if (widget.selectedModules.isEmpty)
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.orange.shade50,
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.orange.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Minimum 1 module required. You can select up to 5 modules.',
                    style: TextStyle(fontSize: 12, color: Colors.orange.shade700),
                  ),
                ),
              ],
            ),
          ),
        
        if (widget.selectedModules.length >= 5)
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.red.shade50,
            child: Row(
              children: [
                Icon(Icons.warning, size: 16, color: Colors.red.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Maximum 5 modules reached. Remove a module to add another.',
                    style: TextStyle(fontSize: 12, color: Colors.red.shade700),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // THIS METHOD RETURNS List<Widget> - FIXED
  List<Widget> _buildModuleChips() {
    final List<Widget> chips = [];
    
    for (int i = 0; i < widget.selectedModules.length; i++) {
      final module = widget.selectedModules[i];
      chips.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Center(
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                module['name'] ?? '',
                style: TextStyle(fontSize: 13, color: Colors.blue.shade800),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () {
                  final newList = List<Map<String, String>>.from(widget.selectedModules);
                  newList.removeAt(i);
                  widget.onModulesChanged(newList);
                },
                child: const Icon(Icons.close, size: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }
    
    return chips;
  }
}
