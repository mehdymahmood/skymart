import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_theme.dart';
import '../../../data/models/product_model.dart';
import '../../../data/providers/mock_data_provider.dart';
import '../../../presentation/controllers/sell_controller.dart';

class PostProductScreen extends StatefulWidget {
  const PostProductScreen({super.key});

  @override
  State<PostProductScreen> createState() => _PostProductScreenState();
}

class _PostProductScreenState extends State<PostProductScreen> {
  late SellController _sellController;
  final _formKey = GlobalKey<FormState>();

  ProductModel? _editProduct;

  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _originalPriceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController(text: '10');
  final _brandCtrl = TextEditingController();
  final _imageUrlCtrl = TextEditingController();
  final _sizesCtrl = TextEditingController();
  final _colorsCtrl = TextEditingController();

  String _categoryId = 'cat_electronics';
  String _categoryName = 'Electronics';
  final List<String> _images = [];

  final List<Map<String, String>> _categories = const [
    {'id': 'cat_electronics', 'name': 'Electronics'},
    {'id': 'cat_fashion', 'name': 'Fashion'},
    {'id': 'cat_home', 'name': 'Home & Living'},
    {'id': 'cat_beauty', 'name': 'Beauty'},
    {'id': 'cat_sports', 'name': 'Sports'},
    {'id': 'cat_books', 'name': 'Books'},
    {'id': 'cat_toys', 'name': 'Toys'},
    {'id': 'cat_automotive', 'name': 'Automotive'},
  ];

  @override
  void initState() {
    super.initState();
    _sellController = Get.isRegistered<SellController>()
        ? Get.find<SellController>()
        : Get.put(SellController());

    final arg = Get.arguments;
    if (arg is ProductModel) {
      _editProduct = arg;
      _nameCtrl.text = arg.name;
      _descCtrl.text = arg.description;
      _priceCtrl.text = arg.price.toStringAsFixed(0);
      _originalPriceCtrl.text = arg.originalPrice?.toStringAsFixed(0) ?? '';
      _stockCtrl.text = arg.stock.toString();
      _brandCtrl.text = arg.brand;
      _sizesCtrl.text = arg.sizes.join(', ');
      _colorsCtrl.text = arg.colors.join(', ');
      _categoryId = arg.categoryId;
      _categoryName = arg.categoryName;
      _images.addAll(arg.images);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _originalPriceCtrl.dispose();
    _stockCtrl.dispose();
    _brandCtrl.dispose();
    _imageUrlCtrl.dispose();
    _sizesCtrl.dispose();
    _colorsCtrl.dispose();
    super.dispose();
  }

  void _addImage() {
    final url = _imageUrlCtrl.text.trim();
    if (url.isEmpty) return;
    setState(() {
      _images.add(url);
      _imageUrlCtrl.clear();
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      Get.snackbar('Missing Fields', 'Please fill in all required fields',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return;
    }

    if (_editProduct != null) {
      _sellController.myProducts.removeWhere((p) => p.id == _editProduct!.id);
      MockDataProvider().removeUserProduct(_editProduct!.id);
    }

    final sizes = _sizesCtrl.text.trim().isEmpty
        ? <String>[]
        : _sizesCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    final colors = _colorsCtrl.text.trim().isEmpty
        ? <String>[]
        : _colorsCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    await _sellController.postProduct(
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      price: double.parse(_priceCtrl.text.trim()),
      originalPrice: _originalPriceCtrl.text.trim().isNotEmpty
          ? double.tryParse(_originalPriceCtrl.text.trim())
          : null,
      categoryId: _categoryId,
      categoryName: _categoryName,
      stock: int.tryParse(_stockCtrl.text.trim()) ?? 10,
      brand: _brandCtrl.text.trim(),
      images: List.from(_images),
      sizes: sizes,
      colors: colors,
    );

    Get.back();
    Get.snackbar(
      _editProduct != null ? 'Product Updated!' : 'Product Published!',
      _editProduct != null
          ? 'Your product has been updated.'
          : 'Your product is now live on SkyMart!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppTheme.successColor,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(_editProduct != null ? 'Edit Product' : 'Post a Product'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // ── Basic Info ──────────────────────────────────────
              _Card(
                title: '📦  Basic Information',
                children: [
                  _Field(
                    controller: _nameCtrl,
                    label: 'Product Name *',
                    hint: 'e.g. Samsung Galaxy S24',
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Product name is required' : null,
                  ),
                  _Field(
                    controller: _brandCtrl,
                    label: 'Brand',
                    hint: 'e.g. Samsung, Apple, Nike',
                  ),
                  _Field(
                    controller: _descCtrl,
                    label: 'Description *',
                    hint: 'Describe your product...',
                    maxLines: 4,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Description is required' : null,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ── Category ────────────────────────────────────────
              _Card(
                title: '🗂️  Category',
                children: [
                  DropdownButtonFormField<String>(
                    value: _categoryId,
                    decoration: _dec('Select Category *'),
                    items: _categories
                        .map((c) => DropdownMenuItem(
                              value: c['id'],
                              child: Text(c['name']!),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() {
                        _categoryId = v;
                        _categoryName =
                            _categories.firstWhere((c) => c['id'] == v)['name']!;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ── Price & Stock ───────────────────────────────────
              _Card(
                title: '💰  Price & Stock',
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _Field(
                          controller: _priceCtrl,
                          label: 'Sale Price (৳) *',
                          hint: '0',
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Required';
                            if (double.tryParse(v.trim()) == null) return 'Invalid';
                            if (double.parse(v.trim()) <= 0) return 'Must be > 0';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _Field(
                          controller: _originalPriceCtrl,
                          label: 'Original Price (৳)',
                          hint: 'Optional',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  _Field(
                    controller: _stockCtrl,
                    label: 'Stock Quantity *',
                    hint: 'e.g. 50',
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      if (int.tryParse(v.trim()) == null) return 'Invalid number';
                      return null;
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ── Images ──────────────────────────────────────────
              _Card(
                title: '🖼️  Product Images',
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _imageUrlCtrl,
                          decoration: _dec('Paste image URL').copyWith(
                            hintText: 'https://...',
                          ),
                          onFieldSubmitted: (_) => _addImage(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: ElevatedButton(
                          onPressed: _addImage,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Add'),
                        ),
                      ),
                    ],
                  ),
                  if (_images.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _images.asMap().entries.map((e) {
                        return Stack(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(7),
                                child: Image.network(
                                  e.value,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: Colors.grey.shade100,
                                    child: const Icon(Icons.broken_image,
                                        color: Colors.grey),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: -4,
                              right: -4,
                              child: GestureDetector(
                                onTap: () => setState(() => _images.removeAt(e.key)),
                                child: Container(
                                  width: 22,
                                  height: 22,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close,
                                      color: Colors.white, size: 13),
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ] else
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'No images added — a placeholder will be used automatically.',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // ── Variants ────────────────────────────────────────
              _Card(
                title: '🎨  Variants (optional)',
                children: [
                  _Field(
                    controller: _sizesCtrl,
                    label: 'Sizes',
                    hint: 'S, M, L, XL',
                  ),
                  _Field(
                    controller: _colorsCtrl,
                    label: 'Colors',
                    hint: 'Red, Blue, Black',
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Submit Button ───────────────────────────────────
              Obx(() => SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: _sellController.isSubmitting.value ? null : _submit,
                      icon: _sellController.isSubmitting.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : Icon(
                              _editProduct != null
                                  ? Icons.save_outlined
                                  : Icons.publish,
                              size: 22),
                      label: Text(
                        _sellController.isSubmitting.value
                            ? 'Publishing...'
                            : _editProduct != null
                                ? 'Update Product'
                                : 'Publish Product',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _editProduct != null
                            ? const Color(0xFF00897B)
                            : AppTheme.primaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  )),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _dec(String label) => InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      );
}

// ── Reusable form field ───────────────────────────────────────────────────────
class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final int maxLines;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.label,
    this.hint,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}

// ── Section card ─────────────────────────────────────────────────────────────
class _Card extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Card({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Color(0xFF1A237E))),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}
