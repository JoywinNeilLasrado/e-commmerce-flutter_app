import 'package:flutter/foundation.dart';

class ShopParams {
  final String? brand;
  final List<int>? conditions;
  final double? minPrice;
  final double? maxPrice;
  final String? sort;
  final String? search;
  final int page;

  ShopParams({
    this.brand,
    this.conditions,
    this.minPrice,
    this.maxPrice,
    this.sort,
    this.search,
    this.page = 1,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ShopParams &&
        other.brand == brand &&
        listEquals(other.conditions, conditions) &&
        other.minPrice == minPrice &&
        other.maxPrice == maxPrice &&
        other.sort == sort &&
        other.search == search &&
        other.page == page;
  }

  @override
  int get hashCode {
    return brand.hashCode ^
        conditions.hashCode ^
        minPrice.hashCode ^
        maxPrice.hashCode ^
        sort.hashCode ^
        search.hashCode ^
        page.hashCode;
  }
}
