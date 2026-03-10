import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

import '../models/product.dart';
import '../providers/product_provider.dart';
import '../widgets/custom_image.dart';

class AddEditProductScreen extends StatefulWidget {
  final String? productId;

  const AddEditProductScreen({super.key, this.productId});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();

  bool get isEditing => widget.productId != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      Future.microtask(() {
        if (!mounted) return;
        final product =
            context.read<ProductProvider>().findById(widget.productId!);
        if (product != null) {
          _nameController.text = product.name;
          _descriptionController.text = product.description;
          _priceController.text = product.price.toString();
          _imageUrlController.text = product.imageUrl;
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ProductProvider>();

    if (isEditing) {
      final updatedProduct = Product(
        id: widget.productId!,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        imageUrl: _imageUrlController.text.trim(),
      );
      await provider.updateProduct(updatedProduct);
    } else {
      await provider.addProduct(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        imageUrl: _imageUrlController.text.trim(),
      );
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isEditing ? 'Item successfully updated.' : 'Item successfully deployed.'),
        backgroundColor: const Color(0xFFE50914),
      ),
    );
    context.go('/products');
  }

  @override
  Widget build(BuildContext context) {
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
      body: Stack(
        children: [
          // Background Glow
          Positioned(
            top: -150, right: -150,
            child: Container(
              width: 400, height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: const Color(0xFFE60A15).withValues(alpha: 0.15), blurRadius: 150, spreadRadius: 50),
                ],
              ),
            ),
          ),
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 500),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: const Color(0xFF181111).withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 20, offset: const Offset(0, 10)),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isEditing ? 'EDIT PRODUCT DETAILS' : 'ADD NEW PRODUCT',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withValues(alpha: 0.6),
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Name
                        _buildInputField(
                          controller: _nameController,
                          label: 'Product Name',
                          icon: Icons.inventory_2_outlined,
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Product Name is required' : null,
                        ),
                        const SizedBox(height: 20),

                        // Description
                        _buildInputField(
                          controller: _descriptionController,
                          label: 'Description',
                          icon: Icons.description_outlined,
                          maxLines: 4,
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Description is required' : null,
                        ),
                        const SizedBox(height: 20),

                        // Price
                        _buildInputField(
                          controller: _priceController,
                          label: 'Price',
                          icon: Icons.attach_money,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Price is required';
                            final price = double.tryParse(v.trim());
                            if (price == null || price <= 0) return 'Enter a valid price';
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Image URL
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildInputField(
                                controller: _imageUrlController,
                                label: 'Image URL or Pick Image',
                                icon: Icons.image_outlined,
                                keyboardType: TextInputType.url,
                                textInputAction: TextInputAction.done,
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () async {
                                final result = await FilePicker.platform.pickFiles(
                                  type: FileType.any, // Use Any to ensure Drive/Local providers show up
                                  withData: true, 
                                );
                                
                                if (result != null && result.files.isNotEmpty) {
                                  final file = result.files.first;
                                  final bytes = file.bytes;
                                  
                                  if (bytes != null) {
                                    final extension = file.extension?.toLowerCase() ?? 'jpg';
                                    final mimeType = (extension == 'png') ? 'image/png' : 'image/jpeg';
                                    final base64Image = 'data:$mimeType;base64,${base64Encode(bytes)}';
                                    
                                    setState(() {
                                      _imageUrlController.text = base64Image;
                                    });
                                  }
                                }
                              },
                              child: Container(
                                width: 56, height: 56,
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                                ),
                                child: const Icon(Icons.photo_library, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (_imageUrlController.text.isNotEmpty)
                          Container(
                            height: 150,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: CustomImage(
                              imageUrl: _imageUrlController.text,
                              fit: BoxFit.cover,
                            ),
                          ),
                        const SizedBox(height: 40),

                        // Submit Button
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
                            FilledButton.icon(
                              onPressed: _submit,
                              icon: Icon(isEditing ? Icons.save : Icons.add_to_photos, color: Colors.white),
                              label: Text(
                                isEditing ? 'UPDATE PRODUCT' : 'ADD PRODUCT',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.white),
                              ),
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFFE60A15),
                                minimumSize: const Size(double.infinity, 56),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    TextInputAction textInputAction = TextInputAction.next,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      maxLines: maxLines,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
        prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: 0.4)),
        alignLabelWithHint: maxLines > 1,
        filled: true,
        fillColor: Colors.black.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE60A15)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }
}
