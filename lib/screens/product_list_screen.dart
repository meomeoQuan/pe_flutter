import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../widgets/custom_image.dart';
import '../widgets/product_card.dart';

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
    final isLoading = productProvider.isLoading;

    final heroProduct = products.isNotEmpty ? products.first : null;
    final newArrivals = products.length > 1 ? products.skip(1).take(4).toList() : <dynamic>[];
    final trendingProducts = products.length > 5 ? products.skip(5).toList() : <dynamic>[];

    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0B),
      body: Stack(
        children: [
          // Radial Glow
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  colors: [const Color(0xFFE60A15).withValues(alpha: 0.15), Colors.transparent],
                  stops: const [0.0, 0.7],
                ),
              ),
            ),
          ),

          // Main Content Area
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Top Custom Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B0B0B).withValues(alpha: 0.8),
                    border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.filter_hdr, color: Color(0xFFE60A15), size: 32),
                          SizedBox(width: 8),
                          Text('LUXE', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2)),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.search, color: Colors.white),
                            onPressed: () {},
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
                                    decoration: const BoxDecoration(color: Color(0xFFE60A15), shape: BoxShape.circle),
                                    child: Text(
                                      '${cartProvider.itemCount}',
                                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, color: Colors.white),
                            color: const Color(0xFF181111),
                            onSelected: (value) {
                              if (value == 'revenue') {
                                context.push('/revenue');
                              } else if (value == 'admin') {
                                context.push('/products/add');
                              } else if (value == 'logout') {
                                context.read<AuthProvider>().logout();
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(value: 'revenue', child: ListTile(leading: Icon(Icons.bar_chart, color: Color(0xFFE60A15)), title: Text('Revenue', style: TextStyle(color: Colors.white)))),
                              const PopupMenuItem(value: 'admin', child: ListTile(leading: Icon(Icons.add_box, color: Colors.white), title: Text('Add Product', style: TextStyle(color: Colors.white)))),
                              const PopupMenuItem(value: 'logout', child: ListTile(leading: Icon(Icons.logout, color: Colors.redAccent), title: Text('Logout', style: TextStyle(color: Colors.white)))),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFFE60A15)))
                      : products.isEmpty
                          ? Center(child: Text('Grid is empty.', style: TextStyle(color: Colors.white.withValues(alpha: 0.6))))
                          : ListView(
                              padding: const EdgeInsets.only(bottom: 120),
                              children: [
                                // Hero Feature Drop
                                if (heroProduct != null)
                                  GestureDetector(
                                    onTap: () => context.go('/products/${heroProduct.id}'),
                                    child: Stack(
                                      children: [
                                        SizedBox(
                                          height: MediaQuery.of(context).size.width * 0.8,
                                          width: double.infinity,
                                          child: CustomImage(
                                            imageUrl: heroProduct.imageUrl,
                                            fit: BoxFit.cover,
                                            fallbackWidget: Container(color: const Color(0xFF181111)),
                                          ),
                                        ),
                                        Positioned.fill(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.bottomCenter,
                                                end: Alignment.topCenter,
                                                colors: [const Color(0xFF0B0B0B).withValues(alpha: 1.0), Colors.transparent],
                                                stops: const [0.0, 0.7],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 24, left: 16, right: 16,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(color: const Color(0xFFE60A15), borderRadius: BorderRadius.circular(4)),
                                                child: const Text('FEATURED DROP', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(heroProduct.name, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, height: 1.1)),
                                              const SizedBox(height: 12),
                                              Row(
                                                children: [
                                                  FilledButton(
                                                    onPressed: () {
                                                      context.read<CartProvider>().addToCart(heroProduct);
                                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${heroProduct.name} added to cart'), backgroundColor: const Color(0xFFE60A15), duration: const Duration(seconds: 1)));
                                                    },
                                                    style: FilledButton.styleFrom(backgroundColor: const Color(0xFFE60A15), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
                                                    child: const Row(
                                                      children: [Icon(Icons.shopping_cart, size: 16), SizedBox(width: 8), Text('Shop Now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  OutlinedButton(
                                                    onPressed: () => context.go('/products/${heroProduct.id}'),
                                                    style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.white.withValues(alpha: 0.2)), backgroundColor: Colors.white.withValues(alpha: 0.1), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
                                                    child: const Text('Details', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                // Horizontal Scrolling Products
                                if (newArrivals.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 24, bottom: 16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text('New Arrivals', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                              GestureDetector(
                                                onTap: () => context.push('/discover'),
                                                child: const Text('View All', style: TextStyle(color: Color(0xFFE60A15), fontSize: 14, fontWeight: FontWeight.w600)),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        SizedBox(
                                          height: 200,
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            padding: const EdgeInsets.symmetric(horizontal: 16),
                                            itemCount: newArrivals.length,
                                            itemBuilder: (context, index) {
                                              final item = newArrivals[index];
                                              return GestureDetector(
                                                onTap: () => context.go('/products/${item.id}'),
                                                child: Container(
                                                  width: 140,
                                                  margin: const EdgeInsets.only(right: 16),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Expanded(
                                                        child: ClipRRect(
                                                          borderRadius: BorderRadius.circular(16),
                                                          child: CustomImage(
                                                            imageUrl: item.imageUrl.isNotEmpty ? item.imageUrl : 'https://via.placeholder.com/150',
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 12),
                                                      Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                                                      const SizedBox(height: 4),
                                                      Text('\$${item.price.toStringAsFixed(2)}', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12)),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                // Vertical Categories (Trending Now)
                                if (trendingProducts.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 24, left: 16, right: 16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Trending Now', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 16),
                                        ...trendingProducts.map((p) => ProductCard(product: p)),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                ),
              ],
            ),
          ),

          // Bottom Navigation Navbar
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: MediaQuery.of(context).padding.bottom + 16),
              decoration: BoxDecoration(
                color: const Color(0xFF0B0B0B).withValues(alpha: 0.95),
                border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _BottomNavItem(icon: Icons.home, label: 'Home', isActive: true),
                  _BottomNavItem(icon: Icons.explore, label: 'Discover', isActive: false, onTap: () => context.push('/discover')),
                  _BottomNavItem(icon: Icons.favorite, label: 'Saved', isActive: false, onTap: () => context.push('/saved')),
                  _BottomNavItem(icon: Icons.person, label: 'Account', isActive: false, onTap: () => context.push('/account')),
                ],
              ),
            ),
          ),

          // Floating Action Button to Add Items (positioned appropriately above the nav bar)
          Positioned(
            right: 16, bottom: MediaQuery.of(context).padding.bottom + 80,
            child: FloatingActionButton(
              onPressed: () => context.go('/products/add'),
              tooltip: 'Add Product',
              backgroundColor: const Color(0xFFE60A15),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const _BottomNavItem({required this.icon, required this.label, required this.isActive, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? const Color(0xFFE60A15) : Colors.white.withValues(alpha: 0.4)),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: isActive ? const Color(0xFFE60A15) : Colors.white.withValues(alpha: 0.4),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
