import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/category_icons.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/primary_button.dart';
import '../providers/category_provider.dart';
import '../providers/product_provider.dart';
import '../services/product_service.dart';

class ProductFormPage extends StatefulWidget {
  final String? productId;

  const ProductFormPage({super.key, this.productId});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _imagePicker = ImagePicker();

  String? _selectedCategoryId;
  File? _selectedImage;
  String? _existingImageUrl;
  bool _isLoading = true;
  String? _loadError;

  bool get isEditMode => widget.productId != null;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final categoryProvider = context.read<CategoryProvider>();
      await categoryProvider.fetchCategories();

      if (isEditMode) {
        final service = context.read<ProductService>();
        final product = await service.getProduct(widget.productId!);
        _nameController.text = product.name;
        _priceController.text = product.price.toStringAsFixed(0);
        _selectedCategoryId = product.categoryId;
        _existingImageUrl = product.image.isNotEmpty ? product.image : null;
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadError = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final file = File(picked.path);
      final error = _validateImageSize(file);

      if (error != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error), backgroundColor: Colors.red),
          );
        }
        return;
      }

      setState(() {
        _selectedImage = file;
      });
    }
  }

  String? _validateImageSize(File file) {
    const maxSizeInBytes = 5 * 1024 * 1024;
    final fileSize = file.lengthSync();

    if (fileSize > maxSizeInBytes) {
      return 'Image size must be less than 5MB';
    }
    return null;
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final productProvider = context.read<ProductProvider>();
    final name = _nameController.text.trim();
    final price = double.parse(_priceController.text.trim());
    final categoryId = _selectedCategoryId!;

    String? imagePath;
    if (_selectedImage != null) {
      imagePath = _selectedImage!.path;
    }

    try {
      if (isEditMode) {
        await productProvider.updateProduct(
          id: widget.productId!,
          name: name,
          categoryId: categoryId,
          price: price,
          imagePath: imagePath,
        );
      } else {
        await productProvider.createProduct(
          name: name,
          categoryId: categoryId,
          price: price,
          imagePath: imagePath,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditMode ? 'Product updated successfully' : 'Product created successfully'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: ${e.toString()}'),
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
          isEditMode ? 'Edit Product' : 'Add Product',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textBlack),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
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
              const Text('Failed to load product', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(
                _loadError!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: AppColors.textBlackSoft),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadData,
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
            _buildImageSection(),
            const SizedBox(height: 16),
            const Text(
              'Product Name',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textBlack),
            ),
            const SizedBox(height: 8),
            AppTextField(
              controller: _nameController,
              hintText: 'Enter product name',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Product name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Category',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textBlack),
            ),
            const SizedBox(height: 8),
            _buildCategoryDropdown(),
            const SizedBox(height: 16),
            const Text(
              'Price',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textBlack),
            ),
            const SizedBox(height: 8),
            AppTextField(
              controller: _priceController,
              hintText: 'Enter price',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Price is required';
                }
                final price = int.tryParse(value.trim());
                if (price == null || price <= 0) {
                  return 'Price must be greater than 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            Consumer<ProductProvider>(
              builder: (context, productProvider, child) {
                return PrimaryButton(
                  onPressed: _handleSubmit,
                  label: isEditMode ? 'Update Product' : 'Add Product',
                  isLoading: isEditMode ? productProvider.isUpdating : productProvider.isCreating,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Product Image',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textBlack),
        ),
        const SizedBox(height: 8),
        if (_selectedImage != null)
          _buildImagePreview(isLocal: true)
        else if (_existingImageUrl != null)
          _buildImagePreview(isLocal: false)
        else
          _buildUploadContainer(),
      ],
    );
  }

  Widget _buildUploadContainer() {
    return GestureDetector(
      onTap: _pickImage,
      child: DottedBorder(
        options: const RoundedRectDottedBorderOptions(
          radius: Radius.circular(12),
          color: AppColors.border,
          strokeWidth: 2,
          dashPattern: [8, 4],
        ),
        child: Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: AppColors.ceramic,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_outlined, size: 48, color: AppColors.textBlackSoft),
              SizedBox(height: 12),
              Text(
                'Click to upload',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textBlack,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'PNG, JPG, WEBP (Max 5MB)',
                style: TextStyle(fontSize: 12, color: AppColors.textBlackSoft),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview({required bool isLocal}) {
    return GestureDetector(
      onTap: _pickImage,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            if (isLocal)
              Image.file(
                _selectedImage!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              )
            else
              Image.network(
                '${ApiConstants.uploadsUrl}$_existingImageUrl',
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildCategoryIconFallback();
                },
              ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    if (isLocal) {
                      _selectedImage = null;
                    } else {
                      _existingImageUrl = null;
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 20, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryIconFallback() {
    IconData iconData = Icons.image_outlined;

    if (_selectedCategoryId != null) {
      final categoryProvider = context.read<CategoryProvider>();
      final selectedCategory = categoryProvider.categories
          .where((cat) => cat.id == _selectedCategoryId)
          .firstOrNull;
      if (selectedCategory != null) {
        iconData = CategoryIcons.getIcon(selectedCategory.icon) ?? Icons.image_outlined;
      }
    }

    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.greenLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(iconData, size: 64, color: AppColors.greenAccent),
    );
  }

  Widget _buildCategoryDropdown() {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
        final categories = categoryProvider.categories;

        return DropdownButtonFormField<String>(
          initialValue: _selectedCategoryId,
          isExpanded: true,
          decoration: InputDecoration(
            hintText: 'Select category',
            hintStyle: const TextStyle(color: AppColors.textBlackSoft, fontSize: 14),
            filled: true,
            fillColor: AppColors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.greenAccent),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          items: categories.map((category) {
            return DropdownMenuItem<String>(
              value: category.id,
              child: Row(
                children: [
                  Icon(
                    CategoryIcons.getIcon(category.icon),
                    size: 20,
                    color: AppColors.textBlackSoft,
                  ),
                  const SizedBox(width: 8),
                  Text(category.name),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
              setState(() {
                _selectedCategoryId = value;
              });
            },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Category is required';
            }
            return null;
          },
        );
      },
    );
  }
}
