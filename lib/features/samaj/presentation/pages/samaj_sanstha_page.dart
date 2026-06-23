import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/widgets/paginated_list_view.dart';
import 'package:pscommunitymobileapp/features/samaj/domain/entities/samaj_sanstha.dart';
import 'package:pscommunitymobileapp/features/samaj/presentation/controllers/samaj_sanstha_controller.dart';

class SamajSansthaPage extends StatefulWidget {
  const SamajSansthaPage({super.key});

  @override
  State<SamajSansthaPage> createState() => _SamajSansthaPageState();
}

class _SamajSansthaPageState extends State<SamajSansthaPage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      appBar: AppBar(title: Text(LK.samajSansthas.tr)),
      body: PaginatedListView<SamajSanstha, SamajSansthaController>(
        emptyMessage: 'No items found',
        itemBuilder: (context, index, sanstha) => _buildSansthaCard(sanstha),
      ),
    );
  }

  Widget _buildSansthaCard(SamajSanstha sanstha) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        title: Text(
          sanstha.name,
          style: AppTextStyles.titleLarge.copyWith(color: AppColors.secondary),
        ),
        subtitle: sanstha.description.isNotEmpty 
            ? Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  sanstha.description,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.mutedForeground),
                ),
              ) 
            : null,
      ),
    );
  }
}
