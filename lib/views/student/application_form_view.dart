import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../viewmodels/application_viewmodel.dart';
import '../../services/storage_service.dart';
import '../../routes/route_manager.dart';

// AppColors class if not in main.dart
class AppColors {
  static const Color primaryRed = Color(0xFFC41E3A);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color offWhite = Color(0xFFF5F5F5);
  static const Color white = Color(0xFFFFFFFF);
}

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
  final _storageService = StorageService();
  final _picker = ImagePicker();

  String? _level1 = 'first-year';
  String? _module1;
  bool _hasSecond = false;
  String? _level2 = 'first-year';
  String? _module2;
  bool _meetsRequirements = false;
  int _yearOfStudy = 1;
  bool _isEditMode = false;
  bool _isSubmitting = false;
  String? _documentUrl;
  bool _docUploaded = false;
  bool _uploading = false;

  final List<String> _levels = ['first-year', 'second-year', 'third-year'];

  final Map<String, List<Map<String, String>>> _modules = {
    'first-year': [
      {'code': 'TPG316C', 'name': 'Programming Fundamentals'},
      {'code': 'SOD116C', 'name': 'Software Development'},
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

  @override
  void initState() {
    super.initState();
    _isEditMode =
        widget.applicationId != null && widget.applicationId!.isNotEmpty;
    print('Edit Mode: $_isEditMode, ID: ${widget.applicationId}');

    if (_isEditMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadApplicationData();
      });
    }
  }

  void _loadApplicationData() {
    print('Loading application data...');
    final appVM = context.read<ApplicationViewModel>();
    final application = appVM.getApplicationById(widget.applicationId!);

    if (application != null) {
      _fullNameController.text = application.fullName;
      _studentNumberController.text = application.studentNumber;
      _yearOfStudy = application.yearOfStudy;

      if (application.modules.isNotEmpty) {
        final m1 = application.modules.first;
        _module1 = m1['name'];
        _level1 = m1['level'] ?? 'first-year';
        print('Module 1 set to: $_module1 (${_level1})');
      }

      if (application.modules.length > 1) {
        _hasSecond = true;
        final m2 = application.modules[1];
        _module2 = m2['name'];
        _level2 = m2['level'] ?? 'first-year';
        print('Module 2 set to: $_module2 (${_level2})');
      }

      _meetsRequirements = application.meetsRequirements;
      _documentUrl = application.supportingDocumentUrl;
      _docUploaded = _documentUrl != null;

      setState(() {});
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _studentNumberController.dispose();
    super.dispose();
  }

  Future<void> _pickDocument() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    setState(() => _uploading = true);
    final url = await _storageService.uploadDocument(
        DateTime.now().millisecondsSinceEpoch.toString(), File(picked.path));
    setState(() {
      _uploading = false;
      if (url != null) {
        _documentUrl = url;
        _docUploaded = true;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Document uploaded'),
              backgroundColor: AppColors.success),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Upload failed'), backgroundColor: AppColors.error),
        );
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Fill all fields'),
            backgroundColor: AppColors.warning),
      );
      return;
    }

    if (_module1 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Select a module'),
            backgroundColor: AppColors.warning),
      );
      return;
    }

    if (!_meetsRequirements) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Confirm eligibility'),
            backgroundColor: AppColors.warning),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final modules = [
      {'level': _level1!, 'name': _module1!}
    ];
    if (_hasSecond && _module2 != null) {
      modules.add({'level': _level2!, 'name': _module2!});
    }

    final vm = context.read<ApplicationViewModel>();
    bool success;

    try {
      if (_isEditMode) {
        success = await vm.updateApplication(
          id: widget.applicationId!,
          fullName: _fullNameController.text.trim(),
          studentNumber: _studentNumberController.text.trim(),
          yearOfStudy: _yearOfStudy,
          modules: modules,
          meetsRequirements: _meetsRequirements,
          documentUrl: _documentUrl,
        );
      } else {
        success = await vm.addApplication(
          fullName: _fullNameController.text.trim(),
          studentNumber: _studentNumberController.text.trim(),
          yearOfStudy: _yearOfStudy,
          modules: modules,
          meetsRequirements: _meetsRequirements,
          documentUrl: _documentUrl,
        );
      }

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditMode
                ? 'Application updated!'
                : 'Application submitted!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pushReplacementNamed(context, RouteManager.studentHome);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(vm.errorMessage ?? 'Failed'),
              backgroundColor: AppColors.error),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  List<DropdownMenuItem<String>> _getModuleItems(String level) {
    final modulesList = _modules[level] ?? [];
    return modulesList.map((m) {
      return DropdownMenuItem<String>(
        value: m['code'],
        child: Text('${m['code']} - ${m['name']}'),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Application' : 'New Application'),
        backgroundColor: AppColors.primaryRed,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Personal Info Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Icon(Icons.person, color: AppColors.primaryRed),
                        const SizedBox(width: 8),
                        const Text('Personal Information',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold))
                      ]),
                      const Divider(),
                      TextFormField(
                        controller: _fullNameController,
                        decoration:
                            const InputDecoration(labelText: 'Full Name'),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _studentNumberController,
                        decoration:
                            const InputDecoration(labelText: 'Student Number'),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        value: _yearOfStudy,
                        decoration:
                            const InputDecoration(labelText: 'Year of Study'),
                        items: const [
                          DropdownMenuItem(value: 1, child: Text('1st Year')),
                          DropdownMenuItem(value: 2, child: Text('2nd Year')),
                          DropdownMenuItem(value: 3, child: Text('3rd Year')),
                        ],
                        onChanged: (v) => setState(() => _yearOfStudy = v ?? 1),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Module 1 Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Icon(Icons.book, color: AppColors.primaryRed),
                        const SizedBox(width: 8),
                        const Text('Module 1 (Required)',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold))
                      ]),
                      const Divider(),
                      DropdownButtonFormField<String>(
                        value: _level1,
                        items: _levels
                            .map((l) => DropdownMenuItem<String>(
                                value: l,
                                child:
                                    Text(l.replaceAll('-', ' ').toUpperCase())))
                            .toList(),
                        onChanged: (v) {
                          setState(() {
                            _level1 = v;
                            _module1 = null;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _module1,
                        items: _getModuleItems(_level1!),
                        onChanged: (v) => setState(() => _module1 = v),
                        validator: (v) => v == null ? 'Select a module' : null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Module 2 (Optional)
              CheckboxListTile(
                title: const Text('Apply for a second module (Optional)'),
                value: _hasSecond,
                onChanged: (v) => setState(() => _hasSecond = v ?? false),
                activeColor: AppColors.primaryRed,
              ),
              if (_hasSecond)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: _level2,
                          items: _levels
                              .map((l) => DropdownMenuItem<String>(
                                  value: l,
                                  child: Text(
                                      l.replaceAll('-', ' ').toUpperCase())))
                              .toList(),
                          onChanged: (v) {
                            setState(() {
                              _level2 = v;
                              _module2 = null;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _module2,
                          items: _getModuleItems(_level2!),
                          onChanged: (v) => setState(() => _module2 = v),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // Document Upload
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Icon(Icons.attach_file, color: AppColors.primaryRed),
                        const SizedBox(width: 8),
                        const Text('Supporting Document',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold))
                      ]),
                      const Divider(),
                      if (_docUploaded)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(children: [
                            Icon(Icons.check_circle, color: AppColors.success),
                            const SizedBox(width: 8),
                            const Text('Document uploaded'),
                          ]),
                        )
                      else if (_uploading)
                        const Center(child: CircularProgressIndicator())
                      else
                        ElevatedButton.icon(
                          onPressed: _pickDocument,
                          icon: const Icon(Icons.upload),
                          label: const Text('Upload Document'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryRed),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Eligibility
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: CheckboxListTile(
                    title: const Text(
                        'I confirm that I meet the minimum requirements (minimum 65% average)'),
                    value: _meetsRequirements,
                    onChanged: (v) =>
                        setState(() => _meetsRequirements = v ?? false),
                    activeColor: AppColors.success,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: AppColors.white)
                    : Text(_isEditMode
                        ? 'Update Application'
                        : 'Submit Application'),
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
