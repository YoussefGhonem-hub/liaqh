import 'package:fitnessapp/data/models/meal_models.dart';
import 'package:fitnessapp/common_widgets/liaqh_loaders.dart';
import 'package:fitnessapp/l10n/app_localizations.dart';
import 'package:fitnessapp/providers/meal_provider.dart';
import 'package:fitnessapp/utils/nutrition_l10n.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ShoppingListScreen extends StatefulWidget {
  final String planId;

  const ShoppingListScreen({Key? key, required this.planId}) : super(key: key);

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<MealProvider>().loadShoppingList(widget.planId));
  }

  Color _categoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'protein':
        return AppColors.primaryColor1;
      case 'carbs':
        return const Color(0xFF2196F3);
      case 'fat':
        return const Color(0xFFFFC107);
      case 'vegetable':
        return const Color(0xFF4CAF50);
      case 'fruit':
        return const Color(0xFFE91E63);
      case 'dairy':
        return const Color(0xFF009688);
      default:
        return AppColors.grayColor;
    }
  }

  Map<String, List<ShoppingItem>> _groupByCategory(List<ShoppingItem> items) {
    final map = <String, List<ShoppingItem>>{};
    for (final item in items) {
      map.putIfAbsent(item.category, () => []).add(item);
    }
    return map;
  }

  double _totalPrice(List<ShoppingItem> items) {
    return items.fold(0.0, (s, i) => s + (i.estimatedPrice ?? 0.0));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final provider = context.watch<MealProvider>();
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: Text(
          l10n.shoppingList,
          style: TextStyle(
              fontWeight: FontWeight.w700,
              color: colors.fg,
              fontSize: 17),
        ),
        backgroundColor: colors.bg,
        elevation: 0,
        foregroundColor: colors.fg,
        actions: [
          IconButton(
            icon: Icon(Icons.share_outlined, color: colors.fg),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(l10n.shareComingSoon),
                    duration: const Duration(seconds: 1)),
              );
            },
          ),
        ],
      ),
      body: provider.loading
          ? const LiaqhPageLoader()
          : provider.shoppingList == null ||
                  provider.shoppingList!.items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shopping_cart_outlined,
                          size: 56, color: colors.subFg),
                      const SizedBox(height: 12),
                      Text(
                        l10n.noShoppingItems,
                        style: TextStyle(
                            color: colors.subFg,
                            fontSize: 16,
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.shoppingListHint,
                        style: TextStyle(
                            color: colors.subFg, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : _ShoppingListBody(
                  shoppingList: provider.shoppingList!,
                  onToggle: (item) => setState(() => item.checked = !item.checked),
                  categoryColor: _categoryColor,
                  groupByCategory: _groupByCategory,
                  totalPrice: _totalPrice,
                ),
    );
  }
}

// ── Body ────────────────────────────────────────────────────────────────────────

class _ShoppingListBody extends StatelessWidget {
  final ShoppingList shoppingList;
  final ValueChanged<ShoppingItem> onToggle;
  final Color Function(String) categoryColor;
  final Map<String, List<ShoppingItem>> Function(List<ShoppingItem>)
      groupByCategory;
  final double Function(List<ShoppingItem>) totalPrice;

  const _ShoppingListBody({
    required this.shoppingList,
    required this.onToggle,
    required this.categoryColor,
    required this.groupByCategory,
    required this.totalPrice,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    final grouped = groupByCategory(shoppingList.items);
    final categories = grouped.keys.toList()..sort();
    final total = totalPrice(shoppingList.items);
    final hasPrice = shoppingList.items.any((i) => i.estimatedPrice != null);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        ...categories.map((cat) {
          final items = grouped[cat]!;
          final color = categoryColor(cat);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category header chip
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    foodCategoryLabel(l10n, cat),
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: color),
                  ),
                ),
              ),
              // Items
              ...items.map((item) => _ShoppingItemTile(
                    item: item,
                    categoryColor: color,
                    onToggle: () => onToggle(item),
                  )),
            ],
          );
        }),
        // Total estimated price
        if (hasPrice && total > 0) ...[
          const SizedBox(height: 20),
          Divider(color: colors.divider),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.totalEstimatedPrice,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: colors.fg),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor1.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  total.toStringAsFixed(2),
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryColor1),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// ── Shopping item tile ─────────────────────────────────────────────────────────

class _ShoppingItemTile extends StatelessWidget {
  final ShoppingItem item;
  final Color categoryColor;
  final VoidCallback onToggle;

  const _ShoppingItemTile({
    required this.item,
    required this.categoryColor,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: item.checked
            ? colors.listTile.withValues(alpha: 0.5)
            : colors.listTile,
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            children: [
              Checkbox(
                value: item.checked,
                onChanged: (_) => onToggle(),
                activeColor: categoryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
                side: BorderSide(color: categoryColor.withValues(alpha: 0.5)),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.foodNameEn,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: item.checked
                              ? colors.subFg
                              : colors.fg,
                          decoration: item.checked
                              ? TextDecoration.lineThrough
                              : null),
                    ),
                    if (item.foodNameAr.isNotEmpty)
                      Text(
                        item.foodNameAr,
                        style: TextStyle(
                            fontSize: 11,
                            color: colors.subFg.withValues(alpha: 0.8),
                            decoration: item.checked
                                ? TextDecoration.lineThrough
                                : null),
                      ),
                  ],
                ),
              ),
              Text(
                '${item.totalGrams.toStringAsFixed(0)}g',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: item.checked
                        ? colors.subFg
                        : categoryColor),
              ),
              if (item.estimatedPrice != null) ...[
                const SizedBox(width: 8),
                Text(
                  item.estimatedPrice!.toStringAsFixed(2),
                  style: TextStyle(
                      fontSize: 11,
                      color: colors.subFg.withValues(alpha: 0.7)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
