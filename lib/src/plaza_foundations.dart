/// ============================================================================
/// PLAZA FOUNDATIONS CATALOG (pure Dart — no Flutter imports)
/// ============================================================================
/// The low-poly Plaza foundations slice: the composed Plaza scene, the kept
/// base #3 "soft" figure sprites, companion set #1 sprites, and the scenery
/// set #1 pieces. Every entry is a baked render or sprite PNG/JPG shipped in
/// assets/plaza/ — there is no live 3D in the app, and this catalog does not
/// pretend otherwise. PlazaSceneScreen renders exactly what is listed here.
/// ============================================================================

enum PlazaFoundationCategory { scene, figure, companion, scenery }

class PlazaFoundationAsset {
  final String id;
  final String name;
  final String assetPath;
  final PlazaFoundationCategory category;
  final String note;

  const PlazaFoundationAsset({
    required this.id,
    required this.name,
    required this.assetPath,
    required this.category,
    required this.note,
  });
}

const String _dir = 'assets/plaza';

/// The one composed scene render: scenery set #1 + figures, baked offline.
const PlazaFoundationAsset plazaSceneAsset = PlazaFoundationAsset(
  id: 'scene-three-quarter',
  name: 'Plaza Scene',
  assetPath: '$_dir/scene_three_quarter.jpg',
  category: PlazaFoundationCategory.scene,
  note: 'Baked three-quarter render of the composed Plaza — not live 3D.',
);

/// Figure base #3 "soft" (the kept consensus base) — 128px sprites.
const List<PlazaFoundationAsset> plazaFigureAssets = [
  PlazaFoundationAsset(
    id: 'figure-male-03-front',
    name: 'Male Base #3 — Front',
    assetPath: '$_dir/lowpoly-male-03_front.png',
    category: PlazaFoundationCategory.figure,
    note: 'Low-poly soft base #3, front sprite.',
  ),
  PlazaFoundationAsset(
    id: 'figure-male-03-three-quarter',
    name: 'Male Base #3 — Three-Quarter',
    assetPath: '$_dir/lowpoly-male-03_three_quarter.png',
    category: PlazaFoundationCategory.figure,
    note: 'Low-poly soft base #3, three-quarter sprite.',
  ),
  PlazaFoundationAsset(
    id: 'figure-female-03-front',
    name: 'Female Base #3 — Front',
    assetPath: '$_dir/lowpoly-female-03_front.png',
    category: PlazaFoundationCategory.figure,
    note: 'Low-poly soft base #3, front sprite.',
  ),
  PlazaFoundationAsset(
    id: 'figure-female-03-three-quarter',
    name: 'Female Base #3 — Three-Quarter',
    assetPath: '$_dir/lowpoly-female-03_three_quarter.png',
    category: PlazaFoundationCategory.figure,
    note: 'Low-poly soft base #3, three-quarter sprite.',
  ),
];

/// Companion set #1 — 128px sprites, soft low-poly matching base #3.
const List<PlazaFoundationAsset> plazaCompanionAssets = [
  PlazaFoundationAsset(
    id: 'companion-fox-front',
    name: 'Fox — Front',
    assetPath: '$_dir/companion-fox-01_front.png',
    category: PlazaFoundationCategory.companion,
    note: 'Companion set #1 fox, front sprite.',
  ),
  PlazaFoundationAsset(
    id: 'companion-fox-three-quarter',
    name: 'Fox — Three-Quarter',
    assetPath: '$_dir/companion-fox-01_three_quarter.png',
    category: PlazaFoundationCategory.companion,
    note: 'Companion set #1 fox, three-quarter sprite.',
  ),
  PlazaFoundationAsset(
    id: 'companion-dog-front',
    name: 'Dog — Front',
    assetPath: '$_dir/companion-dog-01_front.png',
    category: PlazaFoundationCategory.companion,
    note: 'Companion set #1 dog, front sprite.',
  ),
  PlazaFoundationAsset(
    id: 'companion-dog-three-quarter',
    name: 'Dog — Three-Quarter',
    assetPath: '$_dir/companion-dog-01_three_quarter.png',
    category: PlazaFoundationCategory.companion,
    note: 'Companion set #1 dog, three-quarter sprite.',
  ),
  PlazaFoundationAsset(
    id: 'companion-cat-front',
    name: 'Cat — Front',
    assetPath: '$_dir/companion-cat-01_front.png',
    category: PlazaFoundationCategory.companion,
    note: 'Companion set #1 cat, front sprite.',
  ),
  PlazaFoundationAsset(
    id: 'companion-cat-three-quarter',
    name: 'Cat — Three-Quarter',
    assetPath: '$_dir/companion-cat-01_three_quarter.png',
    category: PlazaFoundationCategory.companion,
    note: 'Companion set #1 cat, three-quarter sprite.',
  ),
  PlazaFoundationAsset(
    id: 'companion-songbird-front',
    name: 'Songbird — Front',
    assetPath: '$_dir/companion-songbird-01_front.png',
    category: PlazaFoundationCategory.companion,
    note: 'Companion set #1 songbird, front sprite.',
  ),
  PlazaFoundationAsset(
    id: 'companion-songbird-three-quarter',
    name: 'Songbird — Three-Quarter',
    assetPath: '$_dir/companion-songbird-01_three_quarter.png',
    category: PlazaFoundationCategory.companion,
    note: 'Companion set #1 songbird, three-quarter sprite.',
  ),
  PlazaFoundationAsset(
    id: 'companion-owl-front',
    name: 'Owl — Front',
    assetPath: '$_dir/companion-owl-01_front.png',
    category: PlazaFoundationCategory.companion,
    note: 'Companion set #1 owl, front sprite.',
  ),
  PlazaFoundationAsset(
    id: 'companion-owl-three-quarter',
    name: 'Owl — Three-Quarter',
    assetPath: '$_dir/companion-owl-01_three_quarter.png',
    category: PlazaFoundationCategory.companion,
    note: 'Companion set #1 owl, three-quarter sprite.',
  ),
];

/// Scenery set #1 pieces — three-quarter baked renders (512px, JPG).
const List<PlazaFoundationAsset> plazaSceneryAssets = [
  PlazaFoundationAsset(
    id: 'scenery-storefront-a',
    name: 'Storefront A',
    assetPath: '$_dir/storefront-a_three_quarter.jpg',
    category: PlazaFoundationCategory.scenery,
    note: 'Café/glass storefront shell, equal 6.0×5.0 footprint.',
  ),
  PlazaFoundationAsset(
    id: 'scenery-storefront-b',
    name: 'Storefront B',
    assetPath: '$_dir/storefront-b_three_quarter.jpg',
    category: PlazaFoundationCategory.scenery,
    note: 'Brick/workshop storefront shell, equal 6.0×5.0 footprint.',
  ),
  PlazaFoundationAsset(
    id: 'scenery-billboard',
    name: 'Events Billboard',
    assetPath: '$_dir/billboard_three_quarter.jpg',
    category: PlazaFoundationCategory.scenery,
    note: 'Giant billboard with emissive screen face.',
  ),
  PlazaFoundationAsset(
    id: 'scenery-tree-a',
    name: 'Tree — Round',
    assetPath: '$_dir/tree-a_three_quarter.jpg',
    category: PlazaFoundationCategory.scenery,
    note: 'Round-canopy low-poly tree.',
  ),
  PlazaFoundationAsset(
    id: 'scenery-tree-b',
    name: 'Tree — Pine',
    assetPath: '$_dir/tree-b_three_quarter.jpg',
    category: PlazaFoundationCategory.scenery,
    note: 'Conical pine low-poly tree.',
  ),
  PlazaFoundationAsset(
    id: 'scenery-tree-c',
    name: 'Tree — Flat-Top',
    assetPath: '$_dir/tree-c_three_quarter.jpg',
    category: PlazaFoundationCategory.scenery,
    note: 'Flat-top low-poly tree.',
  ),
  PlazaFoundationAsset(
    id: 'scenery-plaza-ground',
    name: 'Plaza Ground',
    assetPath: '$_dir/plaza-ground_three_quarter.jpg',
    category: PlazaFoundationCategory.scenery,
    note: 'Ground disc with central medallion.',
  ),
  PlazaFoundationAsset(
    id: 'scenery-lamp',
    name: 'Lamp',
    assetPath: '$_dir/lamp_three_quarter.jpg',
    category: PlazaFoundationCategory.scenery,
    note: 'Plaza lamp post.',
  ),
  PlazaFoundationAsset(
    id: 'scenery-bench',
    name: 'Bench',
    assetPath: '$_dir/bench_three_quarter.jpg',
    category: PlazaFoundationCategory.scenery,
    note: 'Plaza bench.',
  ),
];

/// Every foundation asset, scene first.
const List<PlazaFoundationAsset> plazaFoundationAssets = [
  plazaSceneAsset,
  ...plazaFigureAssets,
  ...plazaCompanionAssets,
  ...plazaSceneryAssets,
];
