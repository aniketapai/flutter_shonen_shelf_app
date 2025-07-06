class Anime {
  final int id;
  final String title;
  final String? englishTitle;
  final String? nativeTitle;
  final String? description;
  final String? coverImage;
  final String? bannerImage;
  final List<String> genres;
  final List<String> tags;
  final double? averageScore;
  final int? episodes;
  final String? status;
  final String? season;
  final int? seasonYear;
  final String? format;
  final int? duration;
  final String? source;
  final List<Character> characters;
  final List<Anime> relatedAnime;
  final List<Anime> recommendations;

  Anime({
    required this.id,
    required this.title,
    this.englishTitle,
    this.nativeTitle,
    this.description,
    this.coverImage,
    this.bannerImage,
    this.genres = const [],
    this.tags = const [],
    this.averageScore,
    this.episodes,
    this.status,
    this.season,
    this.seasonYear,
    this.format,
    this.duration,
    this.source,
    this.characters = const [],
    this.relatedAnime = const [],
    this.recommendations = const [],
  });

  factory Anime.fromJson(Map<String, dynamic> json) {
    return Anime(
      id: json['id'] ?? 0,
      title: json['title']?['userPreferred'] ?? json['title']?['romaji'] ?? '',
      englishTitle: json['title']?['english'],
      nativeTitle: json['title']?['native'],
      description: json['description'],
      coverImage: json['coverImage']?['large'],
      bannerImage: json['bannerImage'],
      genres: List<String>.from(json['genres'] ?? []),
      tags:
          (json['tags'] as List<dynamic>?)
              ?.map((tag) => tag['name'] as String)
              .toList() ??
          [],
      averageScore: json['averageScore']?.toDouble(),
      episodes: json['episodes'],
      status: json['status'],
      season: json['season'],
      seasonYear: json['seasonYear'],
      format: json['format'],
      duration: json['duration'],
      source: json['source'],
      characters:
          (json['characters']?['nodes'] as List<dynamic>?)
              ?.map((char) => Character.fromJson(char))
              .toList() ??
          [],
      relatedAnime:
          (json['relations']?['edges'] as List<dynamic>?)
              ?.map((rel) => Anime.fromJson(rel['node']))
              .toList() ??
          [],
      recommendations:
          (json['recommendations']?['nodes'] as List<dynamic>?)
              ?.map((rec) => Anime.fromJson(rec['mediaRecommendation']))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'englishTitle': englishTitle,
      'nativeTitle': nativeTitle,
      'description': description,
      'coverImage': coverImage,
      'bannerImage': bannerImage,
      'genres': genres,
      'tags': tags,
      'averageScore': averageScore,
      'episodes': episodes,
      'status': status,
      'season': season,
      'seasonYear': seasonYear,
      'format': format,
      'duration': duration,
      'source': source,
    };
  }
}

class Character {
  final int id;
  final String name;
  final String? image;
  final String? role;

  Character({required this.id, required this.name, this.image, this.role});

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'] ?? 0,
      name: json['name']?['userPreferred'] ?? json['name']?['full'] ?? '',
      image: json['image']?['large'],
      role: json['role'],
    );
  }
}

class UserList {
  final String name;
  final List<Anime> animes;
  final bool isCustom;

  UserList({required this.name, required this.animes, this.isCustom = false});
}
