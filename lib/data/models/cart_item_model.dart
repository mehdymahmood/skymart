import 'product_model.dart';

class CartItemModel {
  final String id;
  final ProductModel product;
  int quantity;
  final String? selectedSize;
  final String? selectedColor;

  CartItemModel({
    required this.id,
    required this.product,
    this.quantity = 1,
    this.selectedSize,
    this.selectedColor,
  });

  double get totalPrice => product.price * quantity;

  Map<String, dynamic> toJson() => {
        'id': id,
        'product': product.toJson(),
        'quantity': quantity,
        'selectedSize': selectedSize,
        'selectedColor': selectedColor,
      };

  factory CartItemModel.fromJson(Map<String, dynamic> json) => CartItemModel(
        id: json['id'] ?? '',
        product: ProductModel.fromJson(json['product'] ?? {}),
        quantity: json['quantity'] ?? 1,
        selectedSize: json['selectedSize'],
        selectedColor: json['selectedColor'],
      );

  CartItemModel copyWith({
    String? id,
    ProductModel? product,
    int? quantity,
    String? selectedSize,
    String? selectedColor,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      selectedSize: selectedSize ?? this.selectedSize,
      selectedColor: selectedColor ?? this.selectedColor,
    );
  }
}
