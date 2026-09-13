import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/category_icons.dart';
import '../../../shared/widgets/category_filter_chips.dart';
import '../../../shared/widgets/delete_confirmation_dialog.dart';
import '../../../shared/widgets/manage_item_card.dart';
import '../../../shared/widgets/pagination_widget.dart';
import '../../../shared/widgets/search_bar_with_add_button.dart';
import '../../admin/providers/category_provider.dart';
import '../../admin/providers/product_provider.dart';

class ManageProductPage extends StatefulWidget {
  const ManageProductPage({super.key});

  @override
  State<ManageProductPage> createState() => _ManageProductPageState();
}

class _ManageProductPageState extends State<ManageProductPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().fetchCategories();
      context.read<ProductProvider>().fetchProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleEdit(dynamic product) async {
    await context.push('/admin/products/edit/${product.id}');
    if (mounted) {
      context.read<ProductProvider>().refreshProducts();
    }
  }

  Future<void> _handleDelete(dynamic product) async {
    final productProvider = context.read<ProductProvider>();

    await showDialog(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
        title: 'Delete Product',
        message: 'Are you sure you want to delete this product?',
        onConfirm: () async {
          try {
            await productProvider.deleteProduct(product.id);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Product deleted successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to delete: ${e.toString()}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  String _formatPrice(double price) {
    final priceString = price.toStringAsFixed(0);
    final formatted = priceString.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
    return 'Rp $formatted';
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final categoryProvider = context.watch<CategoryProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(context).openDrawer()),
        titleSpacing: 12,
        title: const Text(
          'Manage Product',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textBlack),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: SearchBarWithAddButton(
              hintText: 'Search product...',
              controller: _searchController,
              onChanged: (value) => productProvider.searchProducts(value),
              onAddPressed: () async {
                await context.push('/admin/products/add');
                if (mounted) {
                  context.read<ProductProvider>().refreshProducts();
                }
              },
            ),
          ),
          const SizedBox(height: 24),
          categoryProvider.isLoading
              ? const SizedBox(height: 88, child: Center(child: CircularProgressIndicator()))
              : CategoryFilterChips(
                  categories: categoryProvider.categories
                      .map((cat) => CategoryChipData(id: cat.id, name: cat.name, iconKey: cat.icon))
                      .toList(),
                  selectedCategoryId: productProvider.selectedCategoryId,
                  onCategorySelected: (id) => productProvider.filterByCategory(id),
                ),
          const SizedBox(height: 24),
          Expanded(child: _buildProductList(productProvider)),
        ],
      ),
    );
  }

  Widget _buildProductList(ProductProvider productProvider) {
    if (productProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (productProvider.errorMessage != null) {
      return _buildErrorState(productProvider);
    }

    if (productProvider.products.isEmpty) {
      return const Center(
        child: Text('No products found', style: TextStyle(fontSize: 14, color: AppColors.textBlackSoft)),
      );
    }

    return RefreshIndicator(
      onRefresh: productProvider.refreshProducts,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          ...productProvider.products.map((product) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildProductItem(product: product),
            );
          }),
          PaginationWidget(
            currentPage: productProvider.currentPage,
            totalPages: productProvider.totalPages,
            totalItems: productProvider.totalItems,
            hasPreviousPage: productProvider.hasPreviousPage,
            hasNextPage: productProvider.hasNextPage,
            isLoading: productProvider.isLoading,
            onPrevious: productProvider.previousPage,
            onNext: productProvider.nextPage,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildErrorState(ProductProvider productProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            productProvider.errorMessage!,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: productProvider.refreshProducts, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildProductItem({required dynamic product}) {
    return ManageItemCard(
      content: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              '${ApiConstants.uploadsUrl}${product.image}',
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                print('Image URL: ${ApiConstants.uploadsUrl}${product.image}');
                return Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(color: AppColors.greenLight, borderRadius: BorderRadius.circular(12)),
                  child: Icon(CategoryIcons.getIcon(product.categoryIcon) ?? Icons.fastfood, size: 32, color: AppColors.greenAccent),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(color: AppColors.ceramic, borderRadius: BorderRadius.circular(12)),
                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              spacing: 4,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.categoryName, style: const TextStyle(fontSize: 12, color: AppColors.textBlackSoft)),
                Text(
                  product.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textBlack),
                ),
                Text(_formatPrice(product.price), style: const TextStyle(fontSize: 14, color: AppColors.starbucksGreen)),
              ],
            ),
          ),
        ],
      ),
      onEdit: () => _handleEdit(product),
      onDelete: () => _handleDelete(product),
    );
  }
}
