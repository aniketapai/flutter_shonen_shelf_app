import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import '../services/anilist_service.dart';
import '../theme/app_theme.dart';
import '../providers/service_providers.dart';
import 'enhanced_webview_screen.dart';

class AnimeDetailsScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> anime;

  const AnimeDetailsScreen({super.key, required this.anime});

  @override
  ConsumerState<AnimeDetailsScreen> createState() => _AnimeDetailsScreenState();
}

class _AnimeDetailsScreenState extends ConsumerState<AnimeDetailsScreen> {
  bool _isSynopsisExpanded = false;
  Map<String, dynamic>? _detailedAnime;
  bool _isLoading = true;

  // Add state for add-to-list UI
  bool _showAddToList = false;
  String? _selectedStatus;
  int? _progress;
  double? _score;
  late TextEditingController _progressController;
  late TextEditingController _scoreController;

  static const List<String> _statusOptions = [
    'CURRENT',
    'PLANNING',
    'COMPLETED',
    'DROPPED',
    'PAUSED',
    'REPEATING',
  ];

  @override
  void initState() {
    super.initState();
    _progressController = TextEditingController();
    _scoreController = TextEditingController();
    _loadDetailedAnime();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _scoreController.dispose();
    super.dispose();
  }

  Future<void> _loadDetailedAnime() async {
    try {
      final anilistService = ref.read(anilistServiceProvider);
      final storageService = ref.read(userAnimeStorageServiceProvider);
      final animeId = widget.anime['media']['id'];

      // First try to load from local storage
      final localUserData = await storageService.getAnimeUserData(animeId);

      // Fetch fresh data from AniList API
      final detailedAnime = await anilistService.getDetailedAnimeInfo(animeId);
      final mediaListEntry = detailedAnime['mediaListEntry'] ?? {};

      // Use API data if available, otherwise fall back to local data
      final entryStatus = mediaListEntry['status'] ?? localUserData?['status'];
      final entryProgress =
          mediaListEntry['progress'] ?? localUserData?['progress'] ?? 0;
      final entryScore = mediaListEntry['score'] ?? localUserData?['score'];

      // Store the user data locally for persistence
      if (mediaListEntry.isNotEmpty) {
        await storageService.storeUserAnimeData(animeId, {
          'status': entryStatus,
          'progress': entryProgress,
          'score': entryScore,
          'lastUpdated': DateTime.now().toIso8601String(),
        });
      }

      setState(() {
        // Initialize the edit dialog/dropdown with the user's actual data
        _selectedStatus = _statusOptions.contains(entryStatus)
            ? entryStatus
            : 'CURRENT';
        _progress = entryProgress is int ? entryProgress : 0;
        _score = entryScore != null ? (entryScore as num).toDouble() : 0.0;
        _progressController.text = (_progress ?? 0).toString();
        _scoreController.text = (_score ?? 0.0).toString();

        // Merge user data into detailedAnime for easy access
        _detailedAnime = Map<String, dynamic>.from(detailedAnime);
        _detailedAnime!['progress'] = entryProgress;
        _detailedAnime!['score'] = entryScore;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Fallback to original data if API fails
      _detailedAnime = widget.anime['media'];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final anime = _detailedAnime ?? widget.anime['media'] ?? widget.anime;
    // final progress = anime['progress'];
    // final episodes = anime['episodes'] ?? anime['media']?['episodes'] ?? '?';
    // final score = anime['score'];
    // final originalStatus =
    //     (_detailedAnime ?? widget.anime['media'] ?? widget.anime)['status'];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // App Bar with Hero Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Banner Image Background
                  Image.network(
                    anime['bannerImage'] ?? anime['coverImage']['large'] ?? '',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.card,
                        child: Icon(
                          Icons.tv,
                          size: 80,
                          color: AppColors.textSecondary,
                        ),
                      );
                    },
                  ),
                  // Glass Morphism Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.background.withValues(alpha: 0.3),
                          AppColors.background.withValues(alpha: 0.7),
                          AppColors.background.withValues(alpha: 0.9),
                        ],
                      ),
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.background.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                  ),
                  // Cover Image in Bottom Left
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          anime['coverImage']['large'] ?? '',
                          width: 120,
                          height: 180,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 120,
                              height: 180,
                              color: AppColors.card,
                              child: Icon(
                                Icons.tv,
                                size: 50,
                                color: AppColors.textSecondary,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  // Status Badge in Bottom Right
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(anime['status']),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        _getStatusText(anime['status']),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Rating
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        anime['title']['userPreferred'] ??
                            anime['title']['english'] ??
                            'Unknown Title',
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                              fontFamily: 'Poppins',
                            ),
                      ),
                      const SizedBox(height: 8),
                      if (anime['averageScore'] != null)
                        Row(
                          children: [
                            Icon(Icons.star, size: 16, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              '${(anime['averageScore'] / 10).toStringAsFixed(1)}',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: AppColors.textSecondary,
                                    fontFamily: 'Poppins',
                                  ),
                            ),
                          ],
                        ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Action Buttons
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                _showEpisodeBlocks(context, anime);
                              },
                              icon: const Icon(Icons.grid_view),
                              label: const Text('View Episodes'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.textPrimary,
                                foregroundColor: AppColors.background,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _showAddToList = !_showAddToList;
                                });
                              },
                              icon: const Icon(Icons.add),
                              label: Text(
                                _getStatusText(anime['status']) == 'Not in List'
                                    ? 'Add to List'
                                    : 'Edit List',
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.textPrimary,
                                side: BorderSide(color: AppColors.textPrimary),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  if (_showAddToList) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.textSecondary),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Status Dropdown
                          Text(
                            'Status',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          DropdownButton<String>(
                            value: _statusOptions.contains(_selectedStatus)
                                ? _selectedStatus
                                : 'CURRENT',
                            isExpanded: true,
                            items: const [
                              DropdownMenuItem(
                                value: 'CURRENT',
                                child: Text('Watching'),
                              ),
                              DropdownMenuItem(
                                value: 'PLANNING',
                                child: Text('Planning'),
                              ),
                              DropdownMenuItem(
                                value: 'COMPLETED',
                                child: Text('Completed'),
                              ),
                              DropdownMenuItem(
                                value: 'DROPPED',
                                child: Text('Dropped'),
                              ),
                              DropdownMenuItem(
                                value: 'PAUSED',
                                child: Text('Paused'),
                              ),
                              DropdownMenuItem(
                                value: 'REPEATING',
                                child: Text('Repeating'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedStatus = value;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          // Progress Field
                          Text(
                            'Progress (Episodes Watched)',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 60,
                                child: TextFormField(
                                  controller: _progressController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                ),
                              ),
                              if (anime['episodes'] != null) ...[
                                const SizedBox(width: 8),
                                Text('/ ${anime['episodes']}'),
                              ],
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Score Field
                          Text(
                            'Score',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: 60,
                            child: TextFormField(
                              controller: _scoreController,
                              keyboardType: TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              onChanged: (val) {
                                setState(() {
                                  _score = double.tryParse(val) ?? 0.0;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Save Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                                try {
                                  final authState = ref.read(authStateProvider);
                                  final anilistService = AniListService(
                                    accessToken: ref
                                        .read(authServiceProvider)
                                        .accessToken,
                                    userId: authState.userId,
                                  );
                                  final newProgress =
                                      int.tryParse(_progressController.text) ??
                                      0;
                                  final newScore =
                                      double.tryParse(_scoreController.text) ??
                                      0.0;
                                  final animeId =
                                      anime['id'] ?? anime['media']?['id'];
                                  await anilistService.saveMediaListEntry(
                                    mediaId: animeId,
                                    status:
                                        _statusOptions.contains(_selectedStatus)
                                        ? _selectedStatus!
                                        : 'CURRENT',
                                    progress: newProgress,
                                    score: newScore,
                                  );

                                  // Also store locally for persistence
                                  final storageService = ref.read(
                                    userAnimeStorageServiceProvider,
                                  );
                                  await storageService
                                      .updateAnimeUserData(animeId, {
                                        'status': _selectedStatus,
                                        'progress': newProgress,
                                        'score': newScore,
                                        'lastUpdated': DateTime.now()
                                            .toIso8601String(),
                                      });
                                  Navigator.of(
                                    context,
                                  ).pop(); // Remove loading dialog
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Anime updated in your list!',
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                    ),
                                  );
                                  setState(() {
                                    _showAddToList = false;
                                    _selectedStatus =
                                        _statusOptions.contains(_selectedStatus)
                                        ? _selectedStatus
                                        : 'CURRENT';
                                    _progress = newProgress;
                                    _score = newScore;
                                    _progressController.text = (_progress ?? 0)
                                        .toString();
                                    _scoreController.text = (_score ?? 0.0)
                                        .toString();
                                    if (_detailedAnime != null) {
                                      _detailedAnime =
                                          Map<String, dynamic>.from(
                                            _detailedAnime!,
                                          );
                                      _detailedAnime!['progress'] = newProgress;
                                      _detailedAnime!['score'] = newScore;
                                    }
                                    _isLoading = true;
                                  });
                                  await _loadDetailedAnime();
                                } catch (e) {
                                  Navigator.of(
                                    context,
                                  ).pop(); // Remove loading dialog
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Failed to update list: $e',
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: const Text('Save'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Synopsis (Expandable)
                  if (anime['description'] != null &&
                      anime['description'].toString().isNotEmpty) ...[
                    _buildExpandableSynopsis(context, anime),
                    const SizedBox(height: 24),
                  ],

                  // Genres
                  if (anime['genres'] != null &&
                      anime['genres'].isNotEmpty) ...[
                    Text(
                      'Genres',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (anime['genres'] as List)
                          .map(
                            (genre) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              child: Text(
                                genre,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppColors.textSecondary),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Stats
                  _buildStatsSection(context, anime),

                  const SizedBox(height: 24),

                  // Characters Section
                  if (anime['characters'] != null &&
                      anime['characters']['edges'] != null &&
                      (anime['characters']['edges'] as List).isNotEmpty) ...[
                    _buildCharactersSection(context, anime),
                    const SizedBox(height: 24),
                  ],

                  // Staff Section
                  if (anime['staff'] != null &&
                      anime['staff']['edges'] != null &&
                      (anime['staff']['edges'] as List).isNotEmpty) ...[
                    _buildStaffSection(context, anime),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableSynopsis(
    BuildContext context,
    Map<String, dynamic> anime,
  ) {
    final description = _cleanDescription(anime['description']);
    final isLongDescription = description.length > 200;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Synopsis',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isSynopsisExpanded
              ? description
              : description.substring(
                  0,
                  isLongDescription ? 200 : description.length,
                ),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
            height: 1.5,
            fontFamily: 'Poppins',
          ),
        ),
        if (isLongDescription) ...[
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              setState(() {
                _isSynopsisExpanded = !_isSynopsisExpanded;
              });
            },
            child: Text(
              _isSynopsisExpanded ? 'Read Less' : 'Read More',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCharactersSection(
    BuildContext context,
    Map<String, dynamic> anime,
  ) {
    final characters = anime['characters']['edges'] as List? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Characters',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: characters.length,
            itemBuilder: (context, index) {
              final character = characters[index];
              final node = character['node'];
              final role = character['role'];

              return Container(
                width: 100,
                margin: const EdgeInsets.only(right: 12),
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: node['image']['large'] != null
                            ? Image.network(
                                node['image']['large'],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.person,
                                    size: 30,
                                    color: AppColors.textSecondary,
                                  );
                                },
                              )
                            : Icon(
                                Icons.person,
                                size: 30,
                                color: AppColors.textSecondary,
                              ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      node['name']['userPreferred'] ??
                          node['name']['full'] ??
                          'Unknown',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      role ?? 'Unknown',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontFamily: 'Poppins',
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStaffSection(BuildContext context, Map<String, dynamic> anime) {
    final staff = anime['staff']['edges'] as List? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Staff',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: staff.length,
            itemBuilder: (context, index) {
              final member = staff[index];
              final node = member['node'];
              final role = member['role'];

              return Container(
                width: 100,
                margin: const EdgeInsets.only(right: 12),
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: node['image']['large'] != null
                            ? Image.network(
                                node['image']['large'],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.person,
                                    size: 30,
                                    color: AppColors.textSecondary,
                                  );
                                },
                              )
                            : Icon(
                                Icons.person,
                                size: 30,
                                color: AppColors.textSecondary,
                              ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      node['name']['userPreferred'] ??
                          node['name']['full'] ??
                          'Unknown',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      role ?? 'Unknown',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontFamily: 'Poppins',
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection(BuildContext context, Map<String, dynamic> anime) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildStatItem(
                context,
                'Episodes',
                anime['episodes']?.toString() ?? '?',
                Icons.tv,
              ),
              const SizedBox(width: 24),
              _buildStatItem(
                context,
                'Duration',
                '${anime['duration'] ?? '?'} min',
                Icons.schedule,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatItem(
                context,
                'Type',
                anime['type'] ?? 'Unknown',
                Icons.category,
              ),
              const SizedBox(width: 24),
              _buildStatItem(
                context,
                'Season',
                _getSeasonText(anime['season'], anime['seasonYear']),
                Icons.calendar_today,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'FINISHED':
        return Colors.green;
      case 'RELEASING':
        return Colors.blue;
      case 'NOT_YET_RELEASED':
        return Colors.orange;
      case 'CANCELLED':
        return Colors.red;
      case 'HIATUS':
        return Colors.yellow;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'FINISHED':
        return 'Finished';
      case 'RELEASING':
        return 'Ongoing';
      case 'NOT_YET_RELEASED':
        return 'Upcoming';
      case 'CANCELLED':
        return 'Cancelled';
      case 'HIATUS':
        return 'Hiatus';
      default:
        return status ?? 'N/A'; // Show the raw value or 'N/A' if null
    }
  }

  String _getSeasonText(String? season, int? year) {
    if (season == null || year == null) return 'Unknown';
    return '${season.capitalize()} $year';
  }

  void _showEpisodeBlocks(BuildContext context, Map<String, dynamic> anime) {
    final animeTitle =
        anime['title']['userPreferred'] ??
        anime['title']['english'] ??
        'Unknown Title';

    // Open enhanced WebView directly
    final encodedTitle = Uri.encodeComponent(animeTitle.replaceAll(' ', '+'));
    final url = 'https://animekai.bz/browser?keyword=$encodedTitle';

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            EnhancedWebViewScreen(title: animeTitle, url: url),
      ),
    );
  }

  String _cleanDescription(String description) {
    // Remove HTML tags and clean up the description
    return description
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .trim();
  }
}

extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}
