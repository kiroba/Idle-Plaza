/// ============================================================================
/// PLAZA FOUNDATIONS CATALOG (pure Dart — no Flutter imports)
/// ============================================================================
/// The low-poly Plaza foundations slice: the Plaza backdrop render, the kept
/// base #3 "soft" figure sprites, companion set #1 + #2 sprites, and the
/// scenery set #1 pieces. Every entry is a baked render or sprite PNG/JPG
/// shipped in assets/plaza/ — there is no live 3D in the app, and this
/// catalog does not pretend otherwise.
///
/// The scene screen's top card is a LIVE composite built from this catalog:
/// the no-animals backdrop (plazaSceneAsset) with animal sprites from
/// plazaAnimals composited on top, rotating in and out and idle-animating,
/// under a real-time day/night tint (see src/plaza_live.dart). The sections
/// below the stage still render the catalog grids exactly as listed.
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

/// The live stage backdrop: the composed Plaza scene (scenery set #1 + the
/// Halo) rendered WITHOUT animals — plaza-scene-nopets, same three-quarter
/// camera as the old baked scene. Animals are composited live on top of it
/// from plazaAnimals; they are deliberately not baked in here.
const PlazaFoundationAsset plazaSceneAsset = PlazaFoundationAsset(
  id: 'scene-backdrop',
  name: 'Plaza Backdrop',
  assetPath: '$_dir/scene_backdrop.jpg',
  category: PlazaFoundationCategory.scene,
  note:
      'Baked three-quarter render of the Plaza with no animals — the live stage composites animal sprites over it. Not live 3D.',
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

/// Companion sets #1 + #2 — 128px sprites, soft low-poly matching base #3.
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
  PlazaFoundationAsset(
    id: 'companion-rabbit-front',
    name: 'Rabbit — Front',
    assetPath: '$_dir/companion-rabbit-01_front.png',
    category: PlazaFoundationCategory.companion,
    note: 'Companion set #2 rabbit, front sprite.',
  ),
  PlazaFoundationAsset(
    id: 'companion-rabbit-three-quarter',
    name: 'Rabbit — Three-Quarter',
    assetPath: '$_dir/companion-rabbit-01_three_quarter.png',
    category: PlazaFoundationCategory.companion,
    note: 'Companion set #2 rabbit, three-quarter sprite.',
  ),
  PlazaFoundationAsset(
    id: 'companion-deer-front',
    name: 'Deer — Front',
    assetPath: '$_dir/companion-deer-01_front.png',
    category: PlazaFoundationCategory.companion,
    note: 'Companion set #2 deer, front sprite.',
  ),
  PlazaFoundationAsset(
    id: 'companion-deer-three-quarter',
    name: 'Deer — Three-Quarter',
    assetPath: '$_dir/companion-deer-01_three_quarter.png',
    category: PlazaFoundationCategory.companion,
    note: 'Companion set #2 deer, three-quarter sprite.',
  ),
  PlazaFoundationAsset(
    id: 'companion-bearcub-front',
    name: 'Bear Cub — Front',
    assetPath: '$_dir/companion-bearcub-01_front.png',
    category: PlazaFoundationCategory.companion,
    note: 'Companion set #2 bear cub, front sprite.',
  ),
  PlazaFoundationAsset(
    id: 'companion-bearcub-three-quarter',
    name: 'Bear Cub — Three-Quarter',
    assetPath: '$_dir/companion-bearcub-01_three_quarter.png',
    category: PlazaFoundationCategory.companion,
    note: 'Companion set #2 bear cub, three-quarter sprite.',
  ),
  PlazaFoundationAsset(
    id: 'companion-duck-front',
    name: 'Duck — Front',
    assetPath: '$_dir/companion-duck-01_front.png',
    category: PlazaFoundationCategory.companion,
    note: 'Companion set #2 duck, front sprite.',
  ),
  PlazaFoundationAsset(
    id: 'companion-duck-three-quarter',
    name: 'Duck — Three-Quarter',
    assetPath: '$_dir/companion-duck-01_three_quarter.png',
    category: PlazaFoundationCategory.companion,
    note: 'Companion set #2 duck, three-quarter sprite.',
  ),
  PlazaFoundationAsset(
    id: 'companion-crow-front',
    name: 'Crow — Front',
    assetPath: '$_dir/companion-crow-01_front.png',
    category: PlazaFoundationCategory.companion,
    note: 'Companion set #2 crow, front sprite.',
  ),
  PlazaFoundationAsset(
    id: 'companion-crow-three-quarter',
    name: 'Crow — Three-Quarter',
    assetPath: '$_dir/companion-crow-01_three_quarter.png',
    category: PlazaFoundationCategory.companion,
    note: 'Companion set #2 crow, three-quarter sprite.',
  ),
];

/// ============================================================================
/// LIVE STAGE ANIMAL ROSTER
/// ============================================================================
/// Every animal that can appear on the live Plaza stage. Data-driven: to
/// add a future companion set, add its stills to plazaCompanionAssets, its
/// idle frames to assets/plaza/anim/, and one entry here — the stage,
/// rotation and tests pick it up from this list alone.
/// ============================================================================

const String _animDir = 'assets/plaza/anim';

/// Idle frames shipped per animal: every 2nd frame of the 16-frame idle
/// cycle (frames 001, 003, …, 015), palette-quantized to keep the bundle
/// lean. Played at 8 fps they read as the full idle, just sampled.
const int plazaIdleFrameCount = 8;

class PlazaAnimal {
  /// Short species id, e.g. 'fox'. Also the rotation pool id.
  final String id;

  final String name;

  /// Three-quarter still sprite (assets/plaza/), used in the catalog grid.
  final String stillAsset;

  /// Spot on the square backdrop, as fractions of its width/height.
  ///
  /// ANCHOR: (spotDx, spotDy) is where the sprite's BOTTOM-CENTRE lands —
  /// the animal's feet, or its perch point for birds on the bench backrest
  /// and lamp caps. The sprite is square, so its height equals its width:
  /// spotWidth × backdrop width. (Sprite frames carry some transparent
  /// padding, so the visible animal sits a hair above the anchor — close
  /// enough for a living scene, and the spots below were checked against
  /// the baked companions render, where set #1 sat in these same places.)
  final double spotDx;
  final double spotDy;
  final double spotWidth;

  const PlazaAnimal({
    required this.id,
    required this.name,
    required this.stillAsset,
    required this.spotDx,
    required this.spotDy,
    required this.spotWidth,
  });

  /// The shipped idle frame for step [k] (0-based, < plazaIdleFrameCount).
  String idleFramePath(int k) => '$_animDir/companion-$id-01_idle_$k.png';

  /// All shipped idle frames, in play order.
  List<String> get idleFrames =>
      [for (var k = 0; k < plazaIdleFrameCount; k++) idleFramePath(k)];
}

/// All 10 library animals. Set #1 spots match where they sat in the baked
/// companions scene (fox by the Halo, dog at bench-1, cat on the paving,
/// songbird on bench-2's backrest, owl on lamp-1's cap); set #2 takes the
/// free spots (rabbit on the grass, deer + duck on the front paving, bear
/// cub by the front pine, crow on lamp-2's cap).
const List<PlazaAnimal> plazaAnimals = [
  PlazaAnimal(
    id: 'fox',
    name: 'Fox',
    stillAsset: '$_dir/companion-fox-01_three_quarter.png',
    spotDx: 0.42,
    spotDy: 0.615,
    spotWidth: 0.11,
  ),
  PlazaAnimal(
    id: 'dog',
    name: 'Dog',
    stillAsset: '$_dir/companion-dog-01_three_quarter.png',
    spotDx: 0.335,
    spotDy: 0.58,
    spotWidth: 0.11,
  ),
  PlazaAnimal(
    id: 'cat',
    name: 'Cat',
    stillAsset: '$_dir/companion-cat-01_three_quarter.png',
    spotDx: 0.655,
    spotDy: 0.565,
    spotWidth: 0.11,
  ),
  PlazaAnimal(
    id: 'songbird',
    name: 'Songbird',
    stillAsset: '$_dir/companion-songbird-01_three_quarter.png',
    spotDx: 0.475,
    spotDy: 0.578,
    spotWidth: 0.07,
  ),
  PlazaAnimal(
    id: 'owl',
    name: 'Owl',
    stillAsset: '$_dir/companion-owl-01_three_quarter.png',
    spotDx: 0.335,
    spotDy: 0.46,
    spotWidth: 0.07,
  ),
  PlazaAnimal(
    id: 'rabbit',
    name: 'Rabbit',
    stillAsset: '$_dir/companion-rabbit-01_three_quarter.png',
    spotDx: 0.16,
    spotDy: 0.51,
    spotWidth: 0.11,
  ),
  PlazaAnimal(
    id: 'deer',
    name: 'Deer',
    stillAsset: '$_dir/companion-deer-01_three_quarter.png',
    spotDx: 0.60,
    spotDy: 0.68,
    spotWidth: 0.13,
  ),
  PlazaAnimal(
    id: 'bearcub',
    name: 'Bear Cub',
    stillAsset: '$_dir/companion-bearcub-01_three_quarter.png',
    spotDx: 0.235,
    spotDy: 0.70,
    spotWidth: 0.13,
  ),
  PlazaAnimal(
    id: 'duck',
    name: 'Duck',
    stillAsset: '$_dir/companion-duck-01_three_quarter.png',
    spotDx: 0.52,
    spotDy: 0.735,
    spotWidth: 0.11,
  ),
  PlazaAnimal(
    id: 'crow',
    name: 'Crow',
    stillAsset: '$_dir/companion-crow-01_three_quarter.png',
    spotDx: 0.55,
    spotDy: 0.51,
    spotWidth: 0.07,
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
