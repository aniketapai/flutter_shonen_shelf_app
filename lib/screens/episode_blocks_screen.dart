import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/episode_content_service.dart';
import '../services/anilist_service.dart';

class EpisodeBlocksScreen extends StatefulWidget {
  final String animeTitle;
  final int totalEpisodes;
  final String? coverImage;
  final int? animeId;

  const EpisodeBlocksScreen({
    super.key,
    required this.animeTitle,
    required this.totalEpisodes,
    this.coverImage,
    this.animeId,
  });

  @override
  State<EpisodeBlocksScreen> createState() => _EpisodeBlocksScreenState();
}

class _EpisodeBlocksScreenState extends State<EpisodeBlocksScreen> {
  Map<int, bool> _episodeReleaseStatus = {};
  Map<int, Map<String, dynamic>> _episodeInfo = {};
  bool _isLoading = true;
  int _currentPage = 0;
  static const int _episodesPerPage = 24;

  int get _totalPages => (widget.totalEpisodes / _episodesPerPage).ceil();

  @override
  void initState() {
    super.initState();
    _loadEpisodeData();
  }

  Future<void> _loadEpisodeData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch episode availability from AniList API
      final Map<int, bool> releaseStatus = {};

      if (widget.animeId != null) {
        // Try to get episode availability from AniList
        try {
          final anilistService = AniListService();
          final episodeData = await anilistService.getEpisodeAvailability(
            widget.animeId!,
            widget.totalEpisodes,
          );

          // Parse the episode data to determine release status
          for (int episode = 1; episode <= widget.totalEpisodes; episode++) {
            final episodeInfo = episodeData[episode];
            if (episodeInfo != null) {
              // Check if episode is available based on various criteria
              final isReleased = _determineEpisodeReleaseStatus(episodeInfo);
              releaseStatus[episode] = isReleased;
            } else {
              // If no data available, assume not released
              releaseStatus[episode] = false;
            }
          }
        } catch (e) {
          print('Error fetching episode availability: $e');
          // Fallback: use mock logic
          for (int episode = 1; episode <= widget.totalEpisodes; episode++) {
            releaseStatus[episode] =
                episode <= 8; // Mock: first 8 episodes released
          }
        }
      } else {
        // Fallback: use mock logic when no anime ID
        for (int episode = 1; episode <= widget.totalEpisodes; episode++) {
          releaseStatus[episode] =
              episode <= 8; // Mock: first 8 episodes released
        }
      }

      // Load episode info
      final episodeInfo = await EpisodeContentService.getAllEpisodeInfo(
        widget.animeTitle,
        widget.totalEpisodes,
      );

      setState(() {
        _episodeInfo = episodeInfo;
        _episodeReleaseStatus = releaseStatus;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading episode data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _determineEpisodeReleaseStatus(Map<String, dynamic> episodeInfo) {
    // Check various indicators of episode availability
    final hasTitle =
        episodeInfo['title'] != null &&
        episodeInfo['title'].toString().isNotEmpty;
    final hasDescription =
        episodeInfo['description'] != null &&
        episodeInfo['description'].toString().isNotEmpty;
    final hasAiringSchedule = episodeInfo['airingSchedule'] != null;
    final hasMedia = episodeInfo['media'] != null;

    // Episode is considered released if it has basic info and airing schedule
    return hasTitle && hasAiringSchedule;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Episodes',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.textPrimary),
            onPressed: _loadEpisodeData,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.textPrimary),
                  const SizedBox(height: 16),
                  Text(
                    'Loading episodes...',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Header Info
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (widget.coverImage != null)
                            Container(
                              width: 60,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: NetworkImage(widget.coverImage!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.animeTitle,
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${widget.totalEpisodes} Episodes',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Released episodes are available for viewing',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Pagination Info
                if (_totalPages > 1)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Text(
                          'Page ${_currentPage + 1} of $_totalPages',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Episodes ${_getStartEpisode()} - ${_getEndEpisode()}',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                // Episodes Grid
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: _getEpisodesForCurrentPage().length,
                    itemBuilder: (context, index) {
                      final episodeNumber = _getEpisodesForCurrentPage()[index];
                      final isReleased =
                          _episodeReleaseStatus[episodeNumber] ?? false;
                      final episodeInfo = _episodeInfo[episodeNumber];

                      return _buildEpisodeBlock(
                        episodeNumber,
                        isReleased,
                        episodeInfo,
                      );
                    },
                  ),
                ),

                // Pagination Controls
                if (_totalPages > 1) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Previous Page
                      IconButton(
                        onPressed: _currentPage > 0
                            ? () {
                                setState(() {
                                  _currentPage--;
                                });
                              }
                            : null,
                        icon: Icon(
                          Icons.chevron_left,
                          color: _currentPage > 0
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),

                      // Page Indicators
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _totalPages,
                            (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: index == _currentPage
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary.withValues(
                                        alpha: 0.3,
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Next Page
                      IconButton(
                        onPressed: _currentPage < _totalPages - 1
                            ? () {
                                setState(() {
                                  _currentPage++;
                                });
                              }
                            : null,
                        icon: Icon(
                          Icons.chevron_right,
                          color: _currentPage < _totalPages - 1
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
    );
  }

  Widget _buildEpisodeBlock(
    int episodeNumber,
    bool isReleased,
    Map<String, dynamic>? episodeInfo,
  ) {
    final episodeTitle = episodeInfo?['title'] ?? 'Episode $episodeNumber';
    final episodeDescription =
        episodeInfo?['description'] ??
        'Episode $episodeNumber of ${widget.animeTitle}';

    return GestureDetector(
      onTap: isReleased
          ? () => _showEpisodeDetails(episodeNumber, episodeInfo)
          : null,
      child: Container(
        decoration: BoxDecoration(
          color: isReleased
              ? AppColors.card
              : AppColors.card.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isReleased
                ? AppColors.textSecondary
                : AppColors.textSecondary.withValues(alpha: 0.3),
          ),
        ),
        child: Stack(
          children: [
            // Episode Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Episode Number
                  Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      color: isReleased
                          ? AppColors.textPrimary.withValues(alpha: 0.1)
                          : AppColors.textSecondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        episodeNumber.toString(),
                        style: TextStyle(
                          color: isReleased
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Episode Title
                  Text(
                    episodeTitle,
                    style: TextStyle(
                      color: isReleased
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Episode Description
                  Expanded(
                    child: Text(
                      episodeDescription,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Status Indicator
                  Row(
                    children: [
                      Icon(
                        isReleased ? Icons.check_circle : Icons.block,
                        size: 16,
                        color: isReleased
                            ? Colors.green
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isReleased ? 'Available' : 'Not Released',
                        style: TextStyle(
                          color: isReleased
                              ? Colors.green
                              : AppColors.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Release Status Badge
            if (!isReleased)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(Icons.block, size: 12, color: Colors.white),
                ),
              ),
            // Available Badge for Released Episodes
            if (isReleased)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showEpisodeDetails(
    int episodeNumber,
    Map<String, dynamic>? episodeInfo,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text(
          'Episode $episodeNumber',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              episodeInfo?['title'] ?? 'Episode $episodeNumber',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              episodeInfo?['description'] ??
                  'Episode $episodeNumber of ${widget.animeTitle}',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Episode Available',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Close',
              style: TextStyle(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  List<int> _getEpisodesForCurrentPage() {
    final startEpisode = _getStartEpisode();
    final endEpisode = _getEndEpisode();
    return List.generate(
      endEpisode - startEpisode + 1,
      (index) => startEpisode + index,
    );
  }

  int _getStartEpisode() {
    return _currentPage * _episodesPerPage + 1;
  }

  int _getEndEpisode() {
    final endEpisode = (_currentPage + 1) * _episodesPerPage;
    return endEpisode > widget.totalEpisodes
        ? widget.totalEpisodes
        : endEpisode;
  }
}
