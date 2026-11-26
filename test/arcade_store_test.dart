import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:idle_plaza/src/arcade_scene_image.dart';
import 'package:idle_plaza/src/arcade_store.dart';

void main() {
  group('Arcade storefront', () {
    test('is the Plaza\'s first store, on the ground level', () {
      expect(arcadeStorefront.name, 'The Arcade');
      expect(arcadeStorefront.placement, contains('Ground level'));
      expect(arcadeStorefront.placement, contains('Avenue 1'));
      expect(arcadeStorefront.placement, contains('Storefront A'));
    });

    test('cabinets stand Brawler first, 9x9 second', () {
      expect(arcadeStorefront.cabinets, isNotEmpty);
      expect(arcadeStorefront.firstCabinet.id, 'brawler');
      expect(arcadeStorefront.cabinets[1].id, 'nine-by-nine');
      expect(arcadeStorefront.cabinets[0].status,
          ArcadeCabinetStatus.playable);
      expect(arcadeStorefront.cabinets[1].status,
          ArcadeCabinetStatus.inDesign);
    });

    test('cabinet ids are unique and every cabinet is honest', () {
      final ids = arcadeStorefront.cabinets.map((c) => c.id).toList();
      expect(ids.toSet().length, ids.length);
      for (final c in arcadeStorefront.cabinets) {
        expect(c.name, isNotEmpty, reason: c.id);
        expect(c.tagline, isNotEmpty, reason: c.id);
        expect(c.details, isNotEmpty, reason: c.id);
        expect(c.status.label, isNotEmpty, reason: c.id);
      }
    });

    test('the embedded storefront scene decodes to a JPEG', () {
      final bytes = base64Decode(arcadeStorefrontJpegBase64);
      expect(bytes.length, 80743);
      // JPEG start/end markers.
      expect(bytes.sublist(0, 2), [0xFF, 0xD8]);
      expect(bytes.sublist(bytes.length - 2), [0xFF, 0xD9]);
    });

    test('the Brawler cabinet is playable and says where the game runs', () {
      final brawler =
          arcadeStorefront.cabinets.firstWhere((c) => c.id == 'brawler');
      expect(brawler.details.join(' '), contains('Brawler app build'));
      expect(brawler.details.join(' '), contains('Ophiuchus'));
    });
  });

  group('Brawler roster', () {
    test('has 12 unique zodiac fighters, three per element', () {
      expect(brawlerFighters, hasLength(12));
      final signs = brawlerFighters.map((f) => f.sign).toList();
      expect(signs.toSet().length, signs.length);
      for (final element in BrawlerElement.values) {
        expect(brawlerFighters.where((f) => f.element == element).length, 3,
            reason: element.label);
      }
    });

    test('the boss is Ophiuchus, the 13th sign', () {
      expect(brawlerBossSign, 'Ophiuchus');
      expect(brawlerFighters.map((f) => f.sign), isNot(contains('Ophiuchus')));
    });
  });

  group('9x9 design numbers', () {
    test('structure, shells and heart rooms match the ruled design', () {
      expect(NineByNineDesign.structurePerSide, 13);
      expect(NineByNineDesign.shellCount, 7);
      expect(NineByNineDesign.heartRoomCount, 4);
      expect(NineByNineDesign.escapeRule, 'Holdout');
      expect(NineByNineDesign.modes,
          ['Solo', 'Duos', 'Trios', '4-team survival']);
      expect(NineByNineDesign.runFlowBeats,
          ['Waking', 'Descent', 'Learning', 'Deep', 'Heart', 'Leaving']);
    });
  });
}
