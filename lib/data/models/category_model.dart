class CategoryModel {
  final String id;
  final String name;
  final String icon;
  final String image;
  final String? parentId;
  final List<CategoryModel> subcategories;
  final int productCount;
  final String color;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.image,
    this.parentId,
    this.subcategories = const [],
    this.productCount = 0,
    this.color = '#1A237E',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'icon': icon,
        'image': image,
        'parentId': parentId,
        'subcategories': subcategories.map((s) => s.toJson()).toList(),
        'productCount': productCount,
        'color': color,
      };

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        icon: json['icon'] ?? '',
        image: json['image'] ?? '',
        parentId: json['parentId'],
        subcategories: (json['subcategories'] as List? ?? [])
            .map((s) => CategoryModel.fromJson(s))
            .toList(),
        productCount: json['productCount'] ?? 0,
        color: json['color'] ?? '#1A237E',
      );
}
