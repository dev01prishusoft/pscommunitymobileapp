import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/core/localization/localization_service.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/features/samaj/domain/entities/samaj.dart';
import 'package:pscommunitymobileapp/features/samaj/presentation/controllers/samaj_controller.dart';
import 'package:pscommunitymobileapp/core/widgets/app_drawer.dart';

// ─── Data Model ───────────────────────────────────────────────────────────────

/// Represents a single home-screen grid item.
/// Using a data class keeps the grid builder free of repeated inline calls.
class _MenuItem {
  const _MenuItem({
    required this.icon,
    required this.labelKey,
    required this.route,
  });

  final IconData icon;
  final String labelKey; // translation key — call .tr at render time
  final String route;
}

/// Compile-time constant list — no repeated widget-tree calls.
const List<_MenuItem> _menuItems = [
  _MenuItem(icon: Icons.family_restroom,        labelKey: LK.family,              route: AppRouter.familyAreas),
  _MenuItem(icon: Icons.person_search,          labelKey: LK.findMember,          route: AppRouter.findMember),
  _MenuItem(icon: Icons.groups_outlined,        labelKey: LK.committee,           route: AppRouter.committees),
  _MenuItem(icon: Icons.account_balance_wallet, labelKey: LK.payment,             route: AppRouter.payments),
  _MenuItem(icon: Icons.work,                   labelKey: LK.occupationDirectory, route: AppRouter.occupationDirectory),
  _MenuItem(icon: Icons.wc,                     labelKey: LK.matrimonial,         route: AppRouter.marriage),
  _MenuItem(icon: Icons.share,                  labelKey: LK.share,               route: AppRouter.shareApp),
  _MenuItem(icon: Icons.info_outline,           labelKey: LK.samajInfo,           route: AppRouter.samajProfile),
];

/// Maps upper-case display code → [languageCode, countryCode] for changeLocale.
const Map<String, List<String>> _localeMap = {
  'EN': ['en', 'US'],
  'GU': ['gu', 'IN'],
};

// ─── Page ────────────────────────────────────────────────────────────────────

/// [StatefulWidget] so [_scaffoldKey] is created once and stays stable
/// across rebuilds. A [GlobalKey] inside a [StatelessWidget] is recreated
/// on every build, which can cause state loss.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.surfaceVariant,
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.navyBlue),
        actions: const [
          _LanguageDropdown(),
          SizedBox(width: 16),
        ],
      ),
      // Removed unnecessary Stack — SafeArea is the only child
      body: SafeArea(
        child: Column(
          children: [
            const _HomeHeader(),
            const SizedBox(height: 10),
            const Expanded(child: _HomeMenuGrid()),
          ],
        ),
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 24, right: 24),
      // Single Obx reads samaj once — no nested Obx
      child: Obx(() {
        final samaj = Get.find<SamajController>().samaj.value;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: _SamajNameText(samaj: samaj)),
            _SamajLogo(samaj: samaj),
          ],
        );
      }),
    );
  }
}

class _SamajNameText extends StatelessWidget {
  const _SamajNameText({required this.samaj});

  final Samaj? samaj;

  @override
  Widget build(BuildContext context) {
    return Text(
      samaj?.name ?? LK.samajName.tr,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w900,
        color: AppColors.navyBlue,
        letterSpacing: 0.2,
      ),
    );
  }
}

class _SamajLogo extends StatelessWidget {
  const _SamajLogo({required this.samaj});

  final Samaj? samaj;

  // Shared decoration extracted as a getter to avoid repetition
  static BoxDecoration get _containerDecoration => BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final logoUrl = samaj?.logoUrl;
    return Container(
      width: 80,
      height: 80,
      decoration: _containerDecoration,
      child: ClipOval(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: logoUrl != null && logoUrl.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: logoUrl,
                  fit: BoxFit.contain,
                  placeholder: (_, __) =>
                      const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  errorWidget: (_, __, ___) => _fallbackLogo(),
                )
              : _fallbackLogo(),
        ),
      ),
    );
  }

  Widget _fallbackLogo() =>
      Image.asset('assets/images/prishusoft_logo.png', fit: BoxFit.contain);
}

// ─── Grid ─────────────────────────────────────────────────────────────────────

class _HomeMenuGrid extends StatelessWidget {
  const _HomeMenuGrid();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        // LayoutBuilder for responsive column count
        child: LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth < 320 ? 2 : 3;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _menuItems.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemBuilder: (context, index) {
                final item = _menuItems[index];
                return _MenuCard(item: item);
              },
            );
          },
        ),
      ),
    );
  }
}

// ─── Menu Card ────────────────────────────────────────────────────────────────

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.item});

  final _MenuItem item;

  // Shared card decoration — defined once, reused by every card
  static const BoxDecoration _cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(16)),
  );

  // Shadow can't be const (withValues isn't const), so use a getter
  static BoxDecoration get cardDecorationWithShadow => _cardDecoration.copyWith(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed<void>(item.route),
      child: Container(
        decoration: cardDecorationWithShadow,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                color: AppColors.lightBlue,
                shape: BoxShape.circle,
              ),
              child: Icon(item.icon, size: 32, color: AppColors.navyBlue),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                item.labelKey.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.navyBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Language Dropdown ────────────────────────────────────────────────────────

class _LanguageDropdown extends StatelessWidget {
  const _LanguageDropdown();

  @override
  Widget build(BuildContext context) {
    final loc = Get.find<LocalizationService>();

    return Obx(() {
      // Use loc.currentLocale (reactive) instead of Get.locale (not reactive)
      final currentCode = loc.currentLocale.value.languageCode.toUpperCase();

      // Build code list from API result; fall back to hardcoded list if not yet loaded
      final List<String> codes = loc.languages.isNotEmpty
          ? loc.languages.map((l) => l.code.toUpperCase()).toSet().toList()
          : _localeMap.keys.toList();

      // Ensure current locale is always selectable
      if (!codes.contains(currentCode)) {
        codes.add(currentCode);
      }

      final selectedCode = codes.contains(currentCode) ? currentCode : codes.first;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedCode,
            icon: const Icon(Icons.language, color: AppColors.navyBlue, size: 18),
            style: const TextStyle(
              color: AppColors.navyBlue,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            items: codes
                .map((code) => DropdownMenuItem(value: code, child: Text(' $code')))
                .toList(),
            onChanged: (code) => _changeLocale(loc, code),
          ),
        ),
      );
    });
  }

  void _changeLocale(LocalizationService loc, String? code) {
    if (code == null) return;
    final parts = _localeMap[code];
    if (parts != null) {
      loc.changeLocale(parts[0], parts[1]);
    } else {
      // Unknown code — use lowercase with empty country
      loc.changeLocale(code.toLowerCase(), '');
    }
  }
}
