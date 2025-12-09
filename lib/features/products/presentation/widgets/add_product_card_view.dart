import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glcgate/core/services/fly_to_cart_service.dart';
import 'package:glcgate/core/theme/app_colors.dart';
import 'package:glcgate/features/products/presentation/cubit/products_cubit.dart';
import 'package:glcgate/features/products/presentation/widgets/packing_type_selector.dart';
import 'package:glcgate/features/products/presentation/widgets/product_image_card.dart';

class AddProductCardView extends StatefulWidget {
  const AddProductCardView({super.key});

  @override
  State<AddProductCardView> createState() => _AddProductCardViewState();
}

class _AddProductCardViewState extends State<AddProductCardView> {
  late TextEditingController _controller;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // GlobalKey for product image to track position for fly-to-cart animation
  final GlobalKey _productImageKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatNumber(double number) {
    if (number == number.toInt()) {
      return number.toInt().toString();
    }
    return number.toStringAsFixed(2);
  }

  String _getUnitText(ProductsState state) {
    final selectedProduct = context.read<ProductsCubit>().getSelectedProduct();

    if (state.selectedPackType != null &&
        state.selectedPackType!.contains('بستلة')) {
      return 'بستلة';
    }

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
              ? state.selectedItemMainDes?.quantity?.toInt().toString() ?? ''
              : '';
        }
      },
      builder: (context, state) {
        final cardKey = state.selectedItemMainDes?.itemCode ?? 'empty';

        return AnimatedSize(
          duration: const Duration(milliseconds: 500),
          reverseDuration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          clipBehavior: Clip.none,
          child: state.selectedItemMainDes == null
              ? const SizedBox.shrink(key: ValueKey('empty'))
              : _buildProductCard(context, state, key: ValueKey(cardKey)),
        );
      },
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    ProductsState state, {
    Key? key,
  }) {
    final labelStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
      color: AppColors.grey,
      fontWeight: FontWeight.normal,
    );
    final baseTypes = state.baseList;
    final colorTypes = state.colorList;

    return Container(
      key: key,
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context, state, labelStyle),
          const PackingTypeSelector(),
          const SizedBox(height: 10),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(0, -0.3),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOut,
                          ),
                        ),
                    child: child,
                  ),
                );
              },
              child: baseTypes.isNotEmpty
                  ? const BaseTypeSelector(key: ValueKey('baseTypeSelector'))
                  : const SizedBox.shrink(key: ValueKey('empty')),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(0, -0.3),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOut,
                          ),
                        ),
                    child: child,
                  ),
                );
              },
              child: colorTypes.isNotEmpty
                  ? const ColorsTypeSelector(key: ValueKey('colorTypeSelector'))
                  : const SizedBox.shrink(key: ValueKey('empty')),
            ),
          ),
          const SizedBox(height: 20),
          if (state.selectedPackType != null &&
              (state.selectedBase != null ||
                  state.selectedBase == '' ||
                  baseTypes.isEmpty) &&
              (state.selectedColor != null ||
                  state.selectedColor == '' ||
                  colorTypes.isEmpty)) ...[
            _buildTotalDisplay(context, state),
            const SizedBox(height: 16),
            _buildAddButton(context, state),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ProductsState state,
    TextStyle? labelStyle,
  ) {
    return Stack(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Spacer(),
            ProductImageCard(
              key: _productImageKey,
              imageUrl: state.selectedItemMainDes?.itemURL,
              productDescription: state.selectedItemMainDes?.productDescription,
              width: 220,
              height: 220,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: _buildDetailsSection(context, state, labelStyle),
              ),
            ),
          ],
        ),

        Positioned(
          right: 0,
          top: 0,
          child: InkWell(
            onTap: () {
              context.read<ProductsCubit>().setSelectproductDescription(null);
            },
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.errorColor,
                borderRadius: BorderRadius.circular(50),
              ),
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(8.0),
              child: const Icon(Icons.clear, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsSection(
    BuildContext context,
    ProductsState state,
    TextStyle? labelStyle,
  ) {
    return SelectionArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            state.selectedItemMainDes?.itemCategoryDescription1 ?? '',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            state.selectedItemMainDes?.productDescription ?? '',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.grey,
              fontWeight: FontWeight.normal,
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
            child: state.selectedPackType != null
                ? Column(
                    key: ValueKey(state.selectedPackType),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            _formatNumber(
                              (state.selectedItemMainDes?.conversion ?? 0)
                                  .toDouble(),
                            ),
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: AppColors.errorColor,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(width: 5),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 2.0),
                            child: Text(
                              'جنيه',
                              style: TextStyle(
                                color: AppColors.greyColor,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.scale, color: AppColors.greyColor),
                          const SizedBox(width: 5),
                          Text(
                            _formatNumber(
                              state.selectedItemMainDes?.grossWeight ?? 0.0,
                            ),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: AppColors.grey,
                                  fontWeight: FontWeight.normal,
                                ),
                          ),
                          const SizedBox(width: 5),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 2.0),
                            child: Text(
                              'كجم',
                              style: TextStyle(
                                color: AppColors.greyColor,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            (state.selectedItemMainDes?.conversion ?? 0) > 1
                                ? "(${state.selectedItemMainDes?.conversion}x1)"
                                : "",
                            style: labelStyle,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                  )
                : const SizedBox(key: ValueKey('empty')),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityInput(BuildContext context, ProductsState state) {
    return SizedBox(
      width: 200,
      height: 65,
      child: Form(
        key: _formKey,
        child: TextFormField(
          autofocus: true,
          controller: _controller,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            fillColor: AppColors.white,
            filled: true,
            labelText: 'الكمية',
            suffixIcon: SizedBox(
              width: 50,
              height: 40,
              child: Center(
                child: Text(
                  _getUnitText(state),
                  style: const TextStyle(
                    color: AppColors.greyColor,
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
            labelStyle: const TextStyle(color: AppColors.greyColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.greyColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.greyColor),
            ),
          ),
          keyboardType: TextInputType.number,
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
          onFieldSubmitted: (value) {
            _addItemToCart(context);
          },
          onChanged: (value) {
            if (double.tryParse(value) != null && double.parse(value) > 10000) {
              _controller.text = '10000';
              _controller.selection = TextSelection.fromPosition(
                TextPosition(offset: _controller.text.length),
              );
            }
            setState(() {});
          },
        ),
      ),
    );
  }

  Widget _buildTotalDisplay(BuildContext context, ProductsState state) {
    final quantity = int.tryParse(_controller.text) ?? 0;

    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.centerLeft,
        children: [
          _buildQuantityInput(context, state),
          Positioned(
            right: 220,
            child: SizedBox(
              height: 80,
              child: AnimatedSwitcher(
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
                    ? const SizedBox(key: ValueKey('empty'))
                    : _buildTotalsSection(
                        context,
                        state,
                        quantity,
                        key: ValueKey(quantity),
                      ),
              ),
            ),
          ),
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
    return SizedBox(
      height: 80,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 60,
            width: 85,
            padding: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Text(
                  ' الوزن',
                  style: TextStyle(
                    height: .8,
                    color: AppColors.greyDark,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  _formatNumber(
                    (state.selectedItemMainDes?.grossWeight ?? 0.0) *
                        quantity *
                        (state.selectedItemMainDes?.conversion ?? 1).toDouble(),
                  ),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.grey,
                    height: 1,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  "كيلو جرام",
                  style: TextStyle(
                    color: AppColors.greyDark,
                    height: .8,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            height: 60,
            width: 85,
            padding: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Text(
                  'إجمالي ',
                  style: TextStyle(
                    color: AppColors.greyDark,
                    height: .8,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  _formatNumber(
                    (state.selectedItemMainDes?.conversion ?? 0).toDouble() *
                        quantity.toDouble(),
                  ),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.errorColor,
                    fontWeight: FontWeight.bold,
                    height: 1,
                  ),
                ),
                const Text(
                  'جنيه',
                  style: TextStyle(
                    color: AppColors.greyDark,
                    height: .8,
                    fontSize: 10,
                  ),
                ),
              ],
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
      final imageUrl = state.selectedItemMainDes?.itemURL;

      cubit.updateSelectedQuantity(quantity);
      cubit.addToCart();

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
      _controller.clear();
    }
  }

  Widget _buildAddButton(BuildContext context, ProductsState state) {
    return Center(
      child: SizedBox(
        width: 200,
        child: ElevatedButton(
          onPressed: () => _addItemToCart(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'اضافة للطلب',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
