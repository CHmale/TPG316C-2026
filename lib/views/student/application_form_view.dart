// lib/views/student/application_form_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/application_viewmodel.dart';
import '../../routes/route_manager.dart';
import '../widgets/module_selector.dart';

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

  List<Map<String, String>> _selectedModules = [];
  bool _meetsRequirements = false;
  int _yearOfStudy = 1;
  bool _isEditMode = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.applicationId != null;
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
      _selectedModules = List.from(application.modules);
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
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedModules.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one module'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

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
          modules: _selectedModules,
          meetsRequirements: _meetsRequirements,
        );
      } else {
        success = await appVM.addApplication(
          fullName: _fullNameController.text.trim(),
          studentNumber: _studentNumberController.text.trim(),
          yearOfStudy: _yearOfStudy,
          modules: _selectedModules,
          meetsRequirements: _meetsRequirements,
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

              // Modules Section (3+ modules)
              _buildSectionHeader('Modules Selection', Icons.book),
              const SizedBox(height: 8),
              const Text(
                'Select the modules you want to assist with (minimum 1, maximum 5)',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),

              ModuleSelector(
                selectedModules: _selectedModules,
                onModulesChanged: (newModules) {
                  setState(() {
                    _selectedModules = newModules;
                  });
                },
              ),

              const SizedBox(height: 24),

              // Eligibility Section
              _buildSectionHeader('Eligibility', Icons.verified),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text(
                  'I confirm that I meet the minimum requirements (minimum 65% average in the selected modules)',
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
