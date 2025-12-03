import 'dart:developer';

import 'package:glcgate/core/services/storage_service.dart';
import 'package:glcgate/features/products/data/models/product_item.dart';
import 'package:glcgate/features/products/data/service/products_api_service.dart';

class ProductsRepository {
  final ProductsApiService _apiService = ProductsApiService();
  static const String _itemMasterKey = 'ItemMaster';

  Future<List<ProductItem>> fetchProducts([int versionNo = 0]) async {
    // Try to get cached data
    final cachedData = await StorageService.getProducts();
    final cachedVersion =
        await StorageService.getDataVersion(_itemMasterKey) ?? 0;

    log('Cache version: $cachedVersion, Requested version: $versionNo');

    // If cache is valid, return cached data
    if (cachedData != null && cachedVersion == versionNo && versionNo > 0) {
      log('Returning cached products');
      return cachedData
          .map<ProductItem>((e) => ProductItem.fromJson(e))
          .toList();
    }

    // Fetch from API
    log('Fetching products from API');
    final items = await _apiService.fetchProducts(versionNo: versionNo);

    // Cache the products
    if (items.isNotEmpty) {
      final productsJson = items.map((e) => e.toJson()).toList();
      await StorageService.saveProducts(productsJson);
    }

    return items;
  }
}
