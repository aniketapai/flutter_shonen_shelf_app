import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'settings_screen.dart';
import '../providers/service_providers.dart';
import '../services/anilist_service.dart';
import '../services/user_anime_storage_service.dart';
import 'package:flutter_shonen_shelf/theme/app_theme.dart';
import 'anime_details_screen.dart';
import 'search_screen.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, List<dynamic>> _dismissedItems = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Consumer(
          builder: (context, ref, _) {
            final animeListsAsync = ref.watch(userAnimeListsProvider);
            return animeListsAsync.when(
              data: (animeLists) => Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            ref.invalidate(userAnimeListsProvider);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Library refreshed!'),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'My Library',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.refresh,
                                size: 20,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.settings),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const SettingsScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  // Tab Bar
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.08,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      labelColor: AppColors.textPrimary,
                      unselectedLabelColor: AppColors.textSecondary,
                      labelStyle: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                      labelPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      tabs: const [
                        Tab(text: 'Watching'),
                        Tab(text: 'Planning'),
                        Tab(text: 'Completed'),
                        Tab(text: 'Dropped'),
                      ],
                      indicatorPadding: const EdgeInsets.symmetric(
                        horizontal: -6,
                        vertical: 2,
                      ),
                      splashFactory: NoSplash.splashFactory,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Tab Content
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildAnimeList(
                          'Watching',
                          Icons.play_circle,
                          animeLists['Watching'],
                        ),
                        _buildAnimeList(
                          'Planning',
                          Icons.bookmark,
                          animeLists['Planning'],
                        ),
                        _buildAnimeList(
                          'Completed',
                          Icons.check_circle,
                          animeLists['Completed'],
                        ),
                        _buildAnimeList(
                          'Dropped',
                          Icons.cancel,
                          animeLists['Dropped'],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) {
                if (e is InvalidTokenException) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lock, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        const Text(
                          'Your AniList session has expired.',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text('Please re-authenticate to continue.'),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () async {
                            await ref.read(authStateProvider.notifier).logout();
                          },
                          icon: const Icon(Icons.login),
                          label: const Text('Re-authenticate'),
                        ),
                      ],
                    ),
                  );
                }
                return Center(child: Text('Error loading anime lists'));
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildAnimeList(
    String listType,
    IconData icon,
    List<dynamic>? entries,
  ) {
    final fontSize = ref.watch(fontSizeProvider);
    // Filter out dismissed items
    final dismissedItems = _dismissedItems[listType] ?? [];
    final filteredEntries =
        entries?.where((entry) {
          final mediaId = entry['media']['id'];
          return !dismissedItems.contains(mediaId);
        }).toList() ??
        [];
    if (filteredEntries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            // List Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  listType,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: fontSize + 2,
                  ),
                ),
                Text(
                  '0 anime',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: fontSize,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Empty State
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.08,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        icon,
                        size: 40,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No anime in $listType',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontWeight: FontWeight.bold,
                            fontSize: fontSize + 2,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start adding anime to your $listType list',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w400,
                        fontSize: fontSize,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: 180,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const SearchScreen(),
                            ),
                          );
                        },
                        icon: Icon(Icons.add, color: AppColors.textPrimary),
                        label: Text(
                          'Add Anime',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: fontSize,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.card,
                          foregroundColor: AppColors.textPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                          textStyle: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: fontSize,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
    // Show anime list
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                listType,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: fontSize + 2,
                ),
              ),
              Text(
                '${filteredEntries.length} anime',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: fontSize,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: filteredEntries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final entry = filteredEntries[index];
                final media = entry['media'];
                return Dismissible(
                  key: Key('anime_${media['id']}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete, color: Colors.white, size: 30),
                        SizedBox(height: 4),
                        Text(
                          'Delete',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: AppColors.card,
                          title: const Text(
                            'Delete Anime',
                            style: TextStyle(color: AppColors.textPrimary),
                          ),
                          content: Text(
                            'Remove "${media['title']['romaji']}" from your $listType list?',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  onDismissed: (direction) async {
                    try {
                      // Show loading dialog
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) =>
                            const Center(child: CircularProgressIndicator()),
                      );

                      // Add to dismissed items to prevent rebuild issues
                      final listKey = listType;
                      if (!_dismissedItems.containsKey(listKey)) {
                        _dismissedItems[listKey] = [];
                      }
                      _dismissedItems[listKey]!.add(media['id']);

                      // Delete from AniList API
                      final authState = ref.read(authStateProvider);
                      final accessToken = ref
                          .read(authServiceProvider)
                          .accessToken;

                      if (!authState.isAuthenticated) {
                        throw Exception(
                          'User not authenticated. Please log in again.',
                        );
                      }

                      if (accessToken == null) {
                        throw Exception(
                          'No access token available. Please log in again.',
                        );
                      }

                      final anilistService = AniListService(
                        accessToken: accessToken,
                        userId: authState.userId,
                      );

                      try {
                        await anilistService.deleteMediaListEntry(media['id']);
                      } catch (apiError) {
                        // If API fails, we'll still remove locally but show a warning
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Warning: Could not sync with AniList. Anime removed locally.',
                              ),
                              backgroundColor: Colors.orange,
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        }
                      }

                      // Close loading dialog
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }

                      // Also update local storage to mark as deleted
                      try {
                        final storageService = ref.read(
                          userAnimeStorageServiceProvider,
                        );
                        await storageService.updateAnimeUserData(media['id'], {
                          'status': null,
                          'progress': 0,
                          'score': 0,
                          'deleted': true,
                          'lastUpdated': DateTime.now().toIso8601String(),
                        });
                      } catch (storageError) {
                        // Local storage error is non-critical
                      }

                      // Refresh the lists to get updated data
                      ref.invalidate(userAnimeListsProvider);

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Removed "${media['title']['romaji']}" from your list',
                            ),
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    } catch (e) {
                      // Close loading dialog
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to delete: $e'),
                            backgroundColor: Colors.red,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    }
                  },
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              AnimeDetailsScreen(anime: entry),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              media['coverImage']['large'],
                              width: 56,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  media['title']['romaji'] ?? '',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: fontSize,
                                      ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Progress: ${entry['progress'] ?? 0}',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(fontSize: fontSize - 2),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 18),
                              const SizedBox(width: 4),
                              Text(
                                entry['score'] != null && entry['score'] > 0
                                    ? '${entry['score']}'
                                    : '--',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: fontSize,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
