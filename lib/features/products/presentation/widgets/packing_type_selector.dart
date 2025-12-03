import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glcgate/core/theme/app_colors.dart';
import 'package:glcgate/features/products/presentation/cubit/products_cubit.dart';

Widget _divider() {
  return Divider(
    color: AppColors.grey,
    thickness: .2,
  );
}

Widget _title(String title, BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8.0),
    child: Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.grey,
          ),
    ),
  );
}

class PackingTypeSelector extends StatelessWidget {
  const PackingTypeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductsCubit, ProductsState>(
      builder: (context, state) {
        final packingTypes = state.packTypeList;

        if (packingTypes.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Expanded(child: _divider()),
                _title('نوع العبوة', context),
                Expanded(child: _divider()),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.center,
                runAlignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: packingTypes.map((type) {
                  final isSelected = state.selectedPackType == type;
                  return InkWell(
                    onTap: () {
                      context
                          .read<ProductsCubit>()
                          .setProductFilter(ProductFilterType.packType, type);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        type,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                          color: isSelected ? Colors.white : Colors.black87,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}

class BaseTypeSelector extends StatelessWidget {
  const BaseTypeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductsCubit, ProductsState>(
      builder: (context, state) {
        final baseTypes = state.baseList;

        if (baseTypes.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: _divider()),
                _title('الفئة', context),
                Expanded(child: _divider()),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.center,
                runAlignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: baseTypes.map((type) {
                  final isSelected = state.selectedBase == type;
                  return InkWell(
                    onTap: () {
                      context
                          .read<ProductsCubit>()
                          .setProductFilter(ProductFilterType.base, type);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        type,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.white : Colors.black87,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}

class ColorsTypeSelector extends StatelessWidget {
  const ColorsTypeSelector({super.key});

  Color _parseRgbColor(String rgb) {
    try {
      final parts = rgb.split(',');
      if (parts.length >= 3) {
        return Color.fromRGBO(
          int.parse(parts[0].trim()),
          int.parse(parts[1].trim()),
          int.parse(parts[2].trim()),
          1,
        );
      }
    } catch (e) {
      // Return default color if parsing fails
    }
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductsCubit, ProductsState>(
      builder: (context, state) {
        final colorTypes = state.colorList;

        if (colorTypes.isEmpty) {
          return const SizedBox.shrink();
        }

        // Get RGB values for colors from the items
        final cubit = context.read<ProductsCubit>();
        final selectedItem = state.selectedItemMainDes;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: _divider()),
                _title('اللون', context),
                Expanded(child: _divider()),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.center,
                runAlignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: colorTypes.map((color) {
                  final isSelected = state.selectedColor == color;

                  // Find the RGB value for this color
                  Color codeColor = Colors.grey[300]!;
                  if (selectedItem != null) {
                    final matchingItem = state.items.firstWhere(
                      (item) =>
                          item.itemMainDescription ==
                              selectedItem.itemMainDescription &&
                          item.color == color &&
                          item.rGB != null,
                      orElse: () => selectedItem,
                    );
                    if (matchingItem.rGB != null &&
                        matchingItem.rGB!.isNotEmpty) {
                      codeColor = _parseRgbColor(matchingItem.rGB!);
                    }
                  }

                  // Calculate text color based on background luminance
                  final textColor = codeColor.computeLuminance() > 0.5
                      ? Colors.black87
                      : Colors.white;

                  return InkWell(
                    onTap: () {
                      cubit.setProductFilter(ProductFilterType.color, color);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: codeColor,
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.transparent,
                          width: 2,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: codeColor.withAlpha(128),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            color,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: textColor,
                              fontFamily: 'Cairo',
                            ),
                          ),
                          if (isSelected) const SizedBox(width: 4),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            child: !isSelected
                                ? const SizedBox.shrink()
                                : Icon(
                                    Icons.check_circle,
                                    color: textColor,
                                    size: 16,
                                  ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}

