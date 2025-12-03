import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glcgate/core/helper/responsive.dart';
import 'package:glcgate/core/theme/app_colors.dart';
import 'package:glcgate/features/products/presentation/cubit/products_cubit.dart';

class ProductSearchBar extends StatefulWidget {
  const ProductSearchBar({super.key});

  @override
  State<ProductSearchBar> createState() => _ProductSearchBarState();
}

class _ProductSearchBarState extends State<ProductSearchBar> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);

    return BlocBuilder<ProductsCubit, ProductsState>(
      builder: (context, state) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 24 : 16,
            vertical: 8,
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: 'ابحث عن المنتج هنا...',
              suffixIcon: const Icon(Icons.search),
              prefixIcon: state.searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        context.read<ProductsCubit>().clearSearch();
                        _focusNode.unfocus();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.grey200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.grey200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 20 : 16,
                vertical: isDesktop ? 16 : 12,
              ),
            ),
            onChanged: (value) {
              context.read<ProductsCubit>().setSearchQuery(value);
            },
            textInputAction: TextInputAction.search,
            onSubmitted: (value) {
              _focusNode.unfocus();
            },
          ),
        );
      },
    );
  }
}

