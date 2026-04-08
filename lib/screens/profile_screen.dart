import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/background_audio_service.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/settings_viewmodel.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  int _selectedAvatar = 0;
  bool _isSaving = false;

  // 12 preset avatars
  final List<Map<String, dynamic>> _avatars = [
    {'icon': Icons.person, 'color': Colors.blue},
    {'icon': Icons.sports_esports, 'color': Colors.purple},
    {'icon': Icons.bolt, 'color': Colors.amber},
    {'icon': Icons.local_fire_department, 'color': Colors.red},
    {'icon': Icons.star, 'color': Colors.orange},
    {'icon': Icons.psychology, 'color': Colors.teal},
    {'icon': Icons.military_tech, 'color': Colors.green},
    {'icon': Icons.rocket_launch, 'color': Colors.indigo},
    {'icon': Icons.emoji_events, 'color': Colors.yellow},
    {'icon': Icons.auto_awesome, 'color': Colors.pink},
    {'icon': Icons.sports_martial_arts, 'color': Colors.cyan},
    {'icon': Icons.face, 'color': Colors.deepOrange},
  ];

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthViewModel>().currentUser;
    _nameController = TextEditingController(text: user?.displayName ?? '');
    _selectedAvatar = user?.avatarIndex ?? 0;
    final settings = context.read<SettingsViewModel>();
    if (settings.isMusicEnabled) {
      BackgroundAudioService.playMenuMusic();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    BackgroundAudioService.stopMenuMusic();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final user = authVM.currentUser;
    final theme = Theme.of(context);
    final onBackground = theme.colorScheme.onBackground;
    final surfaceColor = theme.colorScheme.surface;
    final outlineColor = theme.colorScheme.outline.withOpacity(0.5);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Container(
        color: theme.colorScheme.background,
        child: SafeArea(
          child: Column(
            children: [
              // App bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: onBackground),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'Profile',
                      style: TextStyle(
                        color: onBackground,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(Icons.leaderboard, color: onBackground),
                      onPressed: () =>
                          Navigator.pushNamed(context, '/leaderboard'),
                    ),
                    IconButton(
                      icon: Icon(Icons.settings, color: onBackground),
                      onPressed: () =>
                          Navigator.pushNamed(context, '/settings'),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Avatar display
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: (_avatars[_selectedAvatar]['color'] as Color)
                              .withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _avatars[_selectedAvatar]['color'] as Color,
                            width: 3,
                          ),
                        ),
                        child: Icon(
                          _avatars[_selectedAvatar]['icon'] as IconData,
                          size: 52,
                          color: _avatars[_selectedAvatar]['color'] as Color,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Display name
                      Text(
                        user?.displayName ?? 'Player',
                        style: TextStyle(
                          color: onBackground,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      // Email or guest label
                      Text(
                        user?.isGuest == true
                            ? 'Guest Account'
                            : authVM.currentUserEmail,
                        style: TextStyle(
                          color: onBackground.withOpacity(0.75),
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Stats card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: surfaceColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: outlineColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Statistics',
                              style: TextStyle(
                                color: onBackground.withOpacity(0.8),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _statItem('Wins', '${user?.wins ?? 0}'),
                                _divider(),
                                _statItem(
                                  'Matches',
                                  '${user?.totalMatches ?? 0}',
                                ),
                                _divider(),
                                _statItem(
                                  'Accuracy',
                                  '${((user?.accuracy ?? 0) * 100).toStringAsFixed(0)}%',
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Win rate
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: onBackground.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Win Rate',
                                    style: TextStyle(
                                      color: onBackground.withOpacity(0.7),
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    user?.totalMatches == 0
                                        ? '0%'
                                        : '${(((user?.wins ?? 0) / (user?.totalMatches ?? 1)) * 100).toStringAsFixed(0)}%',
                                    style: const TextStyle(
                                      color: Colors.amber,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Edit display name
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: surfaceColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: outlineColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Display Name',
                              style: TextStyle(
                                color: onBackground.withOpacity(0.8),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _nameController,
                              style: TextStyle(color: onBackground),
                              decoration: InputDecoration(
                                hintText: 'Enter display name',
                                hintStyle: TextStyle(
                                  color: onBackground.withOpacity(0.5),
                                ),
                                prefixIcon: Icon(
                                  Icons.person,
                                  color: onBackground.withOpacity(0.7),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: onBackground.withOpacity(0.5),
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.amber,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Avatar picker
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: surfaceColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: outlineColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Choose Avatar',
                              style: TextStyle(
                                color: onBackground.withOpacity(0.8),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                  ),
                              itemCount: _avatars.length,
                              itemBuilder: (context, index) {
                                final isSelected = _selectedAvatar == index;
                                final color = _avatars[index]['color'] as Color;
                                return GestureDetector(
                                  onTap: () =>
                                      setState(() => _selectedAvatar = index),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? color.withOpacity(0.25)
                                          : onBackground.withOpacity(0.05),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? color
                                            : onBackground.withOpacity(0.25),
                                        width: isSelected ? 2.5 : 1,
                                      ),
                                    ),
                                    child: Icon(
                                      _avatars[index]['icon'] as IconData,
                                      color: isSelected
                                          ? color
                                          : onBackground.withOpacity(0.6),
                                      size: 32,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Save button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _isSaving ? null : _saveProfile,
                          child: _isSaving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.black,
                                  ),
                                )
                              : const Text(
                                  'Save Changes',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Sign out
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          side: const BorderSide(color: Colors.redAccent),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                        ),
                        onPressed: () async {
                          await context.read<AuthViewModel>().signOut();
                          if (context.mounted) {
                            Navigator.pushReplacementNamed(context, '/');
                          }
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text('Sign Out'),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Display name cannot be empty.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final success = await context.read<AuthViewModel>().updateProfile(
      displayName: name,
      avatarIndex: _selectedAvatar,
    );

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Profile updated!' : 'Failed to update profile.',
          ),
          backgroundColor: success ? Colors.green : Colors.redAccent,
        ),
      );
    }
  }

  Widget _statItem(String label, String value) {
    final theme = Theme.of(context);
    final onBackground = theme.colorScheme.onBackground;

    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: onBackground,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: onBackground.withOpacity(0.65), fontSize: 12),
        ),
      ],
    );
  }

  Widget _divider() {
    final theme = Theme.of(context);
    return Container(
      width: 1,
      height: 40,
      color: theme.colorScheme.onBackground.withOpacity(0.25),
    );
  }
}
