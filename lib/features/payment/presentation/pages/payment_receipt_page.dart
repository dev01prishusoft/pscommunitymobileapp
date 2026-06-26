import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/widgets/cached_img.dart';
import 'package:pscommunitymobileapp/features/payment/presentation/controllers/payment_controller.dart';
import 'package:pscommunitymobileapp/features/samaj/presentation/controllers/samaj_controller.dart';
import 'package:intl/intl.dart';

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
  final samajController = Get.find<SamajController>();
  late Future<Map<String, dynamic>> _receiptFuture;
  int? _receiptId;
  bool _isRecurringArg = false;
  String _planNameArg = '';
  Map<String, dynamic>? _latestData;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    _receiptId = args?['receiptId'] as int?;
    _isRecurringArg = args?['isRecurring'] as bool? ?? false;
    _planNameArg = args?['planName'] as String? ?? '';
    
    if (_receiptId != null) {
      _receiptFuture = controller.getReceipt(_receiptId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_receiptId == null) {
      return Scaffold(
        appBar: AppBar(title: Text(LK.paymentReceipt.tr)),
        body: Center(child: Text('Invalid Receipt ID')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Get.back<void>(),
        ),
        title: Text(LK.paymentReceipt.tr),
        actions: [
          IconButton(
            onPressed: () => _shareReceipt(),
            icon: Icon(Icons.share, color: AppColors.primary),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _receiptFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return Center(child: Text('No data found'));
          }

          final data = snapshot.data!;
          _latestData = data;
          return _buildContent(data);
        },
      ),
    );
  }

  String _formatDate(dynamic dateStr) {
    if (dateStr == null) return 'N/A';
    final str = dateStr.toString();
    try {
      DateTime dt;
      if (str.endsWith('Z') || str.contains(RegExp(r'[+-]\d{2}:\d{2}$'))) {
        dt = DateTime.parse(str).toLocal();
      } else {
        try {
          if (str.contains('/')) {
            dt = DateFormat('dd/MM/yyyy hh:mm a').parse(str, true).toLocal();
          } else if (str.contains(RegExp(r'^\d{2}-\d{2}-\d{4}'))) {
            dt = DateFormat('dd-MM-yyyy HH:mm:ss').parse(str, true).toLocal();
          } else {
            dt = DateTime.parse('${str}Z').toLocal();
          }
        } catch (_) {
          dt = DateTime.parse(str).toLocal();
        }
      }
      return DateFormat('dd/MM/yyyy hh:mm a').format(dt);
    } catch (e) {
      return str.split('.').first;
    }
  }

  Map<String, String> _getParsedData(Map<String, dynamic> data) {
    return {
      'date': _formatDate(
        data['date'] ??
            data['paymentDate'] ??
            data['createdOn'] ??
            data['transactionDate'],
      ),
      'name':
          (data['name'] ?? data['memberName'] ?? data['fullName'])
              ?.toString() ??
          'N/A',
      'memberNo': data['memberNo']?.toString() ?? 'N/A',
      'planName': (data['planName'] ?? data['plan'])?.toString() ?? (_planNameArg.isNotEmpty ? _planNameArg : 'N/A'),
      'isRecurring': (data['isRecurring']?.toString() == 'true' || data['isRecurring'] == true || _isRecurringArg) 
          ? LK.yes.tr 
          : (data['isRecurring']?.toString() == 'false' || data['isRecurring'] == false)
              ? LK.no.tr
              : 'N/A',
      'recurringPaymentType': (data['recurringPaymentType'] ?? data['recurringType'] ?? data['recurringTypeName'] ?? data['recurringPaymentTypeName'])?.toString() ?? 'N/A',
      'type':
          ((data['type'] ?? data['paymentType'] ?? data['paymentTypeName'])
                      ?.toString() ??
                  'N/A')
              .tr,
      'category':
          (data['category'] ??
                  data['paymentCategory'] ??
                  data['paymentCategoryName'])
              ?.toString() ??
          'N/A',
      'amount': (data['amount'] ?? data['paymentAmount'])?.toString() ?? 'N/A',
      'mode':
          ((data['mode'] ?? data['paymentMode'] ?? data['paymentModeName'])
                      ?.toString() ??
                  'N/A')
              .tr,
      'status':
          ((data['status'] ?? data['paymentStatus'])?.toString() ?? 'N/A').tr,
      'transactionId':
          (data['transactionId'] ?? data['paymentTransactionId'] ?? data['TransactionId'] ?? data['transactionNo'] ?? data['referenceNo'] ?? data['bankTransactionId'])?.toString() ??
          'N/A',
      'receiptNo': data['receiptNo']?.toString() ?? 'N/A',
    };
  }

  Widget _buildContent(Map<String, dynamic> rawData) {
    final data = _getParsedData(rawData);

    return SingleChildScrollView(
      padding: EdgeInsets.all(20.0),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                if (samajController.samaj.value?.logoUrl != null &&
                    samajController.samaj.value!.logoUrl.isNotEmpty)
                  ClipOval(
                    child: CachedImg(
                      url: samajController.samaj.value!.logoUrl,
                      memCacheWidth: 120,
                      width: 60,
                      height: 60,
                      fit: BoxFit.contain,
                      placeholder: (_, __) => const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      errorWidget: (_, __, ___) => const Icon(
                        Icons.account_balance,
                        size: 60,
                        color: AppColors.navyBlue,
                      ),
                    ),
                  )
                else
                  const Icon(
                    Icons.account_balance,
                    size: 60,
                    color: AppColors.navyBlue,
                  ),
                SizedBox(height: 16.h),
                Text(
                  samajController.samaj.value?.name ?? LK.samajName.tr,
                  style: AppTextStyles.headlineLarge.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  LK.officialPaymentReceipt.tr,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          _buildReceiptSection(LK.receiptDetailsLabel.tr, [
            _buildInfoRow(LK.receiptNoLabel.tr, data['receiptNo']!),
            _buildInfoRow(LK.dateLabel.tr, data['date']!),
          ]),
          SizedBox(height: 16.h),
          _buildReceiptSection(LK.memberDetailsLabel.tr, [
            _buildInfoRow(LK.nameLabel.tr, data['name']!),
            _buildInfoRow(LK.memberNoLabel.tr, data['memberNo']!),
          ]),
          SizedBox(height: 16.h),
          _buildReceiptSection(LK.paymentDetailsLabel.tr, [
            if (data['planName'] != 'N/A' && data['planName']!.isNotEmpty)
              _buildInfoRow(LK.planNameLabel.tr, data['planName']!),
            if (data['isRecurring'] != 'N/A')
              _buildInfoRow('${LK.recurring.tr}:', data['isRecurring']!),
            if (data['recurringPaymentType'] != 'N/A' && data['recurringPaymentType']!.isNotEmpty)
              _buildInfoRow(LK.recurringTypeLabel.tr, data['recurringPaymentType']!.tr),
            _buildInfoRow(LK.typeLabel.tr, data['type']!),
            _buildInfoRow(LK.categoryLabel.tr, data['category']!),
            _buildInfoRow(LK.amountLabel.tr, data['amount']!),
            _buildInfoRow(LK.modeLabel.tr, data['mode']!),
            _buildStatusRow(LK.statusLabel.tr, data['status']!),
            if (data['transactionId'] != 'N/A' && data['transactionId']!.isNotEmpty)
              _buildInfoRow(LK.transactionIdLabel.tr, data['transactionId']!),
          ]),
          SizedBox(height: 32.h),
          ElevatedButton.icon(
            onPressed: () => _generateAndPrintPdf(rawData),
            icon: Icon(Icons.file_download, color: AppColors.white),
            label: Text(
              LK.downloadPdf.tr,
              style: AppTextStyles.titleLarge.copyWith(color: AppColors.white),
            ),
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 56),
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
          SizedBox(height: 40.h),
        ],
      ),
    );
  }

  Widget _buildReceiptSection(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
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
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Divider(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          SizedBox(
            width: 110.w,
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.mutedForeground,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          SizedBox(
            width: 110.w,
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.mutedForeground,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.labelLarge.copyWith(
                color: value.toLowerCase() == 'success'
                    ? AppColors.green
                    : AppColors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _shareReceipt() async {
    if (_latestData == null) return;
    final parsed = _getParsedData(_latestData!);
    final pdf = await _generatePdfDocument(parsed);
    final bytes = await pdf.save();

    await Printing.sharePdf(
      bytes: bytes,
      filename: 'receipt_${parsed['receiptNo']}.pdf',
    );
  }

  Future<void> _generateAndPrintPdf(Map<String, dynamic> data) async {
    final parsed = _getParsedData(data);
    final pdf = await _generatePdfDocument(parsed);

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  Future<pw.Document> _generatePdfDocument(Map<String, String> data) async {
    final font = await PdfGoogleFonts.hindVadodaraRegular();
    final boldFont = await PdfGoogleFonts.hindVadodaraBold();

    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(base: font, bold: boldFont),
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text(
                  samajController.samaj.value?.name ?? LK.samajName.tr,
                  style: pw.TextStyle(
                    fontSize: 24.sp,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 20.h),
              pw.Text('${LK.receiptNoLabel.tr} ${data['receiptNo']}'),
              pw.Text('${LK.dateLabel.tr} ${data['date']}'),
              pw.Divider(),
              pw.Text('${LK.nameLabel.tr} ${data['name']}'),
              pw.Text('${LK.memberNoLabel.tr} ${data['memberNo']}'),
              pw.Divider(),
              if (data['planName'] != 'N/A' && data['planName']!.isNotEmpty)
                pw.Text('${LK.planNameLabel.tr} ${data['planName']}'),
              if (data['isRecurring'] != 'N/A')
                pw.Text('${LK.recurring.tr}: ${data['isRecurring']}'),
              if (data['recurringPaymentType'] != 'N/A' && data['recurringPaymentType']!.isNotEmpty)
                pw.Text('${LK.recurringTypeLabel.tr} ${data['recurringPaymentType']!.tr}'),
              pw.Text('${LK.typeLabel.tr} ${data['type']}'),
              pw.Text('${LK.categoryLabel.tr} ${data['category']}'),
              pw.Text('${LK.amountLabel.tr} ${data['amount']}'),
              pw.Text('${LK.modeLabel.tr} ${data['mode']}'),
              pw.Text('${LK.statusLabel.tr} ${data['status']}'),
              pw.Text('${LK.transactionIdLabel.tr} ${data['transactionId']}'),
              pw.SizedBox(height: 40.h),
              pw.Text(
                LK.thankYouForPayment.tr,
                style: pw.TextStyle(fontSize: 14.sp),
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }
}
