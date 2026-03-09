import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/background_wrapper.dart';
import '../widgets/glass_container.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<ProductProvider>().loadProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final cartProvider = context.watch<CartProvider>();
    final products = productProvider.products;

    return BackgroundWrapper(
      hasAppBar: true,
      title: 'STREAM STORE',
      actions: [
        IconButton(
          icon: Icon(
            productProvider.sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
            color: const Color(0xFFE50914),
          ),
          tooltip: productProvider.sortAscending ? 'Price: Low → High' : 'Price: High → Low',
          onPressed: () => productProvider.toggleSortOrder(),
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
              onPressed: () => context.push('/cart'),
            ),
            if (cartProvider.itemCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE50914),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Color(0xFFE50914), blurRadius: 8),
                    ],
                  ),
                  child: Text(
                    '${cartProvider.itemCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          color: const Color(0xFF1E293B), // Dark surface
          onSelected: (value) {
            if (value == 'revenue') {
              context.push('/revenue');
            } else if (value == 'logout') {
              context.read<AuthProvider>().logout();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'revenue',
              child: ListTile(
                leading: Icon(Icons.bar_chart, color: Color(0xFFE50914)),
                title: Text('Revenue', style: TextStyle(color: Colors.white)),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'logout',
              child: ListTile(
                leading: Icon(Icons.logout, color: Colors.redAccent),
                title: Text('Logout', style: TextStyle(color: Colors.white)),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/products/add'),
        tooltip: 'Add Product',
        backgroundColor: const Color(0xFFE50914),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: GlassContainer(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search the grid...',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFFE50914)),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white70),
                          onPressed: () {
                            _searchController.clear();
                            productProvider.setSearchQuery('');
                          },
                        )
                      : null,
                  fillColor: Colors.transparent,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
                onChanged: (value) {
                  productProvider.setSearchQuery(value);
                  setState(() {});
                },
              ),
            ),
          ),
          Expanded(
            child: productProvider.isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFE50914)))
                : products.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.auto_awesome,
                                size: 64, color: Colors.white.withValues(alpha: 0.2)),
                            const SizedBox(height: 16),
                            Text(
                              productProvider.searchQuery.isNotEmpty
                                  ? 'No matches in the system'
                                  : 'Grid is empty.\nInitialize new items!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 16,
                                  letterSpacing: 1),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 80),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          return ProductCard(product: products[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
