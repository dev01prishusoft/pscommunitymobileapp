import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/features/payment/presentation/controllers/payment_controller.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PaymentReceiptPage extends StatefulWidget {
  const PaymentReceiptPage({super.key});

  @override
  State<PaymentReceiptPage> createState() => _PaymentReceiptPageState();
}

class _PaymentReceiptPageState extends State<PaymentReceiptPage> {
  final controller = Get.find<PaymentController>();
  late Future<Map<String, dynamic>> _receiptFuture;
  int? _receiptId;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    _receiptId = args?['receiptId'] as int?;
    if (_receiptId != null) {
      _receiptFuture = controller.getReceipt(_receiptId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_receiptId == null) {
      return Scaffold(
        appBar: AppBar(title: Text(LK.paymentReceipt.tr)),
        body: const Center(child: Text('Invalid Receipt ID')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Get.back<void>(),
        ),
        title: Text(
          LK.paymentReceipt.tr,
          style: const TextStyle(
            color: AppColors.secondary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () => _shareReceipt(),
            icon: const Icon(Icons.share, color: AppColors.primary),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _receiptFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No data found'));
          }

          final data = snapshot.data!;
          return _buildContent(data);
        },
      ),
    );
  }

  Widget _buildContent(Map<String, dynamic> data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // Header Info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                const Icon(Icons.account_balance, size: 60, color: Color(0xFF002B5B)),
                const SizedBox(height: 16),
                Text(
                  LK.samajName.tr,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  LK.officialPaymentReceipt.tr,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Details Sections
          _buildReceiptSection(
            LK.receiptDetailsLabel.tr,
            [
              _buildInfoRow(LK.receiptNoLabel.tr, data['receiptNo']?.toString() ?? 'N/A'),
              _buildInfoRow(LK.dateLabel.tr, data['date']?.toString() ?? 'N/A'),
            ],
          ),
          const SizedBox(height: 16),
          _buildReceiptSection(
            LK.memberDetailsLabel.tr,
            [
              _buildInfoRow(LK.nameLabel.tr, data['name']?.toString() ?? 'N/A'),
              _buildInfoRow(LK.memberNoLabel.tr, data['memberNo']?.toString() ?? 'N/A'),
            ],
          ),
          const SizedBox(height: 16),
          _buildReceiptSection(
            LK.paymentDetailsLabel.tr,
            [
              _buildInfoRow(LK.typeLabel.tr, data['type']?.toString() ?? 'N/A'),
              _buildInfoRow(LK.categoryLabel.tr, data['category']?.toString() ?? 'N/A'),
              _buildInfoRow(LK.amountLabel.tr, data['amount']?.toString() ?? 'N/A'),
              _buildInfoRow(LK.modeLabel.tr, data['mode']?.toString() ?? 'N/A'),
              _buildStatusRow(LK.statusLabel.tr, data['status']?.toString() ?? 'N/A'),
              _buildInfoRow(LK.transactionIdLabel.tr, data['transactionId']?.toString() ?? 'N/A'),
            ],
          ),
          const SizedBox(height: 32),

          // Download PDF Button
          ElevatedButton.icon(
            onPressed: () => _generateAndPrintPdf(data),
            icon: const Icon(Icons.file_download, color: Colors.white),
            label: Text(
              LK.downloadPdf.tr,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildReceiptSection(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Divider(color: AppColors.primary.withValues(alpha: 0.2))),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.mutedForeground,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.secondary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.mutedForeground,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: value.toLowerCase() == 'success' ? Colors.green : Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _shareReceipt() {
     Share.share('Official Receipt from ${LK.samajName.tr}');
  }

  Future<void> _generateAndPrintPdf(Map<String, dynamic> data) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text(LK.samajName.tr, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 20),
              pw.Text('${LK.receiptNoLabel.tr} ${data['receiptNo']}'),
              pw.Text('${LK.dateLabel.tr} ${data['date']}'),
              pw.Divider(),
              pw.Text('${LK.nameLabel.tr} ${data['name']}'),
              pw.Text('${LK.memberNoLabel.tr} ${data['memberNo']}'),
              pw.Divider(),
              pw.Text('${LK.typeLabel.tr} ${data['type']}'),
              pw.Text('${LK.categoryLabel.tr} ${data['category']}'),
              pw.Text('${LK.amountLabel.tr} ${data['amount']}'),
              pw.Text('${LK.modeLabel.tr} ${data['mode']}'),
              pw.Text('${LK.statusLabel.tr} ${data['status']}'),
              pw.Text('${LK.transactionIdLabel.tr} ${data['transactionId']}'),
              pw.SizedBox(height: 40),
              pw.Text('Thank you for your payment!', style: pw.TextStyle(fontStyle: pw.FontStyle.italic)),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }
}
