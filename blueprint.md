# Agent's Obscura - Blueprint

## Vue d'ensemble

Agent's Obscura est une application mobile de jeu de réalité augmentée où les utilisateurs, appelés agents, peuvent laisser des messages virtuels (appelés "obscura") à des endroits géographiques spécifiques. D'autres agents peuvent alors découvrir ces messages en se rendant physiquement à ces endroits, gagnant ainsi des "points de découverte".

## Fonctionnalités

*   **Authentification des utilisateurs :** Les agents s'authentifient à l'aide de leur compte Google.
*   **Profil de l'agent :** Chaque agent a un nom d'utilisateur unique et un nombre de points de découverte.
*   **Création d'Obscura :** Les agents peuvent créer des messages texte et les associer à leur position géographique actuelle.
*   **Détection d'Obscura :** Les agents peuvent utiliser l'écran de détection pour trouver des obscuras à proximité.
*   **Points de découverte :** Les agents gagnent 10 points pour chaque obscura qu'ils découvrent.
*   **Persistance des données :** Toutes les données (agents, obscuras) sont stockées dans Cloud Firestore.

## Structure du projet

Le projet est structuré comme suit :

*   **`lib/`**
    *   **`main.dart`**: Point d'entrée de l'application.
    *   **`models/`**: Contient les modèles de données (`user_model.dart`, `message_model.dart`).
    *   **`services/`**: Contient les services pour interagir avec Firebase (`auth_service.dart`, `user_service.dart`).
    *   **`viewmodels/`**: Contient les viewmodels pour gérer l'état de l'interface utilisateur (`user_viewmodel.dart`).
    *   **`screens/`**: Contient les différents écrans de l'application (`home_screen_dispatcher.dart`, `profile_config_screen.dart`, `dashboard_screen.dart`, `create_message_screen.dart`, `detection_screen.dart`).
*   **`pubspec.yaml`**: Fichier de configuration du projet, y compris les dépendances.

## Style & Design

*   **Thème :** L'application utilise le thème Material Design par défaut de Flutter.
*   **Couleurs :** Le jeu de couleurs principal est basé sur le bleu.
*   **Typographie :** La typographie par défaut de Flutter est utilisée.

## Plan pour les changements actuels

Le plan suivant a été exécuté :

1.  **Configurer le projet Flutter :** Création d'un nouveau projet Flutter.
2.  **Configurer Firebase :** Ajout de Firebase au projet Flutter.
3.  **Créer les modèles de données :**
    *   `UserModel` : pour représenter un utilisateur.
    *   `MessageModel` : pour représenter un message.
4.  **Créer les services :**
    *   `AuthService` : pour gérer l'authentification des utilisateurs.
    *   `UserService` : pour gérer les données utilisateur dans Firestore.
5.  **Créer le ViewModel :**
    *   `UserViewModel` : pour gérer l'état de l'utilisateur.
6.  **Créer les écrans :**
    *   `HomeScreenDispatcher` : pour rediriger les utilisateurs en fonction de leur état d'authentification et de leur profil.
    *   `ProfileConfigScreen` : pour permettre aux nouveaux utilisateurs de configurer leur nom d'utilisateur.
    *   `DashboardScreen` : le tableau de bord principal de l'application.
    *   `CreateMessageScreen` : pour permettre aux utilisateurs de créer de nouveaux messages.
    *   `DetectionScreen` : pour permettre aux utilisateurs de détecter des messages à proximité.
7.  **Mettre à jour `main.dart` :** pour initialiser l'application avec les fournisseurs nécessaires et le répartiteur de l'écran d'accueil.
8.  **Ajouter les dépendances :** ajout des packages nécessaires à `pubspec.yaml`.
