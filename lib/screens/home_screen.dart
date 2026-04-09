import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/background_audio_service.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/lobby_viewmodel.dart';
import '../viewmodels/settings_viewmodel.dart';

final AudioPlayer _homeAudioPlayer = AudioPlayer();

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _headerSlide;
  late final Animation<Offset> _contentSlide;
  late final Animation<Offset> _buttonsSlide;

  late TextEditingController _nameController;
  int _selectedAvatar = 0;
  bool _isSaving = false;
  final List<Map<String, dynamic>> _avatars = [
    {'icon': Icons.person, 'color': Colors.blue},
    {'icon': Icons.sports_esports, 'color': Colors.purple},
    {'icon': Icons.bolt, 'color': Colors.amber},
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

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _headerSlide =
        Tween<Offset>(begin: const Offset(0, -0.15), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0, 0.35, curve: Curves.easeOut),
          ),
        );

    _contentSlide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.2, 0.65, curve: Curves.easeOut),
          ),
        );

    _buttonsSlide =
        Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
          ),
        );

    _animationController.forward();
    final settings = context.read<SettingsViewModel>();
    if (settings.isMusicEnabled) {
      BackgroundAudioService.playMenuMusic();
    }

    final user = context.read<AuthViewModel>().currentUser;
    _nameController = TextEditingController(text: user?.displayName ?? '');
    _selectedAvatar = user?.avatarIndex ?? 0;
  }

  @override
  void dispose() {
    BackgroundAudioService.stopMenuMusic();
    _animationController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _playClickSound() async {
    try {
      await _homeAudioPlayer.play(
        AssetSource('sounds/click.mp3'),
        volume: 0.75,
      );
    } catch (_) {
      //asset isnot ready atm
    }
  }

  void _showHowToPlay(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How to Play'),
        content: const Text(
          'Welcome to Math Battle Arena!\n\n'
          '1. Create a room or join an existing one with a Room ID.\n'
          '2. Answer math questions as fast as possible.\n'
          '3. Each correct answer gives you points and damages your opponent.\n'
          '4. The player with the most HP at the end wins!\n\n'
          'Good luck!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    try {
      final authVM = context.read<AuthViewModel>();
      await authVM.updateProfile(
        displayName: _nameController.text.trim(),
        avatarIndex: _selectedAvatar,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating profile: $e')));
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Widget _buildHomeContent() {
    final authVM = context.watch<AuthViewModel>();
    final theme = Theme.of(context);
    final onBackground = theme.colorScheme.onBackground;
    final surfaceColor = theme.colorScheme.surface;
    final outlineColor = theme.colorScheme.outline.withOpacity(0.6);
    final backgroundGradient = theme.brightness == Brightness.dark
        ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primaryContainer,
              theme.colorScheme.secondaryContainer,
            ],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1a237e), Color(0xFF004d40)],
          );

    return Container(
      decoration: BoxDecoration(gradient: backgroundGradient),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SlideTransition(
                position: _headerSlide,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Math Battle',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: onBackground,
                            ),
                          ),
                          Text(
                            'Welcome, ${authVM.currentUser?.displayName ?? 'Player'}',
                            style: TextStyle(
                              fontSize: 14,
                              color: onBackground.withOpacity(0.75),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.person, color: onBackground),
                            onPressed: () =>
                                Navigator.pushNamed(context, '/profile'),
                          ),
                          IconButton(
                            icon: Icon(Icons.settings, color: onBackground),
                            onPressed: () =>
                                Navigator.pushNamed(context, '/settings'),
                          ),
                          IconButton(
                            icon: Icon(Icons.logout, color: onBackground),
                            onPressed: () {
                              context.read<AuthViewModel>().signOut();
                              Navigator.pushReplacementNamed(context, '/');
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 48),

              SlideTransition(
                position: _contentSlide,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: surfaceColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: outlineColor),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _statItem('Wins', '${authVM.currentUser?.wins ?? 0}'),
                        _divider(),
                        _statItem(
                          'Matches',
                          '${authVM.currentUser?.totalMatches ?? 0}',
                        ),
                        _divider(),
                        _statItem(
                          'Accuracy',
                          '${((authVM.currentUser?.accuracy ?? 0) * 100).toStringAsFixed(0)}%',
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 48),

              SlideTransition(
                position: _buttonsSlide,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Choose a mode',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: onBackground,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _modeCard(
                        context,
                        icon: Icons.add_circle_outline,
                        title: 'Create Room',
                        subtitle: 'Share your Room ID with a friend',
                        color: Colors.amber,
                        onTap: () async {
                          await _playClickSound();
                          _createRoom(context);
                        },
                      ),
                      const SizedBox(height: 12),
                      _modeCard(
                        context,
                        icon: Icons.login,
                        title: 'Join Room',
                        subtitle: 'Enter a Room ID to join a battle',
                        color: Colors.greenAccent,
                        onTap: () async {
                          await _playClickSound();
                          _showJoinDialog(context);
                        },
                      ),
                      const SizedBox(height: 12),
                      _modeCard(
                        context,
                        icon: Icons.play_arrow,
                        title: 'Single Player',
                        subtitle: 'Practice against the clock',
                        color: Colors.blueAccent,
                        onTap: () async {
                          await _playClickSound();
                          Navigator.pushNamed(context, '/battle_single');
                        },
                      ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildHomeContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showHowToPlay(context),
        backgroundColor: Colors.amber,
        child: const Icon(Icons.help_outline, color: Colors.black),
      ),
    );
  }

  Widget _statItem(String label, String value) {
    final theme = Theme.of(context);
    final onBackground = theme.colorScheme.onBackground;

    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
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
      color: theme.colorScheme.onBackground.withOpacity(0.2),
    );
  }

  Widget _modeCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final surfaceColor = theme.colorScheme.surface;
    final outlineColor = theme.colorScheme.outline.withOpacity(0.6);
    final onBackground = theme.colorScheme.onBackground;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: surfaceColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: outlineColor),
            boxShadow: [
              BoxShadow(
                color: onBackground.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 36),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: onBackground,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: onBackground.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios,
                color: onBackground.withOpacity(0.6),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _createRoom(BuildContext context) async {
    final lobbyVM = context.read<LobbyViewModel>();
    final authVM = context.read<AuthViewModel>();
    await lobbyVM.createRoom(
      authVM.currentUser!.uid,
      authVM.currentUser!.displayName,
    );
    if (context.mounted) {
      Navigator.pushNamed(context, '/lobby');
    }
  }

  void _showJoinDialog(BuildContext context) {
    final controller = TextEditingController();
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.colorScheme.primary,
        title: Text(
          'Join Room',
          style: TextStyle(color: theme.colorScheme.onPrimary),
        ),
        content: TextField(
          controller: controller,
          style: TextStyle(color: theme.colorScheme.onBackground),
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            hintText: 'Enter Room ID',
            hintStyle: TextStyle(
              color: theme.colorScheme.onBackground.withOpacity(0.5),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: theme.colorScheme.onBackground.withOpacity(0.5),
              ),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.amber),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: theme.colorScheme.onPrimary.withOpacity(0.8),
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              final roomId = controller.text.trim().toUpperCase();
              if (roomId.isEmpty) return;

              Navigator.pop(ctx);

              final lobbyVM = context.read<LobbyViewModel>();
              final authVM = context.read<AuthViewModel>();

              final success = await lobbyVM.joinRoom(
                roomId,
                authVM.currentUser!.uid,
                authVM.currentUser!.displayName,
              );

              if (context.mounted && success) {
                Navigator.pushNamed(context, '/lobby');
              } else if (context.mounted && !success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Room not found or already full.'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
            child: const Text('Join', style: TextStyle(color: Colors.amber)),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsContent() {
    final settings = context.watch<SettingsViewModel>();
    final theme = Theme.of(context);
    final onBackground = theme.colorScheme.onBackground;

    return Container(
      color: theme.colorScheme.background,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: TextStyle(
                  color: onBackground,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              SwitchListTile(
                title: Text('Music', style: TextStyle(color: onBackground)),
                subtitle: Text(
                  'Play background music',
                  style: TextStyle(color: onBackground.withOpacity(0.7)),
                ),
                value: settings.isMusicEnabled,
                onChanged: context.read<SettingsViewModel>().toggleMusic,
                activeColor: Colors.amber,
              ),
              const SizedBox(height: 16),
              Text(
                'Theme',
                style: TextStyle(
                  color: onBackground,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              RadioListTile<bool>(
                title: Text(
                  'Light Theme',
                  style: TextStyle(color: onBackground),
                ),
                value: false,
                groupValue: settings.isDarkTheme,
                onChanged: (value) =>
                    context.read<SettingsViewModel>().setDarkTheme(false),
                activeColor: Colors.amber,
              ),
              RadioListTile<bool>(
                title: Text(
                  'Dark Theme',
                  style: TextStyle(color: onBackground),
                ),
                value: true,
                groupValue: settings.isDarkTheme,
                onChanged: (value) =>
                    context.read<SettingsViewModel>().setDarkTheme(true),
                activeColor: Colors.amber,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
