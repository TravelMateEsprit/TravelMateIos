# TravelMate iOS

Application mobile iOS pour TravelMate - Plateforme de gestion d'assurances voyage.

## 📱 Description

TravelMate est une application iOS qui permet aux utilisateurs de gérer leurs assurances voyage et aux agences de proposer leurs services. L'application offre une interface intuitive pour consulter, souscrire et gérer des assurances voyage.

## ✨ Fonctionnalités

- **Authentification** : Connexion et inscription pour utilisateurs et agences
- **Gestion des assurances** : Consultation et souscription aux offres d'assurance
- **Tableau de bord agence** : Interface dédiée pour les agences
- **Profil utilisateur** : Gestion des informations personnelles
- **Offres en temps réel** : Mise à jour via WebSocket
- **Groupes** : Fonctionnalité de gestion de groupes

## 🛠 Technologies

- **Langage** : Swift
- **UI Framework** : UIKit
- **Architecture** : MVC
- **Networking** : URLSession
- **Communication temps réel** : WebSocket

## 📋 Prérequis

- Xcode 14.0 ou supérieur
- iOS 15.0 ou supérieur
- macOS Monterey ou supérieur
- CocoaPods (si applicable)

## 🚀 Installation

1. Cloner le repository :
```bash
git clone https://github.com/TravelMateEsprit/TravelMateIos.git
cd TravelMateIos
```

2. Ouvrir le projet dans Xcode :
```bash
open TravelMate.xcodeproj
```

3. Sélectionner le simulateur ou appareil cible

4. Compiler et lancer l'application (Cmd + R)

## ⚙️ Configuration

Avant de lancer l'application, configurer l'URL de l'API backend dans le fichier `TravelMate/Config/Config.swift` :

```swift
static var apiBaseURL: String {
    return "http://localhost:3000"  // Pour simulateur
    // return "http://VOTRE_IP:3000" // Pour appareil physique
}
```

## 📱 Utilisation

1. **Premier lancement** : Écran de bienvenue avec options de connexion/inscription
2. **Inscription** : Choisir entre compte utilisateur ou agence
3. **Navigation** : Interface à onglets pour accéder aux différentes sections
4. **Assurances** : Parcourir et souscrire aux offres disponibles
5. **Profil** : Gérer vos informations personnelles

## 👥 Types d'utilisateurs

- **Utilisateur** : Consultation et souscription aux assurances
- **Agence** : Création et gestion d'offres d'assurance
- **Admin** : Gestion complète de la plateforme

## 📄 Licence

Ce projet est développé dans le cadre académique à Esprit.

## 👨‍💻 Équipe

Projet TravelMate - Esprit
