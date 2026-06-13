import 'dart:async';

import 'package:fitnessapp/data/models/meal_models.dart';
import 'package:fitnessapp/l10n/app_localizations.dart';
import 'package:fitnessapp/providers/meal_provider.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FoodLibraryScreen extends StatefulWidget {
  final bool selectionMode;

  const FoodLibraryScreen({Key? key, this.selectionMode = false})
      : super(key: key);

  @override
  State<FoodLibraryScreen> createState() => _FoodLibraryScreenState();
}

class _FoodLibraryScreenState extends State<FoodLibraryScreen> {
  final _searchCtrl = TextEditingController();
  String _selectedCategory = 'All';
  Timer? _debounce;

  static const _categories = [
    'All',
    'Protein',
    'Carbs',
    'Fat',
    'Vegetable',
    'Fruit',
    'Dairy',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<MealProvider>().loadFoods());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearch(String val) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      context.read<MealProvider>().loadFoods(
            search: val.isEmpty ? null : val,
            category: _selectedCategory == 'All' ? null : _selectedCategory,
          );
    });
  }

  void _onCategoryFilter(String cat) {
    setState(() => _selectedCategory = cat);
    context.read<MealProvider>().loadFoods(
          search: _searchCtrl.text.isEmpty ? null : _searchCtrl.text,
          category: cat == 'All' ? null : cat,
        );
  }

  Future<void> _handleFoodTap(Food food) async {
    if (!widget.selectionMode) return;

    final l10n = AppLocalizations.of(context);
    final gramsCtrl = TextEditingController(text: '100');
    final draft = await showDialog<FoodItemDraft>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          l10n.howManyGrams,
          style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: context.colors.fg),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              food.nameEn,
              style: TextStyle(
                  fontSize: 14,
                  color: context.colors.subFg,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: gramsCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              decoration: InputDecoration(
                hintText: l10n.grams,
                suffixText: 'g',
                filled: true,
                fillColor: context.colors.listTile,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel,
                style: TextStyle(color: context.colors.subFg)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor1,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              final grams = double.tryParse(gramsCtrl.text) ?? 100.0;
              Navigator.pop(
                  ctx, FoodItemDraft(food: food, grams: grams));
            },
            child: Text(l10n.ok),
          ),
        ],
      ),
    );

    if (draft != null && mounted) {
      Navigator.pop(context, draft);
    }
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
          widget.selectionMode ? l10n.selectFood : l10n.foodLibrary,
          style: TextStyle(
              fontWeight: FontWeight.w700,
              color: colors.fg,
              fontSize: 17),
        ),
        backgroundColor: colors.bg,
        elevation: 0,
        foregroundColor: colors.fg,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _searchCtrl,
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: l10n.searchFoods,
                prefixIcon: Icon(Icons.search, color: colors.subFg),
                filled: true,
                fillColor: colors.listTile,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          // Category filter chips
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final cat = _categories[i];
                final selected = _selectedCategory == cat;
                return FilterChip(
                  label: Text(
                    cat,
                    style: TextStyle(
                      fontSize: 12,
                      color: selected
                          ? AppColors.primaryColor1
                          : colors.subFg,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                  selected: selected,
                  onSelected: (_) => _onCategoryFilter(cat),
                  selectedColor: AppColors.primaryColor1.withValues(alpha: 0.15),
                  checkmarkColor: AppColors.primaryColor1,
                  backgroundColor: colors.listTile,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  side: BorderSide.none,
                );
              },
            ),
          ),
          const SizedBox(height: 4),
          // Food list
          Expanded(
            child: provider.loading
                ? const Center(child: CircularProgressIndicator())
                : provider.foods.isEmpty
                    ? Center(
                        child: Text(
                          l10n.noFoodsFound,
                          style: TextStyle(color: colors.subFg),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        itemCount: provider.foods.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) => _FoodTile(
                          food: provider.foods[i],
                          selectionMode: widget.selectionMode,
                          onTap: () => _handleFoodTap(provider.foods[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

// ── Food tile ──────────────────────────────────────────────────────────────────

class _FoodTile extends StatelessWidget {
  final Food food;
  final bool selectionMode;
  final VoidCallback onTap;

  const _FoodTile({
    required this.food,
    required this.selectionMode,
    required this.onTap,
  });

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

  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'protein':
        return Icons.set_meal;
      case 'carbs':
        return Icons.breakfast_dining;
      case 'fat':
        return Icons.water_drop;
      case 'vegetable':
        return Icons.eco;
      case 'fruit':
        return Icons.apple;
      case 'dairy':
        return Icons.local_drink;
      default:
        return Icons.restaurant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final catColor = _categoryColor(food.category);
    final cal = food.caloriesPer100g.toStringAsFixed(0);
    final p = food.proteinPer100g.toStringAsFixed(1);
    final c = food.carbsPer100g.toStringAsFixed(1);
    final f = food.fatPer100g.toStringAsFixed(1);

    return InkWell(
      onTap: selectionMode ? onTap : null,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.listTile,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Category icon container
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: catColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_categoryIcon(food.category),
                  color: catColor, size: 24),
            ),
            const SizedBox(width: 12),
            // Name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.nameEn,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: colors.fg),
                  ),
                  if (food.nameAr.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      food.nameAr,
                      style: TextStyle(
                          fontSize: 11, color: colors.subFg),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Macro chips column
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                _MacroChip(
                    label: '$cal kcal',
                    color: AppColors.primaryColor1),
                const SizedBox(height: 3),
                _MacroChip(label: 'P ${p}g', color: const Color(0xFFE53935)),
                const SizedBox(height: 3),
                _MacroChip(label: 'C ${c}g', color: const Color(0xFF2196F3)),
                const SizedBox(height: 3),
                _MacroChip(label: 'F ${f}g', color: const Color(0xFFFFC107)),
              ],
            ),
            if (selectionMode) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor1,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 16),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  final String label;
  final Color color;
  const _MacroChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 10, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
