import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../viewmodels/lobby_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';

class LobbyScreen extends StatefulWidget {
  const LobbyScreen({super.key});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  bool _isHost = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final lobbyVM = context.read<LobbyViewModel>();
      final authVM = context.read<AuthViewModel>();
      _isHost = lobbyVM.currentRoom?.player1Id == authVM.currentUser?.uid;
      lobbyVM.addListener(_onLobbyChanged);
    });
  }

  void _onLobbyChanged() {
    if (!mounted) return;
    final lobbyVM = context.read<LobbyViewModel>();

    print('=== LOBBY CHANGED ===');
    print('status: ${lobbyVM.status}');
    print('mounted: $mounted');

    if (lobbyVM.status == LobbyStatus.ready) {
      print('=== NAVIGATING TO BATTLE ===');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/battle');
        }
      });
    }
  }

  @override
  void dispose() {
    final lobbyVM = context.read<LobbyViewModel>();
    lobbyVM.removeListener(_onLobbyChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lobbyVM = context.watch<LobbyViewModel>();
    final authVM = context.watch<AuthViewModel>();
    final isHost = lobbyVM.currentRoom?.player1Id == authVM.currentUser?.uid;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) {
          await context.read<LobbyViewModel>().leaveRoom();
          if (context.mounted) Navigator.pop(context);
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1a237e), Color(0xFF004d40)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Lobby',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Room ID card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Room ID',
                          style: TextStyle(color: Colors.white54, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          lobbyVM.roomId,
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                            letterSpacing: 8,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton.icon(
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(text: lobbyVM.roomId),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Room ID copied!'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.copy,
                            color: Colors.white54,
                            size: 16,
                          ),
                          label: const Text(
                            'Copy ID',
                            style: TextStyle(color: Colors.white54),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Player slots
                  _playerSlot('Player 1', true, isHost: true, isReady: true),
                  const SizedBox(height: 12),
                  _playerSlot(
                    'Player 2',
                    lobbyVM.player2Joined,
                    isReady: lobbyVM.player2Ready,
                  ),

                  const SizedBox(height: 32),

                  // Action button based on role
                  if (isHost)
                    _buildHostButton(lobbyVM)
                  else
                    _buildJoinerButton(lobbyVM),

                  const SizedBox(height: 16),

                  if (lobbyVM.errorMessage.isNotEmpty)
                    Text(
                      lobbyVM.errorMessage,
                      style: const TextStyle(color: Colors.redAccent),
                    ),

                  const SizedBox(height: 16),

                  // Leave button
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white38),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () async {
                      await context.read<LobbyViewModel>().leaveRoom();
                      if (context.mounted) Navigator.pop(context);
                    },
                    child: const Text('Leave Room'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHostButton(LobbyViewModel lobbyVM) {
    final canStart = lobbyVM.player2Joined && lobbyVM.player2Ready;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Difficulty',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Row(
          children: ['easy', 'medium', 'hard'].map((d) {
            final isSelected = lobbyVM.selectedDifficulty == d;
            final color = d == 'easy'
                ? Colors.greenAccent
                : d == 'medium'
                ? Colors.amber
                : Colors.redAccent;
            return Expanded(
              child: GestureDetector(
                onTap: () => context.read<LobbyViewModel>().setDifficulty(d),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withValues(alpha: 0.25)
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? color : Colors.white24,
                    ),
                  ),
                  child: Text(
                    d[0].toUpperCase() + d.substring(1),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected ? color : Colors.white38,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: canStart ? Colors.amber : Colors.white24,
              foregroundColor: canStart ? Colors.black : Colors.white38,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: canStart
                ? () async {
                    await context.read<LobbyViewModel>().startGame();
                  }
                : null,
            child: Text(
              canStart
                  ? 'Start Game'
                  : lobbyVM.player2Joined
                  ? 'Waiting for player 2 to ready up...'
                  : 'Waiting for player 2 to join...',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildJoinerButton(LobbyViewModel lobbyVM) {
    final isReady = lobbyVM.player2Ready;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isReady ? Colors.greenAccent : Colors.amber,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: isReady
            ? null
            : () async {
                await context.read<LobbyViewModel>().setReady();
              },
        child: Text(
          isReady ? 'Ready! Waiting for host...' : 'Ready Up',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _playerSlot(
    String label,
    bool isConnected, {
    bool isHost = false,
    bool isReady = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: isConnected
            ? Colors.greenAccent.withValues(alpha: 0.15)
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isConnected ? Colors.greenAccent : Colors.white24,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isConnected ? Icons.person : Icons.person_outline,
            color: isConnected ? Colors.greenAccent : Colors.white38,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: isConnected ? Colors.white : Colors.white38,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (isHost) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'HOST',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          const Spacer(),
          if (isConnected)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isReady
                    ? Colors.greenAccent.withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isReady ? 'Ready' : 'Not Ready',
                style: TextStyle(
                  color: isReady ? Colors.greenAccent : Colors.white38,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            const Text(
              'Waiting...',
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
        ],
      ),
    );
  }
}
