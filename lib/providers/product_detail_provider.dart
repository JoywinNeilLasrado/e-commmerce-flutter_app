import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../services/api_service.dart';

final productDetailProvider =
    FutureProvider.family<ProductDetailResponse, String>((ref, slug) async {
      final apiService = ref.watch(apiServiceProvider);
      return apiService.getProductDetail(slug);
    });
