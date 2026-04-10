# VERA TRADE — Audit Technique & Vision Produit
### Document confidentiel — Avril 2026

---

## Executive Summary

Vera Trade est une **marketplace automobile multi-asset** en cours de construction. Le projet vise a devenir la plateforme de reference pour l'achat, la vente, la location et les services lies aux vehicules — toutes categories confondues (voitures, motos, bateaux, avions, engins de chantier, etc.).

L'ambition n'est pas de concurrencer Leboncoin frontalement (29M visites/mois, effets reseau installes), mais d'attaquer ses **contraintes structurelles** : messagerie bridee, pas de multi-party, pas de prestataires integres, pas de dossier partage, quotas photos/videos. Vera Trade propose une experience transactionnelle complete la ou LBC s'arrete au premier contact.

**Statut** : Pre-lancement. MVP fonctionnel deploye sur veratrade.fr. PWA installable + shells natifs iOS/Android prets.

---

## I. Etat Technique Actuel

### Stack

| Couche | Technologie |
|--------|-------------|
| Backend | **Rails 8.0.2** (Ruby) |
| Base de donnees | **PostgreSQL** |
| Frontend | **Hotwire** (Turbo + Stimulus) |
| CSS | **Tailwind CSS 4.1** + **DaisyUI 5** |
| Build JS | **esbuild** |
| Auth | **Devise** |
| Temps reel | **Solid Cable** (WebSockets) |
| File d'attente | **Solid Queue** |
| Cache | **Solid Cache** |
| Upload media | **Active Storage** + **Cloudinary** |
| Deploiement | **Kamal** (Docker) |
| PWA | Service Worker + Manifest |
| Apps natives | **Capacitor 8** (iOS + Android) |

### Metriques du codebase

| Metrique | Valeur |
|----------|--------|
| Commits | 26 |
| Fichiers Ruby (app/) | 32 |
| Templates ERB | 43 |
| Modeles ActiveRecord | 11 |
| Controllers | 11 (370 LOC) |
| Stimulus controllers | 8 |
| Tables PostgreSQL | 16 |
| Colonnes totales | 215 |
| Gems Ruby | 25 |
| Deps NPM | 11 |
| Tests | 0 (dette technique) |

### Schema de donnees (16 tables)

```
users              — Auth Devise, KYC status, roles
vehicles           — 73 colonnes, multi-asset (voiture/moto/bateau/avion/BTP/PL)
listings           — Annonces liees aux vehicules
categories         — Categorisation des vehicules
conversations      — Messagerie 1:1 (a refactor en multi-party)
messages           — Messages textuels
media_folders      — Dossiers de documents vehicule
media_items        — Fichiers dans les dossiers (flag private)
guest_accounts     — Comptes temporaires (annonce sans inscription)
temporary_listings — Annonces temporaires avant validation
reports            — Signalements (polymorphe)
wallets            — Portefeuille utilisateur
wallet_transactions — Historique debit/credit
active_storage_*   — Gestion des fichiers (Rails native)
```

### Point fort architectural : schema multi-asset

La table `vehicles` contient deja **73 colonnes** couvrant :
- **Voitures** : fiscal_power, co2_emissions, fuel_type, transmission, doors, interior_material...
- **Bateaux** : draft, hull_material, number_of_cabins, number_of_berths, number_of_engines
- **BTP/Machines** : engine_hours, operating_hours, lifting_capacity, maximum_reach, bucket_capacity
- **Poids lourds** : towing_capacity, axles, sleeping_cab, emission_standard
- **Aviation** : flight_hours, ceiling, range
- **Generique** : cylinder_capacity, engine_type, cooling_type, registration, VIN, license_plate

Ce schema est deja pret pour supporter la vision multi-categorie sans migration majeure.

### Fonctionnalites livrees (production)

| Feature | Status |
|---------|--------|
| Recherche full-text | ✅ |
| Filtres serveur (marque, carburant, transmission) | ✅ |
| Filtres prix/annee/km | ✅ |
| Tri (prix, annee, date) | ✅ |
| Pagination (12/page) | ✅ |
| Page show complete | ✅ |
| SEO slugs | ✅ |
| Sitemap XML dynamique | ✅ |
| Meta title/desc dynamiques | ✅ |
| Favoris (add/remove/list) | ✅ |
| Profil vendeur | ✅ |
| Annonces du meme vendeur | ✅ |
| Compteur de vues | ✅ |
| PWA installable (manifest + SW + offline) | ✅ |
| Bottom nav mobile (safe areas) | ✅ |
| Shell natif iOS (Capacitor) | ✅ |
| Shell natif Android (Capacitor) | ✅ |
| Auth Devise (inscription/connexion) | ✅ |
| Messagerie 1:1 (Turbo Stream) | ✅ |
| Upload media (Cloudinary) | ✅ |

---

## II. Vision Produit — 12 Modules

La vision produit de Vera Trade se decompose en **12 modules fonctionnels** qui, ensemble, forment un ecosysteme transactionnel complet.

### Module 1 — Taxonomie Vehicules (300+ sous-types)

**10 categories principales** :
1. Voiture (30 sous-types : berline, SUV, coupe, cabriolet, EV, hybride, collection...)
2. Moto (20 sous-types : sportive, custom, trail, scooter, electrique...)
3. Bateau (20 sous-types : voilier, yacht, catamaran, jet ski, peniche...)
4. Quad/VTT (20 sous-types : loisir, utilitaire, sportif, electrique, SxS...)
5. Avion (20 sous-types : tourisme, affaires, ULM, planeur, drone...)
6. Competition (30 sous-types : F1, rallye, GT3, drift, karting, dragster...)
7. Chantier (30 sous-types : excavatrice, grue, bulldozer, foreuse, nacelle...)
8. Buggy/Kart (30 sous-types : tout-terrain, course, electrique, enfants...)
9. Camion/Benne (30 sous-types : benne, citerne, frigo, plateau, porte-voiture...)
10. Autre (100+ types speciaux : camping-car, militaire, funeraire, PMR, trottinette, drone agricole, sous-marin de plaisance...)

**Formulaire de depot dynamique** : champs conditionnels selon la sous-categorie (carburant pour voiture, cylindree pour moto, longueur pour bateau, heures de vol pour avion, PTAC pour camion).

**Recherche dynamique** : filtres adaptatifs par categorie.

### Module 2 — Dashboard Unifie

Un seul dashboard contextuel selon le role (acheteur, vendeur, prestataire, admin).

- Calendrier integre (RDV, appels, publications programmees)
- Connexion Instagram + Facebook (publication sociale programmee)
- Generation IA (descriptions, reviews, reponses aux avis) — OpenAI
- Multi-profil entreprise : employés avec permissions limitees (pas d'acces wallet/confidentialite)
- 2FA activable par l'utilisateur
- Suppression de compte conditionnelle (0 litige, 0 solde, double auth)
- Centre de rappels/alertes (contrats a signer, livraisons, notifications)
- Favoris et recherches sauvegardees
- Rapports & stats par role (vues, interactions, historique, evaluations)
- Elasticsearch : full-text search avec autocompletion et pertinence

### Module 3 — Messagerie Avancee

Evolution de la messagerie 1:1 actuelle vers un systeme multi-party complet.

**Base** : Statuts (envoye/recu/lu), pieces jointes avec preview, notifications temps reel, archivage, reponses rapides/modeles, historique negociations (offres/contre-offres), emojis et reactions.

**Video** : Chat video vendeur-acheteur (inspection a distance), planification d'appels liee au calendrier, enregistrement avec consentement, partage d'ecran, capture pendant l'appel, qualite adaptative.

**Securite** : Anti-spam/anti-fraude, signalement contenu abusif, support client integre, anonymisation donnees perso (telephone/email masques jusqu'a un stade), traduction automatique (marche international).

### Module 4 — Services & Prestataires

Marketplace de services auto integree a la plateforme principale.

- Discovery : recherche par mot-cle, categories populaires, prestataires verifies (badges), carte interactive
- Profil prestataire : infos, galerie realisations (avant/apres), CV/parcours, services detailles avec tarifs, calendrier de disponibilites
- Evaluations : note globale, badges reputation, notes ciblees (communication, qualite, rapport qualite/prix), avis textuels
- Integration annonces : candidature prestataire sur annonces, invitation dans conversations (multi-party)
- Devis personnalises, suivi de projet basique
- Outils marketing prestataires (mise en avant payante = Business tier)

### Module 5 — Carte Interactive

- Marqueurs personnalises par annonce (style par marque/prix/categorie)
- Clustering (regroupement/eclatement au zoom)
- Infobulles : photo, titre, prix, km + lien annonce
- Filtrage visuel synchronise avec les filtres de recherche
- POI : garages partenaires, stations de recharge EV, centres CT, prestataires
- Zones de recherche personnalisees (polygones/cercles dessinables)
- Distance utilisateur ↔ vehicule + itineraire
- Sauvegarde zones favorites + alertes geographiques (email)
- Heatmaps : concentration annonces, prix moyens par zone
- Evenements auto sur la carte

### Module 6 — Gestion des Litiges

- Formulaire guide d'ouverture (type de probleme + preuves)
- Espace de communication structure entre parties
- Upload preuves par chaque partie
- Mediation par admin de la plateforme
- Statuts : ouvert → en attente → en mediation → resolu → clos
- Historique des litiges par utilisateur
- Regles et procedures publiques
- Outils de resolution (remboursement partiel, retour, accord mutuel)
- Integration paiement : remboursement automatise

### Module 7 — Paiements & Transactions

- Escrow (sequestre) : compte intermediaire acheteur-vendeur
- Paiement en plusieurs fois / credit
- Marge plateforme (take rate 2-5%)
- Smart Contract Escrow : fonds liberes quand conditions remplies (livraison, conformite)
- Depots de garantie en stablecoins (location)

### Module 8 — VERASIM (Comparateur Multi-Usage)

Outil de comparaison de vehicules inspire des benchmarks GPU/CPU.

- **Radar chart "Toile d'araignee"** : axes Performance/Consommation/Confort/Securite/Prix/Equipements/Fiabilite. Un polygone colore par vehicule, superposition pour visualiser les ecarts.
- TCO (Cout Total de Possession) : assurance, entretien, carburant, decote
- Ponderations personnalisees par l'utilisateur
- Historique des prix du marche
- Impact environnemental detaille
- Comparaison visuelle des dimensions
- Mode "Duel" visuel
- Comparaisons sauvegardees et partagees par la communaute
- Integration directe avec les annonces et le financement

### Module 9 — Agents IA (12+)

| Agent | Fonction |
|-------|----------|
| Assistant de recherche | Guide contextuel etape par etape (apparait a droite quand region selectionnee) |
| Support client general | FAQ, guide utilisation, resolution problemes |
| Support litiges | Collecte infos, guide resolution, qualification |
| Feedback client | Sollicitation avis post-transaction |
| Prise de RDV vehicule | Essais, inspections, maintenance |
| Assistant d'achat | Recommandations, vehicules similaires, services complementaires |
| Estimation prix | Valeur marchande basee sur donnees marche |
| Aide financement | Options credit/LOA/LLD, devis assurance |
| Qualification leads | Qualifie acheteurs pour vendeurs et vice versa |
| Soumission documents | Guide KYC, immatriculation, CT, cession |
| Negociation assistee | Conseils prix marche, facilitation offres/contre-offres |
| Rappels maintenance | Dates maintenance, historique entretien |

### Module 10 — Forum Communautaire

- Categories/sous-categories (marque, modele, type de vehicule)
- Threads, recherche avancee, tags, reputation (likes, badges)
- Editeur riche, notifications, messagerie privee
- Galerie photo/video, fiches techniques, calculateurs
- Integration carte et annonces
- Calendrier d'evenements automobiles (synchro Mapbox)

### Module 11 — Evenements Automobiles

- Fiches evenements : nom, dates, lieu, type (salon/rassemblement/course), GPS
- Marqueurs Mapbox interactifs avec pop-ups
- Filtrage synchronise liste ↔ carte
- Sources : sites officiels, federations (FIA, FFSA), medias specialises

### Module 12 — Blockchain & Crypto (Vision Long Terme)

- Historique vehicule sur blockchain (propriete, reparations, km — inviolable)
- NFTs de certificat de propriete numerique
- Tracabilite pieces automobiles
- Loyalty tokens (jetons fidelite)
- Parrainage avec recompenses crypto
- Crowdfunding crypto (importation, renovation)
- Smart lease contracts
- Reputation blockchain (notes inviolables)
- DAO gouvernance (tres long terme)

---

## III. Modele Economique

### Revenue primaire — Abonnements SaaS

| Tier | Prix | Features |
|------|------|----------|
| Free | 0€ | Consulter, 1 annonce, messagerie limitee |
| Pro | 79€/mois | Annonces illimitees, showroom, analytics |
| Business | 199€/mois | Visite virtuelle IA, badge verifie, mise en avant, multi-profil |
| Enterprise | Sur devis | API, integrations custom, SLA |

### Revenue secondaire (Phase 2+)

| Source | Phase | Mecanisme |
|--------|-------|-----------|
| Commission transactions | Phase 2 | Take rate 2-5% via escrow |
| Logistique/transport | Phase 2 | Commission courtage convoyeurs |
| Assurance partenaire | Phase 3 | Affiliation courtier, commission par contrat |
| Mise en avant prestataires | Phase 2 | Placement payant (feature Business) |
| VERASIM premium | Phase 2 | Analyses avancees reservees aux abonnes |

### Revenue tertiaire (Phase 4+)

| Source | Phase | Mecanisme |
|--------|-------|-----------|
| Financement/credit | Phase 4 | Partenariat bancaire (ORIAS requis) |
| Blockchain/NFT | Phase 4+ | Loyalty tokens, escrow smart contracts |

---

## IV. Architecture Cible

```
                        ┌─────────────────────────┐
                        │      CLIENTS            │
                        │                         │
                        │  PWA (Chrome/Safari)    │
                        │  iOS App (Capacitor)    │
                        │  Android App (Capacitor)│
                        └────────────┬────────────┘
                                     │
                        ┌────────────▼────────────┐
                        │     EDGE / CDN          │
                        │  Cloudflare / Kamal     │
                        └────────────┬────────────┘
                                     │
            ┌────────────────────────▼────────────────────────┐
            │                 RAILS 8 CORE                    │
            │                                                 │
            │  Controllers ─── Views (Hotwire/Turbo)          │
            │  Models ──────── ActiveRecord + PostgreSQL      │
            │  Jobs ────────── Solid Queue                    │
            │  Cache ───────── Solid Cache                    │
            │  WebSockets ──── Solid Cable (Action Cable)     │
            │  Auth ────────── Devise + 2FA                   │
            │  Upload ──────── Active Storage + Cloudinary    │
            │  Search ──────── Elasticsearch (a venir)        │
            └──────┬──────────────┬───────────────┬───────────┘
                   │              │               │
         ┌─────────▼──┐  ┌───────▼───────┐  ┌────▼────────┐
         │ PostgreSQL  │  │  Cloudinary   │  │  OpenAI API │
         │ 16 tables   │  │  Media CDN    │  │  Agents IA  │
         │ 215 cols    │  │               │  │             │
         └─────────────┘  └───────────────┘  └─────────────┘
                                                     │
                   ┌─────────────────────────────────▼──┐
                   │         INTEGRATIONS FUTURES        │
                   │                                     │
                   │  Stripe Connect (escrow)            │
                   │  Mapbox (carte interactive)         │
                   │  Instagram/Facebook API (social)    │
                   │  Elasticsearch (search)             │
                   │  WebRTC (video chat)                │
                   │  Blockchain (historique vehicule)    │
                   └─────────────────────────────────────┘
```

---

## V. Feuille de Route

| Phase | Nom | Objectif | Modules |
|-------|-----|----------|---------|
| **0** | Usage interne | MVP fonctionnel, 0 Excel | Core (✅), PWA (✅), recherche (✅) |
| **1** | Beta partenaires | 5 users actifs/semaine | Messagerie multi-party, taxonomie, carte |
| **2** | Commercialisation | MRR > 2k€, churn < 10% | Escrow, services, VERASIM, agents IA |
| **3** | Scale | SaaS autonome, 100+ clients | Forum, evenements, dashboard avance |
| **4** | Structuration | Holding, app native, exit | Blockchain, financement, DAO |

---

## VI. Risques & Dette Technique

| Risque | Severite | Mitigation |
|--------|----------|------------|
| 0 tests automatises | Haute | Ajouter system tests Capybara sur flux critiques |
| Messagerie 1:1 hardcodee | Haute | Refactor conversations → multi-party (prerequis Module 3) |
| Wallet naif (pas d'escrow) | Haute | Brancher Stripe Connect avant toute transaction |
| Schema vehicles 73 colonnes | Moyenne | Acceptable si indexe correctement, sinon decomposer en STI |
| Listing model 18 lignes | Moyenne | Enrichir avec validations et logique metier |
| 0 jobs metier | Moyenne | Creer jobs pour notifications, cleanup, stats |
| README vide | Basse | Rediger apres stabilisation Phase 1 |

---

## VII. Metriques Comparatives

| Critere | Leboncoin | AutoScout24 | Vera Trade (vision) |
|---------|-----------|-------------|---------------------|
| Messagerie | Bridee (anti-fraude) | Basique 1:1 | Multi-party + video + prestataires |
| Prestataires integres | Non | Non | Oui (marketplace services) |
| Dossier partage | Non | Non | Oui (media_folders + permissions) |
| Upload video | Limite | Limite | Illimite (Cloudinary) |
| Escrow | Non | Non | Oui (Stripe Connect) |
| Comparateur | Non | Basique | VERASIM (radar chart, TCO, communautaire) |
| IA | Non | Non | 12 agents (recherche, support, estimation) |
| Blockchain | Non | Non | Historique vehicule inviolable |
| Multi-asset | Non | Voitures/motos | 10 categories, 300+ sous-types |
| App native | Oui | Oui | Oui (Capacitor, pret) |

---

## VIII. Conclusion

Vera Trade n'est pas un clone de Leboncoin. C'est une **plateforme transactionnelle complete** qui couvre l'integralite du cycle de vie d'une transaction vehicule : decouverte → comparaison → contact → inspection (video) → negociation → paiement (escrow) → livraison → litige → evaluation.

Le schema de donnees multi-asset (73 colonnes, 10 categories) est deja en place. Le MVP fonctionne en production. Les shells natifs sont prets. La vision couvre 12 modules fonctionnels distincts avec un modele economique progressif (SaaS → commission → services → blockchain).

L'execution est la seule variable. Le code est la.

---

*Document genere le 10 avril 2026 — Vera Trade v0.1*
*Repo : github.com/flow-web/vera_trade*
*Production : veratrade.fr*
