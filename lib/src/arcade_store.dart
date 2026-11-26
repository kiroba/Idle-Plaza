/// ============================================================================
/// THE ARCADE — the Plaza's first storefront (pure Dart — no Flutter imports)
/// ============================================================================
/// Slice 1 of the Arcade storefront: the store's placement on the Plaza's
/// layered avenues and its cabinets, in the order they stand on the floor.
///
/// The Arcade is the FIRST store in the Plaza: ground level, Avenue 1,
/// in the Storefront A shell (see the foundations catalog — the pond sits
/// in front of Storefront A, so the Arcade faces the pond). Cabinet 01 is
/// the Brawler — nearly complete, actually here, the playtest build.
/// Cabinet 02 is 9x9 — design-stage, honestly marked as such. The two
/// small cabinets behind them (Janken, Spades) are coming soon.
///
/// The Brawler's game itself still runs from its own app build — this
/// slice is the storefront home for it, not a launcher. Launch wiring is
/// a later slice. Nothing here invents a game: the Brawler roster is the
/// 12 zodiac fighters with their elemental specials plus Ophiuchus, the
/// 13th-sign boss, unplayable by design; the 9x9 facts are the ruled
/// design (13 per side, seven shells, four heart rooms, holdout escape).
/// ============================================================================

/// Where a cabinet stands: on the floor and playable, still being designed,
/// or a future cabinet.
enum ArcadeCabinetStatus { playable, inDesign, comingSoon }

extension ArcadeCabinetStatusLabel on ArcadeCabinetStatus {
  String get label => switch (this) {
        ArcadeCabinetStatus.playable => 'PLAYABLE',
        ArcadeCabinetStatus.inDesign => 'IN DESIGN',
        ArcadeCabinetStatus.comingSoon => 'COMING SOON',
      };
}

/// One cabinet on the Arcade floor.
class ArcadeCabinet {
  /// Short id, e.g. 'brawler'. Also the detail-sheet key.
  final String id;

  final String name;

  final String tagline;

  final ArcadeCabinetStatus status;

  /// Honest one-liners for the detail sheet — what the game is and where
  /// it really stands. No launch promises: a playable cabinet's game runs
  /// from its own app build until launch wiring lands.
  final List<String> details;

  const ArcadeCabinet({
    required this.id,
    required this.name,
    required this.tagline,
    required this.status,
    required this.details,
  });
}

/// A Brawler fighter's element — the four classical elements, three signs
/// each, in zodiac order.
enum BrawlerElement { fire, earth, air, water }

extension BrawlerElementLabel on BrawlerElement {
  String get label => switch (this) {
        BrawlerElement.fire => 'Fire',
        BrawlerElement.earth => 'Earth',
        BrawlerElement.air => 'Air',
        BrawlerElement.water => 'Water',
      };
}

/// One of the Brawler's 12 zodiac fighters.
class BrawlerFighter {
  final String sign;
  final BrawlerElement element;

  const BrawlerFighter({required this.sign, required this.element});
}

/// The Brawler roster, in zodiac order: 12 fighters, three per element.
const List<BrawlerFighter> brawlerFighters = [
  BrawlerFighter(sign: 'Aries', element: BrawlerElement.fire),
  BrawlerFighter(sign: 'Taurus', element: BrawlerElement.earth),
  BrawlerFighter(sign: 'Gemini', element: BrawlerElement.air),
  BrawlerFighter(sign: 'Cancer', element: BrawlerElement.water),
  BrawlerFighter(sign: 'Leo', element: BrawlerElement.fire),
  BrawlerFighter(sign: 'Virgo', element: BrawlerElement.earth),
  BrawlerFighter(sign: 'Libra', element: BrawlerElement.air),
  BrawlerFighter(sign: 'Scorpio', element: BrawlerElement.water),
  BrawlerFighter(sign: 'Sagittarius', element: BrawlerElement.fire),
  BrawlerFighter(sign: 'Capricorn', element: BrawlerElement.earth),
  BrawlerFighter(sign: 'Aquarius', element: BrawlerElement.air),
  BrawlerFighter(sign: 'Pisces', element: BrawlerElement.water),
];

/// The Brawler's boss: the 13th sign, in the code, unplayable by design.
/// Beating all 12 fighters plus Ophiuchus unlocks the secret character.
const String brawlerBossSign = 'Ophiuchus';

/// 9x9, the design-stage game — the ruled numbers, nothing more.
class NineByNineDesign {
  /// Master structure: 13 rooms per side (title only — "9x9" is the name).
  static const int structurePerSide = 13;

  /// Concentric difficulty shells, heart included.
  static const int shellCount = 7;

  /// The centre holds four rooms; one has the exit.
  static const int heartRoomCount = 4;

  /// Escaping is a holdout: stay in the correct room until the exit opens.
  static const String escapeRule = 'Holdout';

  static const String genre = 'Psychological ecopunk horror';

  static const List<String> modes = [
    'Solo',
    'Duos',
    'Trios',
    '4-team survival',
  ];

  /// A run's six beats, in order.
  static const List<String> runFlowBeats = [
    'Waking',
    'Descent',
    'Learning',
    'Deep',
    'Heart',
    'Leaving',
  ];
}

/// The Arcade storefront itself.
class ArcadeStorefront {
  final String name;
  final String placement;
  final List<ArcadeCabinet> cabinets;

  const ArcadeStorefront({
    required this.name,
    required this.placement,
    required this.cabinets,
  });

  /// Cabinet 01 — first on the floor.
  ArcadeCabinet get firstCabinet => cabinets.first;
}

/// The Arcade: the Plaza's first store — ground level, Avenue 1, in the
/// Storefront A shell. Brawler first (it is nearly complete and actually
/// here), 9x9 second (design-stage), Janken and Spades behind them.
const ArcadeStorefront arcadeStorefront = ArcadeStorefront(
  name: 'The Arcade',
  placement: 'Ground level · Avenue 1 · Storefront A',
  cabinets: [
    ArcadeCabinet(
      id: 'brawler',
      name: 'OmniBrawler',
      tagline: '2D zodiac fighter — PvP in the Halo Plaza arena',
      status: ArcadeCabinetStatus.playable,
      details: [
        '12 zodiac fighters, each with an elemental special',
        'Online PvP versus, with dual-signed match results',
        'Boss: Ophiuchus, the 13th sign — unplayable by design',
        'The game runs from the Brawler app build; this cabinet is its storefront home — launch wiring lands in a later slice',
      ],
    ),
    ArcadeCabinet(
      id: 'nine-by-nine',
      name: '9x9',
      tagline: 'Psychological ecopunk horror — the living maze',
      status: ArcadeCabinetStatus.inDesign,
      details: [
        'A living, grown maze: 13 rooms per side, seven shells, four heart rooms',
        'Escape is a holdout — stay in the correct room until the exit opens',
        'Solo, duos, trios and 4-team survival; first- or third-person, your call',
        'Herders above, hunters below, terrain that eats — and the grafts you steal from bosses',
      ],
    ),
    ArcadeCabinet(
      id: 'janken',
      name: 'Janken Markov AI',
      tagline: 'Adaptive RPSLS AI',
      status: ArcadeCabinetStatus.comingSoon,
      details: [
        'Rock-paper-scissors-lizard-Spock against an AI that learns your tells',
      ],
    ),
    ArcadeCabinet(
      id: 'spades',
      name: 'Spades Lounge',
      tagline: 'Casual card strategy',
      status: ArcadeCabinetStatus.comingSoon,
      details: [
        'A quiet card table at the back of the Arcade',
      ],
    ),
  ],
);
