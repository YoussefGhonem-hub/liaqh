import 'dart:async';
import 'package:fitnessapp/common_widgets/liaqh_loaders.dart';

import 'package:fitnessapp/data/models/meal_models.dart';
import 'package:fitnessapp/l10n/app_localizations.dart';
import 'package:fitnessapp/providers/meal_provider.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:fitnessapp/utils/nutrition_l10n.dart';
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
    final colors = context.colors;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final countBased = food.isCountBased;
    final unitLabel = countBased
        ? (isAr
                ? (food.unitNameAr ?? food.unitNameEn)
                : (food.unitNameEn ?? food.unitNameAr)) ??
            l10n.pieceUnit
        : '';

    // Default: 1 unit for count foods, 100 g otherwise.
    final ctrl = TextEditingController(text: countBased ? '1' : '100');

    double gramsFromInput() {
      final v = double.tryParse(ctrl.text) ?? 0;
      return countBased ? v * (food.gramsPerUnit ?? 0) : v;
    }

    final draft = await showDialog<FoodItemDraft>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) {
          final grams = gramsFromInput();
          return AlertDialog(
            backgroundColor: colors.bg,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            title: Text(
              countBased ? l10n.howManyUnit(unitLabel) : l10n.howManyGrams,
              style: TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 16, color: colors.fg),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isAr ? food.nameAr : food.nameEn,
                    style: TextStyle(
                        fontSize: 14,
                        color: colors.subFg,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 12),
                TextField(
                  controller: ctrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  autofocus: true,
                  onChanged: (_) => setLocal(() {}),
                  decoration: InputDecoration(
                    hintText: countBased ? l10n.countLabel : l10n.grams,
                    suffixText: countBased ? unitLabel : 'g',
                    filled: true,
                    fillColor: colors.listTile,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                if (countBased) ...[
                  const SizedBox(height: 8),
                  Text(l10n.approxGrams(grams.toStringAsFixed(0)),
                      style: TextStyle(fontSize: 12, color: colors.subFg)),
                ],
                const SizedBox(height: 14),
                // Live macro preview
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _previewChip('🔥 ${food.caloriesFor(grams).toStringAsFixed(0)}',
                        AppColors.primaryColor1),
                    _previewChip(
                        'P ${food.proteinFor(grams).toStringAsFixed(1)}g',
                        const Color(0xFFE53935)),
                    _previewChip('C ${food.carbsFor(grams).toStringAsFixed(1)}g',
                        const Color(0xFF2196F3)),
                    _previewChip('F ${food.fatFor(grams).toStringAsFixed(1)}g',
                        const Color(0xFFFFC107)),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l10n.cancel,
                    style: TextStyle(color: colors.subFg)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor1,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  final g = gramsFromInput();
                  if (g <= 0) return;
                  Navigator.pop(ctx, FoodItemDraft(food: food, grams: g));
                },
                child: Text(l10n.ok),
              ),
            ],
          );
        },
      ),
    );

    if (draft != null && mounted) {
      Navigator.pop(context, draft);
    }
  }

  Widget _previewChip(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(text,
            style: TextStyle(
                fontSize: 11, color: color, fontWeight: FontWeight.w600)),
      );

  Future<void> _addCustomFood() async {
    final created = await showModalBottomSheet<Food>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _CustomFoodSheet(),
    );
    if (created != null && mounted) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.foodAdded),
          backgroundColor: AppColors.successColor,
        ),
      );
      // In selection mode, jump straight to picking grams for the new food.
      if (widget.selectionMode) _handleFoodTap(created);
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addCustomFood,
        backgroundColor: AppColors.primaryColor1,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(l10n.addCustomFood),
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
                    foodCategoryLabel(l10n, cat),
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
                ? const LiaqhPageLoader()
                : provider.foods.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text(
                            l10n.noFoodAddYours,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: colors.subFg),
                          ),
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

// ── Custom food creation sheet ──────────────────────────────────────────────

class _CustomFoodSheet extends StatefulWidget {
  const _CustomFoodSheet();

  @override
  State<_CustomFoodSheet> createState() => _CustomFoodSheetState();
}

class _CustomFoodSheetState extends State<_CustomFoodSheet> {
  final _nameEnCtrl = TextEditingController();
  final _nameArCtrl = TextEditingController();
  final _calCtrl = TextEditingController();
  final _proteinCtrl = TextEditingController();
  final _carbsCtrl = TextEditingController();
  final _fatCtrl = TextEditingController();
  final _gramsPerUnitCtrl = TextEditingController();
  final _unitEnCtrl = TextEditingController();
  final _unitArCtrl = TextEditingController();
  bool _byCount = false;
  String _category = 'Protein';
  String? _error;
  bool _busy = false;

  static const _categories = [
    'Protein', 'Carbs', 'Fat', 'Vegetable', 'Fruit', 'Dairy', 'Other',
  ];

  @override
  void dispose() {
    _nameEnCtrl.dispose();
    _nameArCtrl.dispose();
    _calCtrl.dispose();
    _proteinCtrl.dispose();
    _carbsCtrl.dispose();
    _fatCtrl.dispose();
    _gramsPerUnitCtrl.dispose();
    _unitEnCtrl.dispose();
    _unitArCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    if (_nameEnCtrl.text.trim().isEmpty) {
      setState(() => _error = l10n.foodNameRequired);
      return;
    }
    setState(() {
      _error = null;
      _busy = true;
    });
    final food = await context.read<MealProvider>().createFood(
          nameEn: _nameEnCtrl.text.trim(),
          nameAr: _nameArCtrl.text.trim(),
          category: _category,
          caloriesPer100g: double.tryParse(_calCtrl.text) ?? 0,
          proteinPer100g: double.tryParse(_proteinCtrl.text) ?? 0,
          carbsPer100g: double.tryParse(_carbsCtrl.text) ?? 0,
          fatPer100g: double.tryParse(_fatCtrl.text) ?? 0,
          gramsPerUnit:
              _byCount ? double.tryParse(_gramsPerUnitCtrl.text) : null,
          unitNameEn: _byCount ? _unitEnCtrl.text.trim() : null,
          unitNameAr: _byCount ? _unitArCtrl.text.trim() : null,
        );
    if (!mounted) return;
    setState(() => _busy = false);
    if (food != null) {
      Navigator.pop(context, food);
    } else {
      setState(() => _error = l10n.somethingWentWrong);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 14, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: colors.divider,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.restaurant_menu,
                    color: AppColors.primaryColor1, size: 20),
                const SizedBox(width: 8),
                Text(l10n.newCustomFood,
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: colors.fg)),
              ],
            ),
            const SizedBox(height: 16),
            _field(colors, _nameEnCtrl, l10n.foodNameEnLabel,
                TextInputType.text),
            const SizedBox(height: 10),
            _field(colors, _nameArCtrl, l10n.foodNameArLabel,
                TextInputType.text),
            const SizedBox(height: 14),
            Text(l10n.categoryLabel,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colors.subFg)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((c) {
                final sel = _category == c;
                return GestureDetector(
                  onTap: () => setState(() => _category = c),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel
                          ? AppColors.primaryColor1
                          : colors.listTile,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(foodCategoryLabel(l10n, c),
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: sel ? Colors.white : colors.subFg)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text(l10n.per100gNote,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: colors.fg)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                    child: _numField(colors, _calCtrl, l10n.caloriesPer100)),
                const SizedBox(width: 10),
                Expanded(
                    child: _numField(colors, _proteinCtrl, l10n.proteinPer100)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _numField(colors, _carbsCtrl, l10n.carbsPer100)),
                const SizedBox(width: 10),
                Expanded(child: _numField(colors, _fatCtrl, l10n.fatPer100)),
              ],
            ),
            const SizedBox(height: 14),
            // Measure by count (e.g. eggs)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              activeThumbColor: AppColors.primaryColor1,
              value: _byCount,
              onChanged: (v) => setState(() => _byCount = v),
              title: Text(l10n.measureByCount,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: colors.fg)),
            ),
            if (_byCount) ...[
              _field(colors, _gramsPerUnitCtrl, l10n.gramsPerUnitLabel,
                  const TextInputType.numberWithOptions(decimal: true)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                      child: _field(colors, _unitEnCtrl, l10n.unitNameLabel,
                          TextInputType.text)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _field(colors, _unitArCtrl, l10n.foodNameArLabel,
                          TextInputType.text)),
                ],
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!,
                  style: const TextStyle(
                      color: AppColors.errorColor, fontSize: 13)),
            ],
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _busy ? null : _save,
                icon: _busy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.check, size: 18),
                label: Text(l10n.saveFood),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor1,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  minimumSize: const Size(0, 50),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(AppThemeColors colors, TextEditingController ctrl, String label,
          TextInputType type) =>
      TextField(
        controller: ctrl,
        keyboardType: type,
        style: TextStyle(color: colors.fg, fontSize: 14),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: TextStyle(color: colors.subFg, fontSize: 13),
          filled: true,
          fillColor: colors.listTile,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
        ),
      );

  Widget _numField(
          AppThemeColors colors, TextEditingController ctrl, String label) =>
      _field(colors, ctrl,
          label, const TextInputType.numberWithOptions(decimal: true));
}
