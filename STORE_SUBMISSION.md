# Vera Trade — Store Submission Guide

## Architecture

Vera Trade utilise **Capacitor** pour wrapper le site web `veratrade.fr` dans un shell natif iOS/Android.
Le code source est 100% web (Rails + Hotwire). Les apps natives sont des WebViews pointant vers le site live.

## Pre-requis

### Dev Machine
- **iOS** : Mac avec Xcode 16+, CocoaPods
- **Android** : Android Studio, JDK 17+, SDK 34+

### Comptes
- **Apple Developer** : 99$/an — https://developer.apple.com/programs/
- **Google Play Console** : 25$ one-time — https://play.google.com/console

---

## Build iOS

```bash
# Sync les plugins et config
npx cap sync ios

# Ouvrir dans Xcode
npx cap open ios
```

Dans Xcode :
1. Signer avec le team Apple Developer (Signing & Capabilities)
2. Bundle ID : `fr.veratrade.app`
3. Version : `1.0.0` (Build : `1`)
4. Scheme : `App` → Any iOS Device
5. Product → Archive
6. Distribute App → App Store Connect

### App Store Connect (https://appstoreconnect.apple.com)
- Creer l'app avec Bundle ID `fr.veratrade.app`
- Remplir :
  - Nom : Vera Trade
  - Sous-titre : Marketplace auto premium
  - Categorie : Shopping
  - Mots-cles : voiture, occasion, automobile, marketplace, annonce auto
  - Description (FR) : voir ci-dessous
  - Screenshots : 6.7" (iPhone 15 Pro Max) + 12.9" (iPad Pro)
  - Icone : auto-importee depuis le build
  - URL politique de confidentialite : https://veratrade.fr/privacy
  - URL support : https://veratrade.fr/contact

---

## Build Android

```bash
# Sync
npx cap sync android

# Ouvrir dans Android Studio
npx cap open android
```

Dans Android Studio :
1. Build → Generate Signed Bundle/APK
2. Choisir Android App Bundle (.aab)
3. Creer/utiliser un keystore (GARDER LE KEYSTORE EN SECURITE)
4. Build type : release
5. Signer et generer

### Google Play Console
- Creer l'app "Vera Trade"
- Remplir le store listing :
  - Titre : Vera Trade
  - Description courte : Marketplace automobile premium
  - Description : voir ci-dessous
  - Categorie : Shopping
  - Screenshots : telephone + tablette (7" et 10")
  - Icone 512x512 : `/public/icons/icon-512x512.png`
  - Feature graphic 1024x500 : a creer
  - Politique de confidentialite : https://veratrade.fr/privacy
  - Classification de contenu : remplir le questionnaire
- Production → Creer une release → Upload .aab

---

## Description Store (FR)

```
Vera Trade — La marketplace automobile premium.

Achetez et vendez des vehicules en toute confiance :

• Annonces verifiees avec dossier complet
• Messagerie directe entre acheteurs et vendeurs
• Recherche avancee (marque, prix, annee, carburant, km)
• Favoris pour suivre vos annonces preferees
• Profil vendeur avec historique et avis
• Notifications push pour ne rien manquer

Que vous soyez particulier ou professionnel, Vera Trade vous offre
une experience d'achat-vente automobile moderne et securisee.

Telechargez Vera Trade et trouvez votre prochaine voiture.
```

---

## Checklist avant soumission

- [ ] Privacy policy live sur https://veratrade.fr/privacy
- [ ] Terms of service live sur https://veratrade.fr/terms
- [ ] Contact/support page accessible
- [ ] Screenshots 6.7" iPhone + 12.9" iPad
- [ ] Screenshots Android phone + tablet 7" + 10"
- [ ] Feature graphic Android 1024x500
- [ ] Tester le deep linking (ouvrir une annonce depuis un lien)
- [ ] Tester les push notifications
- [ ] App review : Apple prend 1-7 jours, Google 1-3 jours

---

## Commandes utiles

```bash
# Sync apres chaque changement de config
npx cap sync

# Ouvrir les projets natifs
npx cap open ios
npx cap open android

# Live reload en dev (optionnel)
# Dans capacitor.config.ts, changer server.url vers http://localhost:3000
```

## Keystore Android

**CRITIQUE** : Le keystore signe les mises a jour. Si perdu, impossible de publier des updates.

```bash
# Generer un keystore (une seule fois)
keytool -genkey -v -keystore vera-trade-release.keystore \
  -alias vera-trade -keyalg RSA -keysize 2048 -validity 10000

# Stocker le keystore et le mot de passe dans un endroit securise (1Password, etc.)
```
