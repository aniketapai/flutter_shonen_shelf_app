class StreamingService {
  // List of popular anime titles for special handling
  static const List<String> _popularAnimeTitles = [
    'One Piece',
    'Naruto',
    'Bleach',
    'Dragon Ball',
    'Attack on Titan',
    'Demon Slayer',
    'My Hero Academia',
    'Death Note',
    'Fullmetal Alchemist',
    'Hunter x Hunter',
    'One Punch Man',
    'Tokyo Ghoul',
    'Fairy Tail',
    'Black Clover',
    'Jujutsu Kaisen',
    'Spy x Family',
    'Chainsaw Man',
  ];

  /// Get AnimeKai URL for direct anime page
  static String generateAnimeKaiUrl(String animeTitle, int episodeNumber) {
    // Clean the anime title for URL
    final cleanTitle = animeTitle
        .replaceAll(RegExp(r'[^\w\s-]'), '') // Remove special characters
        .replaceAll(RegExp(r'\s+'), '+') // Replace spaces with +
        .toLowerCase();

    // Check if it's a popular anime with known episode patterns
    final isPopularAnime = _popularAnimeTitles.any(
      (title) => animeTitle.toLowerCase().contains(title.toLowerCase()),
    );

    String finalUrl;

    if (isPopularAnime) {
      // For popular anime, try direct episode URL first
      final directEpisodeUrl =
          'https://animekai.bz/browser?keyword=$cleanTitle+episode+$episodeNumber';
      finalUrl = directEpisodeUrl;
    } else {
      // For other anime, use search with episode number
      final searchUrl =
          'https://animekai.bz/browser?keyword=$cleanTitle+episode+$episodeNumber';
      finalUrl = searchUrl;
    }

    return finalUrl;
  }

  /// Normalize title for AnimeKai format
  static String _normalizeTitleForAnimeKai(String title) {
    // AnimeKai title mapping
    final animeKaiMapping = {
      'Attack on Titan': 'shingeki-no-kyojin',
      'Shingeki no Kyojin': 'shingeki-no-kyojin',
      'Demon Slayer': 'kimetsu-no-yaiba',
      'Kimetsu no Yaiba': 'kimetsu-no-yaiba',
      'Demon Slayer: Kimetsu no Yaiba': 'kimetsu-no-yaiba',
      'My Hero Academia': 'boku-no-hero-academia',
      'Boku no Hero Academia': 'boku-no-hero-academia',
      'One Piece': 'one-piece',
      'Naruto': 'naruto',
      'Dragon Ball': 'dragon-ball',
      'Dragon Ball Z': 'dragon-ball-z',
      'Dragon Ball Super': 'dragon-ball-super',
      'Death Note': 'death-note',
      'Fullmetal Alchemist': 'fullmetal-alchemist-brotherhood',
      'Fullmetal Alchemist: Brotherhood': 'fullmetal-alchemist-brotherhood',
      'Hunter x Hunter': 'hunter-x-hunter',
      'Hunter x Hunter (2011)': 'hunter-x-hunter',
      'One Punch Man': 'one-punch-man',
      'Tokyo Ghoul': 'tokyo-ghoul',
      'Bleach': 'bleach',
      'Fairy Tail': 'fairy-tail',
      'Black Clover': 'black-clover',
      'Jujutsu Kaisen': 'jujutsu-kaisen',
      'Spy x Family': 'spy-x-family',
      'Chainsaw Man': 'chainsaw-man',
      'Vinland Saga': 'vinland-saga',
      'The Promised Neverland': 'yakusoku-no-neverland',
      'Yakusoku no Neverland': 'yakusoku-no-neverland',
    };

    // Check if we have a direct mapping
    if (animeKaiMapping.containsKey(title)) {
      return animeKaiMapping[title]!;
    }

    // Try to find a partial match
    final normalizedTitle = title.toLowerCase();
    for (final entry in animeKaiMapping.entries) {
      if (normalizedTitle.contains(entry.key.toLowerCase()) ||
          entry.key.toLowerCase().contains(normalizedTitle)) {
        return entry.value;
      }
    }

    // Fallback: create slug from title
    return title
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^+|+'), '');
  }
}
