import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';

import 'package:share_plus/share_plus.dart';

class PaymentReceiptPage extends StatelessWidget {
  const PaymentReceiptPage({super.key});

  @override
  Widget build(BuildContext context) {
    final payment = Get.arguments as Map<String, dynamic>?;
    final receiptNo = (payment?['receiptNo'] ?? 'N/A').toString();
    final date = (payment?['date'] ?? 'N/A').toString();
    final name = (payment?['name'] ?? 'N/A').toString();
    final memberNo = (payment?['memberNo'] ?? 'N/A').toString();
    final type = (payment?['type'] ?? 'N/A').toString();
    final category = (payment?['category'] ?? 'N/A').toString();
    final amount = (payment?['amount'] ?? 'N/A').toString();
    final mode = (payment?['mode'] ?? 'N/A').toString();
    final status = (payment?['status'] ?? 'N/A').toString();
    final txnId = (payment?['transactionId'] ?? 'N/A').toString();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
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
          TextButton.icon(
            onPressed: () {
              SharePlus.instance.share(ShareParams(text: 'Check out my payment receipt for ${LK.samajName.tr}'));
            },
            icon: const Icon(Icons.share, size: 18),
            label: Text(LK.share.tr),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                _buildInfoRow(LK.receiptNoLabel.tr, receiptNo),
                _buildInfoRow(LK.dateLabel.tr, date),
              ],
            ),
            const SizedBox(height: 16),
            _buildReceiptSection(
              LK.memberDetailsLabel.tr,
              [
                _buildInfoRow(LK.nameLabel.tr, name),
                _buildInfoRow(LK.memberNoLabel.tr, memberNo),
              ],
            ),
            const SizedBox(height: 16),
            _buildReceiptSection(
              LK.paymentDetailsLabel.tr,
              [
                _buildInfoRow(LK.typeLabel.tr, type),
                _buildInfoRow(LK.categoryLabel.tr, category),
                _buildInfoRow(LK.amountLabel.tr, amount),
                _buildInfoRow(LK.modeLabel.tr, mode),
                _buildStatusRow(LK.statusLabel.tr, status),
                _buildInfoRow(LK.transactionIdLabel.tr, txnId),
              ],
            ),
            const SizedBox(height: 32),

            // Download PDF Button
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(LK.comingSoon.tr)),
                );
              },
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
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
