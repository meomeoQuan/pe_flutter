import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../widgets/cart_item_tile.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final items = cartProvider.items;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
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
      ),
      body: items.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.remove_shopping_cart, size: 64, color: Colors.white.withValues(alpha: 0.2)),
                  const SizedBox(height: 16),
                  Text('Your cart is empty', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 18, letterSpacing: 1)),
                  const SizedBox(height: 24),
                  OutlinedButton(
                    onPressed: () => context.go('/products'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE60A15)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Return to Grid', style: TextStyle(color: Color(0xFFE60A15))),
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                // Background Glow
                Positioned(
                  top: -100, right: -100,
                  child: Container(
                    width: 300, height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: const Color(0xFFE60A15).withValues(alpha: 0.15), blurRadius: 100, spreadRadius: 50),
                      ],
                    ),
                  ),
                ),
                
                SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        const Text('My Cart', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('${items.length} items in your cart', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14)),
                        const SizedBox(height: 32),

                        // Cart Items
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            return CartItemTile(item: items[index]);
                          },
                        ),
                        
                        const SizedBox(height: 16),

                        // Order Summary
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFF181111).withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 20, offset: const Offset(0, 10)),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Order Summary', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 24),
                              
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Subtotal', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14)),
                                  Text('\$${cartProvider.totalPrice.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Estimated Tax', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14)),
                                  Text('\$${(cartProvider.totalPrice * 0.08).toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 24),
                                child: Container(height: 1, color: Colors.white.withValues(alpha: 0.1)),
                              ),
                              
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text('Total', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text('\$${(cartProvider.totalPrice * 1.08).toStringAsFixed(2)}', style: const TextStyle(color: const Color(0xFFE60A15), fontSize: 24, fontWeight: FontWeight.bold)),
                                      Text('Including VAT', style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 10)),
                                    ],
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 32),
                              
                              Stack(
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
                                    onPressed: () => _checkout(context),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: const Color(0xFFE60A15),
                                      minimumSize: const Size(double.infinity, 56),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    ),
                                    child: const Text('CHECKOUT', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 48), // Bottom safe area
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  void _checkout(BuildContext context) {
    final cartProvider = context.read<CartProvider>();
    final orderProvider = context.read<OrderProvider>();
    final total = cartProvider.totalPrice * 1.08;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141414),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        title: const Text('Confirm Purchase', style: TextStyle(color: Colors.white)),
        content: Text(
          'Deduct \$${total.toStringAsFixed(2)} from your credits?',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('CANCEL', style: TextStyle(color: Colors.white70)),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await orderProvider.checkout(
                cartProvider.items,
                total,
              );
              cartProvider.clearCart();

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Transaction successful!'),
                    backgroundColor: Color(0xFFE60A15),
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFE60A15)),
            child: const Text('CONFIRM'),
          ),
        ],
      ),
    );
  }
}
