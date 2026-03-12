import 'brand.dart';

class Product {
  final int id;
  final int phoneModelId;
  final int conditionId;
  final double price;
  final double? originalPrice;
  final String sku;
  final int stock;
  final bool isFeatured;
  final String? description;
  final String? slug;
  final String? primaryImage;
  final String title;

  // Relationships
  final PhoneModel? phoneModel;
  final Condition? condition;
  final List<ProductImage> images;
  final List<Review> reviews;
  final int reviewsCount;

  Product({
    required this.id,
    required this.phoneModelId,
    required this.conditionId,
    required this.price,
    this.originalPrice,
    required this.sku,
    required this.stock,
    required this.isFeatured,
    this.description,
    this.slug,
    this.primaryImage,
    required this.title,
    this.phoneModel,
    this.condition,
    this.images = const [],
    this.reviews = const [],
    this.reviewsCount = 0,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      phoneModelId: json['phone_model_id'] ?? 0,
      conditionId: json['condition_id'] ?? 0,
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      originalPrice: json['original_price'] != null
          ? double.tryParse(json['original_price'].toString())
          : null,
      sku: json['sku'] ?? '',
      stock: json['stock'] ?? 0,
      isFeatured: json['is_featured'] == 1 || json['is_featured'] == true,
      description: json['description'],
      slug: json['slug'],
      primaryImage: json['primary_image'],
      title: json['title'] ?? json['phone_model']?['name'] ?? 'Unknown Product',
      phoneModel: json['phone_model'] != null
          ? PhoneModel.fromJson(json['phone_model'])
          : null,
      condition: json['condition'] != null
          ? Condition.fromJson(json['condition'])
          : null,
      images: (json['images'] as List? ?? [])
          .map((i) => ProductImage.fromJson(i))
          .toList(),
      reviews: (json['reviews'] as List? ?? [])
          .map((r) => Review.fromJson(r))
          .toList(),
      reviewsCount: json['reviews_count'] ?? 0,
    );
  }

  String get imageUrl {
    if (primaryImage != null && primaryImage!.startsWith('http')) {
      return primaryImage!;
    }
    return 'http://10.0.2.2:8000/storage/${primaryImage ?? ''}';
  }
}

class PhoneModel {
  final int id;
  final String name;
  final Brand? brand;
  final String? displaySize;
  final String? displayType;
  final String? processor;
  final String? ram;
  final String? camera;
  final String? battery;
  final String? os;

  PhoneModel({
    required this.id,
    required this.name,
    this.brand,
    this.displaySize,
    this.displayType,
    this.processor,
    this.ram,
    this.camera,
    this.battery,
    this.os,
  });

  factory PhoneModel.fromJson(Map<String, dynamic> json) {
    return PhoneModel(
      id: json['id'],
      name: json['name'],
      brand: json['brand'] != null ? Brand.fromJson(json['brand']) : null,
      displaySize: json['display_size']?.toString(),
      displayType: json['display_type']?.toString(),
      processor: json['processor']?.toString(),
      ram: json['ram']?.toString(),
      camera: json['camera']?.toString(),
      battery: json['battery']?.toString(),
      os: json['os']?.toString(),
    );
  }
}

class Condition {
  final int id;
  final String name;
  final String? description;

  Condition({required this.id, required this.name, this.description});

  factory Condition.fromJson(Map<String, dynamic> json) {
    return Condition(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }
}

// A simple class to represent the Home Screen API response
class HomeData {
  final List<Product> featuredProducts;
  final List<Brand> brands;

  HomeData({required this.featuredProducts, required this.brands});

  factory HomeData.fromJson(Map<String, dynamic> json) {
    var productsJson = json['featuredProducts'] as List? ?? [];
    var brandsJson = json['brands'] as List? ?? [];

    return HomeData(
      featuredProducts: productsJson.map((p) => Product.fromJson(p)).toList(),
      brands: brandsJson.map((b) => Brand.fromJson(b)).toList(),
    );
  }
}

class PaginatedProducts {
  final List<Product> data;
  final int currentPage;
  final int lastPage;
  final int total;
  final int perPage;

  PaginatedProducts({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.perPage,
  });

  factory PaginatedProducts.fromJson(Map<String, dynamic> json) {
    return PaginatedProducts(
      data: (json['data'] as List).map((i) => Product.fromJson(i)).toList(),
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      total: json['total'] ?? 0,
      perPage: json['per_page'] ?? 12,
    );
  }
}

class ProductsResponse {
  final PaginatedProducts products;
  final List<Brand> brands;
  final List<Condition> conditions;

  ProductsResponse({
    required this.products,
    required this.brands,
    required this.conditions,
  });

  factory ProductsResponse.fromJson(Map<String, dynamic> json) {
    return ProductsResponse(
      products: PaginatedProducts.fromJson(json['products']),
      brands: (json['brands'] as List).map((i) => Brand.fromJson(i)).toList(),
      conditions: (json['conditions'] as List)
          .map((i) => Condition.fromJson(i))
          .toList(),
    );
  }
}

class ProductImage {
  final int id;
  final String imagePath;

  ProductImage({required this.id, required this.imagePath});

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(id: json['id'], imagePath: json['image_path']);
  }

  String get fullUrl {
    if (imagePath.startsWith('http')) return imagePath;
    return 'http://10.0.2.2:8000/storage/$imagePath';
  }
}

class Review {
  final int id;
  final int rating;
  final String? comment;
  final String? userName;
  final DateTime? createdAt;

  Review({
    required this.id,
    required this.rating,
    this.comment,
    this.userName,
    this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      rating: json['rating'],
      comment: json['comment'],
      userName: json['user']?['name'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }
}

class ProductDetailResponse {
  final Product product;
  final List<Product> relatedProducts;
  final dynamic userReview; // Simplified for now

  ProductDetailResponse({
    required this.product,
    required this.relatedProducts,
    this.userReview,
  });

  factory ProductDetailResponse.fromJson(Map<String, dynamic> json) {
    return ProductDetailResponse(
      product: Product.fromJson(json['product']),
      relatedProducts: (json['relatedProducts'] as List? ?? [])
          .map((p) => Product.fromJson(p))
          .toList(),
      userReview: json['userReview'],
    );
  }
}

class CompareResponse {
  final List<Product> compareProducts;
  final List<Product> allProducts;
  final List<int> ids;

  CompareResponse({
    required this.compareProducts,
    required this.allProducts,
    required this.ids,
  });

  factory CompareResponse.fromJson(Map<String, dynamic> json) {
    return CompareResponse(
      compareProducts: (json['compareProducts'] as List? ?? [])
          .map((p) => Product.fromJson(p))
          .toList(),
      allProducts: (json['allProducts'] as List? ?? [])
          .map((p) => Product.fromJson(p))
          .toList(),
      ids: (json['ids'] as List? ?? [])
          .map((id) => int.parse(id.toString()))
          .toList(),
    );
  }
}
