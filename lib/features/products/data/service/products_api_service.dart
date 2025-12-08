import 'package:glcgate/core/network/api_service.dart';
import 'package:glcgate/features/products/data/models/product_item.dart';

class ProductsApiService extends ApiService {
  static const String operation = 'Get Item Master';

  // Set user mobile number for authentication
  // This should be set after login or from stored credentials
  // For testing, you can set a valid mobile number here
  void setUserMobileNo(String? mobileNo) {
    userMobileNo = mobileNo;
  }

  // Initialize with a test user (for development only)
  // TODO: Remove this when login system is implemented
  ProductsApiService() {
    // Test mobile number - remove spaces
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

  int? getVersionNumber(ApiResponse response) {
    try {
      final itemMasterVersion = response.versions.firstWhere(
        (v) => v.tableDescription == 'ItemMaster',
        orElse: () => Version(
          id: 0,
          tableId: 0,
          tableDescription: 'ItemMaster',
          versionNo: 0,
        ),
      );
      return itemMasterVersion.versionNo;
    } catch (e) {
      return null;
    }
  }
}
