import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/anime_video_service.dart';
import '../services/episode_content_service.dart';
import 'server_selection_screen.dart';

class EpisodeCardsScreen extends StatefulWidget {
  final String animeTitle;
  final int totalEpisodes;
  final String? coverImage;

  const EpisodeCardsScreen({
    super.key,
    required this.animeTitle,
    required this.totalEpisodes,
    this.coverImage,
  });

  @override
  State<EpisodeCardsScreen> createState() => _EpisodeCardsScreenState();
}

class _EpisodeCardsScreenState extends State<EpisodeCardsScreen> {
  Map<int, List<String>> _episodeAvailability = {};
  Map<int, Map<String, dynamic>> _episodeInfo = {};
  bool _isLoadingAvailability = true;
  bool _isLoadingContent = true;
  int _currentPage = 0;
  static const int _episodesPerPage = 12;

  int get _totalPages => (widget.totalEpisodes / _episodesPerPage).ceil();

  @override
  void initState() {
    super.initState();
    _loadEpisodeData();
  }

  Future<void> _loadEpisodeData() async {
    setState(() {
      _isLoadingAvailability = true;
      _isLoadingContent = true;
    });

    try {
      // Load availability and content in parallel
      final results = await Future.wait([
        AnimeVideoService.getEpisodeAvailability(
          widget.animeTitle,
          widget.totalEpisodes,
        ),
        EpisodeContentService.getAllEpisodeInfo(
          widget.animeTitle,
          widget.totalEpisodes,
        ),
      ]);

      setState(() {
        _episodeAvailability = results[0] as Map<int, List<String>>;
        _episodeInfo = results[1] as Map<int, Map<String, dynamic>>;
        _isLoadingAvailability = false;
        _isLoadingContent = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingAvailability = false;
        _isLoadingContent = false;
      });
    }
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
      body: Column(
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
                          'Powered by Gojo • Tap any episode to start streaming',
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
            child: _isLoadingAvailability
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Powered by Gojo',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Loading episodes...',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: _getEpisodesForCurrentPage().length,
                    itemBuilder: (context, index) {
                      final episodeNumber = _getEpisodesForCurrentPage()[index];
                      final availableServers =
                          _episodeAvailability[episodeNumber] ?? [];
                      final isAvailable = availableServers.isNotEmpty;

                      return _buildEpisodeCard(
                        episodeNumber,
                        isAvailable,
                        availableServers,
                      );
                    },
                  ),
          ),

          // Pagination Controls
          if (_totalPages > 1)
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                  Row(
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
                              : AppColors.textSecondary.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                  ),
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
            ),
        ],
      ),
    );
  }

  Widget _buildEpisodeCard(
    int episodeNumber,
    bool isAvailable,
    List<String> availableServers,
  ) {
    final episodeInfo = _episodeInfo[episodeNumber];
    final episodeTitle = episodeInfo?['title'] ?? 'Episode $episodeNumber';
    final episodeDescription =
        episodeInfo?['description'] ??
        'Episode $episodeNumber of the anime series.';
    final episodeThumbnail = episodeInfo?['thumbnail'] ?? widget.coverImage;
    final episodeDuration = episodeInfo?['duration'] ?? '24:00';

    return GestureDetector(
      onTap: () => _selectEpisode(episodeNumber),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isAvailable
                ? AppColors.textSecondary
                : AppColors.textSecondary.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            // Episode Thumbnail
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      image: episodeThumbnail != null
                          ? DecorationImage(
                              image: NetworkImage(episodeThumbnail),
                              fit: BoxFit.cover,
                            )
                          : null,
                      color: episodeThumbnail == null
                          ? AppColors.background
                          : null,
                    ),
                    child: episodeThumbnail == null
                        ? Center(
                            child: Icon(
                              Icons.play_circle_outline,
                              size: 48,
                              color: AppColors.textSecondary,
                            ),
                          )
                        : null,
                  ),
                  // Duration overlay
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        episodeDuration,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Play button overlay
                  if (isAvailable)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Episode Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            episodeTitle,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isAvailable)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Episode $episodeNumber',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Text(
                        episodeDescription,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.play_circle,
                          size: 16,
                          color: isAvailable
                              ? Colors.green
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isAvailable
                              ? '${availableServers.length} servers'
                              : 'Not available',
                          style: TextStyle(
                            color: isAvailable
                                ? Colors.green
                                : AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectEpisode(int episodeNumber) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ServerSelectionScreen(
          animeTitle: widget.animeTitle,
          episodeNumber: episodeNumber,
        ),
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
