import 'dart:io';
import 'package:fitnessapp/common_widgets/liaqh_loaders.dart';
import 'package:fitnessapp/l10n/app_localizations.dart';
import 'package:fitnessapp/providers/workout_provider.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../common_widgets/round_gradient_button.dart';
import '../../common_widgets/round_textfield.dart';

class AddCustomExerciseScreen extends StatefulWidget {
  const AddCustomExerciseScreen({Key? key}) : super(key: key);

  @override
  State<AddCustomExerciseScreen> createState() => _AddCustomExerciseScreenState();
}

class _AddCustomExerciseScreenState extends State<AddCustomExerciseScreen> {
  final _nameEnCtrl  = TextEditingController();
  final _nameArCtrl  = TextEditingController();
  final _equipCtrl   = TextEditingController();
  final _descCtrl    = TextEditingController();
  final _videoCtrl   = TextEditingController();

  String _selectedMuscle = 'Chest';
  File? _imageFile;
  String? _uploadedImageUrl;
  String? _error;

  static const _muscles = [
    'Chest', 'Back', 'Shoulders', 'Biceps', 'Triceps', 'Forearms',
    'Quads', 'Hamstrings', 'Glutes', 'Calves', 'Abs', 'FullBody',
  ];

  @override
  void dispose() {
    _nameEnCtrl.dispose(); _nameArCtrl.dispose(); _equipCtrl.dispose();
    _descCtrl.dispose();   _videoCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 85, maxWidth: 800);
    if (picked != null) setState(() => _imageFile = File(picked.path));
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    if (_nameEnCtrl.text.trim().isEmpty) {
      setState(() => _error = l10n.exerciseNameRequired);
      return;
    }
    setState(() => _error = null);
    final provider = context.read<WorkoutProvider>();

    // Upload image first if picked
    String? imageUrl = _uploadedImageUrl;
    if (_imageFile != null && imageUrl == null) {
      imageUrl = await provider.uploadExerciseImage(_imageFile!);
    }

    final id = await provider.createCustomExercise(
      nameEn: _nameEnCtrl.text.trim(),
      nameAr: _nameArCtrl.text.trim().isNotEmpty ? _nameArCtrl.text.trim() : null,
      muscleGroup: _selectedMuscle,
      equipment: _equipCtrl.text.trim().isNotEmpty ? _equipCtrl.text.trim() : null,
      description: _descCtrl.text.trim().isNotEmpty ? _descCtrl.text.trim() : null,
      imageUrl: imageUrl,
      videoUrl: _videoCtrl.text.trim().isNotEmpty ? _videoCtrl.text.trim() : null,
    );

    if (id != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.exerciseAdded), backgroundColor: AppColors.successColor),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final provider = context.watch<WorkoutProvider>();
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: Text(l10n.addCustomExercise,
            style: TextStyle(
                fontWeight: FontWeight.w700,
                color: colors.fg,
                fontSize: 17)),
        backgroundColor: colors.bg,
        elevation: 0,
        foregroundColor: colors.fg,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image picker
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 160,
                decoration: BoxDecoration(
                  color: colors.listTile,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppColors.primaryColor1.withValues(alpha: 0.3)),
                ),
                child: _imageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.file(_imageFile!, fit: BoxFit.cover))
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_photo_alternate_outlined,
                              size: 40, color: AppColors.primaryColor1),
                          const SizedBox(height: 8),
                          Text(l10n.addExercisePhoto,
                              style: TextStyle(
                                  color: colors.subFg, fontSize: 13)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),
            RoundTextField(
              textEditingController: _nameEnCtrl,
              hintText: l10n.exerciseNameEn,
              icon: 'assets/icons/user_icon.png',
              textInputType: TextInputType.text,
            ),
            const SizedBox(height: 12),
            RoundTextField(
              textEditingController: _nameArCtrl,
              hintText: l10n.exerciseNameAr,
              icon: 'assets/icons/user_icon.png',
              textInputType: TextInputType.text,
            ),
            const SizedBox(height: 16),
            // Muscle group picker
            Text(l10n.muscleFocus,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: colors.fg)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: _muscles.map((m) {
                final selected = _selectedMuscle == m;
                return GestureDetector(
                  onTap: () => setState(() => _selectedMuscle = m),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primaryColor1
                          : colors.listTile,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(m,
                        style: TextStyle(
                            color: selected
                                ? Colors.white
                                : colors.subFg,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w400,
                            fontSize: 12)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            RoundTextField(
              textEditingController: _equipCtrl,
              hintText: l10n.equipmentHint,
              icon: 'assets/icons/user_icon.png',
              textInputType: TextInputType.text,
            ),
            const SizedBox(height: 12),
            RoundTextField(
              textEditingController: _descCtrl,
              hintText: l10n.descriptionOptional,
              icon: 'assets/icons/message_icon.png',
              textInputType: TextInputType.multiline,
            ),
            const SizedBox(height: 12),
            RoundTextField(
              textEditingController: _videoCtrl,
              hintText: l10n.videoUrl,
              icon: 'assets/icons/message_icon.png',
              textInputType: TextInputType.url,
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!,
                  style: const TextStyle(
                      color: AppColors.errorColor, fontSize: 13)),
            ],
            const SizedBox(height: 28),
            provider.loading
                ? const LiaqhPageLoader()
                : RoundGradientButton(
                    title: l10n.saveExercise,
                    onPressed: _submit,
                  ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
