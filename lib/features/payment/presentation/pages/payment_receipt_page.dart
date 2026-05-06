import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';

import 'package:share_plus/share_plus.dart';

class PaymentReceiptPage extends StatelessWidget {
  const PaymentReceiptPage({super.key});

  @override
  Widget build(BuildContext context) {
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
          'Payment Receipt'.tr,
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
            label: Text('Share'.tr),
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
                    'Official Payment Receipt'.tr,
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
              'RECEIPT DETAILS'.tr,
              [
                _buildInfoRow('Receipt No:'.tr, 'REC20250315001'.tr),
                _buildInfoRow('Date:'.tr, '15 Mar 2025'.tr),
              ],
            ),
            const SizedBox(height: 16),
            _buildReceiptSection(
              'MEMBER DETAILS'.tr,
              [
                _buildInfoRow('Name:'.tr, 'Rajesh Patel'.tr),
                _buildInfoRow('Member No:'.tr, 'MEM001234'.tr),
              ],
            ),
            const SizedBox(height: 16),
            _buildReceiptSection(
              'PAYMENT DETAILS'.tr,
              [
                _buildInfoRow('Type:'.tr, 'Membership Fee'.tr),
                _buildInfoRow('Category:'.tr, 'Annual Membership'.tr),
                _buildInfoRow('Amount:'.tr, '₹2,000'.tr),
                _buildInfoRow('Mode:'.tr, 'UPI'.tr),
                _buildStatusRow('Status:'.tr, 'Success'.tr),
                _buildInfoRow('Transaction ID:'.tr, 'TXN123456'.tr),
              ],
            ),
            const SizedBox(height: 32),

            // Download PDF Button
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Coming Soon'.tr)),
                );
              },
              icon: const Icon(Icons.file_download, color: Colors.white),
              label: Text(
                'DOWNLOAD PDF'.tr,
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
