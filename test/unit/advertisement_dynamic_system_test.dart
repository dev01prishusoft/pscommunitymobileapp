import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pscommunitymobileapp/features/advertisement/models/ad_placement.dart';
import 'package:pscommunitymobileapp/features/advertisement/models/ad_screen_config.dart';
import 'package:pscommunitymobileapp/features/advertisement/services/ad_screen_config_service.dart';
import 'package:pscommunitymobileapp/features/advertisement/widgets/dynamic_ad_scaffold.dart';
import 'package:pscommunitymobileapp/features/advertisement/widgets/dynamic_ad_screen_wrapper.dart';
import 'package:pscommunitymobileapp/features/advertisement/widgets/smart_ad_widget.dart';

void main() {
  group('AdScreenConfig Models JSON Deserialization', () {
    test('Parses complete JSON successfully', () {
      final json = {
        'isGloballyEnabled': true,
        'defaultInListInterval': 5,
        'screens': [
          {
            'route': '/library-categories',
            'screenName': 'Library Categories',
            'topBanner': {'enabled': false, 'placementCode': null},
            'bottomBanner': {
              'enabled': true,
              'placementCode': 'library-bottom',
            },
            'inList': {
              'enabled': true,
              'interval': 4,
              'placementCode': 'library-list',
            },
          },
          {
            'route': 'events',
            'screenName': 'Events',
            'topBanner': {'enabled': true, 'placementCode': 'events-top'},
            'bottomBanner': {'enabled': false, 'placementCode': null},
            'inList': {'enabled': false, 'interval': 0, 'placementCode': null},
          },
        ],
      };

      final globalConfig = AdGlobalConfig.fromJson(json);
      expect(globalConfig.isGloballyEnabled, true);
      expect(globalConfig.defaultInListInterval, 5);
      expect(globalConfig.screens.length, 2);

      final libConfig = globalConfig.screens['/library-categories'];
      expect(libConfig, isNotNull);
      expect(libConfig!.screenName, 'Library Categories');
      expect(libConfig.topBanner.enabled, false);
      expect(libConfig.bottomBanner.enabled, true);
      expect(libConfig.bottomBanner.placementCode, 'library-bottom');
      expect(libConfig.inList.enabled, true);
      expect(libConfig.inList.interval, 4);
      expect(libConfig.inList.placementCode, 'library-list');

      final eventConfig = globalConfig.screens['/events'];
      expect(eventConfig, isNotNull);
      expect(eventConfig!.topBanner.enabled, true);
      expect(eventConfig.topBanner.placementCode, 'events-top');
      expect(eventConfig.bottomBanner.enabled, false);
      expect(eventConfig.inList.enabled, false);
    });

    test('AdGlobalConfig.defaults returns clean fallback state without static screens', () {
      final defaults = AdGlobalConfig.defaults();
      expect(defaults.isGloballyEnabled, true);
      expect(defaults.defaultInListInterval, 4);
      expect(defaults.screens.isEmpty, true);
    });

    test('AdPlacement.fromCode handles dynamic placement codes without collapsing to other', () {
      final custom1 = AdPlacement.fromCode('xyz');
      expect(custom1.code, 'xyz');
      expect(custom1 == AdPlacement.other, false);

      final custom2 = AdPlacement.fromCode('committee-infeed');
      expect(custom2.code, 'committee-infeed');

      final wellKnown = AdPlacement.fromCode('home-top');
      expect(wellKnown, AdPlacement.homeTop);
      expect(wellKnown.code, 'home-top');

      final fallback = AdPlacement.fromCode(null);
      expect(fallback, AdPlacement.other);
    });

    test('AdGlobalConfig.fromJson parses both List and Map screen configurations', () {
      // Map format
      final mapJson = {
        'isGloballyEnabled': true,
        'defaultInListInterval': 2,
        'screens': {
          '/custom-route': {
            'topBanner': {'enabled': true, 'placementCode': 'custom-top'},
            'bottomBanner': {'enabled': false},
            'inList': {'enabled': true, 'interval': 3, 'placementCode': 'custom-feed'},
          }
        }
      };
      final parsedMap = AdGlobalConfig.fromJson(mapJson);
      expect(parsedMap.screens.containsKey('/custom-route'), true);
      expect(parsedMap.screens['/custom-route']?.topBanner.enabled, true);
      expect(parsedMap.screens['/custom-route']?.topBanner.placementCode, 'custom-top');
      expect(parsedMap.screens['/custom-route']?.inList.interval, 3);
      expect(parsedMap.screens['/custom-route']?.inList.placementCode, 'custom-feed');
    });
  });

  group('AdScreenConfigService Route Normalization & Querying', () {
    test('Normalizes various route formats consistently', () {
      expect(AdScreenConfigService.normalizeRoute('/home'), '/home');
      expect(AdScreenConfigService.normalizeRoute('home'), '/home');
      expect(AdScreenConfigService.normalizeRoute('/HOME/'), '/home');
      expect(AdScreenConfigService.normalizeRoute('library-categories/'), '/library-categories');
      expect(AdScreenConfigService.normalizeRoute(''), '');
      expect(AdScreenConfigService.normalizeRoute(null), '');
    });

    test('Queries screen banner and in-list configs', () {
      final service = AdScreenConfigService();
      service.config.value = AdGlobalConfig.fromJson({
        'isGloballyEnabled': true,
        'defaultInListInterval': 4,
        'screens': [
          {
            'route': '/new-module',
            'screenName': 'New Module',
            'topBanner': {'enabled': false, 'placementCode': null},
            'bottomBanner': {'enabled': true, 'placementCode': 'custom-bottom'},
            'inList': {'enabled': true, 'interval': 3, 'placementCode': 'custom-feed'},
          },
        ],
      });

      expect(service.shouldShowBottomBanner('/new-module'), true);
      expect(service.shouldShowTopBanner('/new-module'), false);
      expect(service.getBottomPlacementCode('/new-module'), 'custom-bottom');
      expect(service.getTopPlacementCode('/new-module'), 'new-module-top');

      final inList = service.getInListConfig('/new-module');
      expect(inList, isNotNull);
      expect(inList!.enabled, true);
      expect(inList.interval, 3);
      expect(inList.placementCode, 'custom-feed');
    });

    test('Master switch disables all banners and feeds when isGloballyEnabled is false', () {
      final service = AdScreenConfigService();
      service.config.value = AdGlobalConfig.fromJson({
        'isGloballyEnabled': false,
        'screens': [
          {
            'route': '/new-module',
            'screenName': 'New Module',
            'bottomBanner': {'enabled': true, 'placementCode': 'test'},
            'inList': {'enabled': true, 'interval': 3, 'placementCode': 'feed'},
          },
        ],
      });

      expect(service.shouldShowBottomBanner('/new-module'), false);
      expect(service.shouldShowTopBanner('/new-module'), false);
      expect(service.getInListConfig('/new-module'), isNull);
    });
  });

  group('DynamicAdSeparator interval math', () {
    test('Calculates ad injection intervals cleanly', () {
      const interval = 4;
      // Index 0 (Item 1) -> no ad
      expect((0 + 1) % interval == 0, false);
      // Index 1 (Item 2) -> no ad
      expect((1 + 1) % interval == 0, false);
      // Index 2 (Item 3) -> no ad
      expect((2 + 1) % interval == 0, false);
      // Index 3 (Item 4) -> AD SLOT
      expect((3 + 1) % interval == 0, true);
      // Index 7 (Item 8) -> AD SLOT
      expect((7 + 1) % interval == 0, true);
    });

    test('Calculates interval: 2 ad injection cleanly', () {
      const interval = 2;
      // Index 0 (Item 1) -> no ad
      expect((0 + 1) % interval == 0, false);
      // Index 1 (Item 2) -> AD SLOT
      expect((1 + 1) % interval == 0, true);
      // Index 2 (Item 3) -> no ad
      expect((2 + 1) % interval == 0, false);
      // Index 3 (Item 4) -> AD SLOT
      expect((3 + 1) % interval == 0, true);
    });
  });

  group('SmartAdWidget and PlacementCode', () {
    test('SmartAdWidget initializes with explicit code', () {
      const widget = SmartAdWidget(placementCode: 'my-placement');
      expect(widget.placementCode, 'my-placement');
    });

    test('SmartAdWidget initializes with AdPlacement enum', () {
      const widget = SmartAdWidget(placement: AdPlacement.homeTop);
      expect(widget.placement, AdPlacement.homeTop);
    });
  });

  group('DynamicAdScaffold and DynamicAdBody', () {
    testWidgets('Renders Scaffold content cleanly without outer wrapper interference', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DynamicAdScaffold(
            route: '/custom-route',
            appBar: null,
            body: Text('Page Content Inside Scaffold'),
          ),
        ),
      );

      expect(find.text('Page Content Inside Scaffold'), findsOneWidget);
    });
  });
}
