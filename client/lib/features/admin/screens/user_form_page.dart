import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/primary_button.dart';
import '../providers/user_provider.dart';
import '../services/user_service.dart';

class UserFormPage extends StatefulWidget {
  final String? userId;

  const UserFormPage({super.key, this.userId});

  @override
  State<UserFormPage> createState() => _UserFormPageState();
}

class _UserFormPageState extends State<UserFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoadingData = false;
  String? _loadError;
  bool _isActive = true;

  bool get isEditMode => widget.userId != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      _loadUserData();
    }
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoadingData = true;
      _loadError = null;
    });

    try {
      final service = context.read<UserService>();
      final user = await service.getUser(widget.userId!);
      _nameController.text = user.name;
      _emailController.text = user.email;
      setState(() {
        _isActive = user.isActive;
        _isLoadingData = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingData = false;
        _loadError = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      if (isEditMode) {
        await context.read<UserProvider>().updateUser(
          widget.userId!,
          _nameController.text.trim(),
          _emailController.text.trim(),
          'CASHIER',
          _isActive,
        );
      } else {
        await context.read<UserProvider>().createUser(
          _nameController.text.trim(),
          _emailController.text.trim(),
          'CASHIER',
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditMode ? 'User updated successfully' : 'User created successfully'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditMode ? 'Failed to update user: $e' : 'Failed to create user: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        titleSpacing: 12,
        title: Text(
          isEditMode ? 'Edit User' : 'Add User',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textBlack),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoadingData) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Failed to load user', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(
                _loadError!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: AppColors.textBlackSoft),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadUserData,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.greenAccent, foregroundColor: Colors.white),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'User Name',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textBlack),
            ),
            const SizedBox(height: 8),
            AppTextField(
              controller: _nameController,
              hintText: 'Enter user name',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'User name is required';
                }
                if (value.trim().length < 2) {
                  return 'Name must be at least 2 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Email',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textBlack),
            ),
            const SizedBox(height: 8),
            AppTextField(
              controller: _emailController,
              hintText: 'Enter email address',
              keyboardType: TextInputType.emailAddress,
              readOnly: isEditMode,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Email is required';
                }
                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (!emailRegex.hasMatch(value.trim())) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
            if (isEditMode) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Account Status',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textBlack,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isActive
                                ? 'User can login and access the system'
                                : 'User is blocked from logging in',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textBlackSoft,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isActive,
                      onChanged: (value) {
                        setState(() {
                          _isActive = value;
                        });
                      },
                      activeThumbColor: AppColors.greenAccent,
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),
            Consumer<UserProvider>(
              builder: (context, provider, child) {
                return PrimaryButton(
                  onPressed: _handleSubmit,
                  label: isEditMode ? 'Update User' : 'Add User',
                  isLoading: isEditMode ? provider.isUpdating : provider.isCreating,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
