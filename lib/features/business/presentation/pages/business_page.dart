import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/features/business/presentation/controllers/business_controller.dart';
import 'package:pscommunitymobileapp/features/business/domain/entities/business_category.dart';

class BusinessPage extends StatefulWidget {
  const BusinessPage({super.key});

  @override
  State<BusinessPage> createState() => _BusinessPageState();
}

class _BusinessPageState extends State<BusinessPage> {
  final controller = Get.find<BusinessController>();

  @override
  void initState() {
    super.initState();
    controller.loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          LK.businessInfo.tr,
          style: AppTextStyles.headlineSmall.copyWith(color: AppColors.white),
        ),
        centerTitle: false,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back<void>(),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
      ),
      body: SafeArea(
        child: Obx(
          () => AppStateView(
            state: controller.state.value,
            onRetry: controller.loadCategories,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.9,
                ),
                itemCount: controller.categories.length,
                itemBuilder: (context, index) {
                  final category = controller.categories[index];
                  return _CategoryCard(category: category);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category});
  final BusinessCategory category;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed<void>(AppRouter.occupationDirectory),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIconData(category.iconKey),
                size: 40,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                category.title,
                textAlign: TextAlign.center,
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.foreground,
                  letterSpacing: 0.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String key) {
    switch (key) {
      case 'code':
        return Icons.code_rounded;
      case 'factory':
        return Icons.factory_rounded;
      case 'storefront':
        return Icons.storefront_rounded;
      case 'home_work':
        return Icons.home_work_rounded;
      case 'agriculture':
        return Icons.agriculture_rounded;
      case 'medical':
        return Icons.medical_services_rounded;
      default:
        return Icons.business_center_rounded;
    }
  }
}
