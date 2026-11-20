import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:idle_plaza/src/plaza_foundations.dart';

void main() {
  group('Plaza foundations catalog', () {
    test('is non-empty and covers every section list', () {
      expect(plazaFoundationAssets, isNotEmpty);
      expect(
          plazaFoundationAssets.length,
          1 +
              plazaFigureAssets.length +
              plazaCompanionAssets.length +
              plazaSceneryAssets.length);
      expect(plazaFoundationAssets.first, plazaSceneAsset);
    });

    test('ids are unique', () {
      final ids = plazaFoundationAssets.map((a) => a.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('every asset path lives under assets/plaza/ and is a png or jpg', () {
      for (final a in plazaFoundationAssets) {
        expect(a.assetPath, startsWith('assets/plaza/'), reason: a.id);
        expect(a.assetPath.endsWith('.png') || a.assetPath.endsWith('.jpg'),
            isTrue,
            reason: a.id);
      }
    });

    test('categories cover scene, figure, companion and scenery', () {
      final cats = plazaFoundationAssets.map((a) => a.category).toSet();
      expect(cats, containsAll(PlazaFoundationCategory.values));
      expect(plazaSceneAsset.category, PlazaFoundationCategory.scene);
      for (final a in plazaFigureAssets) {
        expect(a.category, PlazaFoundationCategory.figure);
      }
      for (final a in plazaCompanionAssets) {
        expect(a.category, PlazaFoundationCategory.companion);
      }
      for (final a in plazaSceneryAssets) {
        expect(a.category, PlazaFoundationCategory.scenery);
      }
    });

    test('every referenced asset file exists on disk', () {
      for (final a in plazaFoundationAssets) {
        expect(File(a.assetPath).existsSync(), isTrue,
            reason: '${a.id} -> ${a.assetPath}');
      }
    });

    test('every entry has a name and an honest note', () {
      for (final a in plazaFoundationAssets) {
        expect(a.name, isNotEmpty, reason: a.id);
        expect(a.note, isNotEmpty, reason: a.id);
      }
    });
  });

  group('Live stage roster', () {
    test('scene entry is the no-animals backdrop and the file exists', () {
      expect(plazaSceneAsset.id, 'scene-backdrop');
      expect(plazaSceneAsset.assetPath, 'assets/plaza/scene_backdrop.jpg');
      expect(File(plazaSceneAsset.assetPath).existsSync(), isTrue);
    });

    test('roster has 10 unique animals', () {
      expect(plazaAnimals, hasLength(10));
      final ids = plazaAnimals.map((a) => a.id).toList();
      expect(ids.toSet(), hasLength(ids.length));
    });

    test('every animal still and every idle frame exists on disk', () {
      for (final a in plazaAnimals) {
        expect(File(a.stillAsset).existsSync(), isTrue,
            reason: '${a.id} still -> ${a.stillAsset}');
        expect(a.idleFrames, hasLength(plazaIdleFrameCount), reason: a.id);
        for (final f in a.idleFrames) {
          expect(File(f).existsSync(), isTrue, reason: '${a.id} -> $f');
        }
      }
    });

    test('spots are fractions within the backdrop square', () {
      for (final a in plazaAnimals) {
        expect(a.spotDx, inInclusiveRange(0.0, 1.0), reason: a.id);
        expect(a.spotDy, inInclusiveRange(0.0, 1.0), reason: a.id);
        expect(a.spotWidth, inInclusiveRange(0.0, 1.0), reason: a.id);
      }
    });

    test('companion catalog covers all 10 animals (sets #1 + #2)', () {
      // 20 land-animal stills + 6 fish stills (set #3) = 26.
      expect(plazaCompanionAssets, hasLength(26));
      final paths = plazaCompanionAssets.map((a) => a.assetPath).toSet();
      for (final a in plazaAnimals) {
        expect(paths, contains(a.stillAsset), reason: a.id);
      }
      for (final f in plazaFish) {
        expect(paths, contains(f.stillAsset), reason: f.id);
      }
    });

    test('every animal move frame exists on disk', () {
      for (final a in plazaAnimals) {
        expect(a.moveFrames, hasLength(plazaMoveFrameCount), reason: a.id);
        for (final f in a.moveFrames) {
          expect(File(f).existsSync(), isTrue, reason: '${a.id} -> $f');
        }
      }
    });

    test('fly frames exist exactly for the birds; kind agrees', () {
      for (final a in plazaAnimals) {
        if (plazaBirdIds.contains(a.id)) {
          expect(a.kind, PlazaAnimalKind.bird, reason: a.id);
          expect(a.flyFrames, isNotNull, reason: a.id);
          expect(a.flyFrames, hasLength(plazaFlyFrameCount), reason: a.id);
          for (final f in a.flyFrames!) {
            expect(File(f).existsSync(), isTrue, reason: '${a.id} -> $f');
          }
        } else {
          expect(a.kind, PlazaAnimalKind.land, reason: a.id);
          expect(a.flyFrames, isNull, reason: a.id);
        }
      }
      // The bird set is exactly songbird, owl, duck, crow.
      expect(plazaAnimals.where((a) => a.kind == PlazaAnimalKind.bird).length,
          4);
    });
  });

  group('Pond + fish', () {
    test('fish roster has 3 unique species', () {
      expect(plazaFish, hasLength(3));
      final ids = plazaFish.map((f) => f.id).toList();
      expect(ids.toSet(), hasLength(ids.length));
      expect(ids.toSet(), {'koi', 'goldfish', 'bluefish'});
    });

    test('every fish still and swim frame exists on disk', () {
      for (final f in plazaFish) {
        expect(File(f.stillAsset).existsSync(), isTrue,
            reason: '${f.id} still -> ${f.stillAsset}');
        expect(f.swimFrames, hasLength(plazaSwimFrameCount), reason: f.id);
        for (final path in f.swimFrames) {
          expect(File(path).existsSync(), isTrue, reason: '${f.id} -> $path');
        }
        expect(f.widthFraction, inInclusiveRange(0.0, 1.0), reason: f.id);
      }
    });

    test('pond asset exists and is in the scenery catalog', () {
      expect(plazaPondAsset.assetPath, 'assets/plaza/pond_top_down.png');
      expect(File(plazaPondAsset.assetPath).existsSync(), isTrue);
      expect(plazaSceneryAssets, contains(plazaPondAsset));
      expect(plazaFoundationAssets, contains(plazaPondAsset));
    });

    test('pond constants are backdrop fractions within the square', () {
      final p = plazaPond;
      for (final v in [
        p.layerLeft,
        p.layerTop,
        p.layerWidth,
        p.layerHeight,
        p.waterDx,
        p.waterDy,
        p.usableRx,
        p.usableRy,
        p.waterRx,
        p.waterRy,
      ]) {
        expect(v, inInclusiveRange(0.0, 1.0));
      }
      // The layer rect stays on the stage…
      expect(p.layerLeft + p.layerWidth, lessThanOrEqualTo(1.0));
      expect(p.layerTop + p.layerHeight, lessThanOrEqualTo(1.0));
      // …the water centre sits inside it…
      expect(p.waterDx, inInclusiveRange(p.layerLeft, p.layerLeft + p.layerWidth));
      expect(p.waterDy, inInclusiveRange(p.layerTop, p.layerTop + p.layerHeight));
      // …and the fish-safe ellipse is inside the physical water.
      expect(p.usableRx, lessThan(p.waterRx));
      expect(p.usableRy, lessThan(p.waterRy));
    });
  });
}
