// views/student/application_form_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/application_viewmodel.dart';
import '../../routes/route_manager.dart';

class ApplicationFormView extends StatefulWidget {
  const ApplicationFormView({super.key});

  @override
  State<ApplicationFormView> createState() => _ApplicationFormViewState();
}

class _ApplicationFormViewState extends State<ApplicationFormView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _studentNumberController = TextEditingController();
  String? _selectedModule;
  bool _meetsRequirements = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _studentNumberController.dispose();
    super.dispose();
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_meetsRequirements) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please confirm you meet the requirements'),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final success = await context.read<ApplicationViewModel>().addApplication(
        fullName: _nameController.text.trim(),
        studentNumber: _studentNumberController.text.trim(),
        yearOfStudy: 1,
        module1Level: 'first-year',
        module1Name: _selectedModule!,
        meetsRequirements: true,
        hasSecondModule: false,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Application submitted successfully!')),
        );
        Navigator.pushReplacementNamed(context, RouteManager.studentHome);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to submit application'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Application')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) => v == null || v.isEmpty
                    ? 'Please enter your full name'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _studentNumberController,
                decoration: const InputDecoration(
                  labelText: 'Student Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge),
                ),
                validator: (v) => v == null || v.isEmpty
                    ? 'Please enter your student number'
                    : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Select Module',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.book),
                ),
                value: _selectedModule,
                items: const [
                  DropdownMenuItem(
                    value: 'TPG316C',
                    child: Text('TPG316C - Programming Fundamentals'),
                  ),
                  DropdownMenuItem(
                    value: 'SOD316C',
                    child: Text('SOD316C - Software Development'),
                  ),
                  DropdownMenuItem(
                    value: 'CMN316C',
                    child: Text('CMN316C - Communication Skills'),
                  ),
                  DropdownMenuItem(
                    value: 'ITS316C',
                    child: Text('ITS316C - Information Systems'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedModule = value;
                  });
                },
                validator: (v) => v == null ? 'Please select a module' : null,
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text(
                  'I confirm that I meet the minimum requirements (65% average in the selected module)',
                ),
                value: _meetsRequirements,
                onChanged: (value) {
                  setState(() {
                    _meetsRequirements = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitApplication,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Submit Application',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
