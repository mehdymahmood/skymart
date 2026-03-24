class BannerModel {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String? actionRoute;
  final String? actionParam;
  final String buttonText;

  BannerModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.actionRoute,
    this.actionParam,
    this.buttonText = 'Shop Now',
  });
}
