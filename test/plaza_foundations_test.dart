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
}
