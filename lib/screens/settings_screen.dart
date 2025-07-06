import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/service_providers.dart';
import '../theme/app_theme.dart';
import '../services/anilist_service.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isDarkMode = true; // Default to dark mode

  @override
  Widget build(BuildContext context) {
    final fontSize = ref.watch(fontSizeProvider);
    final themeMode = ref.watch(themeModeProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Account Section
            _buildSectionTitle(context, 'Account'),
            const SizedBox(height: 12),
            _buildSettingsCard(
              context,
              children: [
                _buildSettingsTile(
                  context,
                  icon: Icons.person,
                  title: 'Account Info',
                  subtitle: 'View your AniList profile',
                  onTap: () {
                    _showAccountInfoDialog(context);
                  },
                ),
                const Divider(color: AppColors.textSecondary, height: 1),
                _buildSettingsTile(
                  context,
                  icon: Icons.logout,
                  title: 'Logout',
                  subtitle: 'Sign out of your account',
                  onTap: () async {
                    await ref.read(authStateProvider.notifier).logout();
                    if (context.mounted) {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                  },
                  titleColor: Colors.red,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Display & Interface Section
            _buildSectionTitle(context, 'Display & Interface'),
            const SizedBox(height: 12),
            _buildSettingsCard(
              context,
              children: [
                _buildSettingsTile(
                  context,
                  icon: Icons.dark_mode,
                  title: 'Theme',
                  subtitle: 'Theme switching coming soon!',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Theme switching will be implemented in the future.',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        backgroundColor: AppColors.card,
                      ),
                    );
                  },
                ),
                const Divider(color: AppColors.textSecondary, height: 1),
                _buildSettingsTile(
                  context,
                  icon: Icons.text_fields,
                  title: 'Font Size',
                  subtitle: 'Current: ${fontSize.round()}px',
                  onTap: () {
                    _showFontSizeDialog(context, fontSize);
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // About Section
            _buildSectionTitle(context, 'About'),
            const SizedBox(height: 12),
            _buildSettingsCard(
              context,
              children: [
                _buildSettingsTile(
                  context,
                  icon: Icons.info,
                  title: 'About App',
                  subtitle: 'Version, developer info',
                  onTap: () {
                    _showAboutDialog(context);
                  },
                ),
                const Divider(color: AppColors.textSecondary, height: 1),
                _buildSettingsTile(
                  context,
                  icon: Icons.privacy_tip,
                  title: 'Privacy Policy',
                  subtitle: 'How we handle your data',
                  onTap: () {
                    _showPrivacyPolicyDialog(context);
                  },
                ),
                const Divider(color: AppColors.textSecondary, height: 1),
                _buildSettingsTile(
                  context,
                  icon: Icons.description,
                  title: 'Terms of Service',
                  subtitle: 'App usage terms',
                  onTap: () {
                    _showTermsOfServiceDialog(context);
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        fontFamily: 'Poppins',
      ),
    );
  }

  Widget _buildSettingsCard(
    BuildContext context, {
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.textSecondary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? titleColor,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.textPrimary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.textPrimary, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor ?? AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontFamily: 'Poppins',
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: AppColors.textSecondary,
        size: 20,
      ),
      onTap: onTap,
    );
  }

  void _showFontSizeDialog(BuildContext context, double fontSize) {
    double tempFontSize = fontSize;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppColors.card,
          title: Text(
            'Font Size',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Adjust the font size for better readability',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    'Small',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  Expanded(
                    child: Slider(
                      value: tempFontSize,
                      min: 12.0,
                      max: 20.0,
                      divisions: 8,
                      activeColor: AppColors.textPrimary,
                      inactiveColor: AppColors.textSecondary.withValues(
                        alpha: 0.3,
                      ),
                      onChanged: (value) {
                        setState(() {
                          tempFontSize = value;
                        });
                      },
                    ),
                  ),
                  Text(
                    'Large',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Preview Text',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: tempFontSize,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(fontSizeProvider.notifier).state = tempFontSize;
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Font size updated to ${tempFontSize.round()}px',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.textPrimary,
                foregroundColor: AppColors.background,
              ),
              child: Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text(
          'About Shonen Shelf',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Shonen Shelf is an anime discovery and tracking app that integrates with AniList to provide a seamless anime experience.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Version: 1.0.0',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Build Date: ${DateTime.now().year}',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Developer',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Built with ❤️ by Aniket Pai',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Features',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '• Anime discovery and search\n• Episode tracking and availability\n• AniList integration\n• User library management\n• Dark theme design',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Close',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text(
          'Privacy Policy',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Last updated: ${DateTime.now().year}',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Information We Collect',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '• AniList account information (with your permission)\n• Your anime list and preferences\n• App usage data for improvements',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'How We Use Your Data',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '• To provide personalized anime recommendations\n• To sync your anime list with AniList\n• To improve app functionality and user experience',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Data Security',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your data is stored locally on your device and securely transmitted to AniList API. We do not sell or share your personal information.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Close',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTermsOfServiceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text(
          'Terms of Service',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Last updated: ${DateTime.now().year}',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Acceptance of Terms',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'By using Shonen Shelf, you agree to these terms of service and our privacy policy.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'App Usage',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '• Use the app for personal, non-commercial purposes\n• Respect AniList\'s terms of service\n• Do not attempt to reverse engineer the app',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Limitations',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '• The app is provided "as is" without warranties\n• We are not responsible for any data loss\n• We may update these terms at any time',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Contact',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'For questions about these terms, please contact the developer.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Close',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAccountInfoDialog(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );
    try {
      final authState = ref.read(authStateProvider);
      final anilistService = AniListService(
        accessToken: ref.read(authServiceProvider).accessToken,
        userId: authState.userId,
      );
      final userInfo = await anilistService.getUserInfo();
      if (context.mounted) {
        Navigator.of(context).pop();
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.card,
            title: Text(
              'Account Info',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (userInfo['avatar'] != null &&
                      userInfo['avatar']['large'] != null)
                    Center(
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(
                          userInfo['avatar']['large'],
                        ),
                        radius: 36,
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    'User ID: ${userInfo['id']}',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  if (userInfo['siteUrl'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: InkWell(
                        onTap: () => launchUrl(Uri.parse(userInfo['siteUrl'])),
                        child: Text(
                          'View AniList Profile',
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),
                  if (userInfo['createdAt'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Joined: ${DateTime.fromMillisecondsSinceEpoch(userInfo['createdAt'] * 1000).toLocal().toString().split(" ")[0]}',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  if (userInfo['about'] != null) ...[
                    Text(
                      'About:',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    Text(
                      userInfo['about'],
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                  if (userInfo['statistics'] != null &&
                      userInfo['statistics']['anime'] != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Anime Stats:',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    Text(
                      'Total Anime: ${userInfo['statistics']['anime']['count']}',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    Text(
                      'Mean Score: ${userInfo['statistics']['anime']['meanScore']}',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    Text(
                      'Days Watched: ${userInfo['statistics']['anime']['minutesWatched'] != null ? (userInfo['statistics']['anime']['minutesWatched'] / 1440).toStringAsFixed(1) : '-'}',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    Text(
                      'Episodes Watched: ${userInfo['statistics']['anime']['episodesWatched'] ?? '-'}',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    if (userInfo['statistics']['anime']['genres'] != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Top Genres:',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      Wrap(
                        spacing: 8,
                        children: [
                          for (var genre
                              in userInfo['statistics']['anime']['genres'].take(
                                5,
                              ))
                            Chip(
                              label: Text(
                                '${genre['genre']} (${genre['count']})',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              backgroundColor: AppColors.background,
                              labelStyle: TextStyle(
                                color: AppColors.textPrimary,
                                fontFamily: 'Poppins',
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Close',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to fetch account info: $e',
              style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
