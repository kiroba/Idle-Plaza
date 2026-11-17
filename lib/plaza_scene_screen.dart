import 'package:flutter/material.dart';

import 'src/plaza_foundations.dart';

/// ============================================================================
/// PLAZA FOUNDATIONS SCREEN
/// ============================================================================
/// Shows the low-poly Plaza foundations slice exactly as it exists today:
/// baked renders and sprites from the character pipeline, shipped as app
/// assets. This is NOT a live 3D view — the app has no 3D display path, and
/// the caption on the scene says so. Data comes from the pure-Dart catalog
/// in src/plaza_foundations.dart.
/// ============================================================================

class PlazaSceneScreen extends StatelessWidget {
  const PlazaSceneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        title: const Text('Plaza Foundations',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: const Color(0xFF16162A),
        elevation: 2,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSceneCard(),
          const SizedBox(height: 20),
          _buildSection('Figures — Base #3 Soft', plazaFigureAssets),
          const SizedBox(height: 20),
          _buildSection('Companions — Set #1', plazaCompanionAssets),
          const SizedBox(height: 20),
          _buildSection('Scenery — Set #1 Pieces', plazaSceneryAssets),
        ],
      ),
    );
  }

  Widget _buildSceneCard() {
    return Card(
      color: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _assetImage(plazaSceneAsset, fit: BoxFit.cover, height: 260),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('The Plaza, baked',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                SizedBox(height: 6),
                Text(
                  'This is a baked render of the Plaza foundations — storefronts, billboard, trees and a Halo for scale — '
                  'rendered offline from the low-poly models. It is not a live 3D view; the pieces below are the same '
                  'foundations as individual renders and sprites.',
                  style:
                      TextStyle(color: Colors.grey, fontSize: 12, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<PlazaFoundationAsset> assets) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.82,
          children: [for (final a in assets) _buildAssetCard(a)],
        ),
      ],
    );
  }

  Widget _buildAssetCard(PlazaFoundationAsset asset) {
    return Card(
      color: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: SizedBox(
                  width: double.infinity,
                  child: _assetImage(asset, fit: BoxFit.contain))),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(asset.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 4),
                Text(asset.note,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _assetImage(PlazaFoundationAsset asset,
      {required BoxFit fit, double? height}) {
    return Image.asset(
      asset.assetPath,
      fit: fit,
      height: height,
      errorBuilder: (context, error, stackTrace) => Container(
        height: height,
        color: const Color(0xFF1A1A2E),
        alignment: Alignment.center,
        child: const Icon(Icons.broken_image_outlined,
            color: Colors.grey, size: 32),
      ),
    );
  }
}
