import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glcgate/core/services/fly_to_cart_service.dart';
import 'package:glcgate/core/theme/app_colors.dart';
import 'package:glcgate/features/products/presentation/cubit/products_cubit.dart';
import 'package:glcgate/features/products/presentation/widgets/packing_type_selector.dart';
import 'package:glcgate/features/products/presentation/widgets/product_image_card.dart';

class AddProductCardViewMobile extends StatefulWidget {
  const AddProductCardViewMobile({super.key});

  @override
  State<AddProductCardViewMobile> createState() =>
      _AddProductCardViewMobileState();
}

class _AddProductCardViewMobileState extends State<AddProductCardViewMobile>
    with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  late TextEditingController _controller;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // GlobalKey for product image to track position for fly-to-cart animation
  final GlobalKey _productImageKey = GlobalKey();
  bool _isKeyboardVisible = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _controller = TextEditingController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();

    _focusNode.addListener(() {
      setState(() {
        _isKeyboardVisible = _focusNode.hasFocus;
      });
      if (_isKeyboardVisible) {
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  String _formatNumber(double number) {
    if (number == number.toInt()) {
      return number.toInt().toString();
    }
    return number.toStringAsFixed(2);
  }

  /// Get unit text based on packing type and sellingUM
  String _getUnitText(ProductsState state) {
    final selectedProduct = context.read<ProductsCubit>().getSelectedProduct();

    // Check if packing type contains "بستلة"
    if (state.selectedPackType != null &&
        state.selectedPackType!.contains('بستلة')) {
      return 'بستلة';
    }

    // Check sellingUM
    if (selectedProduct?.sellingUM == "BX") {
      return 'كرتونة';
    }

    return 'عبوة';
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProductsCubit, ProductsState>(
      listener: (context, state) {
        if (state.selectedItemMainDes != null) {
          _controller.text = (state.selectedItemMainDes!.quantity ?? 0) > 0
              ? state.selectedItemMainDes!.quantity?.toInt().toString() ?? ''
              : '';
          if (_isKeyboardVisible) {
            Future.delayed(const Duration(milliseconds: 300), _scrollToBottom);
          }
        }
      },
      builder: (context, state) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: _buildProductCard(context, state),
        );
      },
    );
  }

  Widget _buildProductCard(BuildContext context, ProductsState state) {
    final labelStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
      color: AppColors.grey,
      fontWeight: FontWeight.normal,
    );
    final baseTypes = state.baseList;
    final colorTypes = state.colorList;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      width: double.infinity,
      color: AppColors.grey50,
      child: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        children: [
          _buildHeader(context, state, labelStyle),
          const SizedBox(height: 20),
          const PackingTypeSelector(),
          if (baseTypes.isNotEmpty) ...[
            const SizedBox(height: 16),
            const BaseTypeSelector(),
          ],
          if (colorTypes.isNotEmpty) ...[
            const SizedBox(height: 16),
            const ColorsTypeSelector(),
          ],
          const SizedBox(height: 24),
          if (state.selectedItemMainDes != null &&
              state.selectedPackType != null &&
              ((state.selectedBase != null && state.selectedBase!.isNotEmpty) ||
                  baseTypes.isEmpty) &&
              ((state.selectedColor != null &&
                      state.selectedColor!.isNotEmpty) ||
                  colorTypes.isEmpty)) ...[
            _buildQuantityInput(context, state),
            const SizedBox(height: 20),
            _buildAddButton(context, state),
          ],
        ],
      ),
    );
  }

  Widget _buildTotalsSection(
    BuildContext context,
    ProductsState state,
    int quantity, {
    required ValueKey<int> key,
  }) {
    final boxDecoration = BoxDecoration(
      color: AppColors.grey.withAlpha(13),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.grey.withAlpha(26), width: 1),
    );

    const labelStyle = TextStyle(
      color: AppColors.greyDark,
      height: 0.9,
      fontSize: 10,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: boxDecoration,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('الوزن', style: labelStyle),
                FittedBox(
                  child: Text(
                    _formatNumber(
                      (state.selectedItemMainDes?.grossWeight ?? 0) *
                          (state.selectedItemMainDes?.conversion ?? 1) *
                          quantity,
                    ),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.grey,
                      height: 1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Text("كيلو جرام", style: labelStyle),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: boxDecoration.copyWith(
              border: Border.all(color: AppColors.grey.withAlpha(51), width: 1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('إجمالي', style: labelStyle),
                FittedBox(
                  child: Text(
                    _formatNumber(
                      (state.selectedItemMainDes?.priceSellingUM ?? 0) *
                          quantity,
                    ),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.errorColor,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                  ),
                ),
                const Text('جنيه', style: labelStyle),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ProductsState state,
    TextStyle? labelStyle,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Hero(
            tag: 'product-${state.selectedItemMainDes?.itemCode ?? "image"}',
            child: ProductImageCard(
              key: _productImageKey,
              imageUrl: state.selectedItemMainDes?.uRL,
              itemMainDescription:
                  state.selectedItemMainDes?.itemMainDescription ?? '',
              width: 130,
              height: 130,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: _buildDetailsSection(context, state, labelStyle)),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(
    BuildContext context,
    ProductsState state,
    TextStyle? labelStyle,
  ) {
    bool showDetails = state.selectedPackType != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.infoColor.withAlpha(26),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            state.selectedItemMainDes?.itemCategory1Description ?? '',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.infoColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          state.selectedItemMainDes?.itemMainDescription ?? '',
          style: labelStyle?.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          state.selectedItemMainDes?.itemCode ?? '',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.grey,
            fontWeight: FontWeight.normal,
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: SizeTransition(
                sizeFactor: animation,
                axisAlignment: -1,
                child: child,
              ),
            );
          },
          child: showDetails
              ? Column(
                  key: const ValueKey('details'),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.attach_money_outlined,
                            color: AppColors.errorColor.withAlpha(204),
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatNumber(
                              state.selectedItemMainDes?.priceSellingUM ?? 0,
                            ),
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: AppColors.errorColor,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(width: 4),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 2.0),
                            child: Text(
                              'جنيه',
                              style: TextStyle(
                                color: AppColors.greyColor,
                                fontWeight: FontWeight.normal,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.grey.withAlpha(13),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Icon(
                            Icons.scale,
                            color: AppColors.grey.withAlpha(204),
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatNumber(
                              state.selectedItemMainDes?.grossWeight ?? 0,
                            ),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: AppColors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          const SizedBox(width: 4),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 2.0),
                            child: Text(
                              'كجم',
                              style: TextStyle(
                                color: AppColors.greyColor,
                                fontWeight: FontWeight.normal,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          if ((state.selectedItemMainDes?.conversion ?? 0) >
                              1) ...[
                            const SizedBox(width: 4),
                            Text(
                              "(${state.selectedItemMainDes?.conversion}x1)",
                              style: labelStyle?.copyWith(fontSize: 10),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                )
              : const SizedBox(key: ValueKey('empty')),
        ),
      ],
    );
  }

  Widget _buildQuantityInput(BuildContext context, ProductsState state) {
    final quantity = int.tryParse(_controller.text) ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: SizeTransition(
                  sizeFactor: animation,
                  axisAlignment: -1,
                  child: child,
                ),
              );
            },
            child: quantity == 0
                ? Container(
                    key: const ValueKey('empty'),
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.grey.withAlpha(13),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.grey.withAlpha(26),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'أدخل الكمية لعرض الإجمالي',
                        style: TextStyle(color: AppColors.grey.withAlpha(179)),
                      ),
                    ),
                  )
                : _buildTotalsSection(
                    context,
                    state,
                    quantity,
                    key: ValueKey(quantity),
                  ),
          ),
          const SizedBox(height: 16),
          Form(
            key: _formKey,
            child: TextFormField(
              focusNode: _focusNode,
              controller: _controller,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                fillColor: AppColors.white,
                filled: true,
                labelText: 'الكمية',
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                suffixIcon: Container(
                  width: 50,
                  height: 55,
                  alignment: Alignment.center,
                  child: Text(
                    _getUnitText(state),
                    style: const TextStyle(
                      color: AppColors.greyColor,
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                labelStyle: const TextStyle(color: AppColors.greyColor),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.grey.withAlpha(77)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: AppColors.greyColor,
                    width: 1.5,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.errorColor),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: AppColors.errorColor,
                    width: 1.5,
                  ),
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              autovalidateMode: AutovalidateMode.disabled,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء ادخال الكمية';
                }
                if (int.tryParse(value) != null && int.parse(value) > 10000) {
                  return 'الكمية لا يمكن ان تتجاوز 10,000';
                }
                return null;
              },
              onChanged: (value) {
                if (int.tryParse(value) != null && int.parse(value) > 10000) {
                  _controller.text = '10000';
                  _controller.selection = TextSelection.fromPosition(
                    TextPosition(offset: _controller.text.length),
                  );
                }
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }

  void _addItemToCart(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    final quantity = double.tryParse(_controller.text);
    if (quantity != null && quantity > 0) {
      final cubit = context.read<ProductsCubit>();
      final state = cubit.state;
      final imageUrl = state.selectedItemMainDes?.uRL;

      cubit.updateSelectedQuantity(quantity);
      cubit.addToCart(keepSelection: true);

      // Trigger fly-to-cart animation
      final cartIconKey = cubit.cartIconKey;
      if (cartIconKey != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          FlyToCartService.flyToCart(
            context: context,
            sourceKey: _productImageKey,
            targetKey: cartIconKey,
            imageUrl: imageUrl,
          );
        });
      }

      // Reset form to clear validation errors
      _formKey.currentState!.reset();

      // Show success snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تمت الإضافة للسلة'),
          backgroundColor: AppColors.successColor,
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height * 0.1,
            left: 16,
            right: 16,
          ),
        ),
      );

      // Don't close sheet - user may want to add same item with different specs
      // The listener will automatically clear the quantity field when selectedItemMainDes.quantity becomes 0
    }
  }

  Widget _buildAddButton(BuildContext context, ProductsState state) {
    final bool isEnabled =
        _controller.text.isNotEmpty &&
        int.tryParse(_controller.text) != null &&
        int.parse(_controller.text) > 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 56,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: AppColors.primaryColor.withAlpha(77),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: ElevatedButton.icon(
        onPressed: isEnabled ? () => _addItemToCart(context) : null,
        icon: Icon(
          Icons.add_shopping_cart,
          color: isEnabled ? Colors.white : AppColors.greyColor,
          size: 20,
        ),
        label: const Text(
          'اضافة للطلب',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled
              ? AppColors.primaryColor
              : AppColors.grey200,
          foregroundColor: isEnabled ? Colors.white : AppColors.greyColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}
