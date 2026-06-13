import 'package:cached_network_image/cached_network_image.dart';
import 'package:fitnessapp/data/services/api_service.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Renders a list of uploaded attachments (images / PDF / docs) with a View and
/// a Download action each. Images open in an in-app zoomable viewer; other file
/// types open in the device's default app. Download opens the file URL so the
/// browser/OS saves it.
class AttachmentsView extends StatelessWidget {
  final List<String> urls;
  const AttachmentsView({super.key, required this.urls});

  static String fullUrl(String path) {
    if (path.startsWith('http')) return path;
    return '${ApiService.baseUrl.replaceAll('/api', '')}$path';
  }

  static String _ext(String p) =>
      p.split('?').first.split('.').last.toLowerCase();

  static bool isImage(String p) =>
      ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'heic'].contains(_ext(p));

  static IconData iconFor(String p) {
    final e = _ext(p);
    if (e == 'pdf') return Icons.picture_as_pdf_outlined;
    if (['doc', 'docx'].contains(e)) return Icons.description_outlined;
    if (['xls', 'xlsx', 'csv'].contains(e)) return Icons.table_chart_outlined;
    if (isImage(p)) return Icons.image_outlined;
    return Icons.insert_drive_file_outlined;
  }

  static String fileName(String p) {
    final name = p.split('?').first.split('/').last.split('\\').last;
    try {
      return Uri.decodeComponent(name);
    } catch (_) {
      return name;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      children: [
        for (final u in urls)
          _AttachmentTile(url: u, colors: colors),
      ],
    );
  }
}

class _AttachmentTile extends StatelessWidget {
  final String url;
  final AppThemeColors colors;
  const _AttachmentTile({required this.url, required this.colors});

  Future<void> _open(BuildContext context) async {
    final full = AttachmentsView.fullUrl(url);
    if (AttachmentsView.isImage(url)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              _ImageViewerScreen(url: full, title: AttachmentsView.fileName(url)),
        ),
      );
    } else {
      await _launch(context, full);
    }
  }

  Future<void> _download(BuildContext context) async {
    // Open the file URL; the browser/OS handles saving it to the device.
    await _launch(context, AttachmentsView.fullUrl(url));
  }

  Future<void> _launch(BuildContext context, String full) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await launchUrl(Uri.parse(full),
        mode: LaunchMode.externalApplication);
    if (!ok) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not open the file.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.divider),
      ),
      child: Row(
        children: [
          Icon(AttachmentsView.iconFor(url),
              color: AppColors.primaryColor1, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              AttachmentsView.fileName(url),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: colors.fg, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          IconButton(
            tooltip: 'View',
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.visibility_outlined,
                size: 20, color: AppColors.primaryColor1),
            onPressed: () => _open(context),
          ),
          IconButton(
            tooltip: 'Download',
            visualDensity: VisualDensity.compact,
            icon: Icon(Icons.download_rounded, size: 20, color: colors.subFg),
            onPressed: () => _download(context),
          ),
        ],
      ),
    );
  }
}

/// Full-screen, zoomable in-app viewer for image attachments.
class _ImageViewerScreen extends StatelessWidget {
  final String url;
  final String title;
  const _ImageViewerScreen({required this.url, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 15)),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new_rounded),
            tooltip: 'Open externally',
            onPressed: () => launchUrl(Uri.parse(url),
                mode: LaunchMode.externalApplication),
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.8,
          maxScale: 5,
          child: CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.contain,
            placeholder: (_, __) => const CircularProgressIndicator(
                color: AppColors.primaryColor1),
            errorWidget: (_, __, ___) => const Icon(Icons.broken_image_outlined,
                color: Colors.white54, size: 64),
          ),
        ),
      ),
    );
  }
}
