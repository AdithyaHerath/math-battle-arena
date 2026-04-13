# Math Battle Arena

**Math Battle Arena** is a real-time multiplayer mobile application designed to make mathematical practice both competitive and enjoyable. Built natively for Android, the application allows two players to compete simultaneously in solving arithmetic problems across varying difficulty levels. 

This project was developed for the **PUSL2023 Mobile Application Development** module

## 🎯 Project Overview
Current educational mathematics tools tend to be passive and single-player in nature. Math Battle Arena addresses this gap by introducing real-time competitive mechanics suitable for older learners and university students. By combining sub-second cloud database synchronisation with a native game engine, the app allows players to connect directly using a simple room code and battle head-to-head.

## ✨ Key Features
* **Real-Time Multiplayer:** Create or join live game rooms using a unique six-character alphanumeric code.
* **Dynamic Gameplay Engine:** Procedurally generated arithmetic questions (easy, medium, and hard). 
* **Competitive Mechanics:** A health point system starting at 100 HP per player, featuring combo multipliers (×1, ×2, ×3) and independent per-question timers.
* **Authentication System:** Secure user registration via email/password, password recovery, and an anonymous guest login option.
* **Persistent Profiles & Leaderboards:** Player statistics (total matches, wins, and cumulative answer accuracy) are saved to the cloud and ranked on a global leaderboard.
* **Practice Mode:** A single-player mode for practicing mental arithmetic against the clock.

## 🛠️ Technology Stack
The application follows a three-tier Model-View-ViewModel (MVVM) architectural pattern to ensure clean separation of UI and business logic.

* **Frontend Framework:** Flutter (Dart) for high-performance native UI rendering.
* **State Management:** Provider package for managing view models.
* **Backend Infrastructure:** * **Firebase Authentication:** For identity management and secure logins.
  * **Firebase Realtime Database:** For sub-second live game state synchronisation and lobby tracking.
  * **Cloud Firestore:** For structured, persistent storage of user profiles and match statistics.
