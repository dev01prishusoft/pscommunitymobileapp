
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/features/payment/presentation/controllers/payment_controller.dart';
import 'package:pscommunitymobileapp/features/samaj/presentation/controllers/samaj_controller.dart';

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
      appBar: AppBar(
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
      'planName':
          (data['planName'] ?? data['plan'])?.toString() ??
          (_planNameArg.isNotEmpty ? _planNameArg : 'N/A'),
      'isRecurring':
          (data['isRecurring']?.toString() == 'true' ||
              data['isRecurring'] == true ||
              _isRecurringArg)
          ? LK.yes.tr
          : (data['isRecurring']?.toString() == 'false' ||
                data['isRecurring'] == false)
          ? LK.no.tr
          : 'N/A',
      'recurringPaymentType':
          (data['recurringPaymentType'] ??
                  data['recurringType'] ??
                  data['recurringTypeName'] ??
                  data['recurringPaymentTypeName'])
              ?.toString() ??
          'N/A',
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
          (data['transactionId'] ??
                  data['paymentTransactionId'] ??
                  data['TransactionId'] ??
                  data['transactionNo'] ??
                  data['referenceNo'] ??
                  data['bankTransactionId'])
              ?.toString() ??
          'N/A',
      'receiptNo': data['receiptNo']?.toString() ?? 'N/A',
    };
  }

  Widget _buildContent(Map<String, dynamic> rawData) {
    final data = _getParsedData(rawData);
    final status = data['status'] ?? 'N/A';
    final isSuccess =
        status.toLowerCase() == 'success' ||
        status.toLowerCase() == 'completed' ||
        status.toLowerCase() == 'successful';

    return SingleChildScrollView(
      padding: EdgeInsets.all(20.0),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 24, bottom: 20),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSuccess
                              ? Colors.green.shade50
                              : Colors.orange.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isSuccess
                              ? Icons.check_circle_rounded
                              : Icons.pending_rounded,
                          color: isSuccess ? AppColors.green : AppColors.orange,
                          size: 56,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        isSuccess ? 'Payment Successful' : 'Payment Pending',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: isSuccess ? AppColors.green : AppColors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        '₹${data['amount']}',
                        style: TextStyle(
                          fontSize: 32.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        data['category']!,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: List.generate(
                      30,
                      (index) => Expanded(
                        child: Container(
                          color: index % 2 == 0
                              ? Colors.transparent
                              : Colors.grey.shade200,
                          height: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildReceiptSectionHeader(LK.receiptDetailsLabel.tr),
                      _buildInfoRow(LK.receiptNoLabel.tr, data['receiptNo']!),
                      _buildInfoRow(LK.dateLabel.tr, data['date']!),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(height: 1, color: Colors.black12),
                      ),
                      _buildReceiptSectionHeader(LK.memberDetailsLabel.tr),
                      _buildInfoRow(LK.nameLabel.tr, data['name']!),
                      _buildInfoRow(LK.memberNoLabel.tr, data['memberNo']!),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(height: 1, color: Colors.black12),
                      ),
                      _buildReceiptSectionHeader(LK.paymentDetailsLabel.tr),
                      if (data['isRecurring'] != 'N/A')
                        _buildInfoRow(
                          '${LK.recurring.tr}:',
                          data['isRecurring']!,
                        ),
                      if (data['recurringPaymentType'] != 'N/A' &&
                          data['recurringPaymentType']!.isNotEmpty)
                        _buildInfoRow(
                          LK.recurringTypeLabel.tr,
                          data['recurringPaymentType']!.tr,
                        ),
                      _buildInfoRow(LK.typeLabel.tr, data['type']!),
                      _buildInfoRow(LK.modeLabel.tr, data['mode']!),
                      if (data['transactionId'] != 'N/A' &&
                          data['transactionId']!.isNotEmpty)
                        _buildInfoRow(
                          LK.transactionIdLabel.tr,
                          data['transactionId']!,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: () => _generateAndPrintPdf(rawData),
            icon: Icon(Icons.file_download_rounded, color: AppColors.white),
            label: Text(
              LK.downloadPdf.tr,
              style: AppTextStyles.titleLarge.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 56.h),
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
            ),
          ),
          SizedBox(height: 40.h),
        ],
      ),
    );
  }

  Widget _buildReceiptSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h, top: 4.h),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.bold,
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

  Future<Uint8List?> _loadNetworkImage(String? url) async {
    try {
      if (url == null || url.isEmpty) return null;

      final request = await HttpClient().getUrl(Uri.parse(url));
      final response = await request.close();

      if (response.statusCode == 200) {
        return await consolidateHttpClientResponseBytes(response);
      }
    } catch (e) {
    }

    return null;
  }

  Future<pw.Document> _generatePdfDocument(Map<String, String> data) async {
    final font = await PdfGoogleFonts.hindVadodaraRegular();
    final boldFont = await PdfGoogleFonts.hindVadodaraBold();

    final logoBytes = await _loadNetworkImage(
      samajController.samaj.value?.logoUrl,
    );

    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(base: font, bold: boldFont),
    );

    final primaryColor = PdfColor.fromInt(0xFF8F0500);
    final secondaryColor = PdfColor.fromInt(0xFF4A0200);
    final lightGrey = PdfColor.fromInt(0xFFF9F9F9);
    final borderGrey = PdfColor.fromInt(0xFFE5E5E5);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  if (logoBytes != null)
                    pw.Container(
                      width: 50,
                      height: 50,
                      decoration: const pw.BoxDecoration(
                        shape: pw.BoxShape.circle,
                      ),
                      child: pw.ClipRRect(
                        horizontalRadius: 25,
                        verticalRadius: 25,
                        child: pw.Image(
                          pw.MemoryImage(logoBytes),
                          fit: pw.BoxFit.cover,
                        ),
                      ),
                    )
                  else
                    pw.Container(
                      width: 50,
                      height: 50,
                      decoration: pw.BoxDecoration(
                        shape: pw.BoxShape.circle,
                        color: primaryColor,
                      ),
                      child: pw.Center(
                        child: pw.Text(
                          'S',
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                        ),
                      ),
                    ),
                  pw.SizedBox(width: 16),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          samajController.samaj.value?.name ?? LK.samajName.tr,
                          style: pw.TextStyle(
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                            color: secondaryColor,
                          ),
                        ),
                        if (samajController
                                .samaj
                                .value
                                ?.description
                                .isNotEmpty ??
                            false)
                          pw.Text(
                            samajController.samaj.value!.description,
                            style: const pw.TextStyle(
                              fontSize: 10,
                              color: PdfColors.grey700,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 24),
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                decoration: pw.BoxDecoration(
                  color: primaryColor,
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(4),
                  ),
                ),
                child: pw.Text(
                  LK.officialPaymentReceipt.tr.toUpperCase(),
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          LK.receiptDetailsLabel.tr.toUpperCase(),
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        pw.SizedBox(height: 6),
                        _buildPdfInfoRow(
                          LK.receiptNoLabel.tr,
                          data['receiptNo']!,
                        ),
                        _buildPdfInfoRow(LK.dateLabel.tr, data['date']!),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 32),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          LK.memberDetailsLabel.tr.toUpperCase(),
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        pw.SizedBox(height: 6),
                        _buildPdfInfoRow(LK.nameLabel.tr, data['name']!),
                        _buildPdfInfoRow(
                          LK.memberNoLabel.tr,
                          data['memberNo']!,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 24),
              pw.Divider(color: borderGrey, thickness: 1),
              pw.SizedBox(height: 16),
              pw.Text(
                LK.paymentDetailsLabel.tr.toUpperCase(),
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Table(
                border: pw.TableBorder.all(color: borderGrey, width: 0.5),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(5),
                },
                children: [
                  _buildPdfTableCell(
                    'Category',
                    data['category']!,
                    background: lightGrey,
                    isHeader: true,
                  ),
                  _buildPdfTableCell(LK.typeLabel.tr, data['type']!),
                  _buildPdfTableCell(LK.modeLabel.tr, data['mode']!),
                  if (data['isRecurring'] != 'N/A')
                    _buildPdfTableCell(LK.recurring.tr, data['isRecurring']!),
                  if (data['recurringPaymentType'] != 'N/A' &&
                      data['recurringPaymentType']!.isNotEmpty)
                    _buildPdfTableCell(
                      LK.recurringTypeLabel.tr,
                      data['recurringPaymentType']!.tr,
                    ),
                  if (data['transactionId'] != 'N/A' &&
                      data['transactionId']!.isNotEmpty)
                    _buildPdfTableCell(
                      LK.transactionIdLabel.tr,
                      data['transactionId']!,
                    ),
                  _buildPdfTableCell('Status', data['status']!, isStatus: true),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: pw.BoxDecoration(
                    color: lightGrey,
                    borderRadius: const pw.BorderRadius.all(
                      pw.Radius.circular(6),
                    ),
                    border: pw.Border.all(color: borderGrey, width: 0.5),
                  ),
                  child: pw.Row(
                    mainAxisSize: pw.MainAxisSize.min,
                    children: [
                      pw.Text(
                        'Total Paid:  ',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: secondaryColor,
                        ),
                      ),
                      pw.Text(
                        '₹${data['amount']}',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              pw.Spacer(),
              pw.Divider(color: borderGrey, thickness: 1),
              pw.SizedBox(height: 12),
              pw.Center(
                child: pw.Text(
                  LK.thankYouForPayment.tr,
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: secondaryColor,
                  ),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Center(
                child: pw.Text(
                  'This is a computer-generated receipt, signature is not required.',
                  style: const pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.grey600,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  pw.Widget _buildPdfInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 80,
            child: pw.Text(
              label,
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  pw.TableRow _buildPdfTableCell(
    String label,
    String value, {
    PdfColor? background,
    bool isHeader = false,
    bool isStatus = false,
  }) {
    final statusColor =
        (value.toLowerCase() == 'success' ||
            value.toLowerCase() == 'completed' ||
            value.toLowerCase() == 'successful')
        ? PdfColor.fromInt(0xFF2E7D32)
        : PdfColor.fromInt(0xFFEF6C00);

    return pw.TableRow(
      decoration: background != null
          ? pw.BoxDecoration(color: background)
          : null,
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: PdfColors.grey800,
            ),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: isStatus ? statusColor : PdfColors.black,
            ),
          ),
        ),
      ],
    );
  }
}
