import 'dart:convert';
import 'package:http/http.dart' as http;

class EpisodeContentService {
  // Mock database of episode content (thumbnails, screenshots, info)
  // In a real app, this would be fetched from your backend API
  static final Map<String, Map<String, Map<String, dynamic>>>
  _episodeContent = {
    'Attack on Titan': {
      '1': {
        'title': 'To You, 2,000 Years From Now',
        'description':
            'Eren Yeager lives in a world where humanity is on the brink of extinction due to the Titans.',
        'thumbnail':
            'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=225&fit=crop',
        'screenshots': [
          'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=225&fit=crop',
          'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=225&fit=crop',
          'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=225&fit=crop',
        ],
        'duration': '24:00',
        'airDate': '2013-04-07',
      },
      '2': {
        'title': 'That Day',
        'description':
            'The Colossal Titan appears again, and the battle for humanity begins.',
        'thumbnail':
            'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=225&fit=crop',
        'screenshots': [
          'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=225&fit=crop',
          'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=225&fit=crop',
          'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=225&fit=crop',
        ],
        'duration': '24:00',
        'airDate': '2013-04-14',
      },
      '3': {
        'title': 'A Dim Light Amid Despair',
        'description': 'Eren discovers his ability to transform into a Titan.',
        'thumbnail':
            'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=225&fit=crop',
        'screenshots': [
          'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=225&fit=crop',
          'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=225&fit=crop',
          'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=225&fit=crop',
        ],
        'duration': '24:00',
        'airDate': '2013-04-21',
      },
    },
    'Demon Slayer': {
      '1': {
        'title': 'Cruelty',
        'description':
            'Tanjiro Kamado returns home to find his family slaughtered by demons.',
        'thumbnail':
            'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=225&fit=crop',
        'screenshots': [
          'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=225&fit=crop',
          'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=225&fit=crop',
          'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=225&fit=crop',
        ],
        'duration': '24:00',
        'airDate': '2019-04-06',
      },
      '2': {
        'title': 'Trainer Sakonji Urokodaki',
        'description': 'Tanjiro begins his training to become a Demon Slayer.',
        'thumbnail':
            'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=225&fit=crop',
        'screenshots': [
          'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=225&fit=crop',
          'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=225&fit=crop',
          'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=225&fit=crop',
        ],
        'duration': '24:00',
        'airDate': '2019-04-13',
      },
    },
    'My Hero Academia': {
      '1': {
        'title': 'Izuku Midoriya: Origin',
        'description':
            'Izuku Midoriya dreams of becoming a hero despite being born without a Quirk.',
        'thumbnail':
            'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=225&fit=crop',
        'screenshots': [
          'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=225&fit=crop',
          'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=225&fit=crop',
          'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=225&fit=crop',
        ],
        'duration': '24:00',
        'airDate': '2016-04-03',
      },
      '2': {
        'title': 'What It Takes to Be a Hero',
        'description': 'All Might offers Izuku a chance to inherit his Quirk.',
        'thumbnail':
            'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=225&fit=crop',
        'screenshots': [
          'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=225&fit=crop',
          'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=225&fit=crop',
          'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=225&fit=crop',
        ],
        'duration': '24:00',
        'airDate': '2016-04-10',
      },
    },
  };

  // Title mapping to handle different anime title variations
  static final Map<String, String> _titleMapping = {
    'Shingeki no Kyojin': 'Attack on Titan',
    'Attack on Titan': 'Attack on Titan',
    'Kimetsu no Yaiba': 'Demon Slayer',
    'Demon Slayer': 'Demon Slayer',
    'Demon Slayer: Kimetsu no Yaiba': 'Demon Slayer',
    'Boku no Hero Academia': 'My Hero Academia',
    'My Hero Academia': 'My Hero Academia',
    'My Hero Academia Season 1': 'My Hero Academia',
  };

  // Normalize anime title to match our database
  static String _normalizeTitle(String title) {
    // Try exact match first
    if (_episodeContent.containsKey(title)) {
      return title;
    }

    // Try mapping
    if (_titleMapping.containsKey(title)) {
      return _titleMapping[title]!;
    }

    // Try partial matching (case insensitive)
    final normalizedTitle = title.toLowerCase();
    for (final key in _episodeContent.keys) {
      if (key.toLowerCase().contains(normalizedTitle) ||
          normalizedTitle.contains(key.toLowerCase())) {
        return key;
      }
    }

    // Return original title if no match found
    return title;
  }

  // Get episode information including title, description, and thumbnail
  static Future<Map<String, dynamic>> getEpisodeInfo(
    String animeTitle,
    int episodeNumber,
  ) async {
    try {
      // In a real app, this would fetch from an API
      // For now, we'll generate mock data
      return _generateEpisodeInfo(animeTitle, episodeNumber);
    } catch (e) {
      return _generateEpisodeInfo(animeTitle, episodeNumber);
    }
  }

  // Get all episode information for an anime
  static Future<Map<int, Map<String, dynamic>>> getAllEpisodeInfo(
    String animeTitle,
    int totalEpisodes,
  ) async {
    try {
      final Map<int, Map<String, dynamic>> episodeInfo = {};

      for (int episode = 1; episode <= totalEpisodes; episode++) {
        episodeInfo[episode] = await getEpisodeInfo(animeTitle, episode);
      }

      return episodeInfo;
    } catch (e) {
      // Fallback to mock data
      final Map<int, Map<String, dynamic>> episodeInfo = {};
      for (int episode = 1; episode <= totalEpisodes; episode++) {
        episodeInfo[episode] = _generateEpisodeInfo(animeTitle, episode);
      }
      return episodeInfo;
    }
  }

  // Generate mock episode information
  static Map<String, dynamic> _generateEpisodeInfo(
    String animeTitle,
    int episodeNumber,
  ) {
    final episodeTitles = {
      'Attack on Titan': [
        'To You, 2,000 Years in the Future',
        'That Day',
        'A Dim Light Amid Despair',
        'The Night of the Closing Ceremony',
        'First Battle',
        'The World the Girl Saw',
        'Small Blade',
        'I Can Hear His Heartbeat',
        'Where the Abandoned Carriage Was Headed',
        'Response',
        'The Devious One',
        'Icon',
        'Primal Desire',
        'Can You See Him?',
        'Special Operations Squad',
        'What Needs to be Done Now',
        'Female Titan',
        'Forest of Giant Trees',
        'Bite',
        'Erwin Smith',
        'Crushing Blow',
        'Defeated',
        'Smile',
        'Mercy',
        'Wall',
      ],
      'Demon Slayer': [
        'Cruelty',
        'Trainer Sakonji Urokodaki',
        'Sabito and Makomo',
        'Final Selection',
        'My Own Steel',
        'Swordsman Accompanying a Demon',
        'Muzan Kibutsuji',
        'The Smell of Enchanting Blood',
        'Temari Demon and Arrow Demon',
        'Together Forever',
        'Tsuzumi Mansion',
        'The Boar Rushes Down the Mountain',
        'Something More Important Than Life',
        'Rehabilitation Training',
        'Mount Natagumo',
        'Letting Someone Else Go First',
        'You Must Master a Single Thing',
        'A Forged Bond',
        'Hinokami',
        'Pretend Family',
        'Against Corps Rules',
        'Master of the Mansion',
        'Hashira Meeting',
        'Rehabilitation Training',
        'Tsuzumi Mansion',
        'New Mission',
      ],
      'My Hero Academia': [
        'Izuku Midoriya: Origin',
        'What It Takes to Be a Hero',
        'Roaring Muscles',
        'Start Line',
        'What I Can Do for Now',
        'Rage, You Damn Nerd',
        'Deku vs. Kacchan',
        'Bakugo\'s Starting Line',
        'Yeah, Just Do Your Best, Iida!',
        'Encounter with the Unknown',
        'Game Over',
        'All Might',
        'In Each of Our Hearts',
      ],
    };

    final episodeDescriptions = {
      'Attack on Titan': [
        'Eren Yeager lives in a world where humanity is on the brink of extinction due to giant humanoid creatures called Titans.',
        'The Colossal Titan appears and destroys the outer wall, allowing other Titans to enter the city.',
        'Eren, Mikasa, and Armin witness the destruction of their home and the death of Eren\'s mother.',
        'The survivors are evacuated to the inner walls, and the military begins preparations for the next attack.',
        'Eren joins the military and begins his training to fight against the Titans.',
        'During training, Eren discovers his ability to transform into a Titan and fights against other trainees.',
        'Eren learns to control his Titan form and helps defend the city from a Titan invasion.',
        'The military investigates Eren\'s abilities and decides how to use them in the war against the Titans.',
        'Eren and his comrades are assigned to the Survey Corps and begin their first mission outside the walls.',
        'The Survey Corps encounters a new type of Titan and must adapt their strategies to survive.',
        'Eren and his friends face their first real battle against the Titans outside the safety of the walls.',
        'The military begins to understand the true nature of the Titans and their connection to humanity.',
        'Eren struggles with his dual nature as both human and Titan, questioning his own identity.',
        'The Survey Corps launches a mission to capture a Titan for study and experimentation.',
        'A special operations squad is formed to protect Eren and study his Titan abilities.',
        'The military plans a coordinated attack against the Titans using Eren\'s abilities.',
        'A mysterious female Titan appears and begins attacking the Survey Corps.',
        'The Survey Corps enters a forest to escape the female Titan and regroup.',
        'Eren must fight against the female Titan in a desperate battle for survival.',
        'Commander Erwin Smith leads the Survey Corps in a strategic battle against the Titans.',
        'The Survey Corps suffers heavy losses in their battle against the female Titan.',
        'Eren and his friends must come to terms with the harsh reality of war.',
        'Despite the losses, the Survey Corps continues their mission to protect humanity.',
        'The military makes a difficult decision about how to proceed in the war against the Titans.',
        'The first season concludes with humanity still fighting for survival against the Titans.',
      ],
      'Demon Slayer': [
        'Tanjiro Kamado returns home to find his family slaughtered by demons, with only his sister Nezuko surviving.',
        'Tanjiro meets Sakonji Urokodaki, a former demon slayer who agrees to train him.',
        'Tanjiro meets other trainees Sabito and Makomo who help him improve his skills.',
        'Tanjiro participates in the Final Selection to become an official demon slayer.',
        'Tanjiro receives his own Nichirin Blade and begins his journey as a demon slayer.',
        'Tanjiro encounters his first demon and learns about the demon slayer corps.',
        'Tanjiro meets Muzan Kibutsuji, the demon responsible for his family\'s death.',
        'Tanjiro and Nezuko encounter demons attracted by the smell of blood.',
        'Tanjiro fights against two demons with unique abilities in a temple.',
        'Tanjiro and Nezuko form a bond that will last throughout their journey.',
        'Tanjiro investigates a mansion where people are disappearing mysteriously.',
        'Tanjiro meets Inosuke, a wild boy who fights with two swords.',
        'Tanjiro learns about the importance of protecting others and the value of life.',
        'Tanjiro begins rehabilitation training to recover from his injuries.',
        'Tanjiro and his friends travel to Mount Natagumo for their next mission.',
        'Tanjiro learns about the importance of teamwork and letting others help.',
        'Tanjiro focuses on mastering a single technique to become stronger.',
        'Tanjiro forms a bond with his fellow demon slayers through shared experiences.',
        'Tanjiro discovers his unique breathing technique and its connection to his family.',
        'Tanjiro encounters a demon who pretends to be part of a family.',
        'Tanjiro must break corps rules to save someone in danger.',
        'Tanjiro meets the master of the mansion and learns about his mission.',
        'Tanjiro attends a meeting with the Hashira, the strongest demon slayers.',
        'Tanjiro continues his rehabilitation training to become stronger.',
        'Tanjiro returns to the mansion to complete his mission.',
        'Tanjiro receives a new mission and continues his journey as a demon slayer.',
      ],
      'My Hero Academia': [
        'Izuku Midoriya dreams of becoming a hero despite being born without a Quirk.',
        'Izuku meets All Might and learns what it truly takes to be a hero.',
        'All Might begins training Izuku to inherit his Quirk, One for All.',
        'Izuku takes the entrance exam for U.A. High School\'s hero course.',
        'Izuku struggles to control his new Quirk and find his own way to be a hero.',
        'Bakugo confronts Izuku about his sudden power and challenges him to a fight.',
        'Izuku and Bakugo face off in a training exercise to test their abilities.',
        'Bakugo begins to understand the gap between himself and Izuku.',
        'Izuku and his classmates participate in the U.A. Sports Festival.',
        'Izuku encounters the League of Villains during a training exercise.',
        'The students must work together to survive the villain attack.',
        'All Might reveals his true form and the burden of being the Symbol of Peace.',
        'The first season concludes with Izuku beginning his journey as a hero.',
      ],
    };

    final titles = episodeTitles[animeTitle] ?? [];
    final descriptions = episodeDescriptions[animeTitle] ?? [];

    final title = episodeNumber <= titles.length
        ? titles[episodeNumber - 1]
        : 'Episode $episodeNumber';

    final description = episodeNumber <= descriptions.length
        ? descriptions[episodeNumber - 1]
        : 'Episode $episodeNumber of $animeTitle.';

    return {
      'title': title,
      'description': description,
      'duration': '24:00',
      'thumbnail': null, // Would be fetched from API in real app
      'episodeNumber': episodeNumber,
      'animeTitle': animeTitle,
    };
  }

  // Get episode thumbnail URL (mock implementation)
  static Future<String?> getEpisodeThumbnail(
    String animeTitle,
    int episodeNumber,
  ) async {
    // In a real app, this would fetch from an API
    // For now, return null to use the anime cover image
    return null;
  }

  // Get episode duration (mock implementation)
  static Future<String> getEpisodeDuration(
    String animeTitle,
    int episodeNumber,
  ) async {
    // In a real app, this would be fetched from an API
    return '24:00';
  }

  // Get episode screenshots
  static Future<List<String>> getEpisodeScreenshots(
    String animeTitle,
    int episodeNumber,
  ) async {
    try {
      final episodeInfo = await getEpisodeInfo(animeTitle, episodeNumber);
      final screenshots = episodeInfo['screenshots'] as List<dynamic>?;
      return screenshots?.cast<String>() ?? [];
    } catch (e) {
      return [];
    }
  }

  // Get episode title
  static Future<String?> getEpisodeTitle(
    String animeTitle,
    int episodeNumber,
  ) async {
    try {
      final episodeInfo = await getEpisodeInfo(animeTitle, episodeNumber);
      return episodeInfo['title'];
    } catch (e) {
      return null;
    }
  }

  // Get episode description
  static Future<String?> getEpisodeDescription(
    String animeTitle,
    int episodeNumber,
  ) async {
    try {
      final episodeInfo = await getEpisodeInfo(animeTitle, episodeNumber);
      return episodeInfo['description'];
    } catch (e) {
      return null;
    }
  }

  // Get episode air date
  static Future<String?> getEpisodeAirDate(
    String animeTitle,
    int episodeNumber,
  ) async {
    try {
      final episodeInfo = await getEpisodeInfo(animeTitle, episodeNumber);
      return episodeInfo['airDate'];
    } catch (e) {
      return null;
    }
  }
}
