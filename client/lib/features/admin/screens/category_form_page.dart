import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/category_icons.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/primary_button.dart';
import '../providers/category_provider.dart';
import '../services/category_service.dart';

class CategoryFormPage extends StatefulWidget {
  final String? categoryId;

  const CategoryFormPage({super.key, this.categoryId});

  @override
  State<CategoryFormPage> createState() => _CategoryFormPageState();
}

class _CategoryFormPageState extends State<CategoryFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _selectedIcon;
  bool _showIconError = false;
  bool _isLoadingData = false;
  String? _loadError;

  bool get isEditMode => widget.categoryId != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      _loadCategoryData();
    }
  }

  Future<void> _loadCategoryData() async {
    setState(() {
      _isLoadingData = true;
      _loadError = null;
    });

    try {
      final service = context.read<CategoryService>();
      final category = await service.getCategory(widget.categoryId!);
      _nameController.text = category.name;
      _selectedIcon = category.icon;
      setState(() {
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
    super.dispose();
  }

  void _handleSubmit() async {
    setState(() => _showIconError = true);

    if (!_formKey.currentState!.validate() || _selectedIcon == null) {
      return;
    }

    try {
      if (isEditMode) {
        await context.read<CategoryProvider>().updateCategory(
          widget.categoryId!,
          _nameController.text.trim(),
          _selectedIcon!,
        );
      } else {
        await context.read<CategoryProvider>().createCategory(
          _nameController.text.trim(),
          _selectedIcon!,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditMode ? 'Category updated successfully' : 'Category created successfully'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditMode ? 'Failed to update category: $e' : 'Failed to create category: $e'),
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
          isEditMode ? 'Edit Category' : 'Add Category',
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
              const Text(
                'Failed to load category',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                _loadError!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: AppColors.textBlackSoft),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadCategoryData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.greenAccent,
                  foregroundColor: Colors.white,
                ),
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
              'Category Name',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textBlack),
            ),
            const SizedBox(height: 8),
            AppTextField(
              controller: _nameController,
              hintText: 'Enter category name',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Category name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Select Icon',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textBlack),
            ),
            const SizedBox(height: 8),
            _buildIconGrid(),
            if (_showIconError && _selectedIcon == null)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('Please select an icon', style: TextStyle(color: Colors.red, fontSize: 12)),
              ),
            const SizedBox(height: 32),
            Consumer<CategoryProvider>(
              builder: (context, provider, child) {
                return PrimaryButton(
                  onPressed: _handleSubmit,
                  label: isEditMode ? 'Update Category' : 'Add Category',
                  isLoading: isEditMode ? provider.isUpdating : provider.isCreating,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconGrid() {
    final icons = CategoryIcons.availableIcons;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: icons.length,
      itemBuilder: (context, index) {
        final iconKey = icons[index];
        final isSelected = _selectedIcon == iconKey;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedIcon = iconKey;
              _showIconError = false;
            });
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? AppColors.greenAccent.withValues(alpha: 0.1)
                  : AppColors.ceramic,
              border: Border.all(
                color: isSelected ? AppColors.greenAccent : Colors.transparent,
                width: 2,
              ),
            ),
            child: Icon(
              CategoryIcons.getIcon(iconKey),
              size: 24,
              color: isSelected ? AppColors.greenAccent : AppColors.textBlackSoft,
            ),
          ),
        );
      },
    );
  }
}
