import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const _PlaceholderPage(title: 'Login'),
    ),

    ShellRoute(
      builder: (context, state, child) {
        return _CashierShellLayout(child: child);
      },
      routes: [
        GoRoute(path: '/catalog', builder: (context, state) => const _PlaceholderPage(title: 'Catalog')),
        GoRoute(path: '/cart', builder: (context, state) => const _PlaceholderPage(title: 'Cart')),
        GoRoute(path: '/history', builder: (context, state) => const _PlaceholderPage(title: 'History')),
      ],
    ),

    ShellRoute(
      builder: (context, state, child) {
        return _AdminShellLayout(child: child);
      },
      routes: [
        GoRoute(path: '/admin/dashboard', builder: (context, state) => const _PlaceholderPage(title: 'Dashboard')),
        GoRoute(path: '/admin/users', builder: (context, state) => const _PlaceholderPage(title: 'Users')),
        GoRoute(path: '/admin/categories', builder: (context, state) => const _PlaceholderPage(title: 'Categories')),
        GoRoute(path: '/admin/products', builder: (context, state) => const _PlaceholderPage(title: 'Products')),
      ],
    ),
  ],
);
class _CashierShellLayout extends StatelessWidget {
  final Widget child;
  const _CashierShellLayout({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          child,          
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: const Icon(Icons.storefront, color: Colors.white),
                    onPressed: () => context.go('/catalog'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.shopping_cart, color: Colors.white),
                    onPressed: () => context.go('/cart'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.receipt_long, color: Colors.white),
                    onPressed: () => context.go('/history'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminShellLayout extends StatelessWidget {
  final Widget child;
  const _AdminShellLayout({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _calculateAdminIndex(context),
            onDestinationSelected: (index) {
              if (index == 0) context.go('/admin/dashboard');
              if (index == 1) context.go('/admin/products');
              if (index == 2) context.go('/admin/categories');
              if (index == 3) context.go('/admin/users');
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(icon: Icon(Icons.dashboard), label: Text('Dashboard')),
              NavigationRailDestination(icon: Icon(Icons.inventory_2), label: Text('Products')),
              NavigationRailDestination(icon: Icon(Icons.category), label: Text('Categories')),
              NavigationRailDestination(icon: Icon(Icons.people), label: Text('Users')),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }

  int _calculateAdminIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/admin/dashboard')) return 0;
    if (location.startsWith('/admin/products')) return 1;
    if (location.startsWith('/admin/categories')) return 2;
    if (location.startsWith('/admin/users')) return 3;
    return 0;
  }
}

class _PlaceholderPage extends StatelessWidget {
  final String title;
  const _PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(title, style: const TextStyle(fontSize: 24))),
    );
  }
}