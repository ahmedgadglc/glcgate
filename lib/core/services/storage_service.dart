import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../features/products/data/models/product_item.dart';

class StorageService {
  static const String _itemMasterKey = 'item_master';
  static const String _dataVersionKey = 'data_version';
  static const String _cartListKey = 'cart_list';
  static const String _cartNoteKey = 'cart_note';
  static const String _shipToIDKey = 'ship_to_id';
  static const String _shipToNameKey = 'ship_to_name';

  // ========== Products Storage ==========

  static Future<void> saveProducts(List<Map<String, dynamic>> products) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_itemMasterKey, jsonEncode(products));
  }

  static Future<List<Map<String, dynamic>>?> getProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final productsJson = prefs.getString(_itemMasterKey);
    if (productsJson == null) return null;

    try {
      final List<dynamic> decoded = jsonDecode(productsJson);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      return null;
    }
  }

  static Future<void> clearProducts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_itemMasterKey);
  }

  // ========== Data Version Storage ==========

  static Future<void> saveDataVersion(String key, int version) async {
    final prefs = await SharedPreferences.getInstance();
    final versionsJson = prefs.getString(_dataVersionKey);
    Map<String, dynamic> versions = {};

    if (versionsJson != null) {
      try {
        versions = jsonDecode(versionsJson) as Map<String, dynamic>;
      } catch (e) {
        versions = {};
      }
    }

    versions[key] = version;
    await prefs.setString(_dataVersionKey, jsonEncode(versions));
  }

  static Future<int?> getDataVersion(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final versionsJson = prefs.getString(_dataVersionKey);
    if (versionsJson == null) return null;

    try {
      final Map<String, dynamic> versions =
          jsonDecode(versionsJson) as Map<String, dynamic>;
      return versions[key] as int?;
    } catch (e) {
      return null;
    }
  }

  // ========== Cart Storage ==========

  /// Save cart list to storage
  static Future<void> saveCartList(List<ProductItem> cartList) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = cartList.map((item) => item.toJson()).toList();
    await prefs.setString(_cartListKey, jsonEncode(jsonList));
  }

  /// Set cart list (alias for saveCartList)
  static Future<void> setCartList(List<ProductItem> cartList) async {
    await saveCartList(cartList);
  }

  /// Get cart list from storage
  static Future<List<ProductItem>> getCartList() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = prefs.getString(_cartListKey);
    if (cartJson == null) return [];

    try {
      final List<dynamic> decoded = jsonDecode(cartJson);
      return decoded
          .map((e) => ProductItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get cart item count
  static Future<int> getCartItemCount() async {
    final cartList = await getCartList();
    return cartList.length;
  }

  /// Clear cart
  static Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartListKey);
    await prefs.remove(_cartNoteKey);
  }

  // ========== Cart Note Storage ==========

  /// Set cart note
  static Future<void> setCartNote(String note) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cartNoteKey, note);
  }

  /// Get cart note
  static Future<String?> getCartNote() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_cartNoteKey);
  }

  // ========== Shipping Address Storage ==========

  /// Set ship to ID
  static Future<void> setShipToID(int shipToID) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_shipToIDKey, shipToID);
  }

  /// Get ship to ID
  static Future<int?> getShipToID() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_shipToIDKey);
  }

  /// Set ship to name
  static Future<void> setShipToName(String shipToName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_shipToNameKey, shipToName);
  }

  /// Get ship to name
  static Future<String?> getShipToName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_shipToNameKey);
  }

  /// Clear shipping address
  static Future<void> clearShippingAddress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_shipToIDKey);
    await prefs.remove(_shipToNameKey);
  }

  // ========== Clear All ==========

  /// Clear all stored data
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
