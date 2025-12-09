import 'package:glcgate/core/network/api_service.dart';
import 'package:glcgate/features/products/data/models/product_item.dart';

class ProductsApiService extends ApiService {
  static const String operation = 'Get Item Master';

  ProductsApiService() {
    userMobileNo = 'mhd';
  }

  Future<List<ProductItem>> fetchProducts({int versionNo = 0}) async {
    final Map<String, dynamic> data = {'Operation': operation};

    final response = await request(data);

    if (response == null || response.hasError) {
      throw ApiException(response?.errorMessage ?? 'فشل في جلب المنتجات');
    }
    final List<dynamic>? itemsList = response.data['List0'];

    if (itemsList == null) {
      return [];
    }

    return itemsList.map<ProductItem>((e) => ProductItem.fromJson(e)).toList();
  }
}
