import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../widgets/background_wrapper.dart';
import '../widgets/glass_container.dart';

class ProductDetailScreen extends StatelessWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final product = productProvider.findById(productId);

    if (product == null) {
      return BackgroundWrapper(
        hasAppBar: true,
        title: 'Not Found',
        child: const Center(
          child: Text(
            'This item no longer exists in the grid.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0B),
      body: Stack(
        children: [
          // Hero Image Section
          Positioned(
            top: 0, left: 0, right: 0,
            height: MediaQuery.of(context).size.height * 0.6,
            child: Stack(
              fit: StackFit.expand,
              children: [
                product.imageUrl.isNotEmpty
                    ? Image.network(product.imageUrl, fit: BoxFit.cover)
                    : Container(color: const Color(0xFF181111)),
                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        const Color(0xFF0B0B0B),
                        const Color(0xFF0B0B0B).withValues(alpha: 0.8),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.3, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content Scroll
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: const SizedBox.shrink(),
                  flexibleSpace: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () => context.pop(),
                              child: const SizedBox(
                                width: 36, height: 36,
                                child: Center(child: Icon(Icons.arrow_back, color: Colors.white, size: 20)),
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                  child: InkWell(
                                    customBorder: const CircleBorder(),
                                    onTap: () => context.go('/products/${product.id}/edit'),
                                    child: const SizedBox(
                                      width: 36, height: 36,
                                      child: Center(child: Icon(Icons.edit, color: Colors.white, size: 20)),
                                    ),
                                  ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                  child: InkWell(
                                    customBorder: const CircleBorder(),
                                    onTap: () => _confirmDelete(context, productProvider),
                                    child: const SizedBox(
                                      width: 36, height: 36,
                                      child: Center(child: Icon(Icons.delete, color: Colors.redAccent, size: 20)),
                                    ),
                                  ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(height: MediaQuery.of(context).size.height * 0.5 - 160), // Spacing to push content down
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title & Price
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('PREMIUM ITEM', style: TextStyle(color: Color(0xFFE60A15), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
                                  const SizedBox(height: 8),
                                  Text(
                                    product.name,
                                    style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, height: 1.1),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        
                        // Quick Stats
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              border: Border.symmetric(horizontal: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star, color: Color(0xFFE60A15), size: 20),
                                const SizedBox(width: 8),
                                const Text('4.9', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 4),
                                Text('(128)', style: TextStyle(color: Colors.white.withValues(alpha: 0.5))),
                                const SizedBox(width: 24),
                                Container(width: 1, height: 24, color: Colors.white.withValues(alpha: 0.1)),
                                const SizedBox(width: 24),
                                const Icon(Icons.inventory_2, color: Colors.greenAccent, size: 20),
                                const SizedBox(width: 8),
                                const Text('In Stock', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 14)),
                              ],
                            ),
                          ),
                        ),

                        // About Section
                        const Text('About this item', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        Text(
                          product.description,
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 15, height: 1.6),
                        ),
                        
                        // Specs placeholder
                        const SizedBox(height: 32),
                        const Text('Specifications', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        _buildSpecRow('Design', 'Minimalist, Premium', true),
                        _buildSpecRow('Compatibility', 'Universal', false),
                        _buildSpecRow('Warranty', '1 Year Standard', false),
                        const SizedBox(height: 140), // Bottom padding for FAB and Nav
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Action Bar
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: EdgeInsets.only(left: 24, right: 24, top: 20, bottom: MediaQuery.of(context).padding.bottom + 20),
              decoration: BoxDecoration(
                color: const Color(0xFF0B0B0B).withValues(alpha: 0.95),
                border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFF181111),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: IconButton(
                      icon: Icon(
                        productProvider.isSaved(product.id) ? Icons.favorite : Icons.favorite_border,
                        color: productProvider.isSaved(product.id) ? const Color(0xFFE60A15) : Colors.white,
                      ),
                      onPressed: () {
                        productProvider.toggleSaved(product.id);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFE60A15),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFE60A15).withValues(alpha: 0.4),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                          ),
                        ),
                        FilledButton(
                          onPressed: () {
                            context.read<CartProvider>().addToCart(product);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${product.name} added to cart'),
                                backgroundColor: const Color(0xFFE60A15),
                                action: SnackBarAction(
                                  label: 'VIEW CART',
                                  textColor: Colors.white,
                                  onPressed: () => context.push('/cart'),
                                ),
                              ),
                            );
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFE60A15),
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.shopping_bag_outlined, size: 20),
                              SizedBox(width: 8),
                              Text('ADD TO CART', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecRow(String label, String value, bool isFirst) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: isFirst ? Colors.white.withValues(alpha: 0.1) : Colors.transparent, width: isFirst ? 1 : 0), bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, ProductProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141414),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        title: const Text('PURGE ITEM', style: TextStyle(color: Colors.redAccent)),
        content: const Text(
          'Are you sure you want to permanently delete this item from the grid?',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('CANCEL', style: TextStyle(color: Colors.white70)),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              provider.deleteProduct(productId);
              context.go('/products');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Item purged.'),
                  backgroundColor: Colors.redAccent,
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.redAccent.withValues(alpha: 0.2),
              foregroundColor: Colors.redAccent,
            ),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }
}
