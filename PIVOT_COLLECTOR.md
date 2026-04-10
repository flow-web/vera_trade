# VERA TRADE — Pivot Collector
### Repositionnement vers le segment youngtimer, collection & competition
### Document strategique — avril 2026

---

## 1. Le nouveau positionnement

### Le marche cible, precisement

Vera Trade ne s'adresse plus a "tout le monde qui achete une voiture". Il s'adresse a :

**Le coeur de cible** : l'amateur de 35-55 ans, passionne, revenu moyen-superieur, qui cherche une voiture a **10k-100k euros** qui raconte quelque chose. Pas une Clio de 2019. Une voiture qui a une **ame, une histoire, une culture**.

**Les segments concrets** :

| Segment | Exemples typiques | Fourchette prix | Volume marche FR |
|---|---|---|---|
| **JDM 80s-90s** | Civic EG/EK, CRX, Integra DC2, Supra MK3/MK4, RX-7 FC/FD, MR2, Silvia, Skyline R32/R33, NSX, S2000 | 8k-80k | Croissance forte |
| **Youngtimers europeens** | E30/E36/E46 M3, 190E Cosworth, W124, 964/993, Golf GTI Mk1-Mk2, 205 GTI/Rallye, R5 Turbo, Clio Williams, Delta Integrale | 15k-120k | Stable, tres actif |
| **Youngtimers nouvelle generation** | RS6 C6 V10, M3 E46/E92, 996/997 Turbo, Evo VIII/IX/X, Impreza STI, Focus RS, Civic Type R EP3/FN2 | 20k-80k | En explosion |
| **Preparations & rally cars** | Groupe A, Groupe N, Gr.4 historique, Kit Car, F2000, VHC | 15k-150k | Niche specialisee |
| **Race cars & trackday** | GT3 Cup, Lotus Exige Cup, preparations HPDE, monoplaces formule | 25k-200k | Niche mais solvable |
| **RHD imports & grises** | JDM importees, NA imports, voitures hors marche EU | 10k-150k | Legalement complexe |
| **Collection classique abordable** | Mehari, 2CV, DS, Alpine A310, 504 Coupe, Simca 1000 Rallye, Alfa 75 | 8k-50k | Stable, vieillissant |

Le point commun : **ce sont des voitures ou l'originalite, l'historique, l'etat sous la caisse et la provenance comptent autant que la mecanique**. Les criteres standards de LBC (annee, km, prix) sont insuffisants. Il faut une grammaire completement differente.

### Pourquoi ce pivot est defendable

1. **Expertise fondatrice** : tu connais le milieu. Tu sais ce qu'est la rouille sur des bas de caisse de Honda, le mythe du numero de chassis, la difference entre une R32 GT-R japonaise et une export. C'est un moat.

2. **Volume technique suffisant** : le segment est assez grand pour un business viable (des centaines de milliers de vehicules concernes en France + Europe), assez petit pour ne pas attirer LBC ou AutoScout.

3. **Concurrence faible en France** : pas de BaT francais. Sport Auto Club, LVA, Classic Driver (mais international et haut de gamme), Caradisiac Collection (annuaire, pas marketplace). Place a prendre.

4. **Communaute existante et engagee** : forums (Retro-Club, Forum-Auto, CivicLife, Supra-France, Alpine-Passion...), clubs marques, rassemblements reguliers. Ta plateforme peut agreger ca au lieu de le remplacer.

5. **Monetisation plus propre** : un collectionneur qui achete une 964 a 60k n'a pas le meme budget ni la meme tolerance qu'un etudiant qui cherche une Twingo. Les take rates realistes sont de 2-5% vendeur + 4-5% acheteur (modele BaT), donc un vehicule moyen a 30k = 1500-2500 de revenu plateforme.

### Les references a etudier

1. **Bring a Trailer** (bringatrailer.com) — la bible. Modele numero un.
2. **Collecting Cars** (collectingcars.com) — version UK plus moderne, orientee mobile.
3. **The Market** (themarket.co.uk) — Bonhams, plus editorial et premium.
4. **Petrolicious** (petrolicious.com) — LA reference du contenu automobile enthusiast.
5. **Magneto Magazine** (magnetomagazine.com) — pour l'identite visuelle et le ton editorial.

---

## 2. Identite visuelle & direction artistique

### Le piege a eviter

La DA actuelle Tailwind + DaisyUI mene vers une esthetique **SaaS startup generique**. Pour ce segment, c'est la mort. Les amateurs de youngtimers veulent un site qui **respire l'essence et le cuir**, qui sent le magazine automobile.

### Le brief creatif

**Un mot cle** : *editorial*. Chaque annonce est un article, pas un listing.

**Trois references visuelles directes** :
- *Magneto Magazine* pour la mise en page et la typo
- *Petrolicious* pour la photographie et les videos courtes
- *Rouleur* (cyclisme) pour le ton editorial confiant, minimaliste, premium-sans-etre-snob

### Systeme de design

**Palette** :

| Nom | Usage | Reference |
|---|---|---|
| **Noir profond** `#0A0A0A` | Fond principal | Noir moteur |
| **Creme papier** `#F5F1E8` | Fond clair / texte sur noir | Papier magazine vintage |
| **Rouge sang** `#8B0000` ou `#C41E3A` | Accent, boutons, prix | Rosso corsa |
| **Chrome/Gris metal** `#8B8680` | Bordures, UI secondaire | Chrome des youngtimers |
| **Vert racing** `#004225` | Alternative premium | British Racing Green |
| **Or patine** `#B8860B` | Badges, mentions speciales | Medaille, trophee |

**Typographie** :
- **Titres** : serif a forte personnalite — Canela, GT Sectra, Reckless. Idealement italic display pour les hero titles.
- **Corps** : serif lisible — Source Serif, Tiempos Text, ou Freight Text. Pas de sans-serif pour le corps d'article.
- **UI & data** : sans-serif neutre — Inter, Sohne, ou National.
- **Chiffres & donnees techniques** : fonte mono — JetBrains Mono.

Regle : **jamais plus de 2 familles par page**.

**Textures & details** :
- Grain de film subtil en overlay sur les hero images
- Bordures fines, epaisseur 1px uniquement
- Pas de border-radius lourd — coins droits ou legers (4-8px max)
- Pas de shadows tape-a-l'oeil
- Separateurs horizontaux fins comme dans les journaux
- Majuscules etirees (tracking fort) pour les labels et metadonnees

**Photographie** :
- Hero image **pleine largeur, ratio cinemascope** (21:9 ou 2.35:1)
- Galerie en mosaique editoriale (pas une grille uniforme)
- Grandes tailles — minimum 2000px de large
- Plans larges en contexte + gros plans techniques
- Traitement colorimetrique coherent (LUT cinema discrete)

**Micro-interactions** :
- Transitions lentes (300-500ms, easing naturel)
- Parallaxe leger sur les hero
- Curseur custom sur desktop pour les images cliquables
- Pas de hover bounces

### Premier ecran a valider : la fiche annonce

Structure proposee (inspiree BaT + Magneto) :

```
HERO CINEMASCOPE — photo principale pleine largeur 21:9
TITRE EDITORIAL serif italic
  1992 Honda CRX Si Mk2 — 98,000 km
  ANNONCE N°0472 · LYON · PARTICULIER
PRIX + METADONNEES CLES
GALERIE EDITORIALE — mosaique asymetrique 20-30 photos HD
RECIT VENDEUR — editorial, serif, large (pas une fiche technique)
HISTORIQUE DETAILLE (timeline) + ETAT & REVISIONS
RUST MAP INTERACTIVE — schema avec zones annotees
SPECIFICATIONS TECHNIQUES — tableau dense serif + mono
DOCUMENTS VERIFIES — carte grise, FFVE, historique, CT
VENDEUR — profil + score confiance + historique vente
COMMENTAIRES & QUESTIONS (publiques, style BaT)
```

---

## 3. Features specifiques au segment collector

### F1 — Rust Map Interactive (LE feature signature)

Schema isometrique/3D de la voiture. Le vendeur pointe les zones a probleme : seuils, bas de caisse, planchers, passages de roue, jonctions de caisson, ailes arrieres. Pour chaque point : gravite (surface/profond/perfore), photo macro obligatoire, traitement eventuel. Visualisation code couleur vert/orange/rouge.

**Un vendeur qui ne remplit pas la rust map ne peut pas publier.** Transparence forcee.

Technique : SVG interactif, Stimulus controller `rust-map-controller`. Stockage JSONB sur `vehicles.rust_map_data`.

### F2 — Originality Score & Matching Numbers Check

Score d'originalite 0-100%. Matching numbers : chassis, moteur, boite — verification croisee documentation constructeur. Badge visuel : "Tout d'origine", "Restauration a l'identique", "Modifiee", "Prepa competition".

Le modifie n'est pas pejoratif — c'est transparent.

Technique : table `vehicle_originality`. Score calcule en methode Ruby.

### F3 — Provenance Ledger (timeline de propriete)

Timeline verticale editoriale : chaque proprietaire = un chapitre. Periode, region, usage declare, kilometrage annuel moyen, evenements marquants, photos d'epoque.

Technique : table `provenance_entries`. Les verified entries forment un graphe de confiance.

### F4 — Documents verifies (dossier voiture)

Dossier structure par categorie : carte grise, FFVE, controles techniques, factures d'entretien datees, rapports d'expertise, certificats de conformite, documents d'importation.

OCR automatique pour extraire date, km, intervention, cout. Verification cross-check automatique.

Technique : enrichir `media_folders` + `media_items` avec type de document, `reveal_stage`, job OCR.

### F5 — Expert Inspection Program

Reseau d'inspecteurs independants specialises par marque/epoque. L'acheteur paie 150-400 euros, l'expert suit un protocole standardise par type de voiture, remet un rapport detaille.

Expert touche 70%, Vera Trade 30%. Inspection obligatoire si > 30k.

Technique : table `inspections`, protocoles en YAML versionnes par modele.

### F6 — Parts & NOS Sourcing

Index de disponibilite des pieces par modele : NOS, repro qualite, repro, occasion, indisponible. Score de maintenabilite. Marketplace de pieces integree aux annonces. Alerte NOS.

Technique : tables `parts_listings`, `parts_wanted`. Matching async.

### F7 — Event & Rally Integration

Calendrier evenements majeurs. Annonces taguees "vue a [evenement] [annee]". Inscriptions rallyes historiques facilitees (ASA, FFVE, ACO).

Technique : tables `events`, `event_participations`, `event_registrations`.

### F8 — Legal RHD & Import

Module d'assistance administrative : procedure, cout, delai par type de vehicule. Partenariats specialistes import. Documentation legale a jour des regles RHD. Alerte changements legislatifs (Crit'Air, ZFE).

### F9 — Insurance & Storage specialises

Partenariats assureurs collection. Devis instantane valeur agreee. Annuaire garages de stockage specialises. Reseau convoyeurs pros avec remorques fermees.

### F10 — Encheres type BaT (hybride fixed-price + auction)

Deux modes : prix fixe avec offres + enchere 7 jours (reserve optionnel, anti-snipe 2 min, commentaires publics). Frais vendeur 5%, frais acheteur 4,5% (plafonnes 5000 chacun).

Selection editoriale obligatoire pour les encheres.

Technique : Solid Cable pour temps reel, tables `auctions`, `bids`, `auction_watchers`.

### F11 — Scoring communautaire & reputation

Profil public enrichi : vehicules possedes, historique ventes, collections thematiques, badges. Signature editoriale (articles, essais). Systeme de mentorat.

### F12 — Editorial integre

Section editoriale : essais, tests, guides d'achat par modele, interviews, reportages evenements. SEO massif. Cross-linking articles <-> annonces. Podcast/videos long terme.

---

## 4. Workflows adaptes au segment

### Workflow vente (vendeur particulier)

```
1.  Inscription + KYC niveau 1
2.  Creation annonce :
    a. Selection marque/modele/annee (catalogue structure)
    b. Saisie numero chassis (verification format, HistoVec)
    c. Upload photos (minimum 20, checklist guidee)
    d. Rust map (F1) obligatoire
    e. Originality check (F2) obligatoire
    f. Provenance ledger (F3) — au moins proprietaire actuel
    g. Recit editorial (guide + assistant IA optionnel)
    h. Upload documents (F4)
    i. Choix mode vente : prix fixe ou enchere
3.  Soumission a validation editoriale (auto + humain)
4.  Publication
5.  Discussion publique (commentaires + questions, style BaT)
6.  Offres / encheres
7.  Acceptation → KYC niveau 2 + preuve de fonds acheteur
8.  Escrow ouvert
9.  Option inspection (F5) — obligatoire si > 30k
10. Signature electronique dossier de cession
11. Organisation logistique
12. Livraison + validation acheteur
13. Liberation fonds vendeur
14. Evaluations mutuelles
```

### Protocole d'inspection (exemple Honda CRX EE8)

```yaml
protocol: honda_crx_ee8_v1
model: Honda CRX Si Mk2 (EE8/ED9)
years: 1988-1991
duration_minutes: 90
checkpoints:
  bodywork:
    - seuils_droits: [photo, note, perforation_check]
    - seuils_gauches: [photo, note, perforation_check]
    - bas_de_caisse: [photo, note]
    - planchers_avant: [soulever_moquette, photo, note]
    - planchers_arriere: [photo, note]
    - passages_de_roue: [photo_4x, note]
    - hayon_inferieur: [photo, note, rouille_classique]
    - montants_de_pare_brise: [photo, note]
  mechanical:
    - compression_cylindres: [test_obligatoire, valeurs]
    - fuites_huile: [photo, description]
    - courroie_distribution: [date_remplacement, km]
    - embrayage: [essai, note]
    - direction: [jeu, note]
    - suspension: [amortisseurs, rotules, photos]
  interior:
    - sellerie: [photo, note, origine_ou_refaite]
    - tableau_de_bord: [photo, fissures]
    - electronique: [tous_boutons_testes, note]
  documentation:
    - chassis_number_visible: [photo_matching_avec_carte_grise]
    - moteur_number: [photo_si_accessible, matching_number_check]
  road_test:
    - acceleration: [note]
    - freinage: [note]
    - comportement_route: [note]
    - bruits_anormaux: [description]
rouille_critique_zones:
  - seuils
  - planchers
  - hayon_inferieur
deal_breakers:
  - perforation_plancher
  - chassis_non_matching_declare_matching
  - moteur_non_conforme_declare_origine
```

---

## 5. Schema technique — evolutions a prevoir

### Nouvelles tables

```
vehicle_models           — catalogue structure (marque, modele, generation, annees)
vehicle_rust_reports     — rust maps par vehicule (JSONB)
vehicle_originality      — scoring et details matching numbers
provenance_entries       — timeline de propriete
vehicle_documents        — documents structures par categorie
inspection_protocols     — YAML/JSON des protocoles par modele
inspections              — demandes et rapports d'inspection
inspectors               — reseau d'experts
auctions                 — encheres
bids                     — offres en enchere
auction_watchers         — suiveurs d'encheres
events                   — evenements auto
event_participations     — vehicule → evenement
parts_listings           — pieces a vendre
parts_wanted             — alertes pieces
user_profiles            — enrichissement profil (bio, badges, collections)
user_badges              — systeme de reputation
editorial_posts          — contenu editorial
post_vehicle_links       — cross-linking article <-> annonces
questions                — Q&A publiques sous annonces (style BaT)
```

### Enrichissements tables existantes

- `vehicles` : ajouter `vehicle_model_id`, `chassis_number`, `engine_number`, `matching_numbers_status`, `originality_score`, `storage_location`, `usage_type`
- `users` : `kyc_level` (0-3), `proof_of_funds_status`, `reputation_score`, `specialist_marques` (array)
- `conversations` : ajouter `inspection_id`

### Services a creer

- `RustMapService` — validation et rendu
- `OriginalityScorer` — calcul du score
- `InspectionMatcher` — trouver l'inspecteur le plus proche
- `AuctionEngine` — gestion des encheres (jobs, anti-snipe)
- `DocumentParser` — OCR et extraction
- `ProvenanceVerifier` — verification graphe de propriete

---

## 6. Modele economique revise

| Source | Mecanisme | Take rate estime | Phase |
|---|---|---|---|
| **Commission vente (prix fixe)** | Escrow | 2% vendeur + 2% acheteur | Phase 1 |
| **Commission enchere** | BaT model | 5% vendeur + 4,5% acheteur (plafonne) | Phase 2 |
| **Inspections expertes** | Commission 30% sur 200-400 | 60-120 par inspection | Phase 1 |
| **Insurance leads** | Affiliation assureur collection | 30-100 par contrat signe | Phase 2 |
| **Convoyage** | Commission courtier transport | 10-15% | Phase 2 |
| **Pieces detachees** | Commission marketplace | 5-10% | Phase 3 |
| **Abonnement Pro** | SaaS | 49-199/mois | Phase 1 |
| **Listing premium** | Booster | 20-100 par annonce | Phase 1 |
| **Editorial sponsorise** | Publi-redactionnel | CPM ou forfait | Phase 2 |
| **Inscriptions evenements** | Affiliation / co-organisation | Variable | Phase 3 |
| **Rapports de marche** | Data anonymisee aux pros | 300-1500/rapport | Phase 3 |

**Scenario realiste phase 2 (18-24 mois)** :
- 50 ventes/mois a 25k en moyenne → 1,25M de GMV/mois
- Take rate effectif ~4% → 50k/mois de revenu commission
- 30 inspections/mois → 3k
- 15 leads insurance/mois → 1k
- 20 abonnements Pro → 2k
- **Total ~56k MRR** soit ~670k/an

---

## 7. Plan d'action 90 jours

### Jours 1-15 : Positionnement & DA
- Interviewer 10-15 collectionneurs (clubs, forums, rassemblements)
- Passer 2h sur BaT, analyser 50 annonces
- Moodboard DA (nano-banana) : 30-50 compositions
- Validation palette, typos, regles de composition
- Premier logo + wordmark
- Decision nom : garder Vera Trade ou pivoter

### Jours 16-30 : MVP fiche annonce
- Redesign complet fiche annonce (structure editoriale)
- Implementation Rust Map (F1)
- Implementation Originality Check (F2)
- Implementation Provenance Ledger (F3)
- Refactor media_items → documents structures (F4)

### Jours 31-45 : MVP recherche & catalogue
- Catalogue structure `vehicle_models` (50 modeles cibles)
- Filtres adaptes : epoque, usage, etat caisse, originalite, budget
- Embeddings pgvector pour recherche semantique
- Pages dediees par modele (SEO)

### Jours 46-60 : Q&A publique + commentaires
- Refactor conversations → multi-party
- Systeme de questions publiques sous annonces (style BaT)
- Moderation
- Tests automatises sur flux critiques

### Jours 61-75 : Premieres annonces curees
- 10-20 annonces en mode "main picked" — vehicules connus ou contacts directs
- Chaque annonce traitee comme un article editorial
- Distribution : forums, clubs, Instagram, partenariats bloggers

### Jours 76-90 : Lancement soft
- Ouverture inscriptions publiques (vendeurs)
- Moderation editoriale manuelle
- Premier evenement (rassemblement francais)
- Collecte feedback, iteration

**Objectif 90 jours** : 50 annonces de qualite, 500 inscrits, 5 ventes conclues.

---

## 8. Les questions a trancher maintenant

1. **Nom** : Vera Trade reste ou pivote ? Suggestions si pivot : *Carnet, Heritage, Rouille & Chrome, Garage 9, Cote & Grade, Patine, Six Mille*
2. **Geographie** : France only phase 1, puis Europe phase 2 ?
3. **Segment d'entree** : JDM 90s (expertise + demande + 0 concurrence FR) ?
4. **Moderation** : 100% manuel au debut (qualite max) ?
5. **Editorial** : qui ecrit ? Toi au debut ?
6. **Partenariats 90 jours** : 1-2 clubs marques, 1 media specialise, 1 assureur collection, 3-5 experts inspecteurs
7. **Budget** : ~6000 pour 90 jours (infra 300/mois, licences 200/mois, comm 1000, photos pro 2000)

---

## Conclusion

Le pivot collector/youngtimer/racing est **plus defendable, plus rentable au vehicule, plus culturellement fort et plus difficile a copier** que la vision generaliste. Il exploite ton expertise reelle au lieu de la noyer dans une marketplace de masse.

Le code existant reste utile a 80% : auth, media, conversations, wallet, catalogue vehicle. Il faut reorienter, enrichir, et refaire la peinture.

La vraie bataille n'est pas technique. Elle est **editoriale et communautaire**. Si tu reussis a faire publier 50 annonces dignes d'un magazine dans les 90 premiers jours, tu as gagne la premiere manche.

---

*Document de pivot — avril 2026*
*A lire apres l'audit principal et la vision etendue*
