import 'package:graphql_flutter/graphql_flutter.dart';
import '../models/anime.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class InvalidTokenException implements Exception {}

class AniListService {
  static const String _baseUrl = 'https://graphql.anilist.co';
  late GraphQLClient _client;
  final String? accessToken;
  final int? userId;

  AniListService({this.accessToken, this.userId}) {
    _initializeClient();
  }

  void _initializeClient() {
    final HttpLink httpLink = HttpLink(_baseUrl);

    _client = GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(store: InMemoryStore()),
    );
  }

  // Trending Anime Query
  static const String _trendingQuery = '''
    query GetTrendingAnime(\$page: Int, \$perPage: Int) {
      Page(page: \$page, perPage: \$perPage) {
        media(sort: TRENDING_DESC, type: ANIME, status: RELEASING) {
          id
          title {
            userPreferred
            romaji
            english
            native
          }
          coverImage {
            large
            medium
          }
          bannerImage
          averageScore
          episodes
          status
          format
          genres
          description
        }
      }
    }
  ''';

  // Anime Details Query
  static const String _animeDetailsQuery = '''
    query GetAnimeDetails(\$id: Int) {
      Media(id: \$id, type: ANIME) {
        id
        title {
          userPreferred
          romaji
          english
          native
        }
        coverImage {
          large
          medium
        }
        bannerImage
        description
        averageScore
        episodes
        status
        season
        seasonYear
        format
        duration
        source
        genres
        tags {
          name
        }
        characters(sort: ROLE, perPage: 10) {
          nodes {
            id
            name {
              userPreferred
              full
            }
            image {
              large
            }
            role
          }
        }
        relations {
          edges {
            node {
              id
              title {
                userPreferred
                romaji
              }
              coverImage {
                large
              }
              averageScore
              status
            }
          }
        }
        recommendations(perPage: 10, sort: RATING_DESC) {
          nodes {
            mediaRecommendation {
              id
              title {
                userPreferred
                romaji
              }
              coverImage {
                large
              }
              averageScore
              status
            }
          }
        }
      }
    }
  ''';

  // Search Anime Query
  static const String _searchQuery = '''
    query SearchAnime(\$search: String, \$page: Int, \$perPage: Int) {
      Page(page: \$page, perPage: \$perPage) {
        media(search: \$search, type: ANIME, sort: POPULARITY_DESC) {
          id
          title {
            userPreferred
            romaji
            english
            native
          }
          coverImage {
            large
            medium
          }
          bannerImage
          averageScore
          episodes
          status
          format
          genres
          description
        }
      }
    }
  ''';

  // User Lists Query (requires authentication)
  static const String _userListsQuery = '''
    query GetUserLists(\$userId: Int) {
      MediaListCollection(userId: \$userId, type: ANIME) {
        lists {
          name
          isCustom
          entries {
            media {
              id
              title {
                userPreferred
                romaji
                english
                native
              }
              coverImage {
                large
                medium
              }
              bannerImage
              averageScore
              episodes
              status
              format
              genres
              description
            }
            status
            progress
          }
        }
      }
    }
  ''';

  Future<List<Anime>> getTrendingAnime({int page = 1, int perPage = 20}) async {
    try {
      final result = await _client.query(
        QueryOptions(
          document: gql(_trendingQuery),
          variables: {'page': page, 'perPage': perPage},
        ),
      );

      if (result.hasException) {
        throw Exception('Failed to fetch trending anime: ${result.exception}');
      }

      final data = result.data;
      if (data == null) return [];

      final mediaList = data['Page']['media'] as List<dynamic>;
      return mediaList.map((json) => Anime.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error fetching trending anime: $e');
    }
  }

  Future<Anime?> getAnimeDetails(int id) async {
    try {
      final result = await _client.query(
        QueryOptions(document: gql(_animeDetailsQuery), variables: {'id': id}),
      );

      if (result.hasException) {
        throw Exception('Failed to fetch anime details: ${result.exception}');
      }

      final data = result.data;
      if (data == null) return null;

      final media = data['Media'];
      return Anime.fromJson(media);
    } catch (e) {
      throw Exception('Error fetching anime details: $e');
    }
  }

  Future<List<Anime>> searchAnime(
    String query, {
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final result = await _client.query(
        QueryOptions(
          document: gql(_searchQuery),
          variables: {'search': query, 'page': page, 'perPage': perPage},
        ),
      );

      if (result.hasException) {
        throw Exception('Failed to search anime: ${result.exception}');
      }

      final data = result.data;
      if (data == null) return [];

      final mediaList = data['Page']['media'] as List<dynamic>;
      return mediaList.map((json) => Anime.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error searching anime: $e');
    }
  }

  Future<List<UserList>> getUserLists(int userId, String? accessToken) async {
    if (accessToken == null) {
      throw Exception('Access token required for user lists');
    }

    try {
      // Update client with auth token
      final HttpLink httpLink = HttpLink(
        _baseUrl,
        defaultHeaders: {'Authorization': 'Bearer $accessToken'},
      );

      final authClient = GraphQLClient(
        link: httpLink,
        cache: GraphQLCache(store: InMemoryStore()),
      );

      final result = await authClient.query(
        QueryOptions(
          document: gql(_userListsQuery),
          variables: {'userId': userId},
        ),
      );

      if (result.hasException) {
        throw Exception('Failed to fetch user lists: ${result.exception}');
      }

      final data = result.data;
      if (data == null) return [];

      final lists = data['MediaListCollection']['lists'] as List<dynamic>;
      return lists.map((list) {
        final entries = list['entries'] as List<dynamic>;
        final animes = entries
            .map((entry) => Anime.fromJson(entry['media']))
            .toList();

        return UserList(
          name: list['name'],
          animes: animes,
          isCustom: list['isCustom'] ?? false,
        );
      }).toList();
    } catch (e) {
      throw Exception('Error fetching user lists: $e');
    }
  }

  // Mock data for development/testing
  List<Anime> getMockTrendingAnime() {
    return [
      Anime(
        id: 1,
        title: "Attack on Titan",
        englishTitle: "Attack on Titan",
        description:
            "Centuries ago, mankind was slaughtered to near extinction by monstrous humanoid creatures called Titans...",
        coverImage:
            "https://s4.anilist.co/file/anilistcdn/media/anime/cover/large/bx16498-4uJqblGmzHPs.jpg",
        averageScore: 9.0,
        episodes: 25,
        status: "FINISHED",
        genres: ["Action", "Drama", "Fantasy"],
      ),
      Anime(
        id: 2,
        title: "Demon Slayer",
        englishTitle: "Demon Slayer: Kimetsu no Yaiba",
        description:
            "Tanjiro Kamado's life changes when his family is attacked by demons...",
        coverImage:
            "https://s4.anilist.co/file/anilistcdn/media/anime/cover/large/bx101922-PEn1CTc94liC.jpg",
        averageScore: 8.5,
        episodes: 26,
        status: "FINISHED",
        genres: ["Action", "Fantasy", "Historical"],
      ),
      Anime(
        id: 3,
        title: "My Hero Academia",
        englishTitle: "My Hero Academia",
        description:
            "In a world where people with superpowers are the norm, Izuku Midoriya has dreams of becoming a hero...",
        coverImage:
            "https://s4.anilist.co/file/anilistcdn/media/anime/cover/large/bx21418-XWMPME3Ap7xL.jpg",
        averageScore: 8.2,
        episodes: 13,
        status: "FINISHED",
        genres: ["Action", "Comedy", "Supernatural"],
      ),
    ];
  }

  Future<Map<String, List<dynamic>>> fetchUserAnimeLists() async {
    final query = '''
      query (
        \$userId: Int
      ) {
        MediaListCollection(userId: \$userId, type: ANIME) {
          lists {
            name
            entries {
              media {
                id
                title { romaji english native }
                coverImage { large }
                status
              }
              status
              progress
              score
            }
          }
        }
      }
    ''';
    final variables = {'userId': userId};
    final response = await http.post(
      Uri.parse('https://graphql.anilist.co'),
      headers: {
        'Content-Type': 'application/json',
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      },
      body: json.encode({'query': query, 'variables': variables}),
    );
    final data = json.decode(response.body);
    if (data['errors'] != null &&
        data['errors'].toString().contains('Invalid token')) {
      throw InvalidTokenException();
    }
    if (response.statusCode == 200) {
      final lists =
          data['data']['MediaListCollection']['lists'] as List<dynamic>;
      final Map<String, List<dynamic>> result = {};
      for (final list in lists) {
        result[list['name']] = list['entries'] as List<dynamic>;
      }
      return result;
    } else {
      throw Exception('Failed to fetch anime lists: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getDetailedAnimeInfo(int animeId) async {
    const query = '''
      query (
        \$id: Int
      ) {
        Media(id: \$id) {
          id
          title {
            romaji
            english
            native
            userPreferred
          }
          description
          coverImage {
            large
            medium
          }
          bannerImage
          episodes
          duration
          type
          status
          season
          seasonYear
          averageScore
          genres
          mediaListEntry {
            id
            status
            progress
            score
          }
          characters(sort: [ROLE, RELEVANCE], perPage: 10) {
            edges {
              role
              node {
                id
                name {
                  full
                  userPreferred
                }
                image {
                  large
                }
              }
            }
          }
          staff(sort: [RELEVANCE], perPage: 10) {
            edges {
              role
              node {
                id
                name {
                  full
                  userPreferred
                }
                image {
                  large
                }
              }
            }
          }
        }
      }
    ''';

    try {
      final response = await http.post(
        Uri.parse('https://graphql.anilist.co'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'query': query,
          'variables': {'id': animeId},
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']['Media'];
      } else {
        throw Exception('Failed to load anime details');
      }
    } catch (e) {
      throw Exception('Failed to load anime details: $e');
    }
  }

  // Add or update anime in user's AniList list
  Future<Map<String, dynamic>> saveMediaListEntry({
    required int mediaId,
    required String
    status, // e.g., CURRENT, PLANNING, COMPLETED, DROPPED, PAUSED, REPEATING
    int? progress,
    double? score,
  }) async {
    const String mutation = '''
      mutation SaveMediaListEntry(
        \$mediaId: Int,
        \$status: MediaListStatus,
        \$progress: Int,
        \$score: Float
      ) {
        SaveMediaListEntry(mediaId: \$mediaId, status: \$status, progress: \$progress, score: \$score) {
          id
          status
          score
          progress
          media {
            id
            title { romaji }
          }
        }
      }
    ''';

    final variables = {
      'mediaId': mediaId,
      'status': status,
      'progress': progress ?? 0,
      'score': score ?? 0.0,
    };

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      },
      body: json.encode({'query': mutation, 'variables': variables}),
    );

    final data = json.decode(response.body);
    if (data['errors'] != null) {
      throw Exception('AniList error: ' + data['errors'].toString());
    }
    return data['data']['SaveMediaListEntry'];
  }

  // Get episode availability for an anime
  Future<Map<int, Map<String, dynamic>>> getEpisodeAvailability(
    int animeId,
    int totalEpisodes,
  ) async {
    const String query = '''
      query GetEpisodeAvailability(\$id: Int) {
        Media(id: \$id, type: ANIME) {
          id
          title {
            userPreferred
            romaji
            english
          }
          episodes
          status
          airingSchedule(notYetAired: false, perPage: 100) {
            nodes {
              episode
              airingAt
              timeUntilAiring
              mediaId
            }
          }
          episodes {
            id
            title
            description
            number
            airingAt
            timeUntilAiring
          }
        }
      }
    ''';

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'query': query,
          'variables': {'id': animeId},
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final media = data['data']['Media'];

        final Map<int, Map<String, dynamic>> episodeData = {};

        // Process airing schedule to determine episode availability
        final airingSchedule = media['airingSchedule']?['nodes'] ?? [];
        final episodes = media['episodes'] ?? [];

        for (int episode = 1; episode <= totalEpisodes; episode++) {
          // Check if episode has aired
          final airedEpisode = airingSchedule.firstWhere(
            (node) => node['episode'] == episode,
            orElse: () => null,
          );

          // Check if episode has detailed info
          final episodeInfo = episodes.firstWhere(
            (ep) => ep['number'] == episode,
            orElse: () => null,
          );

          final Map<String, dynamic> episodeInfoMap = {};

          if (airedEpisode != null) {
            episodeInfoMap['airingSchedule'] = airedEpisode;
            episodeInfoMap['title'] =
                episodeInfo?['title'] ?? 'Episode $episode';
            episodeInfoMap['description'] = episodeInfo?['description'] ?? '';
            episodeInfoMap['media'] = media;
          }

          episodeData[episode] = episodeInfoMap;
        }

        return episodeData;
      } else {
        throw Exception('Failed to load episode availability');
      }
    } catch (e) {
      // Return empty map on error
      return {};
    }
  }

  // Delete anime from user's AniList list
  Future<void> deleteMediaListEntry(int mediaId) async {
    if (accessToken == null) {
      throw Exception('No access token available for AniList API');
    }

    // First, get the MediaList entry ID for this media
    const String query = '''
      query GetMediaListEntry(\$mediaId: Int, \$userId: Int) {
        MediaList(mediaId: \$mediaId, userId: \$userId) {
          id
        }
      }
    ''';

    try {
      final queryResponse = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode({
          'query': query,
          'variables': {'mediaId': mediaId, 'userId': userId},
        }),
      );

      if (queryResponse.statusCode == 200) {
        final queryData = json.decode(queryResponse.body);
        final mediaListEntry = queryData['data']?['MediaList'];

        if (mediaListEntry == null) {
          throw Exception('Anime not found in your list');
        }

        final mediaListId = mediaListEntry['id'];

        // Now delete using the MediaList ID
        const String mutation = '''
          mutation DeleteMediaListEntry(
            \$id: Int
          ) {
            DeleteMediaListEntry(id: \$id) {
              deleted
            }
          }
        ''';
        final variables = {'id': mediaListId};

        final response = await http.post(
          Uri.parse(_baseUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
          body: json.encode({'query': mutation, 'variables': variables}),
        );

        if (response.statusCode != 200) {
          throw Exception('HTTP ${response.statusCode}: ${response.body}');
        }

        final data = json.decode(response.body);

        // Check for GraphQL errors
        if (data['errors'] != null && data['errors'].isNotEmpty) {
          final errors = data['errors'] as List;
          final errorMessages = errors
              .map((e) => e['message'] ?? 'Unknown error')
              .join(', ');
          throw Exception('AniList API error: $errorMessages');
        }

        // Check if deletion was successful
        final result = data['data']?['DeleteMediaListEntry'];
        if (result == null) {
          throw Exception('Invalid response from AniList API');
        }
      } else {
        throw Exception('Failed to get MediaList entry');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getUserInfo() async {
    const String query = '''
      query {
        Viewer {
          id
          name
          about
          avatar {
            large
            medium
          }
          siteUrl
          createdAt
          statistics {
            anime {
              count
              meanScore
              minutesWatched
              episodesWatched
              chaptersRead
              genres {
                genre
                count
              }
            }
            manga {
              count
              meanScore
              chaptersRead
              volumesRead
              genres {
                genre
                count
              }
            }
          }
        }
      }
    ''';
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      },
      body: json.encode({'query': query}),
    );
    final data = json.decode(response.body);
    if (data['errors'] != null &&
        data['errors'].toString().contains('Invalid token')) {
      throw InvalidTokenException();
    }
    if (response.statusCode == 200) {
      return data['data']['Viewer'] as Map<String, dynamic>;
    } else {
      throw Exception('Failed to fetch user info');
    }
  }
}
