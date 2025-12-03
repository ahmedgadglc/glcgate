import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glcgate/core/theme/app_colors.dart';
import 'package:glcgate/features/products/presentation/cubit/products_cubit.dart';
import 'package:glcgate/features/products/presentation/widgets/add_product_card_view_mobile.dart';

void showAddProductBottomSheet(BuildContext context1) {
  final ProductsCubit productsCubit = context1.read<ProductsCubit>();

  showModalBottomSheet(
    context: context1,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    transitionAnimationController: AnimationController(
      vsync: Navigator.of(context1),
      duration: const Duration(milliseconds: 400),
    ),
    builder: (BuildContext context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.95,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return BlocProvider.value(
            value: productsCubit,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.grey50,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(38),
                    blurRadius: 15,
                    spreadRadius: 0,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(top: 20),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.withAlpha(26),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: const AddProductCardViewMobile(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

