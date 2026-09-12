import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/category_icons.dart';
import '../../../shared/widgets/category_filter_chips.dart';
import '../../../shared/widgets/manage_item_card.dart';
import '../../../shared/widgets/search_bar_with_add_button.dart';
import '../models/product_model.dart';

const List<CategoryChipData> _categories = [
  CategoryChipData(id: 'cat1', name: 'Coffee', iconKey: 'local_cafe'),
  CategoryChipData(id: 'cat2', name: 'Cake', iconKey: 'cake'),
  CategoryChipData(id: 'cat3', name: 'Fast Food', iconKey: 'fastfood'),
  CategoryChipData(id: 'cat4', name: 'Drinks', iconKey: 'local_bar'),
];

const List<Product> _allProducts = [
  Product(id: '1', name: 'Espresso', image: '', price: 25000, categoryId: 'cat1', categoryName: 'Coffee', categoryIcon: 'local_cafe'),
  Product(id: '2', name: 'Cappuccino', image: '', price: 30000, categoryId: 'cat1', categoryName: 'Coffee', categoryIcon: 'local_cafe'),
  Product(id: '3', name: 'Caffe Latte', image: '', price: 32000, categoryId: 'cat1', categoryName: 'Coffee', categoryIcon: 'local_cafe'),
  Product(id: '4', name: 'Chocolate Cake', image: '', price: 35000, categoryId: 'cat2', categoryName: 'Cake', categoryIcon: 'cake'),
  Product(id: '5', name: 'Red Velvet Cake', image: '', price: 38000, categoryId: 'cat2', categoryName: 'Cake', categoryIcon: 'cake'),
  Product(id: '6', name: 'Tiramisu', image: '', price: 42000, categoryId: 'cat2', categoryName: 'Cake', categoryIcon: 'cake'),
  Product(id: '7', name: 'Beef Burger', image: '', price: 45000, categoryId: 'cat3', categoryName: 'Fast Food', categoryIcon: 'fastfood'),
  Product(id: '8', name: 'French Fries', image: '', price: 20000, categoryId: 'cat3', categoryName: 'Fast Food', categoryIcon: 'fastfood'),
  Product(id: '9', name: 'Orange Juice', image: '', price: 18000, categoryId: 'cat4', categoryName: 'Drinks', categoryIcon: 'local_bar'),
  Product(id: '10', name: 'Mineral Water', image: '', price: 8000, categoryId: 'cat4', categoryName: 'Drinks', categoryIcon: 'local_bar'),
];

class ManageProductPage extends StatefulWidget {
  const ManageProductPage({super.key});

  @override
  State<ManageProductPage> createState() => _ManageProductPageState();
}

class _ManageProductPageState extends State<ManageProductPage> {
  final _searchController = TextEditingController();
  String? _selectedCategoryId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Product> get _filteredProducts {
    if (_selectedCategoryId == null) return _allProducts;
    return _allProducts.where((product) => product.categoryId == _selectedCategoryId).toList();
  }

  void _onCategorySelected(String? categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
    });
  }

  void _handleEdit(Product product) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Edit ${product.name} - Not implemented yet'),
      backgroundColor: AppColors.greenAccent,
    ));
  }

  void _handleDelete(Product product) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Delete ${product.name} - Not implemented yet'),
      backgroundColor: Colors.red,
    ));
  }

  String _formatPrice(double price) {
    final priceString = price.toStringAsFixed(0);
    final formatted = priceString.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
    return 'Rp $formatted';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(context).openDrawer()),
        titleSpacing: 12,
        title: const Text('Manage Product', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textBlack)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: SearchBarWithAddButton(
              hintText: 'Search product...',
              controller: _searchController,
              onChanged: (value) {},
              onAddPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Add Product - Not implemented yet'), backgroundColor: AppColors.greenAccent),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          CategoryFilterChips(
            categories: _categories,
            selectedCategoryId: _selectedCategoryId,
            onCategorySelected: _onCategorySelected,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _filteredProducts.isEmpty
                ? const Center(child: Text('No products found in this category', style: TextStyle(fontSize: 14, color: AppColors.textBlackSoft)))
                : RefreshIndicator(
                    onRefresh: () async {},
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        ..._filteredProducts.map((product) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildProductItem(product: product),
                          );
                        }),
                        _buildPagination(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem({required Product product}) {
    return ManageItemCard(
      content: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(color: AppColors.greenLight, borderRadius: BorderRadius.circular(12)),
            child: Icon(CategoryIcons.getIcon(product.categoryIcon) ?? Icons.fastfood, size: 32, color: AppColors.greenAccent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              spacing: 4,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.categoryName, style: const TextStyle(fontSize: 12, color: AppColors.textBlackSoft)),
                Text(product.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textBlack)),
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

  Widget _buildPagination() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        children: [
          Text('Page 1 of 1  (${_filteredProducts.length} items)', style: const TextStyle(fontSize: 13, color: AppColors.textBlackSoft)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPaginationButton(label: 'Prev', onPressed: null),
              const SizedBox(width: 12),
              _buildPaginationButton(label: 'Next', onPressed: null),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationButton({required String label, required VoidCallback? onPressed}) {
    return SizedBox(
      width: 100,
      height: 40,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.greenAccent,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.greenAccent.withValues(alpha: 0.4),
          disabledForegroundColor: Colors.white70,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      ),
    );
  }
}
