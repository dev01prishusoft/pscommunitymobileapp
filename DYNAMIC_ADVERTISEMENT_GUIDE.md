# Dynamic Advertisement System Integration Guide

This guide covers all scenarios and examples for displaying advertisements (Top Banners, Bottom Banners, and In-List / In-Feed Ads) dynamically in **PS Community Mobile App**.

---

## 🚀 Overview & Key Features

1. **Backend Driven**: Screen advertisement settings (top banner, bottom banner, and in-list ad intervals) are driven dynamically by the API (`/api/v1/member/advertisements/screen-config`).
2. **Zero Layout Shift**: If a screen has no ads enabled or backend returns 0 active campaigns, widgets seamlessly collapse to `SizedBox.shrink()` or `regularSeparator`. No blank boxes or broken spaces.
3. **Single Slot Injection by Default**: In-list ads show **only once** at the specified index or interval position (e.g. after item 4) by default, and do not repeat unless `repeat: true` is explicitly passed.
4. **Auto-Prefetching**: As soon as a screen opens, `DynamicAdScaffold` eagerly prefetches placement ads in the background so that ads are ready in memory by the time the user scrolls.
5. **Dynamic Fallbacks & Aliases**: Supports automatic fallback aliases (e.g., `find-member` <-> `member-directory`, `marriage` <-> `matrimonial-directory`, `events` <-> `event-list`, etc.).

---

## 📌 Scenario 1: Screen with Dynamic Top / Bottom Banners (`DynamicAdScaffold`)

Replace Flutter's standard `Scaffold` with `DynamicAdScaffold` and supply the screen's `route`. Top and bottom banners are automatically controlled by the backend config.

```dart
import 'package:flutter/material.dart';
import 'package:pscommunitymobileapp/core/constants/app_router.dart';
import 'package:pscommunitymobileapp/features/advertisement/widgets/dynamic_ad_scaffold.dart';

class MySamplePage extends StatelessWidget {
  const MySamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicAdScaffold(
      route: AppRouter.mySampleRoute, // E.g. '/my-sample'
      appBar: AppBar(
        title: const Text('My Screen Title'),
      ),
      body: Center(
        child: Text('Screen Content'),
      ),
    );
  }
}
```

### Optional Props:
- `disableTopAd: true` — Suppresses the top banner for this screen even if enabled in backend.
- `disableBottomAd: true` — Suppresses the bottom banner for this screen even if enabled in backend.
- Keyboard auto-detection: The bottom banner automatically hides when the on-screen keyboard opens.

---

## 📌 Scenario 2: Paginated List with In-Feed Ad (`PaginatedListView`)

If your screen uses `PaginatedListView`, simply pass the `route` property. The ad slot will be automatically injected at the position configured in the backend.

```dart
import 'package:flutter/material.dart';
import 'package:pscommunitymobileapp/core/constants/app_router.dart';
import 'package:pscommunitymobileapp/core/widgets/paginated_list_view.dart';
import 'package:pscommunitymobileapp/features/advertisement/widgets/dynamic_ad_scaffold.dart';

class MyMemberDirectoryPage extends StatelessWidget {
  const MyMemberDirectoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicAdScaffold(
      route: AppRouter.findMember,
      appBar: AppBar(title: const Text('Member Directory')),
      body: PaginatedListView<Member, FindMemberController>(
        route: AppRouter.findMember, // Links with backend in-list config
        padding: const EdgeInsets.all(16.0),
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index, member) => MemberCard(member: member),
      ),
    );
  }
}
```

### Optional Overrides in `PaginatedListView`:
- `adIndex: 3` — Explicitly target a 0-based index instead of backend config.
- `adInterval: 4` — Override backend interval for this list.
- `repeatAds: true` — Repeat the ad every interval instead of showing only once.

---

## 📌 Scenario 3: Standard Drop-in List Replacement (`DynamicAdListView.builder`)

Use `DynamicAdListView.builder` as a direct drop-in replacement for standard `ListView.builder`.

```dart
import 'package:flutter/material.dart';
import 'package:pscommunitymobileapp/core/constants/app_router.dart';
import 'package:pscommunitymobileapp/features/advertisement/widgets/dynamic_ad_list_view.dart';

class MyItemListPage extends StatelessWidget {
  final List<Item> items;
  const MyItemListPage({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return DynamicAdListView.builder(
      route: AppRouter.mySampleRoute,
      itemCount: items.length,
      itemBuilder: (context, index) => ItemCard(item: items[index]),
      separatorBuilder: (context, index) => const SizedBox(height: 8),
    );
  }
}
```

### Optional Overrides in `DynamicAdListView.builder`:
```dart
DynamicAdListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemCard(item: items[index]),
  adIndex: 2,           // Force ad to show after index 2
  adInterval: 4,        // Or set custom interval
  repeatAds: false,     // Default is false (single placement)
  placementCode: 'custom-feed-slot',
)
```

---

## 📌 Scenario 4: Standard `ListView.separated` using `DynamicAdSeparator`

If you are using a standard Flutter `ListView.separated`, simply wrap your regular separator with `DynamicAdSeparator`:

```dart
import 'package:flutter/material.dart';
import 'package:pscommunitymobileapp/core/constants/app_router.dart';
import 'package:pscommunitymobileapp/features/advertisement/widgets/dynamic_ad_separator.dart';

ListView.separated(
  itemCount: items.length,
  padding: const EdgeInsets.all(16),
  itemBuilder: (context, index) => MyCardWidget(items[index]),
  separatorBuilder: (context, index) => DynamicAdSeparator(
    index: index,
    route: AppRouter.events, // Reads in-list config for '/events'
    regularSeparator: const SizedBox(height: 12),
  ),
)
```

---

## 📌 Scenario 5: Slivers & Custom Scroll Views (`SliverList.separated`)

For complex screens with sticky filters or `CustomScrollView` (like Matrimonial/Marriage screen):

```dart
import 'package:flutter/material.dart';
import 'package:pscommunitymobileapp/core/constants/app_router.dart';
import 'package:pscommunitymobileapp/features/advertisement/widgets/dynamic_ad_separator.dart';

CustomScrollView(
  slivers: [
    SliverToBoxAdapter(child: FilterHeaderWidget()),
    SliverList.separated(
      itemCount: items.length,
      separatorBuilder: (context, index) => DynamicAdSeparator(
        route: AppRouter.marriage,
        index: index,
        regularSeparator: const SizedBox(height: 6),
      ),
      itemBuilder: (context, index) => MarriageProfileCard(items[index]),
    ),
  ],
)
```

---

## 📌 Scenario 6: Standalone Ad Card / Banner Anywhere (`SmartAdWidget`)

To display an ad card anywhere in the UI (e.g. inside a drawer, popup, dashboard widget, or footer):

```dart
import 'package:flutter/material.dart';
import 'package:pscommunitymobileapp/features/advertisement/widgets/advertisement_card.dart';
import 'package:pscommunitymobileapp/features/advertisement/widgets/smart_ad_widget.dart';

// Auto-detects screen route name:
const SmartAdWidget()

// With a specific placement code:
const SmartAdWidget(
  placementCode: 'home-top',
  layout: AdLayout.banner, // Options: AdLayout.banner, AdLayout.card
)

// In-feed card style with custom padding:
const SmartAdWidget(
  placementCode: 'my-custom-slot',
  layout: AdLayout.card,
  height: 120,
  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
)
```

---

## ⚙️ Backend API Response Reference

The dynamic system reads configuration from `/api/v1/member/advertisements/screen-config`.

### Example Backend Response:
```json
{
  "isGloballyEnabled": true,
  "defaultInListInterval": 4,
  "screens": [
    {
      "route": "/home",
      "screenName": "Home Screen",
      "topBanner": { "enabled": true, "placementCode": "home-top" },
      "bottomBanner": { "enabled": true, "placementCode": "home-bottom" },
      "inList": { "enabled": false, "interval": 0, "placementCode": null }
    },
    {
      "route": "/find-member",
      "screenName": "Member Directory",
      "topBanner": { "enabled": false, "placementCode": null },
      "bottomBanner": { "enabled": false, "placementCode": null },
      "inList": { "enabled": true, "interval": 4, "placementCode": "find-member" }
    },
    {
      "route": "/marriage",
      "screenName": "Matrimonial Directory",
      "topBanner": { "enabled": false, "placementCode": null },
      "bottomBanner": { "enabled": false, "placementCode": null },
      "inList": { "enabled": true, "interval": 3, "placementCode": "marriage" }
    }
  ]
}
```

---

## 🧪 Verification & Testing

To run the automated dynamic advertisement system test suite:

```bash
flutter test test/unit/advertisement_dynamic_system_test.dart
```

To run static analysis:
```bash
flutter analyze
```

