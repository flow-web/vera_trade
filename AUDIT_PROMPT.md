# Prompt d'Audit Vera Trade — À donner à un consultant externe

Copie-colle ce prompt tel quel dans une session Claude, GPT-4, ou envoie-le à un freelance dev/business.

---

## PROMPT

Tu es un consultant senior spécialisé en marketplaces digitales et en produits automobiles de niche. Tu audites **Vera Trade**, une marketplace éditoriale française de youngtimers et voitures de collection (segment 10k-100k€), positionnée comme le "Bring a Trailer français".

### Contexte technique
- Stack : Rails 8, PostgreSQL, Tailwind v4, Stimulus/Turbo, Solid Cable (WebSockets), Cloudinary (photos), Docker, VPS Debian
- Modèle économique : commission 5% vendeur + 4.5% acheteur sur enchères 7 jours
- Cible : passionné 35-55 ans, youngtimer JDM 80s-90s, EU, prépa/rally, collection abordable
- Concurrent direct en France : zéro (pas de BaT français)
- Site live : https://veratrade.fr
- MVP lancé avril 2026, fondateur solo (CEO, pas dev)

### Features livrées
- Catalogue avec recherche pondérée pg_search + filtres (segment, marque, carburant, transmission, prix, km)
- Wizard dépôt 7 étapes (véhicule, photos, Rust Map SVG interactif, mécanique, historique, documents, review)
- Rust Map : cartographie de corrosion zone par zone avec score transparence /100
- Originality Score : matching numbers, peinture d'origine, intérieur
- Provenance Ledger : timeline historique du véhicule
- Q&A publique BaT-style (questions visiteurs + réponses vendeur)
- Contact vendeur + offre privée
- Messagerie privée avec badge unread
- Favoris + recherches sauvegardées
- Live Auction : enchères temps réel via ActionCable, anti-snipe +2min, reserve price, bid increments par palier
- Escrow : Smart Wallet avec états (pending → paid → held → released/disputed/refunded), prêt pour Stripe Connect
- KYC : upload documents (CNI + justificatif domicile), review admin manuelle, gate sur publish + enchérir
- Rate limiting (rack-attack) sur auth, contact, messages, enchères
- Sécurité : CSP nonces, sanitize XSS, force_ssl, Devise paranoid, password 12 chars min
- Design system "Cinematic Archivist" : dark #0A0A0A, Rosso Corsa #C41E3A, Playfair Display italic, JetBrains Mono specs, 0px radius

### Ce que tu dois auditer

**1. PRODUIT & PMF (Product-Market Fit)**
- Le MVP est-il suffisant pour tester le marché ?
- Quelles features manquent AVANT de mettre un premier euro de marketing ?
- Quelles features sont superflues et diluent l'expérience ?
- Le modèle BaT (enchères éditoriales) est-il viable en France culturellement et légalement ?
- Comment obtenir les 50 premières annonces de qualité sans équipe ?

**2. UX & DESIGN**
- Ouvre https://veratrade.fr et navigue le catalogue, une fiche annonce, le wizard
- La hiérarchie visuelle est-elle claire ? Le design fait-il "premium collector" ou "template startup" ?
- Les photos sont-elles mises en valeur ? La lightbox fonctionne-t-elle ?
- Le parcours vendeur (wizard 7 étapes) est-il trop long, trop court, bien dosé ?
- Le mobile est-il utilisable (teste sur iPhone/Android) ?
- Le dark mode permanent est-il le bon choix pour ce segment ?

**3. COMMERCIAL & STRATÉGIE**
- Le nom "Vera Trade" est-il le bon ? Alternatives proposées : PATINE, CARNET, Rouille & Chrome, Garage 9
- La commission 9.5% total (5% vendeur + 4.5% acheteur) est-elle compétitive vs BaT US (5%+5%) ?
- Quel segment d'entrée : JDM 90s, youngtimers EU, prépa, ou tous en même temps ?
- Stratégie de lancement : community-first, PR auto, clubs, influenceurs YouTube ?
- Risques juridiques sur les enchères entre particuliers en France ?

**4. TECHNIQUE (si tu es dev)**
- Architecture Rails 8 : qualité du code, tests, CI
- Sécurité pour une marketplace financière (enchères jusqu'à 100k€)
- Scalabilité : goulots d'étranglement prévisibles
- Performance : LCP, bundle size, lazy loading
- RGPD : conformité données personnelles, droit à l'effacement, Google Fonts

**5. MONÉTISATION**
- Le modèle commission-only est-il viable à < 50 annonces/mois ?
- Faut-il un revenu récurrent (SaaS) en parallèle ?
- Quand introduire les paiements réels (Stripe Connect) ?
- Faut-il un minimum de listing price (ex: 8k€) pour filter la qualité ?

### Format de livrable attendu

```
## Score global /100

## Top 3 forces (ce qui marche déjà)

## Top 3 faiblesses critiques (à corriger avant lancement public)

## Top 5 recommandations par ordre de priorité
Pour chaque : quoi faire, pourquoi, effort estimé, impact attendu

## Red flags (risques bloquants si non traités)

## Décisions à trancher (avec ta recommandation)
- Nom
- Segment d'entrée
- Modèle de pricing
- Timing lancement

## Plan 30-60-90 jours recommandé
```

### Ce que tu NE dois PAS faire
- Ne pas être poli ou diplomatique. Sois direct, tranche, donne des opinions claires même si inconfortables.
- Ne pas lister 20 features à builder. Dis ce qu'il faut RETIRER autant que ce qu'il faut ajouter.
- Ne pas rester théorique. Teste le site, clique partout, essaie de créer un compte, de naviguer sur mobile.
