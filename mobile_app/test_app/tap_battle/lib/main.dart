import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'game.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PlayerSelectScreen(),
    );
  }
}

class PlayerSelectScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select Player")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: Text("Player 1"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GameScreen("player1"),
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text("Player 2"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GameScreen("player2"),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  final String playerId;
  GameScreen(this.playerId);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late TapGame game;
  bool canTap = false;
  int? startTime;

  @override
  void initState() {
    super.initState();
    game = TapGame("room1", widget.playerId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Reaction Game (${widget.playerId})")),
      body: Center(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('rooms')
              .doc("room1")
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return Text("Loading...");

            var data = snapshot.data!.data() as Map<String, dynamic>;

            startTime = data['startTime'];
            String status = data['status'] ?? "waiting";

            canTap = status == "go";

            int p1 = data['player1Time'] ?? 0;
            int p2 = data['player2Time'] ?? 0;

            String winner = "";
            if (p1 > 0 && p2 > 0) {
              winner = p1 < p2 ? "Player 1 Wins!" : "Player 2 Wins!";
            }

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  canTap ? "TAP NOW!" : "WAIT...",
                  style: TextStyle(fontSize: 30),
                ),

                SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () {
                    game.startGame();
                  },
                  child: Text("START"),
                ),

                SizedBox(height: 20),

                ElevatedButton(
                  onPressed: canTap
                      ? () {
                          int now =
                              DateTime.now().millisecondsSinceEpoch;
                          int reactionTime = now - startTime!;

                          game.sendReactionTime(reactionTime);
                        }
                      : null,
                  child: Text("TAP"),
                ),

                SizedBox(height: 30),

                DataTable(
                  columns: const [
                    DataColumn(label: Text('Player', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Time', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Delay', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: [
                    DataRow(cells: [
                      const DataCell(Text('Player 1')),
                      DataCell(Text(p1 == 0 ? '--' : '$p1 ms')),
                      DataCell(Text(
                        (p1 > 0 && p2 > 0) ? (p1 == p2 ? '0 ms' : (p1 < p2 ? '-${p2 - p1} ms' : '+${p1 - p2} ms')) : '-',
                        style: TextStyle(color: (p1 > 0 && p2 > 0 && p1 < p2) ? Colors.green : Colors.red),
                      )),
                    ]),
                    DataRow(cells: [
                      const DataCell(Text('Player 2')),
                      DataCell(Text(p2 == 0 ? '--' : '$p2 ms')),
                      DataCell(Text(
                        (p1 > 0 && p2 > 0) ? (p1 == p2 ? '0 ms' : (p2 < p1 ? '-${p1 - p2} ms' : '+${p2 - p1} ms')) : '-',
                        style: TextStyle(color: (p1 > 0 && p2 > 0 && p2 < p1) ? Colors.green : Colors.red),
                      )),
                    ]),
                  ],
                ),

                SizedBox(height: 20),

                Text(
                  winner,
                  style: const TextStyle(fontSize: 24, color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}