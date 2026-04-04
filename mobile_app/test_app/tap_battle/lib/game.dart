// import 'package:flame/game.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class TapGame {
//   final String roomId;
//   final String playerId; // "player1" or "player2"

//   TapGame(this.roomId, this.playerId);

//   void increaseScore() {
//     FirebaseFirestore.instance
//         .collection('rooms')
//         .doc(roomId)
//         .update({
//       playerId: FieldValue.increment(1),
//     });
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';

class TapGame {
  final String roomId;
  final String playerId;

  TapGame(this.roomId, this.playerId);

  void startGame() {
    FirebaseFirestore.instance.collection('rooms').doc(roomId).update({
      "startTime": DateTime.now().millisecondsSinceEpoch,
      "status": "go",
      "player1Time": 0,
      "player2Time": 0,
    });
  }

  void sendReactionTime(int time) {
    FirebaseFirestore.instance.collection('rooms').doc(roomId).update({
      "${playerId}Time": time,
    });
  }
}