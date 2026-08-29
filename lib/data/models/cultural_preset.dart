import 'dart:convert';

class CulturalDietPreset {
  final String id;
  final String name; // e.g. South Indian, North Indian, Mediterranean, East Asian, Middle Eastern, Latin American, Western
  final String regionDescription;
  final String iconEmoji;
  final List<String> stapleCarbs; // Rice, Millets, Roti, Pita, Couscous, Quinoa, Noodles, Corn
  final List<String> stapleProteins; // Lentils/Dal, Paneer, Tofu, Chickpeas, Eggs, Fish, Chicken
  final List<String> stapleFats; // Mustard oil, Sesame oil, Coconut oil, Ghee, Olive oil
  final List<String> primarySpices; // Turmeric, Cumin, Mustard, Zaatar, Sumac, Ginger, Garlic, Soy
  final List<String> signatureDishes; // Dosa, Hummus, Sambar, Stir-Fry, Shakshuka, Guacamole
  final String typicalDietProfile; // High-carb moderate-protein, Low-carb high-fat, etc.

  const CulturalDietPreset({
    required this.id,
    required this.name,
    required this.regionDescription,
    required this.iconEmoji,
    required this.stapleCarbs,
    required this.stapleProteins,
    required this.stapleFats,
    required this.primarySpices,
    required this.signatureDishes,
    required this.typicalDietProfile,
  });

  static List<CulturalDietPreset> get presets => const [
    CulturalDietPreset(
      id: 'south_indian',
      name: 'South Indian',
      regionDescription: 'Fermented crepes/cakes, coconut, tamarind, lentils, curry leaves, and millets',
      iconEmoji: '🥥',
      stapleCarbs: ['Parboiled Rice', 'Foxtail Millet', 'Finger Millet (Ragi)', 'Poha (Flattened Rice)', 'Semolina'],
      stapleProteins: ['Toor Dal', 'Urad Dal', 'Moong Dal', 'Chana Dal', 'Paneer', 'Curd/Yogurt'],
      stapleFats: ['Sesame Oil', 'Coconut Oil', 'Ghee'],
      primarySpices: ['Curry Leaves', 'Mustard Seeds', 'Asafoetida (Hing)', 'Tamarind', 'Black Pepper', 'Turmeric'],
      signatureDishes: ['Masala Dosa', 'Idli & Sambar', 'Upma', 'Curd Rice', 'Rasam', 'Bisi Bele Bath'],
      typicalDietProfile: 'Fermented & gut-friendly, naturally vegetarian-rich, high complex carbs with dal proteins',
    ),
    CulturalDietPreset(
      id: 'north_indian',
      name: 'North Indian',
      regionDescription: 'Whole wheat flatbreads, rich gravies, paneer, legumes, and aromatic garam masala',
      iconEmoji: '🫓',
      stapleCarbs: ['Whole Wheat Atta (Roti)', 'Basmati Rice', 'Bajra (Pearl Millet)', 'Besan (Gram Flour)'],
      stapleProteins: ['Paneer', 'Rajma (Kidney Beans)', 'Kabuli Chana (Chickpeas)', 'Urad Dal', 'Moong Dal', 'Chicken Tikka'],
      stapleFats: ['Ghee', 'Mustard Oil'],
      primarySpices: ['Cumin Seeds', 'Garam Masala', 'Kasoori Methi', 'Coriander Powder', 'Cardamom', 'Ginger-Garlic'],
      signatureDishes: ['Roti & Dal Tadka', 'Palak Paneer', 'Rajma Chawal', 'Chole Bhature', 'Aloo Gobi', 'Paneer Tikka'],
      typicalDietProfile: 'Protein & calcium dense, rich in dairy, whole wheat fiber with hearty legume stews',
    ),
    CulturalDietPreset(
      id: 'mediterranean',
      name: 'Mediterranean',
      regionDescription: 'Extra virgin olive oil, fresh vegetables, legumes, whole grains, nuts, and seafood',
      iconEmoji: '🫒',
      stapleCarbs: ['Whole Wheat Pita', 'Couscous', 'Bulgur', 'Farro', 'Barley'],
      stapleProteins: ['Chickpeas', 'Lentils', 'Greek Yogurt', 'Feta Cheese', 'Salmon', 'Sardines', 'Eggs'],
      stapleFats: ['Extra Virgin Olive Oil', 'Tahini', 'Walnuts', 'Pine Nuts'],
      primarySpices: ['Oregano', 'Rosemary', 'Thyme', 'Garlic', 'Lemon Juice', 'Sumac'],
      signatureDishes: ['Hummus & Pita', 'Greek Salad with Feta', 'Falafel Platter', 'Tabbouleh', 'Grilled Salmon Bowl', 'Shakshuka'],
      typicalDietProfile: 'Heart-healthy MUFAs & PUFAs, anti-inflammatory antioxidants, high fiber and lean protein',
    ),
    CulturalDietPreset(
      id: 'middle_eastern',
      name: 'Middle Eastern',
      regionDescription: 'Aromatic herbs, tahini, pomegranate, roasted vegetables, and grilled skewers',
      iconEmoji: '🥙',
      stapleCarbs: ['Flatbread', 'Freekeh', 'Rice with Vermicelli', 'Lentil Rice (Mujaddara)'],
      stapleProteins: ['Chickpeas', 'Fava Beans (Ful Medames)', 'Labneh', 'Lentils', 'Lamb', 'Chicken Shawarma'],
      stapleFats: ['Tahini', 'Olive Oil', 'Pistachios'],
      primarySpices: ['Zaatar', 'Sumac', 'Cardamom', 'Cinnamon', 'Cumin', 'Mint'],
      signatureDishes: ['Hummus with Pine Nuts', 'Baba Ganoush', 'Mujaddara', 'Ful Medames', 'Fattoush Salad', 'Shawarma Wrap'],
      typicalDietProfile: 'High fiber legumes, rich plant fats from sesame & olive, antioxidant herb blends',
    ),
    CulturalDietPreset(
      id: 'east_asian',
      name: 'East Asian',
      regionDescription: 'Steamed greens, soy ferments, tofu, broth-based soups, and quick wok-tossed dishes',
      iconEmoji: '🥢',
      stapleCarbs: ['Jasmine Rice', 'Brown Rice', 'Soba Noodles', 'Rice Noodles', 'Sweet Potato'],
      stapleProteins: ['Firm Tofu', 'Edamame', 'Tempeh', 'Eggs', 'Chicken Breast', 'White Fish', 'Shrimp'],
      stapleFats: ['Sesame Oil', 'Peanut Oil'],
      primarySpices: ['Soy Sauce / Tamari', 'Ginger', 'Scallions', 'Miso', 'Garlic', 'Chili Crisp'],
      signatureDishes: ['Tofu Stir-fry with Veggies', 'Miso Soup with Wakame', 'Bibimbap', 'Steamed Dumplings', 'Soba Salad'],
      typicalDietProfile: 'Clean high protein from soy, low saturated fat, high vegetable micronutrient density',
    ),
    CulturalDietPreset(
      id: 'latin_american',
      name: 'Latin American',
      regionDescription: 'Corn tortillas, black and pinto beans, avocado, lime, peppers, and fresh cilantro',
      iconEmoji: '🥑',
      stapleCarbs: ['Corn Tortillas', 'Brown Rice', 'Plantains', 'Quinoa', 'Sweet Potatoes'],
      stapleProteins: ['Black Beans', 'Pinto Beans', 'Queso Fresco', 'Eggs', 'Grilled Chicken', 'Steak'],
      stapleFats: ['Avocado Oil', 'Fresh Avocados', 'Pumpkin Seeds (Pepitas)'],
      primarySpices: ['Cilantro', 'Cumin', 'Smoked Paprika', 'Lime Juice', 'Jalapeño', 'Garlic'],
      signatureDishes: ['Black Bean Burrito Bowl', 'Guacamole & Crisps', 'Huevos Rancheros', 'Ceviche', 'Fajitas'],
      typicalDietProfile: 'High soluble fiber from beans, healthy avocado fats, metabolism-boosting peppers',
    ),
    CulturalDietPreset(
      id: 'western_balanced',
      name: 'Western Balanced & Continental',
      regionDescription: 'Oats, lean poultry, fresh garden salads, whole grain sourdough, and roasted vegetables',
      iconEmoji: '🥗',
      stapleCarbs: ['Rolled Oats', 'Whole Grain Sourdough', 'Brown Rice', 'Quinoa', 'Baby Potatoes'],
      stapleProteins: ['Eggs & Egg Whites', 'Greek Yogurt', 'Cottage Cheese', 'Chicken Breast', 'Salmon', 'Lentils'],
      stapleFats: ['Olive Oil', 'Almond Butter', 'Flaxseeds', 'Chia Seeds'],
      primarySpices: ['Black Pepper', 'Garlic Powder', 'Paprika', 'Basil', 'Dijon Mustard'],
      signatureDishes: ['Overnight Oats with Berries', 'Avocado & Egg Sourdough Toast', 'Grilled Chicken Salad', 'Quinoa Veggie Bowl'],
      typicalDietProfile: 'High protein macro balance, flexible calorie budgeting, nutrient dense whole foods',
    ),
  ];

  static CulturalDietPreset getById(String id) {
    return presets.firstWhere(
      (p) => p.id == id,
      orElse: () => presets.first,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'regionDescription': regionDescription,
      'iconEmoji': iconEmoji,
      'stapleCarbs': stapleCarbs,
      'stapleProteins': stapleProteins,
      'stapleFats': stapleFats,
      'primarySpices': primarySpices,
      'signatureDishes': signatureDishes,
      'typicalDietProfile': typicalDietProfile,
    };
  }

  factory CulturalDietPreset.fromMap(Map<String, dynamic> map) {
    return CulturalDietPreset(
      id: map['id'] ?? 'south_indian',
      name: map['name'] ?? 'South Indian',
      regionDescription: map['regionDescription'] ?? '',
      iconEmoji: map['iconEmoji'] ?? '🥥',
      stapleCarbs: List<String>.from(map['stapleCarbs'] ?? []),
      stapleProteins: List<String>.from(map['stapleProteins'] ?? []),
      stapleFats: List<String>.from(map['stapleFats'] ?? []),
      primarySpices: List<String>.from(map['primarySpices'] ?? []),
      signatureDishes: List<String>.from(map['signatureDishes'] ?? []),
      typicalDietProfile: map['typicalDietProfile'] ?? '',
    );
  }
}
