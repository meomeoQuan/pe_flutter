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

    return BackgroundWrapper(
      hasAppBar: true,
      title: 'Details',
      actions: [
        IconButton(
          icon: const Icon(Icons.edit, color: Color(0xFFE50914)),
          tooltip: 'Edit',
          onPressed: () => context.go('/products/${product.id}/edit'),
        ),
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.redAccent),
          tooltip: 'Delete',
          onPressed: () => _confirmDelete(context, productProvider),
        ),
      ],
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100), // Space for FAB
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hero Image with glow
                if (product.imageUrl.isNotEmpty)
                  Container(
                    height: 350,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE50914).withValues(alpha: 0.2),
                          blurRadius: 50,
                          spreadRadius: 10,
                        )
                      ],
                    ),
                    child: CachedNetworkImage(
                      imageUrl: product.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => const Center(
                        child: CircularProgressIndicator(color: Color(0xFFE50914)),
                      ),
                      errorWidget: (_, _, _) => Container(
                        color: Colors.white.withValues(alpha: 0.05),
                        child: Icon(Icons.broken_image,
                            size: 64, color: Colors.white.withValues(alpha: 0.3)),
                      ),
                    ),
                  )
                else
                  Container(
                    height: 300,
                    color: Colors.white.withValues(alpha: 0.05),
                    child: Icon(Icons.image,
                        size: 64, color: Colors.white.withValues(alpha: 0.3)),
                  ),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: GlassContainer(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Price
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE50914).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFE50914).withValues(alpha: 0.5),
                            ),
                          ),
                          child: Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Description Title
                        Row(
                          children: [
                            const Icon(Icons.info_outline, color: Color(0xFFE50914), size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'DESCRIPTION',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white.withValues(alpha: 0.5),
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Description Content
                        Text(
                          product.description,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Floating Add to Cart Button Positioned at Bottom
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE50914).withValues(alpha: 0.4),
                    blurRadius: 30,
                    spreadRadius: 2,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: FilledButton.icon(
                onPressed: () {
                  context.read<CartProvider>().addToCart(product);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${product.name} added to cart'),
                      backgroundColor: const Color(0xFFE50914),
                      action: SnackBarAction(
                        label: 'VIEW CART',
                        textColor: Colors.white,
                        onPressed: () => context.push('/cart'),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.add_shopping_cart, size: 24),
                label: const Text(
                  'ADD TO CART',
                  style: TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.bold),
                ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  backgroundColor: const Color(0xFFE50914),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
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
