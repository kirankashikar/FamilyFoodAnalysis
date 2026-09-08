import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:family_food_analysis/data/models/grocery_item.dart';
import 'package:family_food_analysis/ui/core/image_capture.dart';
import 'package:family_food_analysis/ui/theme/app_theme.dart';
import 'package:family_food_analysis/ui/view_models/main_view_model.dart';

import 'store_connectors_modal.dart';

enum _BillSheetStage { chooser, working, preview, manualEntry }

/// Unified "Add Grocery Bill" entry point: native camera/gallery OCR, PDF
/// scanning, a hint for sharing a forwarded receipt email into the app, a
/// shortcut into the existing Costco/Amazon store connectors, and a manual
/// paste-text fallback (also the only path that works on web, since on-device
/// OCR/PDF rendering are mobile-only).
class AddBillSheet extends StatefulWidget {
  /// When set (e.g. a file shared into the app from Mail), scanning starts
  /// immediately instead of showing the chooser.
  final String? initialFilePath;

  const AddBillSheet({super.key, this.initialFilePath});

  /// Shows the sheet responsively: a centered dialog on desktop widths, or a
  /// full-height bottom sheet on mobile.
  static void show(BuildContext context, {String? initialFilePath}) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    if (isDesktop) {
      showDialog(context: context, builder: (ctx) => AddBillSheet(initialFilePath: initialFilePath));
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (ctx) => AddBillSheet(initialFilePath: initialFilePath),
      );
    }
  }

  @override
  State<AddBillSheet> createState() => _AddBillSheetState();
}

class _AddBillSheetState extends State<AddBillSheet> {
  _BillSheetStage _stage = _BillSheetStage.chooser;
  String _workingMessage = '';
  String? _errorMessage;
  GroceryReceipt? _parsedReceipt;
  final TextEditingController _storeCtrl = TextEditingController();
  final TextEditingController _manualTextCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialFilePath != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _processFilePath(widget.initialFilePath!);
      });
    }
  }

  @override
  void dispose() {
    _storeCtrl.dispose();
    _manualTextCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    final content = Container(
      width: isDesktop ? 600 : double.infinity,
      constraints: isDesktop ? const BoxConstraints(maxHeight: 720) : null,
      height: isDesktop ? null : MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: isDesktop
            ? BorderRadius.circular(24)
            : const BorderRadius.vertical(top: Radius.circular(20)),
        border: isDesktop
            ? Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder)
            : null,
      ),
      child: Column(
        mainAxisSize: isDesktop ? MainAxisSize.min : MainAxisSize.max,
        children: [
          if (!isDesktop)
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
            child: Row(
              children: [
                const Icon(Icons.receipt_long_rounded, color: AppColors.primary, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _titleForStage(),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.3),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: _buildStageBody(context),
            ),
          ),
        ],
      ),
    );

    if (!isDesktop) {
      return SafeArea(child: content);
    }
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: content,
    );
  }

  String _titleForStage() {
    switch (_stage) {
      case _BillSheetStage.chooser:
        return 'Add Grocery Bill';
      case _BillSheetStage.working:
        return 'Scanning Receipt...';
      case _BillSheetStage.preview:
        return 'Review Items';
      case _BillSheetStage.manualEntry:
        return 'Paste Receipt Text';
    }
  }

  Widget _buildStageBody(BuildContext context) {
    switch (_stage) {
      case _BillSheetStage.chooser:
        return _buildChooser(context);
      case _BillSheetStage.working:
        return _buildWorking(context);
      case _BillSheetStage.preview:
        return _buildPreview(context);
      case _BillSheetStage.manualEntry:
        return _buildManualEntry(context);
    }
  }

  Widget _buildChooser(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pick how you\'d like to bring in a grocery bill.',
          style: TextStyle(fontSize: 13, color: AppColors.muted(context)),
        ),
        const SizedBox(height: 16),
        _actionTile(
          context,
          icon: Icons.camera_alt_rounded,
          iconColor: AppColors.primary,
          title: 'Scan with Camera',
          subtitle: 'On-device OCR reads items straight off the receipt',
          onTap: () => _scanImage(ImageSource.camera),
        ),
        _actionTile(
          context,
          icon: Icons.photo_library_rounded,
          iconColor: AppColors.secondary,
          title: 'Choose from Gallery',
          subtitle: 'Scan a receipt photo you already took',
          onTap: () => _scanImage(ImageSource.gallery),
        ),
        _actionTile(
          context,
          icon: Icons.picture_as_pdf_rounded,
          iconColor: AppColors.roseAlert,
          title: 'Upload PDF',
          subtitle: 'Emailed invoice or scanned PDF receipt',
          onTap: _scanPdf,
        ),
        _actionTile(
          context,
          icon: Icons.forward_to_inbox_rounded,
          iconColor: AppColors.warmAmber,
          title: 'Forward from Email',
          subtitle: 'Share a forwarded receipt email into this app',
          onTap: () => _showShareHint(context),
        ),
        _actionTile(
          context,
          icon: Icons.hub_rounded,
          iconColor: const Color(0xFF0060A9),
          title: 'Pull from Costco / Amazon',
          subtitle: 'Import already-connected store purchase history',
          onTap: () {
            Navigator.of(context).pop();
            StoreConnectorsModal.show(context);
          },
        ),
        _actionTile(
          context,
          icon: Icons.keyboard_alt_outlined,
          iconColor: AppColors.purpleVibrant,
          title: 'Paste Receipt Text',
          subtitle: kIsWeb ? 'Works on web — try a sample receipt too' : 'Manual entry or demo sample receipts',
          onTap: () => setState(() => _stage = _BillSheetStage.manualEntry),
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(_errorMessage!, style: const TextStyle(fontSize: 12, color: AppColors.roseAlert)),
        ],
      ],
    );
  }

  Widget _actionTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: isDark ? AppColors.darkCardElevated : AppColors.lightCardElevated,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(subtitle, style: TextStyle(fontSize: 11, color: AppColors.muted(context))),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWorking(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(_workingMessage, style: TextStyle(fontSize: 13, color: AppColors.muted(context))),
        ],
      ),
    );
  }

  Widget _buildPreview(BuildContext context) {
    final receipt = _parsedReceipt!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _storeCtrl,
          decoration: const InputDecoration(
            labelText: 'Store Name',
            prefixIcon: Icon(Icons.store_rounded),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 18),
            const SizedBox(width: 8),
            Text(
              'Detected ${receipt.extractedItems.length} items (Total: \$${receipt.totalAmount.toStringAsFixed(2)})',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          constraints: const BoxConstraints(maxHeight: 260),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCardElevated : AppColors.lightCardElevated,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: receipt.extractedItems.length,
            itemBuilder: (ctx, i) {
              final it = receipt.extractedItems[i];
              return ListTile(
                dense: true,
                leading: Text(it.category.iconEmoji),
                title: Text(it.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                subtitle: Text('${it.quantity} ${it.unit} • ${it.category.displayName}'),
                trailing: Text('\$${it.estimatedCost.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            TextButton(
              onPressed: () => setState(() {
                _stage = _BillSheetStage.chooser;
                _parsedReceipt = null;
              }),
              child: const Text('Rescan'),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _confirmAndSave,
              icon: const Icon(Icons.save_rounded, size: 18),
              label: const Text('Confirm & Save to Inventory'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildManualEntry(BuildContext context) {
    final vm = context.read<MainViewModel>();
    final presets = vm.ocrService.getSampleReceiptPresets();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Paste receipt text, or load a sample to try the parser.',
          style: TextStyle(fontSize: 13, color: AppColors.muted(context)),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: presets.map((p) {
            return ActionChip(
              avatar: const Icon(Icons.receipt_rounded, size: 16),
              label: Text(p.storeName),
              onPressed: () => setState(() {
                _manualTextCtrl.text = p.rawText;
                _storeCtrl.text = p.storeName;
              }),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _storeCtrl,
          decoration: const InputDecoration(labelText: 'Store Name'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _manualTextCtrl,
          maxLines: 8,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          decoration: const InputDecoration(
            labelText: 'Receipt Text',
            hintText: 'Item Name   Qty   Price...',
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            TextButton(
              onPressed: () => setState(() => _stage = _BillSheetStage.chooser),
              child: const Text('Back'),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _manualTextCtrl.text.trim().isEmpty
                  ? null
                  : () async {
                      final vm = context.read<MainViewModel>();
                      final receipt = await vm.parseReceiptText(_manualTextCtrl.text, storeName: _storeCtrl.text);
                      setState(() {
                        _parsedReceipt = receipt;
                        _storeCtrl.text = receipt.storeName;
                        _stage = _BillSheetStage.preview;
                      });
                    },
              icon: const Icon(Icons.bolt_rounded, size: 18),
              label: const Text('Extract & Parse Items'),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _scanImage(ImageSource source) async {
    setState(() => _errorMessage = null);
    final XFile? picked = await ImageCapture.pickImage(source: source);
    if (picked == null || !mounted) return;
    await _processFilePath(picked.path);
  }

  Future<void> _scanPdf() async {
    setState(() => _errorMessage = null);

    if (kIsWeb) {
      setState(() {
        _errorMessage = 'PDF scanning needs the mobile app — try "Paste Receipt Text" here on web.';
      });
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    final path = result?.files.single.path;
    if (path == null || !mounted) return;
    await _processFilePath(path);
  }

  /// Runs the OCR pipeline over an image or PDF file path — shared by the
  /// camera/gallery/PDF pickers above and by files shared into the app from
  /// another app (e.g. Mail's Share Sheet).
  Future<void> _processFilePath(String path) async {
    final isPdf = path.toLowerCase().endsWith('.pdf');

    if (kIsWeb) {
      setState(() {
        _stage = _BillSheetStage.chooser;
        _errorMessage = 'On-device OCR needs the mobile app — try "Paste Receipt Text" here on web.';
      });
      return;
    }

    setState(() {
      _stage = _BillSheetStage.working;
      _workingMessage = isPdf ? 'Reading PDF pages with on-device OCR...' : 'Reading receipt with on-device OCR...';
      _errorMessage = null;
    });

    final vm = context.read<MainViewModel>();
    try {
      final receipt = isPdf
          ? await vm.parseReceiptText(await vm.ocrService.extractTextFromPdf(path))
          : await vm.scanReceiptImage(path);
      if (!mounted) return;
      setState(() {
        _parsedReceipt = receipt;
        _storeCtrl.text = receipt.storeName;
        _stage = _BillSheetStage.preview;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _stage = _BillSheetStage.chooser;
        _errorMessage = 'Could not read that ${isPdf ? 'PDF' : 'receipt'}. Please try again or paste the text manually.';
      });
    }
  }

  void _confirmAndSave() {
    final vm = context.read<MainViewModel>();
    final receipt = _parsedReceipt!;
    final renamed = GroceryReceipt(
      id: receipt.id,
      storeName: _storeCtrl.text.trim().isEmpty ? receipt.storeName : _storeCtrl.text.trim(),
      date: receipt.date,
      totalAmount: receipt.totalAmount,
      extractedItems: receipt.extractedItems,
      receiptImageUrl: receipt.receiptImageUrl,
      rawText: receipt.rawText,
    );
    vm.processReceiptBill(renamed);
    Navigator.of(context).pop();
  }

  void _showShareHint(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.forward_to_inbox_rounded, color: AppColors.warmAmber),
            SizedBox(width: 8),
            Text('Forward from Email'),
          ],
        ),
        content: const Text(
          'Open the grocery receipt email in your Mail app, tap Share, and choose '
          'FamilyFood. The receipt image or PDF opens here ready to scan — no need '
          'to leave your inbox.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
