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
  
  // CHANGE: This becomes a LIST instead of a single module
  List<Map<String, String>> _selectedModules = [];  // ← LIST of modules
  bool _meetsRequirements = false;
  int _yearOfStudy = 1;
  bool _isEditMode = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.applicationId != null && widget.applicationId!.isNotEmpty;
    
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
      _selectedModules = List.from(application.modules);  // ← LOAD LIST
      _meetsRequirements = application.meetsRequirements;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _studentNumberController.dispose();
    super.dispose();
  }

  bool get isFormValid {
    return _fullNameController.text.trim().isNotEmpty &&
           _studentNumberController.text.trim().isNotEmpty &&
           _selectedModules.isNotEmpty &&  // ← CHECK LIST NOT EMPTY
           _meetsRequirements == true;
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields'), backgroundColor: Colors.orange),
      );
      return;
    }
    
    if (_selectedModules.isEmpty) {  // ← CHECK LIST NOT EMPTY
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one module'), backgroundColor: Colors.orange),
      );
      return;
    }
    
    if (!_meetsRequirements) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please confirm you meet the requirements'), backgroundColor: Colors.orange),
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
          modules: _selectedModules,  // ← PASS THE LIST
          meetsRequirements: _meetsRequirements,
        );
      } else {
        success = await appVM.addApplication(
          fullName: _fullNameController.text.trim(),
          studentNumber: _studentNumberController.text.trim(),
          yearOfStudy: _yearOfStudy,
          modules: _selectedModules,  // ← PASS THE LIST
          meetsRequirements: _meetsRequirements,
        );
      }

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditMode ? 'Application updated!' : 'Application submitted!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacementNamed(context, RouteManager.studentHome);
      } else if (mounted) {
        final error = context.read<ApplicationViewModel>().errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error ?? 'Failed to submit'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Application' : 'New Application'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ================================================
              // SECTION 1: PERSONAL INFORMATION
              // ================================================
              const Text(
                'Personal Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Enter full name' : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _studentNumberController,
                decoration: const InputDecoration(
                  labelText: 'Student Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Enter student number' : null,
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
              ),
              const SizedBox(height: 24),

              // ================================================
              // SECTION 2: MODULES SELECTION
              // REPLACE THE SINGLE DROPDOWN WITH MODULE SELECTOR
              // ================================================
              const Text(
                'Modules Selection',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select the modules you want to assist with (minimum 1, maximum 5)',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              
              // ================================================
              // MODULE SELECTOR WIDGET - ADDED HERE
              // ================================================
              ModuleSelector(
                selectedModules: _selectedModules,
                onModulesChanged: (newModules) {
                  setState(() {
                    _selectedModules = newModules;
                  });
                },
              ),
              
              const SizedBox(height: 24),

              // ================================================
              // SECTION 3: ELIGIBILITY
              // ================================================
              const Text(
                'Eligibility',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              CheckboxListTile(
                title: const Text(
                  'I confirm that I meet the minimum requirements (minimum 65% average in the selected modules)',
                ),
                value: _meetsRequirements,
                onChanged: (v) => setState(() => _meetsRequirements = v ?? false),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 32),

              // ================================================
              // SECTION 4: SUBMIT BUTTON
              // ================================================
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitApplication,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: isFormValid ? Colors.blue : Colors.grey,
                  foregroundColor: Colors.white,
                ),
                child: _isSubmitting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(_isEditMode ? 'Update Application' : 'Submit Application', style: const TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 16),
              
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
