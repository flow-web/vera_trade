# 🗺️ Carte Interactive Mapbox - Vera Trade

## Aperçu

La carte interactive de Vera Trade utilise **Mapbox GL JS** avec **Stimulus** pour offrir une expérience cartographique riche et moderne. Cette fonctionnalité permet aux utilisateurs de visualiser et rechercher des véhicules sur une carte interactive avec de nombreuses fonctionnalités avancées.

## ✨ Fonctionnalités Principales

### 🎯 Affichage et Navigation
- **Carte interactive Mapbox** avec style streets-v12
- **Marqueurs personnalisés** pour différents types d'annonces
- **Clustering automatique** des marqueurs proches (évite le surchargement visuel)
- **Contrôles de navigation** (zoom, rotation, plein écran)
- **Géolocalisation utilisateur** avec marqueur animé

### 🔍 Recherche et Filtres
- **Geocoder intégré** pour rechercher des adresses
- **Filtres avancés** :
  - Marque et modèle
  - Fourchette de prix
  - Année de fabrication
  - Type de carburant
  - Transmission
  - Kilométrage maximum
  - Rayon de recherche depuis la position utilisateur

### 🛣️ Itinéraires et Distances
- **Calcul d'itinéraires** vers les véhicules avec l'API Directions de Mapbox
- **Affichage des distances** depuis la position utilisateur
- **Informations de trajet** : distance, durée estimée
- **Visualisation des routes** sur la carte

### 🎨 Zones de Recherche Personnalisées
- **Dessin de polygones** directement sur la carte
- **Sauvegarde des zones** en localStorage
- **Filtrage par zones dessinées**
- **Chargement des zones sauvegardées**

### 📱 Interface Utilisateur
- **Design responsive** avec TailwindCSS et DaisyUI
- **Popups informatives** au clic sur les marqueurs
- **Panneau de filtres latéral**
- **Mode mobile optimisé**
- **Guide d'utilisation intégré**

## 🚀 Installation et Configuration

### 1. Prérequis
```bash
# Mapbox et dépendances déjà installées via npm
npm install mapbox-gl @mapbox/mapbox-gl-geocoder supercluster
```

### 2. Token Mapbox
Configurez votre token Mapbox public :

```bash
# Dans .env ou variables d'environnement
export MAPBOX_ACCESS_TOKEN=pk.your_public_mapbox_token_here
```

Ou dans `config/credentials.yml.enc` :
```yaml
mapbox:
  access_token: pk.your_public_mapbox_token_here
```

### 3. Base de données
Exécutez les migrations pour ajouter les coordonnées GPS :
```bash
rails db:migrate
```

## 🏗️ Architecture Technique

### Backend (Rails)
- **Contrôleur** : `MapController` - Gère l'affichage et la recherche
- **Modèle** : `Vehicle` - Intègre le géocodage automatique
- **Routes** : Support de la recherche AJAX et géocodage

### Frontend (Stimulus + Mapbox)
- **Contrôleur Stimulus** : `map_controller.js` - Orchestration de la carte
- **Mapbox GL JS** : Rendu de la carte et interactions
- **Supercluster** : Clustering performant des marqueurs

### Styles (TailwindCSS)
- **Classes utilitaires** pour le layout responsive
- **Styles personnalisés** pour les éléments Mapbox
- **Design system** cohérent avec DaisyUI

## 📊 Données et Géolocalisation

### Géocodage Automatique
Le modèle `Vehicle` intègre un système de géocodage automatique :

```ruby
# Callback automatique lors de la sauvegarde
before_save :geocode_address, if: :should_geocode?

# Utilise l'API Mapbox Geocoding
def self.geocode_address(address_string)
  # Conversion adresse → coordonnées GPS
end
```

### Scopes Géographiques
```ruby
# Recherche par proximité
Vehicle.near(latitude, longitude, radius_km)

# Recherche dans une zone rectangulaire
Vehicle.within_bounds(north, south, east, west)

# Véhicules avec coordonnées uniquement
Vehicle.with_coordinates
```

## 🎛️ Guide d'Utilisation

### Pour les Utilisateurs
1. **Navigation** : Utilisez la molette pour zoomer, cliquez-glissez pour vous déplacer
2. **Recherche** : Utilisez le geocoder en haut à gauche pour trouver une adresse
3. **Filtres** : Ajustez les critères dans le panneau latéral
4. **Marqueurs** : Cliquez sur un cluster pour zoomer, sur un marqueur pour voir les détails
5. **Itinéraires** : Activez l'option "Afficher les itinéraires" et cliquez sur "Itinéraire" dans une popup
6. **Zones personnalisées** : Activez "Dessiner des zones" et cliquez pour créer un polygone

### Raccourcis Clavier
- **Maj + Glisser** : Rotation de la carte
- **Ctrl + Molette** : Zoom précis
- **Double-clic** : Zoom rapide

## 🔧 Personnalisation

### Styles de Marqueurs
Les marqueurs sont stylisés selon le type d'annonce :
- 🔵 **Bleu** : Véhicules
- 🟢 **Vert** : Pièces détachées  
- 🟡 **Jaune** : Services

### Configuration des Clusters
```javascript
// Dans map_controller.js
this.cluster = new Supercluster({
  radius: 40,        // Rayon de clustering
  maxZoom: 16,       // Zoom max pour clustering
  minPoints: 2       // Points minimum pour un cluster
})
```

### Styles de Carte Mapbox
Modifiez le style dans `initializeMap()` :
```javascript
style: 'mapbox://styles/mapbox/streets-v12'
// Autres options : satellite-v9, outdoors-v12, etc.
```

## 🐛 Dépannage

### Problèmes Courants

1. **Carte ne s'affiche pas**
   - Vérifiez le token Mapbox
   - Contrôlez la console pour les erreurs JavaScript
   - Assurez-vous que les CSS Mapbox sont chargés

2. **Pas de véhicules sur la carte**
   - Vérifiez que les véhicules ont des coordonnées GPS
   - Exécutez la migration de données de test

3. **Géocodage ne fonctionne pas**
   - Vérifiez la configuration du token Mapbox
   - Contrôlez les logs Rails pour les erreurs d'API

### Logs et Debugging
```bash
# Logs de géocodage
tail -f log/development.log | grep "géocodage"

# Console JavaScript pour erreurs Mapbox
# Ouvrez les DevTools > Console
```

## 📈 Performance

### Optimisations Intégrées
- **Clustering automatique** pour de grandes quantités de données
- **Lazy loading** des données via AJAX
- **Filtres côté serveur** pour réduire le payload
- **Caching des zones sauvegardées** en localStorage

### Recommandations
- Limitez l'affichage à 1000 marqueurs maximum
- Utilisez la pagination pour de grandes datasets
- Optimisez les images des véhicules (variants Active Storage)

## 🔄 Mises à Jour et Évolutions

### Fonctionnalités Futures
- [ ] **Heatmap** des zones de concentration
- [ ] **Alertes géographiques** par email
- [ ] **Export des zones** au format GeoJSON
- [ ] **Intégration traffic temps réel**
- [ ] **Mode satellite/terrain**

### API et Intégrations
- [ ] **Google Places** en alternative à Mapbox
- [ ] **OpenStreetMap** pour les données libres
- [ ] **Waze API** pour les itinéraires optimisés

## 📞 Support

Pour toute question sur la carte interactive :
- 📧 Contactez l'équipe technique
- 📖 Consultez la documentation Mapbox GL JS
- 🐛 Reportez les bugs via les issues GitHub

---

**Vera Trade** - Marketplace automobile avec géolocalisation avancée 🚗🗺️ 