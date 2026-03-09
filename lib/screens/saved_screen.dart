import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/product_provider.dart';
import '../widgets/product_card.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final savedProducts = productProvider.savedProducts;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181111).withValues(alpha: 0.8),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
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
        title: const Text(
          'Saved Items',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: savedProducts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: Colors.white.withValues(alpha: 0.2)),
                  const SizedBox(height: 16),
                  Text('No saved items yet', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 16)),
                  const SizedBox(height: 24),
                  OutlinedButton(
                    onPressed: () => context.push('/discover'),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: const Color(0xFFE60A15).withValues(alpha: 0.5)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Explore Products', style: TextStyle(color: Color(0xFFE60A15))),
                  )
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: savedProducts.length,
              itemBuilder: (context, index) {
                return ProductCard(product: savedProducts[index]);
              },
            ),
    );
  }
}
