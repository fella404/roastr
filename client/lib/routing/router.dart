import 'package:client/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../features/auth/providers/auth_provider.dart';
import '../features/auth/screens/login_page.dart';
import '../shared/widgets/admin_drawer.dart';
import '../shared/widgets/floating_close_button.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  redirect: (context, state) {
    final authProvider = context.read<AuthProvider>();
    final isAuthenticated = authProvider.isAuthenticated;
    final location = state.uri.toString();
    final isLoginPage = location == '/login';

    if (!isAuthenticated && !isLoginPage) {
      return '/login';
    }

    if (isAuthenticated && isLoginPage) {
      final role = authProvider.user?.role;
      if (role == 'ADMIN') return '/admin/dashboard';
      return '/catalog';
    }

    if (isAuthenticated) {
      final role = authProvider.user?.role;
      if (role == 'CASHIER' && location.startsWith('/admin')) {
        return '/catalog';
      }
      if (role == 'ADMIN' && !location.startsWith('/admin') && !isLoginPage) {
        return '/admin/dashboard';
      }
    }

    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const Loginpage()),

    ShellRoute(
      builder: (context, state, child) {
        return _CashierShellLayout(child: child);
      },
      routes: [
        GoRoute(
          path: '/catalog',
          builder: (context, state) => const _PlaceholderPage(title: 'Catalog'),
        ),
        GoRoute(
          path: '/cart',
          builder: (context, state) => const _PlaceholderPage(title: 'Cart'),
        ),
        GoRoute(
          path: '/history',
          builder: (context, state) => const _PlaceholderPage(title: 'History'),
        ),
      ],
    ),

    ShellRoute(
      builder: (context, state, child) {
        return _AdminShellLayout(child: child);
      },
      routes: [
        GoRoute(
          path: '/admin/dashboard',
          builder: (context, state) =>
              const _PlaceholderPage(title: 'Dashboard'),
        ),
        GoRoute(
          path: '/admin/users',
          builder: (context, state) => const _PlaceholderPage(title: 'Users'),
        ),
        GoRoute(
          path: '/admin/categories',
          builder: (context, state) =>
              const _PlaceholderPage(title: 'Categories'),
        ),
        GoRoute(
          path: '/admin/products',
          builder: (context, state) =>
              const _PlaceholderPage(title: 'Products'),
        ),
        GoRoute(
          path: '/admin/transactions',
          builder: (context, state) =>
              const _PlaceholderPage(title: 'Transaction History'),
        ),
        GoRoute(
          path: '/admin/profile',
          builder: (context, state) => const _PlaceholderPage(title: 'Profile'),
        ),
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

class _AdminShellLayout extends StatefulWidget {
  final Widget child;
  const _AdminShellLayout({required this.child});

  @override
  State<_AdminShellLayout> createState() => _AdminShellLayoutState();
}

class _AdminShellLayoutState extends State<_AdminShellLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  OverlayEntry? _floatingCloseButtonEntry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const AdminDrawer(),
      drawerEnableOpenDragGesture: false,
      onDrawerChanged: (isOpen) {
        if (isOpen) {
          _showFloatingCloseButton();
        } else {
          _hideFloatingCloseButton();
        }
      },
      body: widget.child,
    );
  }

  void _showFloatingCloseButton() {
    _floatingCloseButtonEntry?.remove();
    _floatingCloseButtonEntry = OverlayEntry(
      builder: (context) =>
          FloatingCloseButton(onTap: () => Navigator.of(context).pop()),
    );
    Overlay.of(context).insert(_floatingCloseButtonEntry!);
  }

  void _hideFloatingCloseButton() {
    _floatingCloseButtonEntry?.remove();
    _floatingCloseButtonEntry = null;
  }

  @override
  void dispose() {
    _floatingCloseButtonEntry?.remove();
    super.dispose();
  }
}

class _PlaceholderPage extends StatelessWidget {
  final String title;
  const _PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).uri.toString();
    final isAdminPage = currentLocation.startsWith('/admin');

    return Scaffold(
      appBar: AppBar(
        leading: isAdminPage
            ? IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              )
            : null,
        titleSpacing: 12,
        title: Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textBlack,
          ),
        ),
      ),
      body: Center(child: Text(title, style: const TextStyle(fontSize: 24))),
    );
  }
}
