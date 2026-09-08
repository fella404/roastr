import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/models/user_model.dart';

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final currentLocation = GoRouterState.of(context).uri.toString();

    return Drawer(
      width: 280,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Column(
        children: [
          _buildHeader(context, user),
          Expanded(child: _buildNavigationItems(context, currentLocation)),
          const Divider(height: 1, thickness: 1, color: AppColors.ceramic),
          _buildLogoutButton(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, User? user) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16, topPadding + 16, 16, 16),
      decoration: BoxDecoration(color: AppColors.greenAccent),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Roastr',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 8),
          if (user != null)
            Text(
              '${user.name} (${user.role[0].toUpperCase() + user.role.substring(1).toLowerCase()})',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.white.withValues(alpha: 0.9),
              ),
            )
          else
            Text(
              'Guest',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.white.withValues(alpha: 0.7),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNavigationItems(BuildContext context, String currentLocation) {
    final navItems = [
      _NavItem(
        icon: Icons.dashboard,
        label: 'Dashboard',
        route: '/admin/dashboard',
      ),
      _NavItem(
        icon: Icons.category,
        label: 'Manage Category',
        route: '/admin/categories',
      ),
      _NavItem(
        icon: Icons.inventory_2,
        label: 'Manage Product',
        route: '/admin/products',
      ),
      _NavItem(icon: Icons.people, label: 'Manage User', route: '/admin/users'),
      _NavItem(
        icon: Icons.receipt_long,
        label: 'Transaction History',
        route: '/admin/transactions',
      ),
      _NavItem(icon: Icons.person, label: 'Profile', route: '/admin/profile'),
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: navItems.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = navItems[index];
        final isActive = currentLocation == item.route;

        return ListTile(
          leading: Icon(
            item.icon,
            color: isActive ? AppColors.white : AppColors.textBlack,
            size: 24,
          ),
          title: Text(
            item.label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              color: isActive ? AppColors.white : AppColors.textBlack,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          tileColor: isActive
              ? AppColors.greenAccent.withValues(alpha: 0.7)
              : null,
          onTap: () {
            context.go(item.route);
          },
        );
      },
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () async {
            final authProvider = context.read<AuthProvider>();
            await authProvider.logout();
            if (context.mounted) {
              context.go('/login');
            }
          },
          icon: const Icon(Icons.logout, color: Colors.red, size: 20),
          label: const Text(
            'Logout',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),
          style: ElevatedButton.styleFrom(
            alignment: Alignment.centerLeft,
            elevation: 0,
            backgroundColor: Colors.red.shade50,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String route;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}
