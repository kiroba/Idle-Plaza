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
      expect(plazaCompanionAssets, hasLength(20));
      final paths = plazaCompanionAssets.map((a) => a.assetPath).toSet();
      for (final a in plazaAnimals) {
        expect(paths, contains(a.stillAsset), reason: a.id);
      }
    });
  });
}
