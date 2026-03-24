class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? originalPrice;
  final String categoryId;
  final String categoryName;
  final List<String> images;
  final double rating;
  final int reviewCount;
  final int stock;
  final bool isFeatured;
  final bool isFlashSale;
  final bool isPopular;
  final List<String> sizes;
  final List<String> colors;
  final List<String> tags;
  final String brand;
  final int soldCount;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.categoryId,
    required this.categoryName,
    required this.images,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.stock = 0,
    this.isFeatured = false,
    this.isFlashSale = false,
    this.isPopular = false,
    this.sizes = const [],
    this.colors = const [],
    this.tags = const [],
    this.brand = '',
    this.soldCount = 0,
  });

  double get discountPercent {
    if (originalPrice == null || originalPrice! <= price) return 0;
    return ((originalPrice! - price) / originalPrice!) * 100;
  }

  bool get hasDiscount => originalPrice != null && originalPrice! > price;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'originalPrice': originalPrice,
        'categoryId': categoryId,
        'categoryName': categoryName,
        'images': images,
        'rating': rating,
        'reviewCount': reviewCount,
        'stock': stock,
        'isFeatured': isFeatured,
        'isFlashSale': isFlashSale,
        'isPopular': isPopular,
        'sizes': sizes,
        'colors': colors,
        'tags': tags,
        'brand': brand,
        'soldCount': soldCount,
      };

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        description: json['description'] ?? '',
        price: (json['price'] ?? 0).toDouble(),
        originalPrice: json['originalPrice'] != null ? (json['originalPrice']).toDouble() : null,
        categoryId: json['categoryId'] ?? '',
        categoryName: json['categoryName'] ?? '',
        images: List<String>.from(json['images'] ?? []),
        rating: (json['rating'] ?? 0).toDouble(),
        reviewCount: json['reviewCount'] ?? 0,
        stock: json['stock'] ?? 0,
        isFeatured: json['isFeatured'] ?? false,
        isFlashSale: json['isFlashSale'] ?? false,
        isPopular: json['isPopular'] ?? false,
        sizes: List<String>.from(json['sizes'] ?? []),
        colors: List<String>.from(json['colors'] ?? []),
        tags: List<String>.from(json['tags'] ?? []),
        brand: json['brand'] ?? '',
        soldCount: json['soldCount'] ?? 0,
      );

  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? originalPrice,
    String? categoryId,
    String? categoryName,
    List<String>? images,
    double? rating,
    int? reviewCount,
    int? stock,
    bool? isFeatured,
    bool? isFlashSale,
    bool? isPopular,
    List<String>? sizes,
    List<String>? colors,
    List<String>? tags,
    String? brand,
    int? soldCount,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      images: images ?? this.images,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      stock: stock ?? this.stock,
      isFeatured: isFeatured ?? this.isFeatured,
      isFlashSale: isFlashSale ?? this.isFlashSale,
      isPopular: isPopular ?? this.isPopular,
      sizes: sizes ?? this.sizes,
      colors: colors ?? this.colors,
      tags: tags ?? this.tags,
      brand: brand ?? this.brand,
      soldCount: soldCount ?? this.soldCount,
    );
  }
}
