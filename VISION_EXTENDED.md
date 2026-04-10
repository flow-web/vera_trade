# VERA TRADE — Vision Etendue
### Companion document a l'audit d'avril 2026
### Modules 13 → 25 + couches transversales

---

## Preambule

L'audit initial couvre 12 modules. Il decrit une marketplace transactionnelle complete. Ce document part d'une question differente : **si on devait construire en 2026 la plateforme d'echange de vehicules que personne n'a encore construite, qu'est-ce qui manquerait ?**

Reponse courte : la couche **physique-numerique**. Les marketplaces actuelles (LBC, AutoScout, La Centrale, Mobile.de, Carvana, Cazoo) digitalisent l'annonce et le contact. Aucune ne digitalise le **vehicule lui-meme**, son **historique reel**, son **etat mesurable**, ni la **chaine de confiance** entre vendeur et acheteur. C'est la que se trouve le territoire vierge.

Les modules ci-dessous sont classes du plus faisable (existe en librairie, integrable en quelques semaines) au plus ambitieux (necessite R&D ou partenariats).

---

## Module 13 — Jumeau numerique 3D du vehicule

**Le probleme** : une annonce = 8 photos plates. L'acheteur ne peut pas tourner autour du vehicule, zoomer sur un pare-chocs, verifier l'etat d'un seuil de porte.

**La solution 2026** :
- **Photogrammetrie via smartphone** : le vendeur fait le tour du vehicule en filmant 60 secondes. Un service backend (ex. Luma AI, Polycam, ou self-host via NeRF/Gaussian Splatting) reconstruit un modele 3D navigable.
- **LiDAR scan natif** sur iPhone Pro / iPad Pro : precision sub-millimetrique, exportable en USDZ. Capacitor a deja des plugins ARKit/ARCore.
- **Visualisation web** : Three.js ou model-viewer (Google) embarque dans la page show de l'annonce. Aucun plugin requis cote acheteur.
- **Annotations** : le vendeur peut "epingler" des defauts directement sur le modele 3D (rayure portiere arriere droite, impact pare-brise). L'acheteur les voit en contexte.

**Stack** : Active Storage stocke les .glb/.usdz, Cloudinary les sert, une vue Stimulus charge model-viewer. Backend Python separe pour la reconstruction (job asynchrone via Solid Queue + webhook).

**Effort** : moyen. Le pipeline existe, c'est de l'integration.

**Effet de marche** : aucune marketplace generaliste ne le fait. C'est ce qui fait basculer une visite physique en visite a distance credible.

---

## Module 14 — Inspection assistee par vision par ordinateur

**Le probleme** : un acheteur ne sait pas evaluer un vehicule. Un vendeur honnete ne sait pas prouver qu'il l'est. La confiance manque des deux cotes.

**La solution 2026** :
- **Detection automatique de defauts** sur photos : modeles de segmentation entraines sur datasets carrosserie (rayures, bosses, rouille, jantes abimees). Plusieurs modeles open-source existent (Tractable, Ravin AI font ca commercialement pour les assureurs).
- **Score d'etat automatique** : note 0-100 generee par le modele, affichee a cote de la note vendeur. Inviolable parce que recalculee a chaque upload.
- **Comparaison photo/realite** : si l'acheteur visite, il prend une photo, le systeme la compare aux photos de l'annonce et flag les divergences (nouvelle rayure ? pneus changes ?).
- **OCR plaque + VIN** : extraction automatique depuis la photo, verification format, recoupement avec les bases.

**Stack** : modele servi via une API Python (FastAPI ou Modal/Replicate pour demarrer sans infra). Rails appelle l'API en async via un job. Resultats stockes dans une table `vehicle_inspections`.

**Effort** : moyen-haut. Faisable en MVP avec un modele generique (YOLO entraine sur dataset public), affinable ensuite.

**Effet** : c'est le **"badge de confiance algorithmique"**. Tu rends mesurable ce qui etait subjectif.

---

## Module 15 — Integration HistoVec & sources officielles francaises

**Le probleme** : l'historique d'un vehicule en France est eclate entre HistoVec (gouvernement), SIV, OTC (Organisme Technique Central, controles techniques), et l'historique du concessionnaire.

**La solution 2026** :
- **HistoVec** : service public gratuit. Le vendeur genere un rapport, te le depose, tu le parses (PDF) et tu affiches les donnees structurees dans l'annonce (date 1ere immat, nombre de proprietaires, gage/non gage, vol, sinistres declares DVS).
- **API controle technique** : l'OTC publie certaines donnees. A defaut, parsing OCR du PV de CT uploade.
- **API constructeur** quand elle existe (BMW ConnectedDrive, Mercedes Me, Tesla API) : kilometrage reel, historique entretien constructeur. Necessite consentement vendeur via OAuth.
- **Carte grise dematerialisee** : ANTS publie l'API SIV pour les pros agrees. Long terme.

**Stack** : un service Ruby `HistovecParser` qui prend un PDF en entree, en sort un hash structure stocke en JSONB sur la table vehicles. Securite : les donnees sont verifiees cote serveur, pas modifiables par le vendeur apres import.

**Effort** : faible pour HistoVec (parsing PDF), moyen pour le reste.

**Effet** : tu deviens la **seule plateforme grand public ou l'historique est verifie** sans avoir a payer Carfax/AutoDNA.

---

## Module 16 — Connexion telematique OBD2 / vehicule connecte

**Le probleme** : le kilometrage affiche peut etre trafique. L'historique d'usage (conduite agressive, pannes, codes defaut) est invisible.

**La solution 2026** :
- **Dongle OBD2 Bluetooth** (~30 euros, ex. OBDLink MX+) : le vendeur le branche, l'app Capacitor lit en BLE le kilometrage reel ECU, les codes defaut actifs et historiques, le voltage batterie, l'etat des capteurs.
- **Snapshot signe** : les donnees sont horodatees et signees cote serveur. L'acheteur voit "kilometrage ECU verifie le 12/04/2026".
- **Vehicules connectes natifs** : integration directe Smartcar API (couvre ~30 marques en Europe, OAuth utilisateur). Tesla, BMW, Ford, Mercedes, Hyundai, etc.
- **Historique de trajets** (avec consentement) : ratio ville/autoroute, accelerations brutales, regime moteur moyen — tout ce qui dit la vraie vie d'une mecanique.

**Stack** : plugin Capacitor BLE custom (ou wrapper d'une lib existante), endpoint Rails `/api/v1/telemetry/snapshots` qui ingere et signe. Smartcar a un SDK JS utilisable cote Stimulus.

**Effort** : moyen-haut. Le hardware existe, le BLE en Capacitor demande du custom code.

**Effet** : c'est **la fin du compteur trafique**. Argument marketing massif.

---

## Module 17 — Generation multimodale d'annonces

**Le probleme** : 80% des vendeurs particuliers font des annonces mediocres (titre vague, description copiee, photos mal cadrees).

**La solution 2026** :
- **Photo vers annonce complete** : le vendeur upload 5 photos, un LLM multimodal (Claude Opus, GPT-4o, Gemini) genere titre, description, points forts, equipements detectes visuellement (jantes alu, toit ouvrant, GPS). Le vendeur valide ou edite.
- **Coaching photo en temps reel** : pendant la prise de vue dans l'app, un overlay AR indique "recule de 2m", "cadre toute la voiture", "eclaire mieux l'interieur". Possible avec MediaPipe ou un modele de scoring qualite photo.
- **Description SEO-optimisee** generee a partir des donnees structurees + photos.
- **Traduction automatique** vers EN/DE/IT/ES pour exposer les annonces premium au marche europeen.

**Stack** : tu as deja OpenAI prevu pour les agents. Ajouter un service `ListingComposer` qui prend les photos + donnees structurees, retourne un draft d'annonce. Cout marginal par annonce ~0,05 euros.

**Effort** : faible. C'est de l'orchestration LLM.

**Effet** : qualite moyenne du catalogue qui monte d'un cran. SEO mecaniquement booste.

---

## Module 18 — KYC & signature electronique de niveau notarial

**Le probleme** : un dossier de cession vehicule en France = certificat de cession, carte grise barree, controle technique, certificat de non-gage. Tout en papier ou en PDF maile. Source numero 1 d'arnaques.

**La solution 2026** :
- **KYC niveau eIDAS substantiel** via Onfido, Veriff, ou ID.me : reconnaissance faciale + liveness + lecture NFC de la piece d'identite (passeport ou CNIe francaise). Exige pour toute transaction > 5000 euros.
- **Signature electronique qualifiee** via Yousign, DocuSign, ou Universign : valeur legale equivalente manuscrite, archivage a valeur probante 10 ans.
- **Generation automatique du dossier de cession** : Cerfa 15776 pre-rempli, certificat de non-gage importe via API, CT scanne. Tout signe electroniquement par les deux parties dans la conv.
- **Teledeclaration ANTS** : le changement de carte grise est declenche automatiquement (le vendeur genere le code, l'acheteur l'utilise).

**Stack** : Yousign a une API REST propre, integrable en quelques jours. Onfido pareil. Tu as deja Devise, il faut juste ajouter un champ `kyc_level` sur users et un workflow.

**Effort** : faible-moyen. C'est de l'integration SaaS.

**Effet** : tu fais disparaitre **la friction administrative** qui pousse les gens a passer chez le concessionnaire. C'est un avantage competitif enorme face a LBC.

---

## Module 19 — Open Banking & verification de solvabilite

**Le probleme** : un vendeur de vehicule a 30k euros ne sait pas si l'acheteur peut payer. L'acheteur ne sait pas si la promesse d'achat sera honoree.

**La solution 2026** :
- **PSD2/DSP2 via Bridge, Tink ou Powens** : l'acheteur connecte son compte bancaire en lecture seule, le systeme verifie la solvabilite instantanement (presence des fonds, ou capacite d'emprunt).
- **Pre-approval credit auto** : integration directe avec courtiers en ligne (Younited, Cofidis, Floa). L'acheteur a une enveloppe pre-approuvee avant meme de visiter.
- **Preuve de fonds tokenisee** : un badge "fonds verifies" apparait dans la conversation cote acheteur, sans reveler le montant exact.

**Stack** : Bridge a une API Rails-friendly. Tu crees une table `proof_of_funds` liee au user, avec un statut, un score, une expiration (24-48h).

**Effort** : moyen. Regulation francaise stricte (AMF, ACPR), mais les agregateurs gerent ca.

**Effet** : tu **elimines les faux acheteurs** qui pourrissent la vie des vendeurs sur LBC.

---

## Module 20 — Encheres live & encheres inversees

**Le probleme** : la vente a prix fixe est sous-optimale pour les vehicules rares, les voitures de collection, les flottes pro.

**La solution 2026** :
- **Encheres live en temps reel** : style BCA, Copart, Catawiki. WebSockets via Solid Cable (que tu as deja). Compte a rebours, anti-snipe (extension auto si bid dans les 30 dernieres secondes), proxy bidding.
- **Encheres inversees (RFQ)** : un acheteur poste "je cherche une Golf GTI 2020-2022, 50k km max, budget 18-22k euros, livrable Lyon". Les vendeurs postulent. L'acheteur choisit. Inverse total du modele LBC.
- **Encheres flash B2B** : pour les pros qui veulent ecouler du stock vite. Slot d'1h, max 50 vehicules, reserve Business tier.
- **Group buying** : 5 acheteurs s'unissent pour acheter une flotte, negocient ensemble. Specifique au B2B/professions liberales.

**Stack** : Action Cable (Solid Cable) gere ca nativement. Tables `auctions`, `bids`, `auction_participants`. L'anti-snipe est un job programme qui prolonge la fin si besoin.

**Effort** : moyen. C'est du Rails classique mais le temps reel demande des tests rigoureux.

**Effet** : tu ouvres deux **nouveaux segments** (collection + B2B) sans denaturer le core.

---

## Module 21 — Marketplace pieces detachees integree

**Le probleme** : tu vends une voiture, tu vends aussi son ecosysteme. Pieces, accessoires, options. Personne n'a unifie les deux.

**La solution 2026** :
- **Catalogue pieces lie au VIN** : une base comme TecDoc (la reference europeenne) liee au vehicule. L'acheteur consulte une fiche vehicule, voit les pieces compatibles disponibles sur la plateforme.
- **Vendeurs particuliers** : "je vends ma Clio + j'ai garde un kit d'origine". Lie a l'annonce principale.
- **Vendeurs pros** : casses auto, importateurs, fabricants. Inventaire synchronise via API.
- **Compatibilite automatique** : le systeme te dit "cette piece est compatible avec ton vehicule" via le VIN. Tu n'as pas a chercher.
- **Garage virtuel** : l'utilisateur enregistre ses vehicules dans son dashboard, recoit des alertes pieces, rappels d'entretien, recommandations.

**Stack** : licence TecDoc (payante mais standard de l'industrie) ou alternative open data. Modele `parts`, `vehicle_compatibilities`, `garage_vehicles`.

**Effort** : haut (la donnee est complexe, les licences coutent).

**Effet** : tu deviens **le seul endroit ou acheter une voiture et toute sa vie apres**. LTV utilisateur multipliee.

---

## Module 22 — Subscription & P2P rental natifs

**Le probleme** : la possession recule, surtout chez les <35 ans. Care by Volvo, Lynk & Co, Finn ont prouve que le marche existe.

**La solution 2026** :
- **Abonnement vehicule** : un vendeur pro (loueur, concession) propose un vehicule en abonnement mensuel tout compris (assurance, entretien, assistance). Annulable.
- **Location P2P** type Getaround/Turo : un particulier loue son vehicule entre deux utilisations. Integre au meme catalogue.
- **Boite a cles connectee** (KeyCafe, Igloohome) : remise des cles securisee sans rencontre physique. API REST disponible.
- **Assurance a l'usage** : partenariat avec un assureur (ex. Wakam) pour couvrir uniquement la duree de location. Souscription en 30 secondes dans l'app.

**Stack** : tables `rental_offerings`, `bookings`, `insurance_contracts`. Stripe Connect gere la recurrence. Calendrier de disponibilite par vehicule.

**Effort** : moyen-haut. Le legal/insurance est le bottleneck, pas la tech.

**Effet** : tu es **les trois marketplaces en une** (vente + location + abonnement) sur le meme catalogue.

---

## Module 23 — Recommandation semantique par embeddings

**Le probleme** : les filtres traditionnels (marque, prix, km) sont lourds. L'utilisateur veut "une voiture comme celle-ci mais moins chere" ou "quelque chose de fun pour les week-ends".

**La solution 2026** :
- **Embeddings vectoriels** sur chaque annonce : description + caracteristiques + photos (CLIP) vers vecteur 1024 dim.
- **Base vectorielle** : pgvector (extension PostgreSQL native, donc compatible avec ton stack actuel). Pas besoin de Pinecone ou Weaviate.
- **"Vehicles like this one"** : un bouton sur chaque annonce qui retourne les 10 plus proches semantiquement. Pas juste les memes specs — semantiquement proches.
- **Recherche en langage naturel** : "SUV familial fiable moins de 20k pas allemand" vers embedding de la requete + cosine similarity. Plus puissant qu'Elasticsearch sur ce cas.
- **Recommandations personnalisees** : basees sur l'historique de l'utilisateur (vues, favoris, recherches sauvees).

**Stack** : `pgvector` s'installe en 5 minutes sur ta Postgres. OpenAI text-embedding-3 ou un modele local (sentence-transformers). Job qui calcule l'embedding a la creation/update d'annonce.

**Effort** : faible. C'est une des choses les plus rentables a brancher.

**Effet** : qualite de recherche qui depasse Elasticsearch sur les requetes floues. Differenciateur immediat.

---

## Module 24 — Detection de fraude par ML & score de confiance dynamique

**Le probleme** : LBC est ronge par les arnaques (faux vendeurs, faux acheteurs, faux paiements, vol d'identite). Leur moderation est manuelle et debordee.

**La solution 2026** :
- **Score de confiance utilisateur** dynamique, calcule en continu : anciennete, KYC, historique transactions, signalements, vitesse de reponse, patterns de comportement.
- **Detection d'anomalies** : ML supervise sur les patterns de fraude connus. Annonce avec photos volees ailleurs (reverse image search via TinEye API ou self-hosted), prix anormalement bas, vendeur recemment cree qui poste 50 annonces, message contenant des mots-cles suspects.
- **Reverse image search interne** : tu indexes toutes les photos uploadees et tu detectes les reutilisations.
- **Honeypot accounts** : faux acheteurs/vendeurs geres par l'equipe pour reperer les arnaqueurs en amont.
- **Action automatique** : suspension immediate si score < seuil, escalade humaine si zone grise.

**Stack** : table `trust_scores` mise a jour par job, modele simple (XGBoost ou meme regression logistique au debut) servi en interne. Reverse image search via embeddings CLIP + pgvector.

**Effort** : moyen. Demarre en regles, apprends progressivement.

**Effet** : c'est ce qui te permet de **dormir la nuit** quand tu auras 100k utilisateurs.

---

## Module 25 — API publique & ecosysteme developpeur

**Le probleme** : LBC est ferme. Les pros bricolent des scrapers. Les outils tiers n'existent pas.

**La solution 2026** :
- **API REST + GraphQL publique** : annonces, recherche, profils publics, evenements. Authentification OAuth2.
- **Webhooks** : notifications sortantes pour les pros (nouvelle annonce matchant un critere, changement de prix, vendu).
- **Embeds** : un concessionnaire peut afficher son catalogue Vera Trade sur son site avec un iframe ou un script JS.
- **SDK officiels** : JS, Python, Ruby, PHP. Generation automatique depuis OpenAPI spec.
- **Marketplace de plugins** : integrations Zapier, Make, n8n. Connect to HubSpot, Salesforce, Pipedrive.
- **Plan API** payant pour l'acces commercial (rate limits, SLA).

**Stack** : Rails fait ca nativement. `rails-api`, `graphql-ruby`, Doorkeeper pour OAuth2.

**Effort** : moyen. L'API est facile, la doc et le DX sont le travail reel.

**Effet** : tu crees un **ecosysteme** autour de toi. Les pros ne peuvent plus partir parce que leurs outils internes dependent de ton API.

---

## Couches transversales

Ces briques ne sont pas des modules — elles touchent tout.

### Privacy & souverainete
- **Hebergement europeen obligatoire** : OVH, Scaleway, ou Hetzner. RGPD by design. Argument differenciant face aux US.
- **Chiffrement at-rest** sur les colonnes sensibles (KYC, IBAN, documents). Rails 7+ a `encrypts` natif.
- **Right to be forgotten** automatise : un user supprime son compte, un job orchestre purge / anonymise toutes les donnees liees en respectant les obligations legales (10 ans pour transactions).
- **Portabilite** : export complet des donnees utilisateur en JSON ou CSV en un clic.

### Accessibilite (WCAG 2.2 AA)
- Aucune marketplace francaise n'est vraiment accessible. C'est un avantage legal (loi 2005, obligations 2025) et marketing (~12M de personnes en France avec un handicap).
- DaisyUI est un bon point de depart mais pas suffisant. Audit avec axe-core en CI.

### Performance & Core Web Vitals
- **Hotwire est ton ami** : minimise le JS. Vise <50kb de JS critique.
- **Images responsives** : Cloudinary fait ca mais a configurer (formats AVIF, srcset, lazy loading natif).
- **Score Lighthouse 95+** sur les pages cles. C'est un facteur SEO majeur face a LBC qui rame.

### Observabilite
- Sentry (erreurs), Honeybadger ou AppSignal (Rails-natif), Plausible/Umami (analytics RGPD-friendly).
- Tracing OpenTelemetry pour les flux critiques (recherche, paiement, KYC).
- Dashboard interne admin (Avo ou ActiveAdmin) pour moderation et support.

### Internationalisation
- **i18n Rails** des maintenant, meme si tout est en francais. Cout de ne pas le faire = 10x plus tard.
- Locales prioritaires : FR, EN, DE, IT, ES. Marche DACH = 100M de personnes, AutoScout y regne mais la satisfaction est faible.

### Tests automatises (la dette critique)
- **0 tests = mort certaine** quand le code passera 5k LOC. Priorite absolue pour la phase 1.
- Stack recommandee : RSpec + FactoryBot + Capybara (system tests) + VCR pour les API externes.
- Cible realiste : 60% de couverture sur le critique (paiement, KYC, search) avant Phase 2.

---

## Reorganisation du modele economique

L'audit propose 4 tiers SaaS. On pousse plus loin.

| Source de revenu | Quand | Marge typique | Complexite |
|---|---|---|---|
| **SaaS pro** (Pro/Business/Enterprise) | Phase 1 | 70-85% | Faible |
| **Commission transaction** (escrow) | Phase 2 | 100% (take rate) | Moyenne |
| **Verifications payantes** (KYC, HistoVec, inspection IA) | Phase 2 | 50-80% | Faible |
| **Lead generation** (assurance, financement, garages) | Phase 2 | 100% | Moyenne |
| **Logistique** (commission convoyeurs) | Phase 3 | 10-15% | Haute |
| **Pieces detachees** (commission marketplace) | Phase 3 | 5-15% | Haute |
| **Location & abonnement** (commission booking) | Phase 3 | 15-20% | Haute |
| **Encheres** (frais vendeur + acheteur) | Phase 3 | 100% | Moyenne |
| **API & ecosysteme** (plans dev) | Phase 3 | 90% | Faible |
| **Donnees anonymisees** (rapports marche aux pros) | Phase 4 | 100% | Faible |
| **Token de fidelite / DAO** | Phase 4+ | NA | Tres haute |

L'enjeu est de **multiplier les sources** pour ne dependre d'aucune. LBC depend a >90% du SaaS pro. C'est leur force et leur fragilite.

---

## Ce qu'il faut accepter

1. **Tout faire seul est impossible**. Les briques 13-25 necessitent au minimum : 1 dev backend Rails senior, 1 dev frontend Hotwire/3D, 1 dev mobile Capacitor, 1 ML engineer (a temps partiel ou freelance), 1 designer produit, 1 ops/legal. Tu peux demarrer a 1-2 et grossir, mais pas finir a 1.

2. **Le legal est le vrai bottleneck**, pas la tech. KYC/AML, escrow, ORIAS pour l'assurance, IOBSP pour le credit, RGPD, CNIL. Compter 6-12 mois pour chaque agrement. Anticiper des maintenant.

3. **L'effet reseau de LBC est leur seul vrai moat**. La seule chance est de **ne pas les attaquer frontalement** mais de prendre des verticales qu'ils ignorent : vehicules de collection, B2B/flottes, vehicules connectes haut de gamme, marche europeen multi-pays.

4. **Le MVP doit choisir**. 25 modules ne se lancent pas en meme temps. Pour la phase 1 : Module 13 (3D), Module 17 (annonces IA), Module 18 (KYC + signature), Module 23 (embeddings). Quatre seulement. Tout le reste attend.

5. **Le code existant est l'avantage**. 26 commits, 16 tables, 73 colonnes vehicule, PWA + Capacitor prets. C'est plus que ce que 95% des "marketplaces tech-killer" de pitch deck ont.

---

## Synthese

L'audit decrivait une marketplace transactionnelle complete. Ce document ajoute la couche qui la rend **inimitable** : digitalisation du vehicule physique (3D, telemetrie, vision), digitalisation de l'historique reel (HistoVec, OBD, constructeur), digitalisation de la confiance (KYC notarial, score ML, open banking), et digitalisation de l'experience d'achat (embeddings, IA multimodale, encheres, abonnement).

Aucune marketplace au monde n'a ces 25 modules reunis en 2026. La plupart en ont 5-8. Si Vera Trade en assemble ne serait-ce que 15 d'ici 2028, c'est deja une categorie nouvelle.

---

*Document compagnon — avril 2026*
*A lire avec l'audit principal Vera Trade v0.1*
