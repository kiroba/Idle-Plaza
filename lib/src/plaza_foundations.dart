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
///
/// Live Plaza 2 adds journeys and the pond: animals WALK to and from their
/// spots on a swap (birds FLY — move/fly frame sets below), and the pond
/// set piece (plazaPondAsset, placed by plazaPond) carries fish from
/// plazaFish, drifting on ovals inside its water.
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
  PlazaFoundationAsset(
    id: 'companion-koi-front',
    name: 'Koi — Front',
    assetPath: '$_dir/companion-koi-01_front.png',
    category: PlazaFoundationCategory.companion,
    note: 'Companion set #3 (pond fish) koi, front sprite.',
  ),
  PlazaFoundationAsset(
    id: 'companion-koi-three-quarter',
    name: 'Koi — Three-Quarter',
    assetPath: '$_dir/companion-koi-01_three_quarter.png',
    category: PlazaFoundationCategory.companion,
    note: 'Companion set #3 (pond fish) koi, three-quarter sprite.',
  ),
  PlazaFoundationAsset(
    id: 'companion-goldfish-front',
    name: 'Goldfish — Front',
    assetPath: '$_dir/companion-goldfish-01_front.png',
    category: PlazaFoundationCategory.companion,
    note: 'Companion set #3 (pond fish) goldfish, front sprite.',
  ),
  PlazaFoundationAsset(
    id: 'companion-goldfish-three-quarter',
    name: 'Goldfish — Three-Quarter',
    assetPath: '$_dir/companion-goldfish-01_three_quarter.png',
    category: PlazaFoundationCategory.companion,
    note: 'Companion set #3 (pond fish) goldfish, three-quarter sprite.',
  ),
  PlazaFoundationAsset(
    id: 'companion-bluefish-front',
    name: 'Blue Fish — Front',
    assetPath: '$_dir/companion-bluefish-01_front.png',
    category: PlazaFoundationCategory.companion,
    note: 'Companion set #3 (pond fish) blue fish, front sprite.',
  ),
  PlazaFoundationAsset(
    id: 'companion-bluefish-three-quarter',
    name: 'Blue Fish — Three-Quarter',
    assetPath: '$_dir/companion-bluefish-01_three_quarter.png',
    category: PlazaFoundationCategory.companion,
    note: 'Companion set #3 (pond fish) blue fish, three-quarter sprite.',
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

/// Move frames shipped per animal: the whole 8-frame move cycle,
/// palette-quantized the same way. Played while walking to/from a spot.
const int plazaMoveFrameCount = 8;

/// Fly frames shipped per bird: the whole 8-frame fly cycle.
const int plazaFlyFrameCount = 8;

/// Swim frames shipped per fish: the whole 8-frame swim cycle.
const int plazaSwimFrameCount = 8;

/// How an animal travels on a rotation swap: land animals walk, birds fly.
enum PlazaAnimalKind { land, bird }

/// The roster's birds — the animals with a fly cycle.
const Set<String> plazaBirdIds = {'songbird', 'owl', 'duck', 'crow'};

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

  /// The shipped move frame for step [k] (0-based, < plazaMoveFrameCount).
  String moveFramePath(int k) => '$_animDir/companion-$id-01_move_$k.png';

  /// All shipped move frames, in play order — played while the animal
  /// walks to or from its spot during a rotation swap.
  List<String> get moveFrames =>
      [for (var k = 0; k < plazaMoveFrameCount; k++) moveFramePath(k)];

  /// True for the birds (songbird, owl, duck, crow).
  bool get isBird => plazaBirdIds.contains(id);

  /// The shipped fly frame for step [k] (0-based, < plazaFlyFrameCount).
  /// Only meaningful for birds — see [flyFrames].
  String flyFramePath(int k) => '$_animDir/companion-$id-01_fly_$k.png';

  /// All shipped fly frames for birds; null for land animals, which walk
  /// instead. Birds fly in and out on rotation swaps.
  List<String>? get flyFrames => isBird
      ? [for (var k = 0; k < plazaFlyFrameCount; k++) flyFramePath(k)]
      : null;

  /// Travel kind for rotation swaps: bird iff this animal has fly frames.
  PlazaAnimalKind get kind =>
      flyFrames != null ? PlazaAnimalKind.bird : PlazaAnimalKind.land;
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

/// ============================================================================
/// POND FISH ROSTER (companion set #3)
/// ============================================================================
/// Fish live only in the pond (see plazaPond): they drift on small ovals
/// inside the water's fish-safe ellipse, cycling their swim frames, and
/// species rotate on the same timer family as the land animals. They
/// never walk, fly, or leave the water.
/// ============================================================================

class PlazaFish {
  /// Short species id, e.g. 'koi'. Also the fish rotation pool id.
  final String id;

  final String name;

  /// Three-quarter still sprite (assets/plaza/), used in the catalog grid.
  final String stillAsset;

  /// On-stage sprite width as a fraction of the stage width. Stylized:
  /// at true scale against the pond these fish would be a few pixels —
  /// they are drawn at companion scale so they read on a phone screen.
  final double widthFraction;

  const PlazaFish({
    required this.id,
    required this.name,
    required this.stillAsset,
    required this.widthFraction,
  });

  /// The shipped swim frame for step [k] (0-based, < plazaSwimFrameCount).
  String swimFramePath(int k) => '$_animDir/companion-$id-01_swim_$k.png';

  /// All shipped swim frames, in play order.
  List<String> get swimFrames =>
      [for (var k = 0; k < plazaSwimFrameCount; k++) swimFramePath(k)];
}

/// All 3 pond fish (set #3). Lengths 0.43 / 0.36 / 0.39 pond units —
/// widths below keep that ordering at the stylized on-stage scale.
const List<PlazaFish> plazaFish = [
  PlazaFish(
    id: 'koi',
    name: 'Koi',
    stillAsset: '$_dir/companion-koi-01_three_quarter.png',
    widthFraction: 0.058,
  ),
  PlazaFish(
    id: 'goldfish',
    name: 'Goldfish',
    stillAsset: '$_dir/companion-goldfish-01_three_quarter.png',
    widthFraction: 0.050,
  ),
  PlazaFish(
    id: 'bluefish',
    name: 'Blue Fish',
    stillAsset: '$_dir/companion-bluefish-01_three_quarter.png',
    widthFraction: 0.054,
  ),
];

/// ============================================================================
/// THE POND — measured placement on the backdrop
/// ============================================================================
/// The pond set piece sits at world (−5.6, 4.0) in the composed scene, in
/// front of Storefront A. Its layer image (plazaPondAsset) is the ortho
/// top-down render with the (opaque) ground outside the rim circular-
/// masked away and the square perspective-warped to the backdrop camera,
/// so the layer lands where the real 3D pond lands in the scene render.
///
/// All numbers below are backdrop fractions, MEASURED by rendering the
/// pond alone with the backdrop's exact camera (az 32° / el 24°, target
/// (0, 2.0, 1.2)) and projecting the geometry: the layer rect is the
/// projected 5.6-unit top-down frame (bbox of its four corners); the water
/// centre and radii are the projected water circles (the usable ellipse
/// is the r ≤ 1.70 fish-safe circle; the physical ellipse is the r = 1.92
/// water disc). Cross-checked against the pond render's alpha silhouette
/// and a PIL composite read — the warped layer sits naturally on the
/// paving in front of Storefront A.
/// ============================================================================

/// The pond layer image: top-down render, masked + perspective-warped.
const PlazaFoundationAsset plazaPondAsset = PlazaFoundationAsset(
  id: 'pond-top-down',
  name: 'Pond — Top-Down (Warped)',
  assetPath: '$_dir/pond_top_down.png',
  category: PlazaFoundationCategory.scenery,
  note:
      'Pond set piece, ortho top-down render circular-masked and perspective-warped to the backdrop camera — composited live over the backdrop, with the fish swimming in it.',
);

class PlazaPond {
  /// Layer rect on the square backdrop, as fractions.
  final double layerLeft;
  final double layerTop;
  final double layerWidth;
  final double layerHeight;

  /// Water centre on the backdrop, as fractions.
  final double waterDx;
  final double waterDy;

  /// Fish-safe ellipse radii (the r ≤ 1.70 circle, projected): fish
  /// centres and their swim ovals stay inside this.
  final double usableRx;
  final double usableRy;

  /// Physical water ellipse radii (the r = 1.92 disc, projected).
  final double waterRx;
  final double waterRy;

  const PlazaPond({
    required this.layerLeft,
    required this.layerTop,
    required this.layerWidth,
    required this.layerHeight,
    required this.waterDx,
    required this.waterDy,
    required this.usableRx,
    required this.usableRy,
    required this.waterRx,
    required this.waterRy,
  });
}

/// The measured pond placement (see the section comment above).
const PlazaPond plazaPond = PlazaPond(
  layerLeft: 0.2930,
  layerTop: 0.4336,
  layerWidth: 0.2148,
  layerHeight: 0.0869,
  waterDx: 0.4020,
  waterDy: 0.4725,
  usableRx: 0.0452,
  usableRy: 0.0175,
  waterRx: 0.0511,
  waterRy: 0.0198,
);

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
  plazaPondAsset,
];

/// Every foundation asset, scene first.
const List<PlazaFoundationAsset> plazaFoundationAssets = [
  plazaSceneAsset,
  ...plazaFigureAssets,
  ...plazaCompanionAssets,
  ...plazaSceneryAssets,
];
