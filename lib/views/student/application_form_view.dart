// lib/views/student/application_form_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/application_viewmodel.dart';
import '../../routes/route_manager.dart';

class ApplicationFormView extends StatefulWidget {
  final String? applicationId;

  const ApplicationFormView({super.key, this.applicationId});

  @override
  State<ApplicationFormView> createState() => _ApplicationFormViewState();
}

class _ApplicationFormViewState extends State<ApplicationFormView> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _studentNumberController = TextEditingController();

  String? _selectedModule1Level;
  String? _selectedModule1Name;
  bool _hasSecondModule = false;
  String? _selectedModule2Level;
  String? _selectedModule2Name;
  bool _meetsRequirements = false;
  int _yearOfStudy = 1;
  bool _isEditMode = false;
  bool _isSubmitting = false;

  final List<String> _levels = ['first-year', 'second-year', 'third-year'];

  final Map<String, List<String>> _modulesByLevel = {
    'first-year': ['TPG316C', 'SOD316C', 'CMN316C', 'ITS316C'],
    'second-year': ['PRG216C', 'DBS216C', 'WEB216C', 'SYS216C'],
    'third-year': ['PRJ316C', 'ADV316C', 'Mob316C', 'NWK316C'],
  };

  final Map<String, String> _moduleNames = {
    'TPG316C': 'Programming Fundamentals',
    'SOD316C': 'Software Development',
    'CMN316C': 'Communication Skills',
    'ITS316C': 'Information Systems',
    'PRG216C': 'Advanced Programming',
    'DBS216C': 'Database Systems',
    'WEB216C': 'Web Development',
    'SYS216C': 'Systems Analysis',
    'PRJ316C': 'Project Management',
    'ADV316C': 'Advanced Databases',
    'Mob316C': 'Mobile Development',
    'NWK316C': 'Networking',
  };

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.applicationId != null;
    _selectedModule1Level = 'first-year';
    if (_isEditMode) {
      _loadApplicationData();
    }
  }

  void _loadApplicationData() {
    final appVM = context.read<ApplicationViewModel>();
    final application = appVM.getApplicationById(widget.applicationId!);
    if (application != null) {
      _fullNameController.text = application.fullName;
      _studentNumberController.text = application.studentNumber;
      _yearOfStudy = application.yearOfStudy;
      _selectedModule1Level = application.module1Level;
      _selectedModule1Name = application.module1Name;
      _hasSecondModule = application.hasSecondModule;
      if (_hasSecondModule) {
        _selectedModule2Level = application.module2Level;
        _selectedModule2Name = application.module2Name;
      }
      _meetsRequirements = application.meetsRequirements;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _studentNumberController.dispose();
    super.dispose();
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_meetsRequirements) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please confirm you meet the requirements'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final appVM = context.read<ApplicationViewModel>();
      bool success;

      if (_isEditMode) {
        success = await appVM.updateApplication(
          id: widget.applicationId!,
          fullName: _fullNameController.text.trim(),
          studentNumber: _studentNumberController.text.trim(),
          yearOfStudy: _yearOfStudy,
          module1Level: _selectedModule1Level!,
          module1Name: _selectedModule1Name!,
          module2Level: _hasSecondModule ? _selectedModule2Level : null,
          module2Name: _hasSecondModule ? _selectedModule2Name : null,
          meetsRequirements: _meetsRequirements,
          hasSecondModule: _hasSecondModule,
        );
      } else {
        success = await appVM.addApplication(
          fullName: _fullNameController.text.trim(),
          studentNumber: _studentNumberController.text.trim(),
          yearOfStudy: _yearOfStudy,
          module1Level: _selectedModule1Level!,
          module1Name: _selectedModule1Name!,
          module2Level: _hasSecondModule ? _selectedModule2Level : null,
          module2Name: _hasSecondModule ? _selectedModule2Name : null,
          meetsRequirements: _meetsRequirements,
          hasSecondModule: _hasSecondModule,
        );
      }

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditMode
                  ? 'Application updated successfully!'
                  : 'Application submitted successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacementNamed(context, RouteManager.studentHome);
      } else if (mounted) {
        final error = context.read<ApplicationViewModel>().errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Failed to submit application'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Application' : 'New Application'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Personal Information Section
              _buildSectionHeader('Personal Information', Icons.person),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter full name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _studentNumberController,
                decoration: const InputDecoration(
                  labelText: 'Student Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter student number' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _yearOfStudy,
                decoration: const InputDecoration(
                  labelText: 'Year of Study',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.school),
                ),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('1st Year')),
                  DropdownMenuItem(value: 2, child: Text('2nd Year')),
                  DropdownMenuItem(value: 3, child: Text('3rd Year')),
                ],
                onChanged: (v) => setState(() => _yearOfStudy = v ?? 1),
                validator: (v) => v == null ? 'Select year' : null,
              ),
              const SizedBox(height: 24),

              // Module 1 Section
              _buildSectionHeader(
                'Module 1 Application (Required)',
                Icons.book,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedModule1Level,
                decoration: const InputDecoration(
                  labelText: 'Academic Level',
                  border: OutlineInputBorder(),
                ),
                items: _levels.map((level) {
                  return DropdownMenuItem(
                    value: level,
                    child: Text(level.replaceAll('-', ' ').toUpperCase()),
                  );
                }).toList(),
                onChanged: (v) {
                  setState(() {
                    _selectedModule1Level = v;
                    _selectedModule1Name = null;
                  });
                },
                validator: (v) => v == null ? 'Select level' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedModule1Name,
                decoration: const InputDecoration(
                  labelText: 'Module',
                  border: OutlineInputBorder(),
                ),
                items: _selectedModule1Level != null
                    ? (_modulesByLevel[_selectedModule1Level] ?? []).map((
                        code,
                      ) {
                        return DropdownMenuItem(
                          value: code,
                          child: Text('$code - ${_moduleNames[code]}'),
                        );
                      }).toList()
                    : [],
                onChanged: (v) => setState(() => _selectedModule1Name = v),
                validator: (v) => v == null ? 'Select module' : null,
              ),
              const SizedBox(height: 24),

              // Module 2 Section (Optional)
              CheckboxListTile(
                title: const Text('Apply for a second module (Optional)'),
                value: _hasSecondModule,
                onChanged: (v) => setState(() => _hasSecondModule = v ?? false),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              if (_hasSecondModule) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedModule2Level,
                  decoration: const InputDecoration(
                    labelText: 'Academic Level (Module 2)',
                    border: OutlineInputBorder(),
                  ),
                  items: _levels.map((level) {
                    return DropdownMenuItem(
                      value: level,
                      child: Text(level.replaceAll('-', ' ').toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (v) {
                    setState(() {
                      _selectedModule2Level = v;
                      _selectedModule2Name = null;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedModule2Name,
                  decoration: const InputDecoration(
                    labelText: 'Module (Module 2)',
                    border: OutlineInputBorder(),
                  ),
                  items: _selectedModule2Level != null
                      ? (_modulesByLevel[_selectedModule2Level] ?? []).map((
                          code,
                        ) {
                          return DropdownMenuItem(
                            value: code,
                            child: Text('$code - ${_moduleNames[code]}'),
                          );
                        }).toList()
                      : [],
                  onChanged: (v) => setState(() => _selectedModule2Name = v),
                ),
              ],
              const SizedBox(height: 24),

              // Eligibility Section
              _buildSectionHeader('Eligibility', Icons.verified),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text(
                  'I confirm that I meet the minimum requirements (minimum 65% average in the selected module(s))',
                ),
                value: _meetsRequirements,
                onChanged: (v) =>
                    setState(() => _meetsRequirements = v ?? false),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 32),

              // Submit Button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitApplication,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        _isEditMode
                            ? 'Update Application'
                            : 'Submit Application',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Icon(icon, size: 20, color: Colors.blue),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
