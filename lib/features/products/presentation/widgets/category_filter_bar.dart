import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glcgate/core/theme/app_colors.dart';
import 'package:glcgate/features/products/presentation/cubit/products_cubit.dart';

class CategoryFilterBar extends StatefulWidget {
  const CategoryFilterBar({
    super.key,
    required this.tabList,
    this.filterType = CategoryFilterType.category1,
  });

  final List<String> tabList;
  final CategoryFilterType filterType;

  @override
  State<CategoryFilterBar> createState() => _CategoryFilterBarState();
}

class _CategoryFilterBarState extends State<CategoryFilterBar>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = _createTabController();
  }

  TabController _createTabController() {
    return TabController(
      length: widget.tabList.length,
      initialIndex: widget.tabList.indexWhere((element) => element == 'الكل'),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(CategoryFilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tabList.length != widget.tabList.length) {
      final newController = _createTabController();
      _tabController.dispose();
      _tabController = newController;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0, right: 0),
      child: TabBar(
        padding: const EdgeInsets.only(right: 10),
        tabAlignment: TabAlignment.start,
        controller: _tabController,
        isScrollable: true,
        labelColor: Theme.of(context).primaryColor,
        unselectedLabelColor: AppColors.greyColor,
        unselectedLabelStyle: Theme.of(context).textTheme.bodySmall,
        indicatorColor: Theme.of(context).primaryColor,
        dividerColor: Colors.transparent,
        tabs: widget.tabList
            .map((category) => Tab(text: category, height: 48))
            .toList(),
        onTap: (index) {
          context.read<ProductsCubit>().setSelectedFilter(
            widget.filterType,
            widget.tabList[index],
          );
        },
      ),
    );
  }
}
