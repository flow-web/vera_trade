# M8 — Wizard dépôt d'annonce « Cinematic Archivist »

> **Pour les workers agentiques :** Suivre `superpowers:executing-plans`. Les étapes utilisent la syntaxe checkbox (`- [ ]`).

**Goal :** Livrer le wizard de création/édition d'annonce 7 étapes cohérent avec la refonte Stitch, avec 5 nouveaux modèles (RustMap, RustZone, ProvenanceEvent, OriginalityScore, ListingQuestion/Answer), Rust Map SVG éditable, Turbo Frames par étape et persistance auto-save.

**Architecture :**
- Branche dédiée `feat/listing-wizard-stitch` depuis `redesign/stitch-cinematic-archivist` (migrations isolées, PR séparée)
- Routes `resource :listing_wizards, only: [:new, :create, :edit, :update]` + member `:publish`
- Chaque étape = Turbo Frame `<turbo-frame id="wizard_step">` rafraîchi via PATCH du step courant
- Persistance : `listings.draft_data` jsonb pour les champs intermédiaires + `listings.wizard_step` int (0..6) + `listings.published_at` ts
- `Listings#status` enum gagne `:draft` (status initial pendant le wizard, transition vers `:active` au publish)
- Stimulus controllers : `listing-wizard`, `rust-map-editor`, `photo-dropzone`, `provenance-timeline`
- TDD strict : chaque modèle et chaque step controller est couvert avant l'implémentation

**Tech stack :**
- Rails 8.0.2 + Postgres 16 + Minitest + Active Storage
- Tailwind v4.1.5 + Stimulus + Turbo (esbuild)
- SVG silhouettes vectorielles pour la Rust Map (stockées dans `app/assets/images/silhouettes/`)
- Design system « Cinematic Archivist » (tokens dans `application.tailwind.css`)

**Contraintes :**
- Pas de gem ajoutée (Wicked, Trestle, Avo, ViewComponent exclus)
- Français strict dans l'UI
- Zéro leak DaisyUI — classes `btn-vera-*`, `input-vera`, `card-vera`, `label-small`, `eyebrow`, `playfair-italic`
- Migrations reverse-compatibles (nullable, defaults) pour ne pas casser les fixtures/tests existants

**Convention container dev :**
- Tout passe par `docker exec vera-trade-web` — pas de Ruby sur le host
- Après chaque modification de code Ruby ou migration : `docker compose build web && docker compose up -d --force-recreate web`
- Pour les vues ERB/JS : `docker cp` vers `/rails/...` suffit pour itération rapide, rebuild final avant commit

---

## Task 0 — Préparation de la branche

**Files :**
- Aucun fichier modifié, setup git uniquement

- [ ] **Step 0.1 — Créer la branche de travail depuis redesign/stitch-cinematic-archivist**

```bash
cd /home/debian/vera_trade
git checkout redesign/stitch-cinematic-archivist
git pull origin redesign/stitch-cinematic-archivist
git checkout -b feat/listing-wizard-stitch
```

Expected : branche locale créée, `git status` clean.

- [ ] **Step 0.2 — Vérifier le container et l'accès DB**

```bash
docker ps --format '{{.Names}}\t{{.Status}}' | grep vera
docker exec vera-trade-web bin/rails runner 'puts ActiveRecord::Base.connection.active?'
```

Expected :
```
vera-trade-web	Up N minutes
vera-trade-db	Up N days (healthy)
true
```

- [ ] **Step 0.3 — Lancer la suite de tests actuelle comme baseline**

```bash
docker exec vera-trade-web bin/rails test 2>&1 | tail -20
```

Expected : suite passe (ou au minimum les failures sont connues et documentées, pas introduites par M8).

---

## Task 1 — Migrations DB

**Files :**
- Create : `db/migrate/20260411120001_create_rust_maps.rb`
- Create : `db/migrate/20260411120002_create_rust_zones.rb`
- Create : `db/migrate/20260411120003_create_provenance_events.rb`
- Create : `db/migrate/20260411120004_create_originality_scores.rb`
- Create : `db/migrate/20260411120005_create_listing_questions.rb`
- Create : `db/migrate/20260411120006_create_listing_answers.rb`
- Create : `db/migrate/20260411120007_add_wizard_fields_to_listings.rb`

- [ ] **Step 1.1 — Migration `create_rust_maps`**

```ruby
# db/migrate/20260411120001_create_rust_maps.rb
class CreateRustMaps < ActiveRecord::Migration[8.0]
  def change
    create_table :rust_maps do |t|
      t.references :listing, null: false, foreign_key: true, index: { unique: true }
      t.string :silhouette_variant, null: false, default: "sedan"
      t.integer :transparency_score, default: 100 # 0-100, 100 = vehicle pristine
      t.text :notes
      t.timestamps
    end
  end
end
```

- [ ] **Step 1.2 — Migration `create_rust_zones`**

```ruby
# db/migrate/20260411120002_create_rust_zones.rb
class CreateRustZones < ActiveRecord::Migration[8.0]
  def change
    create_table :rust_zones do |t|
      t.references :rust_map, null: false, foreign_key: true
      t.decimal :x_pct, precision: 5, scale: 2, null: false  # 0.00..100.00
      t.decimal :y_pct, precision: 5, scale: 2, null: false
      t.string :status, null: false, default: "ok" # ok|surface|deep|perforation
      t.string :label
      t.text :note
      t.integer :position, default: 0
      t.timestamps
    end
    add_index :rust_zones, [:rust_map_id, :position]
  end
end
```

- [ ] **Step 1.3 — Migration `create_provenance_events`**

```ruby
# db/migrate/20260411120003_create_provenance_events.rb
class CreateProvenanceEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :provenance_events do |t|
      t.references :listing, null: false, foreign_key: true
      t.integer :event_year, null: false
      t.string :event_type, null: false, default: "service" # purchase|service|restoration|race|award|exhibition
      t.string :label, null: false
      t.text :description
      t.integer :position, default: 0
      t.timestamps
    end
    add_index :provenance_events, [:listing_id, :position]
    add_index :provenance_events, :event_year
  end
end
```

- [ ] **Step 1.4 — Migration `create_originality_scores`**

```ruby
# db/migrate/20260411120004_create_originality_scores.rb
class CreateOriginalityScores < ActiveRecord::Migration[8.0]
  def change
    create_table :originality_scores do |t|
      t.references :listing, null: false, foreign_key: true, index: { unique: true }
      t.integer :overall_score, default: 100 # 0-100
      t.boolean :matching_numbers, default: false
      t.integer :original_paint_pct, default: 100
      t.boolean :original_interior, default: false
      t.text :notes
      t.timestamps
    end
  end
end
```

- [ ] **Step 1.5 — Migration `create_listing_questions`**

```ruby
# db/migrate/20260411120005_create_listing_questions.rb
class CreateListingQuestions < ActiveRecord::Migration[8.0]
  def change
    create_table :listing_questions do |t|
      t.references :listing, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :body, null: false
      t.boolean :published, default: false
      t.timestamps
    end
    add_index :listing_questions, [:listing_id, :published]
  end
end
```

- [ ] **Step 1.6 — Migration `create_listing_answers`**

```ruby
# db/migrate/20260411120006_create_listing_answers.rb
class CreateListingAnswers < ActiveRecord::Migration[8.0]
  def change
    create_table :listing_answers do |t|
      t.references :listing_question, null: false, foreign_key: true, index: { unique: true }
      t.references :user, null: false, foreign_key: true
      t.text :body, null: false
      t.timestamps
    end
  end
end
```

- [ ] **Step 1.7 — Migration `add_wizard_fields_to_listings`**

```ruby
# db/migrate/20260411120007_add_wizard_fields_to_listings.rb
class AddWizardFieldsToListings < ActiveRecord::Migration[8.0]
  def change
    change_table :listings do |t|
      t.jsonb :draft_data, default: {}, null: false
      t.integer :wizard_step, default: 0, null: false
      t.datetime :published_at
      # views_count existe déjà ? Sinon on l'ajoute nullable avec default 0
    end

    add_column :listings, :views_count, :integer, default: 0, null: false unless column_exists?(:listings, :views_count)
    add_column :listings, :slug, :string unless column_exists?(:listings, :slug)
    add_index :listings, :slug, unique: true unless index_exists?(:listings, :slug)
    add_index :listings, :published_at
    add_index :listings, :wizard_step
  end
end
```

- [ ] **Step 1.8 — Exécuter les migrations + vérifier le schema**

```bash
docker exec vera-trade-web bin/rails db:migrate
docker exec vera-trade-web bin/rails db:migrate:status | tail -20
docker exec vera-trade-web cat db/schema.rb | grep -E "create_table \"(rust_maps|rust_zones|provenance_events|originality_scores|listing_questions|listing_answers)\""
```

Expected : 7 migrations marked `up`. `create_table` lines visibles dans schema.rb.

- [ ] **Step 1.9 — Copier le schema.rb modifié vers le host + commit**

```bash
docker cp vera-trade-web:/rails/db/schema.rb db/schema.rb
git add db/migrate/2026041112000*_*.rb db/schema.rb
git commit -m "feat(db): M8 — migrations wizard dépôt (RustMap, provenance, originality, Q&A)"
```

---

## Task 2 — Modèles & associations

**Files :**
- Create : `app/models/rust_map.rb`
- Create : `app/models/rust_zone.rb`
- Create : `app/models/provenance_event.rb`
- Create : `app/models/originality_score.rb`
- Create : `app/models/listing_question.rb`
- Create : `app/models/listing_answer.rb`
- Modify : `app/models/listing.rb`
- Create : `test/models/rust_map_test.rb`
- Create : `test/models/rust_zone_test.rb`
- Create : `test/models/provenance_event_test.rb`
- Create : `test/models/originality_score_test.rb`
- Create : `test/models/listing_question_test.rb`
- Create : `test/fixtures/rust_maps.yml`
- Create : `test/fixtures/rust_zones.yml`
- Create : `test/fixtures/provenance_events.yml`
- Create : `test/fixtures/originality_scores.yml`
- Create : `test/fixtures/listing_questions.yml`
- Create : `test/fixtures/listing_answers.yml`

- [ ] **Step 2.1 — Fixture `rust_maps.yml`**

```yaml
# test/fixtures/rust_maps.yml
one:
  listing: one
  silhouette_variant: sedan
  transparency_score: 94
  notes: "Véhicule globalement sain, 2 zones surface au plancher arrière"
```

- [ ] **Step 2.2 — Test RustMap**

```ruby
# test/models/rust_map_test.rb
require "test_helper"

class RustMapTest < ActiveSupport::TestCase
  test "belongs to a listing and has many zones" do
    rm = rust_maps(:one)
    assert_equal listings(:one), rm.listing
    assert rm.respond_to?(:zones)
  end

  test "silhouette_variant defaults to sedan" do
    rm = RustMap.new
    assert_equal "sedan", rm.silhouette_variant
  end

  test "transparency_score defaults to 100" do
    rm = RustMap.new
    assert_equal 100, rm.transparency_score
  end

  test "transparency_score is clamped between 0 and 100" do
    rm = RustMap.new(transparency_score: 120)
    refute rm.valid?
    assert_includes rm.errors[:transparency_score], "must be less than or equal to 100"
  end

  VALID_VARIANTS = %w[sedan coupe wagon suv hatch convertible motorcycle van pickup].freeze

  test "valid silhouette variants" do
    VALID_VARIANTS.each do |variant|
      rm = RustMap.new(silhouette_variant: variant, listing: listings(:one))
      assert rm.valid?, "expected #{variant} to be valid: #{rm.errors.full_messages}"
    end
  end

  test "invalid silhouette variant is rejected" do
    rm = RustMap.new(silhouette_variant: "spaceship", listing: listings(:one))
    refute rm.valid?
  end
end
```

- [ ] **Step 2.3 — Run RustMap test to see it FAIL**

```bash
docker exec vera-trade-web bin/rails test test/models/rust_map_test.rb 2>&1 | tail -15
```

Expected : erreur `uninitialized constant RustMap` ou similaire.

- [ ] **Step 2.4 — Implémenter `app/models/rust_map.rb`**

```ruby
# app/models/rust_map.rb
class RustMap < ApplicationRecord
  VALID_VARIANTS = %w[sedan coupe wagon suv hatch convertible motorcycle van pickup].freeze

  belongs_to :listing
  has_many :zones, -> { order(position: :asc) }, class_name: "RustZone", dependent: :destroy

  validates :silhouette_variant, presence: true, inclusion: { in: VALID_VARIANTS }
  validates :transparency_score,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 0,
              less_than_or_equal_to: 100
            }

  # Recalcule le score de transparence à partir des zones existantes.
  # ok = 0pt, surface = -5pt, deep = -12pt, perforation = -25pt. Min 0.
  def recompute_score!
    penalty = zones.sum { |z| RustZone::SEVERITY.fetch(z.status, 0) }
    update!(transparency_score: [100 - penalty, 0].max)
  end
end
```

- [ ] **Step 2.5 — Re-run RustMap test → vert**

```bash
docker exec vera-trade-web bin/rails test test/models/rust_map_test.rb 2>&1 | tail -10
```

Expected : `5 runs, 8 assertions, 0 failures, 0 errors`.

- [ ] **Step 2.6 — Fixture + test RustZone**

```yaml
# test/fixtures/rust_zones.yml
one:
  rust_map: one
  x_pct: 42.50
  y_pct: 68.00
  status: surface
  label: "Plancher arrière droit"
  note: "Oxydation superficielle, pas de perforation"
  position: 0
two:
  rust_map: one
  x_pct: 55.10
  y_pct: 71.20
  status: ok
  label: "Longeron droit"
  position: 1
```

```ruby
# test/models/rust_zone_test.rb
require "test_helper"

class RustZoneTest < ActiveSupport::TestCase
  test "belongs to a rust_map" do
    assert_equal rust_maps(:one), rust_zones(:one).rust_map
  end

  test "coordinates are required" do
    z = RustZone.new(rust_map: rust_maps(:one), status: "ok")
    refute z.valid?
    assert_includes z.errors[:x_pct], "can't be blank"
    assert_includes z.errors[:y_pct], "can't be blank"
  end

  test "coordinates are clamped to 0..100" do
    z = RustZone.new(rust_map: rust_maps(:one), x_pct: 150, y_pct: -5, status: "ok")
    refute z.valid?
    assert_includes z.errors[:x_pct], "must be less than or equal to 100"
    assert_includes z.errors[:y_pct], "must be greater than or equal to 0"
  end

  test "status must be in enum" do
    z = RustZone.new(rust_map: rust_maps(:one), x_pct: 10, y_pct: 10, status: "molten")
    refute z.valid?
  end

  test "SEVERITY hash drives score penalty" do
    assert_equal 0,  RustZone::SEVERITY["ok"]
    assert_equal 5,  RustZone::SEVERITY["surface"]
    assert_equal 12, RustZone::SEVERITY["deep"]
    assert_equal 25, RustZone::SEVERITY["perforation"]
  end
end
```

- [ ] **Step 2.7 — Run RustZone test → FAIL**

```bash
docker exec vera-trade-web bin/rails test test/models/rust_zone_test.rb 2>&1 | tail -15
```

- [ ] **Step 2.8 — Implémenter `app/models/rust_zone.rb`**

```ruby
# app/models/rust_zone.rb
class RustZone < ApplicationRecord
  VALID_STATUSES = %w[ok surface deep perforation].freeze
  SEVERITY = { "ok" => 0, "surface" => 5, "deep" => 12, "perforation" => 25 }.freeze

  belongs_to :rust_map

  validates :x_pct, :y_pct, presence: true,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :status, presence: true, inclusion: { in: VALID_STATUSES }
end
```

- [ ] **Step 2.9 — Run RustZone test → GREEN**

```bash
docker exec vera-trade-web bin/rails test test/models/rust_zone_test.rb 2>&1 | tail -10
```

- [ ] **Step 2.10 — Fixture + test ProvenanceEvent**

```yaml
# test/fixtures/provenance_events.yml
one:
  listing: one
  event_year: 1989
  event_type: purchase
  label: "Première main"
  description: "Livrée neuve par le concessionnaire Citroën de Lyon"
  position: 0
two:
  listing: one
  event_year: 2012
  event_type: restoration
  label: "Restauration complète"
  description: "Peinture intégrale, révision moteur, intérieur refait"
  position: 1
```

```ruby
# test/models/provenance_event_test.rb
require "test_helper"

class ProvenanceEventTest < ActiveSupport::TestCase
  test "belongs to listing" do
    assert_equal listings(:one), provenance_events(:one).listing
  end

  test "event_year required" do
    e = ProvenanceEvent.new(listing: listings(:one), event_type: "purchase", label: "x")
    refute e.valid?
    assert_includes e.errors[:event_year], "can't be blank"
  end

  test "label required" do
    e = ProvenanceEvent.new(listing: listings(:one), event_type: "purchase", event_year: 1990)
    refute e.valid?
  end

  test "event_type must be valid" do
    e = ProvenanceEvent.new(listing: listings(:one), event_year: 1990, label: "x", event_type: "abduction")
    refute e.valid?
  end
end
```

- [ ] **Step 2.11 — Implémenter `app/models/provenance_event.rb`**

```ruby
# app/models/provenance_event.rb
class ProvenanceEvent < ApplicationRecord
  VALID_TYPES = %w[purchase service restoration race award exhibition registration].freeze

  belongs_to :listing
  validates :event_year, presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 1900, less_than_or_equal_to: 2100 }
  validates :label, presence: true
  validates :event_type, presence: true, inclusion: { in: VALID_TYPES }

  default_scope -> { order(event_year: :asc, position: :asc) }
end
```

- [ ] **Step 2.12 — Run ProvenanceEvent test → GREEN**

```bash
docker exec vera-trade-web bin/rails test test/models/provenance_event_test.rb 2>&1 | tail -10
```

- [ ] **Step 2.13 — Fixture + test OriginalityScore**

```yaml
# test/fixtures/originality_scores.yml
one:
  listing: one
  overall_score: 94
  matching_numbers: true
  original_paint_pct: 85
  original_interior: true
  notes: "Numéros d'origine, peinture 85% d'origine, intérieur 100% matching"
```

```ruby
# test/models/originality_score_test.rb
require "test_helper"

class OriginalityScoreTest < ActiveSupport::TestCase
  test "belongs to listing" do
    assert_equal listings(:one), originality_scores(:one).listing
  end

  test "overall_score clamped 0..100" do
    s = OriginalityScore.new(listing: listings(:one), overall_score: 110)
    refute s.valid?
  end

  test "original_paint_pct clamped 0..100" do
    s = OriginalityScore.new(listing: listings(:one), original_paint_pct: 150)
    refute s.valid?
  end
end
```

- [ ] **Step 2.14 — Implémenter `app/models/originality_score.rb`**

```ruby
# app/models/originality_score.rb
class OriginalityScore < ApplicationRecord
  belongs_to :listing

  validates :overall_score,
            numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :original_paint_pct,
            numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
end
```

- [ ] **Step 2.15 — Fixture ListingQuestion + ListingAnswer**

```yaml
# test/fixtures/listing_questions.yml
one:
  listing: one
  user: user_two
  body: "Est-ce que la peinture est d'origine sur la totalité de la caisse ?"
  published: true
```

```yaml
# test/fixtures/listing_answers.yml
one:
  listing_question: one
  user: user_one
  body: "Non, le capot et l'aile arrière droite ont été repeints en 2012 après léger accroc."
```

```ruby
# test/models/listing_question_test.rb
require "test_helper"

class ListingQuestionTest < ActiveSupport::TestCase
  test "belongs to listing and user" do
    q = listing_questions(:one)
    assert q.listing
    assert q.user
  end

  test "body required" do
    q = ListingQuestion.new(listing: listings(:one), user: users(:user_one))
    refute q.valid?
  end

  test "has one answer" do
    q = listing_questions(:one)
    assert_equal "listing_answers", q.answer.class.table_name
  end
end
```

- [ ] **Step 2.16 — Implémenter `ListingQuestion` + `ListingAnswer`**

```ruby
# app/models/listing_question.rb
class ListingQuestion < ApplicationRecord
  belongs_to :listing
  belongs_to :user
  has_one :answer, class_name: "ListingAnswer", dependent: :destroy

  validates :body, presence: true

  scope :published, -> { where(published: true) }
end
```

```ruby
# app/models/listing_answer.rb
class ListingAnswer < ApplicationRecord
  belongs_to :listing_question
  belongs_to :user

  validates :body, presence: true
end
```

- [ ] **Step 2.17 — Update Listing model**

```ruby
# app/models/listing.rb — ajoutez ces lignes après `has_many_attached :photos`
  has_one :rust_map, dependent: :destroy
  has_many :provenance_events, dependent: :destroy
  has_one :originality_score, dependent: :destroy
  has_many :listing_questions, dependent: :destroy

  # Ajoute :draft au enum (préserve les valeurs existantes)
  enum :status, { active: "active", pending: "pending", sold: "sold", draft: "draft" }, default: "draft"

  # Helper
  def wizard_in_progress?
    draft? && wizard_step < 7
  end

  def publishable?
    draft? && vehicle.present? && photos.any? && rust_map.present?
  end
```

- [ ] **Step 2.18 — Update Listing test pour couvrir le draft workflow**

Append to `test/models/listing_test.rb` :
```ruby
  test "listing status defaults to draft" do
    l = Listing.new(title: "x", description: "x", user: users(:user_one), vehicle: vehicles(:one))
    assert_equal "draft", l.status
  end

  test "wizard_in_progress? is true when draft and step < 7" do
    l = listings(:one)
    l.update!(status: "draft", wizard_step: 3)
    assert l.wizard_in_progress?
  end

  test "publishable? requires vehicle, photos, rust_map" do
    l = listings(:one)
    l.update!(status: "draft")
    refute l.publishable?  # no photos, no rust_map
  end

  test "has_one rust_map association" do
    l = listings(:one)
    assert l.respond_to?(:rust_map)
  end
```

- [ ] **Step 2.19 — Lancer tous les tests modèles**

```bash
docker exec vera-trade-web bin/rails test test/models 2>&1 | tail -15
```

Expected : 0 failures (fix les fixtures si des modèles existants tombent à cause du enum :status default changé).

- [ ] **Step 2.20 — Commit Task 2**

```bash
git add app/models db/schema.rb test/fixtures test/models
git commit -m "feat(models): M8 — RustMap/RustZone/Provenance/Originality/Q&A + Listing draft enum"
```

---

## Task 3 — Routes & controller squelette

**Files :**
- Modify : `config/routes.rb`
- Create : `app/controllers/listing_wizards_controller.rb`
- Create : `test/controllers/listing_wizards_controller_test.rb`

- [ ] **Step 3.1 — Ajouter les routes wizard**

Edit `config/routes.rb`, ajouter **avant** `resources :listings` :
```ruby
  resources :listing_wizards, only: [:new, :create, :edit, :update] do
    member do
      patch :publish
      patch :save_step
    end
  end
```

- [ ] **Step 3.2 — Vérifier les routes**

```bash
docker exec vera-trade-web bin/rails routes 2>&1 | grep listing_wizard
```

Expected :
```
new_listing_wizard   GET   /listing_wizards/new
     listing_wizards  POST  /listing_wizards
edit_listing_wizard   GET   /listing_wizards/:id/edit
     listing_wizard  PATCH /listing_wizards/:id
publish_listing_wizard PATCH /listing_wizards/:id/publish
save_step_listing_wizard PATCH /listing_wizards/:id/save_step
```

- [ ] **Step 3.3 — Test controller wizard (TDD)**

```ruby
# test/controllers/listing_wizards_controller_test.rb
require "test_helper"

class ListingWizardsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:user_one)
    sign_in @user  # uses devise test helper; adjust if setup differs
  end

  test "new redirects to create (create fresh draft then edit step 0)" do
    get new_listing_wizard_path
    assert_redirected_to edit_listing_wizard_path(assigns(:listing))
    assert assigns(:listing).draft?
    assert_equal 0, assigns(:listing).wizard_step
  end

  test "edit renders step 0 layout" do
    listing = Listing.create!(
      user: @user,
      vehicle: Vehicle.create!(make: "Renault", model: "R5", year: 1989, price: 12000),
      title: "Brouillon",
      description: "draft",
      status: "draft",
      wizard_step: 0
    )
    get edit_listing_wizard_path(listing)
    assert_response :success
    assert_select "[data-controller='listing-wizard']"
    assert_select "[data-listing-wizard-step-value='0']"
  end

  test "save_step advances the listing draft_data and wizard_step" do
    listing = Listing.create!(
      user: @user,
      vehicle: Vehicle.create!(make: "x", model: "y", year: 2000, price: 1),
      title: "Brouillon",
      description: "d",
      status: "draft"
    )
    patch save_step_listing_wizard_path(listing), params: {
      step: 0,
      listing: { draft_data: { vehicle: { make: "Citroën", model: "CX" } } }
    }, as: :turbo_stream

    assert_response :success
    listing.reload
    assert_equal 1, listing.wizard_step
    assert_equal "Citroën", listing.draft_data.dig("vehicle", "make")
  end

  test "publish rejects when not publishable" do
    listing = Listing.create!(
      user: @user,
      vehicle: Vehicle.create!(make: "x", model: "y", year: 2000, price: 1),
      title: "x",
      description: "d",
      status: "draft"
    )
    patch publish_listing_wizard_path(listing)
    assert_redirected_to edit_listing_wizard_path(listing)
    assert_equal "draft", listing.reload.status
  end
end
```

- [ ] **Step 3.4 — Run controller test → FAIL (controller missing)**

```bash
docker exec vera-trade-web bin/rails test test/controllers/listing_wizards_controller_test.rb 2>&1 | tail -20
```

- [ ] **Step 3.5 — Implémenter squelette `ListingWizardsController`**

```ruby
# app/controllers/listing_wizards_controller.rb
class ListingWizardsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_listing, only: [:edit, :update, :save_step, :publish]
  before_action :ensure_owner, only: [:edit, :update, :save_step, :publish]

  STEPS = %w[vehicle photos rust_map mechanics history documents review].freeze

  def new
    listing = current_user.listings.create!(
      title: "Brouillon #{Time.current.to_i}",
      description: " ",
      status: "draft",
      wizard_step: 0,
      vehicle: Vehicle.create!(make: "À définir", model: "À définir", year: Date.current.year, price: 1)
    )
    @listing = listing
    redirect_to edit_listing_wizard_path(listing)
  end

  def edit
    @current_step = (@listing.wizard_step || 0).to_i
    @step_key = STEPS[@current_step] || STEPS.first
  end

  def save_step
    step_index = params[:step].to_i
    merged = (@listing.draft_data || {}).deep_merge(normalized_draft_data)
    next_step = [step_index + 1, STEPS.size - 1].min
    @listing.update!(draft_data: merged, wizard_step: next_step)
    @current_step = next_step
    @step_key = STEPS[next_step]

    respond_to do |fmt|
      fmt.turbo_stream
      fmt.html { redirect_to edit_listing_wizard_path(@listing) }
    end
  end

  def update
    save_step
  end

  def publish
    unless @listing.publishable?
      redirect_to edit_listing_wizard_path(@listing), alert: "Complétez tous les champs requis avant de publier."
      return
    end

    @listing.update!(status: "active", published_at: Time.current)
    redirect_to listing_path(@listing), notice: "Annonce publiée."
  end

  private

  def set_listing
    @listing = current_user.listings.find(params[:id])
  end

  def ensure_owner
    redirect_to listings_path, alert: "Non autorisé." unless @listing.user == current_user
  end

  def normalized_draft_data
    raw = params.fetch(:listing, {})[:draft_data]
    return {} unless raw

    case raw
    when ActionController::Parameters then raw.permit!.to_h
    when Hash then raw
    else {}
    end
  end
end
```

- [ ] **Step 3.6 — Re-run controller test → GREEN**

```bash
docker exec vera-trade-web bin/rails test test/controllers/listing_wizards_controller_test.rb 2>&1 | tail -15
```

- [ ] **Step 3.7 — Commit Task 3**

```bash
git add config/routes.rb app/controllers/listing_wizards_controller.rb test/controllers/listing_wizards_controller_test.rb
git commit -m "feat(wizard): M8 — routes + controller squelette save_step / publish"
```

---

## Task 4 — Layout wizard & Stimulus nav

**Files :**
- Create : `app/views/listing_wizards/edit.html.erb`
- Create : `app/views/listing_wizards/_layout.html.erb`
- Create : `app/views/listing_wizards/_nav.html.erb`
- Create : `app/views/listing_wizards/_progress.html.erb`
- Create : `app/views/listing_wizards/save_step.turbo_stream.erb`
- Create : `app/javascript/controllers/listing_wizard_controller.js`
- Modify : `app/javascript/controllers/index.js`

- [ ] **Step 4.1 — `edit.html.erb` (shell avec Turbo Frame)**

```erb
<%# app/views/listing_wizards/edit.html.erb %>
<% content_for :title, "Publier une annonce — Vera Trade" %>

<section class="relative bg-bg-primary min-h-screen">
  <div class="max-w-[1200px] mx-auto px-5 lg:px-10 py-12 lg:py-16">

    <header class="mb-12">
      <p class="eyebrow mb-4">Publication — Dépôt guidé</p>
      <h1 class="font-display text-[44px] lg:text-[64px] leading-[1.05] text-text-primary">
        <span class="playfair-italic">Déposez</span> votre voiture.
      </h1>
      <p class="font-body italic text-[16px] text-text-secondary max-w-[560px] mt-4">
        Sept étapes, une fiche irréprochable. Nous préférons une annonce honnête à une annonce flatteuse.
      </p>
    </header>

    <%= render "progress", current_step: @current_step %>

    <%= turbo_frame_tag "wizard_step", data: { controller: "listing-wizard", listing_wizard_step_value: @current_step } do %>
      <%= render "listing_wizards/step_#{format('%02d', @current_step)}_#{@step_key}", listing: @listing %>
    <% end %>
  </div>
</section>
```

- [ ] **Step 4.2 — `_progress.html.erb` (indicateur étapes)**

```erb
<%# app/views/listing_wizards/_progress.html.erb %>
<nav aria-label="Étapes de publication" class="mb-16">
  <% steps = [
    { key: "vehicle",   label: "Véhicule" },
    { key: "photos",    label: "Photos" },
    { key: "rust_map",  label: "Rust Map" },
    { key: "mechanics", label: "Mécanique" },
    { key: "history",   label: "Historique" },
    { key: "documents", label: "Documents" },
    { key: "review",    label: "Revue" }
  ] %>
  <ol class="flex items-center gap-2 lg:gap-6 overflow-x-auto pb-2">
    <% steps.each_with_index do |s, i| %>
      <% state = if i < current_step then :done
                 elsif i == current_step then :active
                 else :pending end %>
      <li class="flex items-center gap-2 lg:gap-4 shrink-0">
        <span class="w-7 h-7 flex items-center justify-center font-mono text-[11px] border <%= case state
            when :done then 'border-accent-red text-accent-red'
            when :active then 'border-accent-red bg-accent-red text-text-primary'
            else 'border-line text-text-muted' end %>">
          <%= format('%02d', i + 1) %>
        </span>
        <span class="font-ui text-[10px] lg:text-[11px] uppercase tracking-[0.2em] hidden lg:inline <%= case state
            when :done then 'text-text-secondary'
            when :active then 'text-text-primary'
            else 'text-text-muted' end %>">
          <%= s[:label] %>
        </span>
        <% if i < steps.size - 1 %>
          <span class="hidden lg:inline-block w-10 h-px bg-line" aria-hidden="true"></span>
        <% end %>
      </li>
    <% end %>
  </ol>
</nav>
```

- [ ] **Step 4.3 — `_nav.html.erb` (prev/next/publish)**

```erb
<%# app/views/listing_wizards/_nav.html.erb %>
<%# Locals: listing, current_step, is_last, can_go_back %>
<div class="flex items-center justify-between gap-4 pt-10 border-t border-line mt-12">
  <% if can_go_back %>
    <%= button_to save_step_listing_wizard_path(listing),
        params: { step: current_step - 2, listing: { draft_data: {} } },
        method: :patch,
        class: "btn-vera-secondary cursor-pointer" do %>
      ← Étape précédente
    <% end %>
  <% else %>
    <span></span>
  <% end %>

  <% if is_last %>
    <%= button_to publish_listing_wizard_path(listing),
        method: :patch,
        class: "btn-vera-primary cursor-pointer" do %>
      Publier l'annonce
    <% end %>
  <% else %>
    <button type="submit" form="wizard-form-step-<%= current_step %>" class="btn-vera-primary cursor-pointer">
      Étape suivante →
    </button>
  <% end %>
</div>
```

- [ ] **Step 4.4 — `save_step.turbo_stream.erb`**

```erb
<%# app/views/listing_wizards/save_step.turbo_stream.erb %>
<%= turbo_stream.replace "wizard_step" do %>
  <%= turbo_frame_tag "wizard_step", data: { controller: "listing-wizard", listing_wizard_step_value: @current_step } do %>
    <%= render "listing_wizards/step_#{format('%02d', @current_step)}_#{@step_key}", listing: @listing %>
  <% end %>
<% end %>
```

- [ ] **Step 4.5 — Stimulus controller `listing_wizard_controller.js`**

```javascript
// app/javascript/controllers/listing_wizard_controller.js
import { Controller } from "@hotwired/stimulus"

// Wizard parent controller: tracks current step value and scrolls smoothly
// when the turbo-frame is replaced.
export default class extends Controller {
  static values = { step: Number }

  connect() {
    // Smooth scroll to top of the frame after each step transition
    this.element.scrollIntoView({ behavior: "smooth", block: "start" })
  }

  stepValueChanged(newValue, oldValue) {
    if (typeof oldValue !== "undefined" && newValue !== oldValue) {
      console.debug(`[wizard] step ${oldValue} → ${newValue}`)
    }
  }
}
```

- [ ] **Step 4.6 — Register Stimulus controller**

Edit `app/javascript/controllers/index.js`, append at the end :
```javascript
import ListingWizardController from "./listing_wizard_controller"
application.register("listing-wizard", ListingWizardController)
```

- [ ] **Step 4.7 — Rebuild JS bundle et vérifier en container**

```bash
docker cp app/javascript/controllers/listing_wizard_controller.js vera-trade-web:/rails/app/javascript/controllers/listing_wizard_controller.js
docker cp app/javascript/controllers/index.js vera-trade-web:/rails/app/javascript/controllers/index.js
docker cp app/views/listing_wizards/edit.html.erb vera-trade-web:/rails/app/views/listing_wizards/edit.html.erb
docker cp app/views/listing_wizards/_progress.html.erb vera-trade-web:/rails/app/views/listing_wizards/_progress.html.erb
docker cp app/views/listing_wizards/_nav.html.erb vera-trade-web:/rails/app/views/listing_wizards/_nav.html.erb
docker cp app/views/listing_wizards/save_step.turbo_stream.erb vera-trade-web:/rails/app/views/listing_wizards/save_step.turbo_stream.erb
docker exec vera-trade-web npx yarn build:css
docker exec vera-trade-web npx yarn build
```

- [ ] **Step 4.8 — Smoke test l'accès au wizard (sous auth)**

```bash
rm -f /tmp/cookies.txt
CSRF=$(curl -s -c /tmp/cookies.txt http://127.0.0.1:8098/users/sign_in | grep -oE 'name="authenticity_token" value="[^"]+"' | head -1 | sed 's/.*value="\([^"]*\)".*/\1/')
curl -s -b /tmp/cookies.txt -c /tmp/cookies.txt -o /dev/null -X POST http://127.0.0.1:8098/users/sign_in \
  --data-urlencode "authenticity_token=$CSRF" \
  --data-urlencode "user[email]=admin@veratrade.fr" \
  --data-urlencode "user[password]=Azerty123!" \
  --data-urlencode "commit=Se connecter"
curl -s -b /tmp/cookies.txt -L -o /tmp/wizard.html -w "HTTP %{http_code} / %{size_download}B\n" http://127.0.0.1:8098/listing_wizards/new
echo "markers: $(grep -c 'data-controller="listing-wizard"\|Publier une annonce\|Étapes de publication\|playfair-italic' /tmp/wizard.html)"
```

Expected : HTTP 200, markers >= 4.

- [ ] **Step 4.9 — Commit Task 4**

```bash
git add app/views/listing_wizards/ app/javascript/controllers/
git commit -m "feat(wizard): M8 — layout shell + Turbo Frame + Stimulus nav + progress"
```

---

## Task 5 — Step 1 Véhicule

**Files :**
- Create : `app/views/listing_wizards/_step_00_vehicle.html.erb`

- [ ] **Step 5.1 — Formulaire Véhicule**

```erb
<%# app/views/listing_wizards/_step_00_vehicle.html.erb %>
<%# Locals: listing %>
<% draft = listing.draft_data.with_indifferent_access %>
<% v = draft[:vehicle] || {} %>

<div class="max-w-[720px]">
  <div class="mb-10">
    <h2 class="font-display text-[32px] playfair-italic text-text-primary">Étape 01 — Véhicule</h2>
    <p class="font-body italic text-[15px] text-text-muted mt-2">Les fondamentaux. Marque, modèle, année, prix — tout ce qui permet d'identifier la voiture en un coup d'œil.</p>
  </div>

  <%= form_with url: save_step_listing_wizard_path(listing),
        method: :patch,
        data: { turbo_frame: "wizard_step" },
        html: { id: "wizard-form-step-0", class: "space-y-8", novalidate: true } do |f| %>
    <%= f.hidden_field :step, value: 0 %>

    <div class="grid grid-cols-1 sm:grid-cols-2 gap-6">
      <div>
        <label class="label-small block mb-3" for="vehicle_make">Marque</label>
        <input id="vehicle_make" name="listing[draft_data][vehicle][make]" value="<%= v[:make] %>" class="input-vera" placeholder="Citroën" />
      </div>
      <div>
        <label class="label-small block mb-3" for="vehicle_model">Modèle</label>
        <input id="vehicle_model" name="listing[draft_data][vehicle][model]" value="<%= v[:model] %>" class="input-vera" placeholder="BX GTi 16V" />
      </div>
      <div>
        <label class="label-small block mb-3" for="vehicle_year">Année</label>
        <input id="vehicle_year" type="number" name="listing[draft_data][vehicle][year]" value="<%= v[:year] %>" class="input-vera input-mono" placeholder="1989" min="1900" max="<%= Date.current.year %>" />
      </div>
      <div>
        <label class="label-small block mb-3" for="vehicle_km">Kilométrage</label>
        <input id="vehicle_km" type="number" name="listing[draft_data][vehicle][kilometers]" value="<%= v[:kilometers] %>" class="input-vera input-mono" placeholder="142500" min="0" />
      </div>
      <div class="sm:col-span-2">
        <label class="label-small block mb-3" for="vehicle_price">Prix demandé (€)</label>
        <input id="vehicle_price" type="number" name="listing[draft_data][vehicle][price]" value="<%= v[:price] %>" class="input-vera input-mono" placeholder="18500" min="0" />
      </div>
      <div class="sm:col-span-2">
        <label class="label-small block mb-3" for="vehicle_location">Localisation</label>
        <input id="vehicle_location" name="listing[draft_data][vehicle][location]" value="<%= v[:location] %>" class="input-vera" placeholder="Lyon (69)" />
      </div>
      <div>
        <label class="label-small block mb-3" for="vehicle_vin">VIN (optionnel)</label>
        <input id="vehicle_vin" name="listing[draft_data][vehicle][vin]" value="<%= v[:vin] %>" class="input-vera input-mono uppercase" maxlength="17" placeholder="VF7XXXXXXXXXXXXXX" />
      </div>
      <div>
        <label class="label-small block mb-3" for="vehicle_plate">Immatriculation</label>
        <input id="vehicle_plate" name="listing[draft_data][vehicle][license_plate]" value="<%= v[:license_plate] %>" class="input-vera input-mono uppercase" placeholder="AB-123-CD" />
      </div>
    </div>

    <%= render "listing_wizards/nav",
          listing: listing,
          current_step: 1,
          is_last: false,
          can_go_back: false %>
  <% end %>
</div>
```

- [ ] **Step 5.2 — Copier vers container et tester**

```bash
docker cp app/views/listing_wizards/_step_00_vehicle.html.erb vera-trade-web:/rails/app/views/listing_wizards/_step_00_vehicle.html.erb
curl -s -b /tmp/cookies.txt -L -o /tmp/wz1.html -w "HTTP %{http_code} / %{size_download}B\n" http://127.0.0.1:8098/listing_wizards/new
grep -c 'Marque\|Modèle\|Kilométrage\|Localisation\|Étape 01' /tmp/wz1.html
```

Expected : HTTP 200, markers >= 5.

- [ ] **Step 5.3 — Commit**

```bash
git add app/views/listing_wizards/_step_00_vehicle.html.erb
git commit -m "feat(wizard): M8 — step 01 Véhicule (marque/modèle/année/km/prix/lieu/VIN)"
```

---

## Task 6 — Step 2 Photos

**Files :**
- Create : `app/views/listing_wizards/_step_01_photos.html.erb`
- Create : `app/javascript/controllers/photo_dropzone_controller.js`
- Modify : `app/javascript/controllers/index.js`
- Modify : `app/controllers/listing_wizards_controller.rb` (gérer photos attach)

- [ ] **Step 6.1 — Stimulus `photo_dropzone_controller.js`**

```javascript
// app/javascript/controllers/photo_dropzone_controller.js
import { Controller } from "@hotwired/stimulus"

// Minimal drop-zone preview controller. File actually upload via direct-upload
// when the wizard form submits (ActiveStorage direct upload on the hidden input).
export default class extends Controller {
  static targets = ["input", "preview", "list"]

  connect() {
    this.files = []
  }

  browse() { this.inputTarget.click() }

  onDrop(event) {
    event.preventDefault()
    this.element.classList.remove("border-accent-red")
    this.addFiles(event.dataTransfer.files)
  }

  onDragOver(event) {
    event.preventDefault()
    this.element.classList.add("border-accent-red")
  }

  onDragLeave() { this.element.classList.remove("border-accent-red") }

  onChange(event) { this.addFiles(event.target.files) }

  addFiles(fileList) {
    for (const file of Array.from(fileList)) {
      if (this.files.length >= 10) break
      if (!file.type.startsWith("image/")) continue
      this.files.push(file)
      this.renderThumb(file)
    }
  }

  renderThumb(file) {
    const reader = new FileReader()
    reader.onload = (e) => {
      const li = document.createElement("li")
      li.className = "relative border border-line aspect-[4/3] overflow-hidden"
      li.innerHTML = `
        <img src="${e.target.result}" class="w-full h-full object-cover" alt="${file.name}" />
        <span class="absolute bottom-0 left-0 right-0 px-2 py-1 font-mono text-[10px] uppercase tracking-[0.1em] text-text-muted bg-bg-primary/80 truncate">${file.name}</span>
      `
      this.listTarget.appendChild(li)
    }
    reader.readAsDataURL(file)
  }
}
```

Register in `app/javascript/controllers/index.js` :
```javascript
import PhotoDropzoneController from "./photo_dropzone_controller"
application.register("photo-dropzone", PhotoDropzoneController)
```

- [ ] **Step 6.2 — Vue step 2 Photos**

```erb
<%# app/views/listing_wizards/_step_01_photos.html.erb %>
<%# Locals: listing %>
<div class="max-w-[900px]">
  <div class="mb-10">
    <h2 class="font-display text-[32px] playfair-italic text-text-primary">Étape 02 — Photos</h2>
    <p class="font-body italic text-[15px] text-text-muted mt-2">Dix photos maximum. La première sera la couverture. Privilégiez la lumière naturelle.</p>
  </div>

  <%= form_with url: save_step_listing_wizard_path(listing),
        method: :patch,
        multipart: true,
        data: { turbo_frame: "wizard_step" },
        html: { id: "wizard-form-step-1", class: "space-y-8", novalidate: true } do |f| %>
    <%= f.hidden_field :step, value: 1 %>

    <div class="border border-line border-dashed p-10 text-center transition-colors"
         data-controller="photo-dropzone"
         data-action="drop->photo-dropzone#onDrop dragover->photo-dropzone#onDragOver dragleave->photo-dropzone#onDragLeave click->photo-dropzone#browse">
      <svg class="mx-auto w-10 h-10 text-text-muted mb-4" fill="none" stroke="currentColor" stroke-width="1.2" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" d="M12 4v12m0 0l-4-4m4 4l4-4M4 20h16"/>
      </svg>
      <p class="font-ui text-[11px] uppercase tracking-[0.2em] text-text-primary mb-2">Déposer ou cliquer pour ajouter</p>
      <p class="font-body italic text-[13px] text-text-muted">Formats JPG/WEBP — 5 Mo max par image — 10 images max</p>
      <input type="file" name="listing[photos][]" accept="image/*" multiple class="sr-only"
             data-photo-dropzone-target="input" data-action="change->photo-dropzone#onChange" />

      <ul class="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-4 mt-8" data-photo-dropzone-target="list"></ul>
    </div>

    <% if listing.photos.any? %>
      <div>
        <p class="label-small text-accent-red mb-4">Photos déjà enregistrées</p>
        <ul class="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-4">
          <% listing.photos.each do |p| %>
            <li class="relative border border-line aspect-[4/3] overflow-hidden">
              <%= image_tag p, class: "w-full h-full object-cover" %>
            </li>
          <% end %>
        </ul>
      </div>
    <% end %>

    <%= render "listing_wizards/nav",
          listing: listing,
          current_step: 2,
          is_last: false,
          can_go_back: true %>
  <% end %>
</div>
```

- [ ] **Step 6.3 — Controller : attacher photos sur `save_step` quand step=1**

Dans `ListingWizardsController#save_step`, avant `@listing.update!(...)` :
```ruby
    if params.dig(:listing, :photos).present?
      @listing.photos.attach(params[:listing][:photos])
    end
```

- [ ] **Step 6.4 — Smoke test**

```bash
docker cp app/views/listing_wizards/_step_01_photos.html.erb vera-trade-web:/rails/app/views/listing_wizards/_step_01_photos.html.erb
docker cp app/javascript/controllers/photo_dropzone_controller.js vera-trade-web:/rails/app/javascript/controllers/photo_dropzone_controller.js
docker cp app/javascript/controllers/index.js vera-trade-web:/rails/app/javascript/controllers/index.js
docker cp app/controllers/listing_wizards_controller.rb vera-trade-web:/rails/app/controllers/listing_wizards_controller.rb
docker exec vera-trade-web npx yarn build
# TODO : simuler un POST avec une photo en test integration si besoin
```

- [ ] **Step 6.5 — Commit**

```bash
git add app/views/listing_wizards/_step_01_photos.html.erb app/javascript/controllers/photo_dropzone_controller.js app/javascript/controllers/index.js app/controllers/listing_wizards_controller.rb
git commit -m "feat(wizard): M8 — step 02 Photos (drop-zone + preview Stimulus + ActiveStorage)"
```

---

## Task 7 — Step 3 Rust Map éditable (composant signature)

**Files :**
- Create : `app/assets/images/silhouettes/sedan.svg`
- Create : `app/assets/images/silhouettes/coupe.svg`
- Create : `app/assets/images/silhouettes/wagon.svg`
- Create : `app/assets/images/silhouettes/hatch.svg`
- Create : `app/assets/images/silhouettes/convertible.svg`
- Create : `app/assets/images/silhouettes/suv.svg`
- Create : `app/assets/images/silhouettes/motorcycle.svg`
- Create : `app/assets/images/silhouettes/van.svg`
- Create : `app/assets/images/silhouettes/pickup.svg`
- Create : `app/views/listing_wizards/_step_02_rust_map.html.erb`
- Create : `app/javascript/controllers/rust_map_editor_controller.js`
- Modify : `app/javascript/controllers/index.js`
- Modify : `app/controllers/listing_wizards_controller.rb`

- [ ] **Step 7.1 — Créer une silhouette SVG de base (sedan)**

Le profil latéral doit tenir dans un viewBox 1000x400, stroke white, fond transparent. Les autres silhouettes copient le même viewBox pour simplifier l'édition. Version minimaliste suffisante pour itération visuelle :

```xml
<!-- app/assets/images/silhouettes/sedan.svg -->
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1000 400" fill="none" stroke="currentColor" stroke-width="2.5">
  <path d="M60 280 Q60 260 90 250 L170 240 Q210 180 280 170 L560 165 Q640 170 700 220 L880 235 Q940 245 940 285 L940 305 L60 305 Z" />
  <!-- roues -->
  <circle cx="220" cy="305" r="45" />
  <circle cx="220" cy="305" r="22" />
  <circle cx="780" cy="305" r="45" />
  <circle cx="780" cy="305" r="22" />
  <!-- fenêtres -->
  <path d="M220 240 L300 180 L540 175 L610 225" />
  <line x1="410" y1="180" x2="410" y2="230" />
</svg>
```

Pour les autres variantes : reprendre le même gabarit avec modifs de toit/hayon/capote. Acceptable d'utiliser le même SVG temporairement pour toutes les variantes au premier commit — à affiner itérativement.

- [ ] **Step 7.2 — Dupliquer pour les 8 autres variants**

```bash
for v in coupe wagon hatch convertible suv motorcycle van pickup; do
  cp app/assets/images/silhouettes/sedan.svg "app/assets/images/silhouettes/$v.svg"
done
```

Itération design : ajuster chaque SVG à son profil distinctif en PR suivante (backlog).

- [ ] **Step 7.3 — Helper pour inline SVG**

Append to `app/helpers/listings_helper.rb` :
```ruby
  def silhouette_svg(variant)
    safe_variant = RustMap::VALID_VARIANTS.include?(variant.to_s) ? variant.to_s : "sedan"
    path = Rails.root.join("app/assets/images/silhouettes/#{safe_variant}.svg")
    return "".html_safe unless File.exist?(path)
    File.read(path).html_safe
  end
```

- [ ] **Step 7.4 — Stimulus `rust_map_editor_controller.js`**

```javascript
// app/javascript/controllers/rust_map_editor_controller.js
import { Controller } from "@hotwired/stimulus"

// Rust Map editor: SVG canvas with click-to-add zones, click-to-select,
// keyboard shortcuts for status (1=ok, 2=surface, 3=deep, 4=perforation).
// Drag to reposition. Persists JSON into a hidden input on form submit.
export default class extends Controller {
  static targets = ["canvas", "stateInput", "summary", "zoneList", "scoreOutput"]
  static values = { zones: Array }

  connect() {
    this.zones = this.hasZonesValue ? [...this.zonesValue] : []
    this.selectedId = null
    this.dragState = null
    this.render()
  }

  onCanvasClick(event) {
    // Ignore if we're coming out of a drag
    if (this.dragState?.moved) { this.dragState = null; return }
    const rect = this.canvasTarget.getBoundingClientRect()
    const x = ((event.clientX - rect.left) / rect.width) * 100
    const y = ((event.clientY - rect.top) / rect.height) * 100
    const zone = {
      id: `z${Date.now()}${Math.floor(Math.random() * 999)}`,
      x: +x.toFixed(2),
      y: +y.toFixed(2),
      status: "surface",
      label: "",
      note: ""
    }
    this.zones.push(zone)
    this.selectedId = zone.id
    this.persist()
    this.render()
  }

  onDotMouseDown(event) {
    event.stopPropagation()
    const id = event.currentTarget.dataset.zoneId
    this.selectedId = id
    this.dragState = { id, moved: false }
    this.render()
  }

  onCanvasMouseMove(event) {
    if (!this.dragState) return
    this.dragState.moved = true
    const rect = this.canvasTarget.getBoundingClientRect()
    const x = Math.max(0, Math.min(100, ((event.clientX - rect.left) / rect.width) * 100))
    const y = Math.max(0, Math.min(100, ((event.clientY - rect.top) / rect.height) * 100))
    const z = this.zones.find(zz => zz.id === this.dragState.id)
    if (z) {
      z.x = +x.toFixed(2)
      z.y = +y.toFixed(2)
      this.persist()
      this.render()
    }
  }

  onCanvasMouseUp() {
    if (this.dragState) {
      setTimeout(() => { this.dragState = null }, 50)
    }
  }

  onKeyDown(event) {
    if (!this.selectedId) return
    const map = { "1": "ok", "2": "surface", "3": "deep", "4": "perforation" }
    if (map[event.key]) {
      this.setStatus(map[event.key])
    } else if (event.key === "Delete" || event.key === "Backspace") {
      this.deleteSelected()
    }
  }

  setStatusFromSelect(event) {
    this.setStatus(event.target.value)
  }

  setStatus(status) {
    const z = this.zones.find(zz => zz.id === this.selectedId)
    if (z) { z.status = status; this.persist(); this.render() }
  }

  updateLabel(event) {
    const z = this.zones.find(zz => zz.id === this.selectedId)
    if (z) { z.label = event.target.value; this.persist() }
  }

  updateNote(event) {
    const z = this.zones.find(zz => zz.id === this.selectedId)
    if (z) { z.note = event.target.value; this.persist() }
  }

  deleteSelected() {
    this.zones = this.zones.filter(z => z.id !== this.selectedId)
    this.selectedId = null
    this.persist()
    this.render()
  }

  selectZone(event) {
    this.selectedId = event.currentTarget.dataset.zoneId
    this.render()
  }

  persist() {
    this.stateInputTarget.value = JSON.stringify(this.zones)
    this.scoreOutputTarget.textContent = this.computeScore()
  }

  computeScore() {
    const severity = { ok: 0, surface: 5, deep: 12, perforation: 25 }
    const penalty = this.zones.reduce((acc, z) => acc + (severity[z.status] || 0), 0)
    return Math.max(0, 100 - penalty)
  }

  render() {
    // Clear dots
    this.canvasTarget.querySelectorAll(".rust-dot").forEach(el => el.remove())
    this.zones.forEach(z => {
      const dot = document.createElement("button")
      dot.type = "button"
      dot.className = `rust-dot absolute w-3.5 h-3.5 -translate-x-1/2 -translate-y-1/2 rust-dot-${z.status} ${z.id === this.selectedId ? "ring-2 ring-accent-red ring-offset-2 ring-offset-bg-primary" : ""}`
      dot.style.left = `${z.x}%`
      dot.style.top = `${z.y}%`
      dot.dataset.zoneId = z.id
      dot.dataset.action = "mousedown->rust-map-editor#onDotMouseDown click->rust-map-editor#selectZone"
      dot.setAttribute("aria-label", `Zone ${z.label || z.status}`)
      this.canvasTarget.appendChild(dot)
    })
    this.renderSummary()
  }

  renderSummary() {
    const selected = this.zones.find(z => z.id === this.selectedId)
    if (!this.hasSummaryTarget) return
    if (!selected) {
      this.summaryTarget.innerHTML = `<p class="font-body italic text-text-muted text-[14px]">Cliquez sur la silhouette pour ajouter une zone.</p>`
      return
    }
    this.summaryTarget.innerHTML = `
      <p class="label-small text-accent-red mb-4">Zone sélectionnée</p>
      <div class="space-y-4">
        <div>
          <label class="label-small block mb-2">Libellé</label>
          <input type="text" value="${selected.label || ""}" class="input-vera" placeholder="Plancher arrière droit" data-action="input->rust-map-editor#updateLabel" />
        </div>
        <div>
          <label class="label-small block mb-2">Sévérité</label>
          <select class="input-vera" data-action="change->rust-map-editor#setStatusFromSelect">
            <option value="ok" ${selected.status === "ok" ? "selected" : ""}>Sain</option>
            <option value="surface" ${selected.status === "surface" ? "selected" : ""}>Oxydation surface</option>
            <option value="deep" ${selected.status === "deep" ? "selected" : ""}>Corrosion profonde</option>
            <option value="perforation" ${selected.status === "perforation" ? "selected" : ""}>Perforation</option>
          </select>
        </div>
        <div>
          <label class="label-small block mb-2">Note (optionnel)</label>
          <textarea class="input-vera" rows="3" placeholder="Contexte, traitement prévu…" data-action="input->rust-map-editor#updateNote">${selected.note || ""}</textarea>
        </div>
        <button type="button" class="btn-vera-secondary !border-accent-red !text-accent-red" data-action="click->rust-map-editor#deleteSelected">Supprimer la zone</button>
      </div>
    `
  }
}
```

Register in `index.js` :
```javascript
import RustMapEditorController from "./rust_map_editor_controller"
application.register("rust-map-editor", RustMapEditorController)
```

- [ ] **Step 7.5 — Vue step 3 Rust Map**

```erb
<%# app/views/listing_wizards/_step_02_rust_map.html.erb %>
<%# Locals: listing %>
<% draft = listing.draft_data.with_indifferent_access %>
<% rm_data = draft[:rust_map] || {} %>
<% variant = rm_data[:silhouette_variant] || "sedan" %>
<% existing_zones = rm_data[:zones] || [] %>

<div class="max-w-[1100px]" tabindex="0" data-controller="rust-map-editor" data-rust-map-editor-zones-value="<%= existing_zones.to_json %>" data-action="keydown->rust-map-editor#onKeyDown">
  <div class="mb-10">
    <h2 class="font-display text-[32px] playfair-italic text-text-primary">Étape 03 — Rust Map</h2>
    <p class="font-body italic text-[15px] text-text-muted mt-2">Notre signature. Cliquez sur la silhouette pour placer des zones et indiquer leur état. Ce geste prend deux minutes. Il en vaut la peine.</p>
  </div>

  <%= form_with url: save_step_listing_wizard_path(listing),
        method: :patch,
        data: { turbo_frame: "wizard_step" },
        html: { id: "wizard-form-step-2", class: "space-y-8", novalidate: true } do |f| %>
    <%= f.hidden_field :step, value: 2 %>
    <%= hidden_field_tag "listing[draft_data][rust_map][zones]", existing_zones.to_json, data: { rust_map_editor_target: "stateInput" } %>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
      <div class="lg:col-span-2 space-y-6">
        <div class="flex items-center justify-between">
          <div>
            <p class="label-small mb-1">Silhouette</p>
            <select name="listing[draft_data][rust_map][silhouette_variant]" class="input-vera">
              <% RustMap::VALID_VARIANTS.each do |opt| %>
                <option value="<%= opt %>" <%= 'selected' if opt == variant %>><%= opt.capitalize %></option>
              <% end %>
            </select>
          </div>
          <div class="text-right">
            <p class="label-micro">Score transparence</p>
            <p class="font-mono text-[44px] text-accent-red" data-rust-map-editor-target="scoreOutput">100</p>
          </div>
        </div>

        <div class="relative border border-line bg-bg-secondary aspect-[5/2] select-none cursor-crosshair"
             data-rust-map-editor-target="canvas"
             data-action="click->rust-map-editor#onCanvasClick mousemove->rust-map-editor#onCanvasMouseMove mouseup->rust-map-editor#onCanvasMouseUp mouseleave->rust-map-editor#onCanvasMouseUp">
          <div class="absolute inset-0 flex items-center justify-center text-text-muted">
            <div class="w-[90%] h-[85%]"><%= silhouette_svg(variant) %></div>
          </div>
        </div>

        <div class="flex items-center gap-6 text-[10px] font-ui uppercase tracking-[0.2em] text-text-muted">
          <span class="flex items-center gap-2"><span class="w-2 h-2 rust-dot-ok"></span>Sain</span>
          <span class="flex items-center gap-2"><span class="w-2 h-2 rust-dot-surface"></span>Surface</span>
          <span class="flex items-center gap-2"><span class="w-2 h-2 rust-dot-deep"></span>Profonde</span>
          <span class="flex items-center gap-2"><span class="w-2 h-2 rust-dot-perforation"></span>Perforation</span>
        </div>
        <p class="font-body italic text-[13px] text-text-muted">Raccourcis clavier : <kbd class="font-mono">1</kbd> sain, <kbd class="font-mono">2</kbd> surface, <kbd class="font-mono">3</kbd> profonde, <kbd class="font-mono">4</kbd> perforation, <kbd class="font-mono">Suppr</kbd> supprime la zone sélectionnée.</p>
      </div>

      <aside class="lg:col-span-1 card-vera p-6" data-rust-map-editor-target="summary">
        <p class="font-body italic text-text-muted text-[14px]">Cliquez sur la silhouette pour ajouter une zone.</p>
      </aside>
    </div>

    <%= render "listing_wizards/nav",
          listing: listing,
          current_step: 3,
          is_last: false,
          can_go_back: true %>
  <% end %>
</div>
```

- [ ] **Step 7.6 — Controller : persister le RustMap au save_step de l'étape 2**

Dans `ListingWizardsController#save_step` après le `@listing.update!(...)`, ajoutez :
```ruby
    if step_index == 2
      persist_rust_map!
    end
```

Et dans la private section :
```ruby
  def persist_rust_map!
    draft_rm = @listing.draft_data.dig("rust_map") || {}
    rm = @listing.rust_map || @listing.build_rust_map
    rm.silhouette_variant = draft_rm["silhouette_variant"] || "sedan"
    rm.save!

    # Wipe & recreate zones from the JSON payload
    rm.zones.destroy_all
    parsed_zones = JSON.parse(draft_rm["zones"].to_s) rescue []
    parsed_zones.each_with_index do |z, idx|
      rm.zones.create!(
        x_pct: z["x"].to_f,
        y_pct: z["y"].to_f,
        status: z["status"] || "ok",
        label: z["label"],
        note: z["note"],
        position: idx
      )
    end
    rm.recompute_score!
  end
```

- [ ] **Step 7.7 — Copier vers container, rebuild JS, smoke test**

```bash
docker cp app/assets/images/silhouettes vera-trade-web:/rails/app/assets/images/
docker cp app/views/listing_wizards/_step_02_rust_map.html.erb vera-trade-web:/rails/app/views/listing_wizards/_step_02_rust_map.html.erb
docker cp app/javascript/controllers/rust_map_editor_controller.js vera-trade-web:/rails/app/javascript/controllers/rust_map_editor_controller.js
docker cp app/javascript/controllers/index.js vera-trade-web:/rails/app/javascript/controllers/index.js
docker cp app/helpers/listings_helper.rb vera-trade-web:/rails/app/helpers/listings_helper.rb
docker cp app/controllers/listing_wizards_controller.rb vera-trade-web:/rails/app/controllers/listing_wizards_controller.rb
docker exec vera-trade-web npx yarn build
```

- [ ] **Step 7.8 — Commit Task 7**

```bash
git add app/assets/images/silhouettes app/views/listing_wizards/_step_02_rust_map.html.erb app/javascript/controllers/rust_map_editor_controller.js app/javascript/controllers/index.js app/helpers/listings_helper.rb app/controllers/listing_wizards_controller.rb
git commit -m "feat(wizard): M8 — step 03 Rust Map éditeur SVG Stimulus + persistence RustZones"
```

---

## Task 8 — Step 4 Mécanique

**Files :**
- Create : `app/views/listing_wizards/_step_03_mechanics.html.erb`

- [ ] **Step 8.1 — Vue step 4**

```erb
<%# app/views/listing_wizards/_step_03_mechanics.html.erb %>
<%# Locals: listing %>
<% draft = listing.draft_data.with_indifferent_access %>
<% m = draft[:mechanics] || {} %>
<% os = draft[:originality] || {} %>

<div class="max-w-[900px]">
  <div class="mb-10">
    <h2 class="font-display text-[32px] playfair-italic text-text-primary">Étape 04 — Mécanique</h2>
    <p class="font-body italic text-[15px] text-text-muted mt-2">Originalité, finitions et état. Un collectionneur préférera toujours la vérité à l'enjolivement.</p>
  </div>

  <%= form_with url: save_step_listing_wizard_path(listing),
        method: :patch,
        data: { turbo_frame: "wizard_step" },
        html: { id: "wizard-form-step-3", class: "space-y-10", novalidate: true } do |f| %>
    <%= f.hidden_field :step, value: 3 %>

    <div>
      <p class="label-small text-accent-red mb-6">Originalité</p>
      <div class="space-y-6">
        <label class="flex items-center gap-3 cursor-pointer group">
          <input type="hidden" name="listing[draft_data][originality][matching_numbers]" value="0" />
          <input type="checkbox" name="listing[draft_data][originality][matching_numbers]" value="1" <%= 'checked' if os[:matching_numbers].to_s == '1' %> class="peer sr-only" />
          <span class="w-4 h-4 border border-line-strong flex items-center justify-center peer-checked:bg-accent-red peer-checked:border-accent-red">
            <svg class="w-3 h-3 text-text-primary opacity-0 peer-checked:opacity-100" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="3"><path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7"/></svg>
          </span>
          <span class="font-ui text-[11px] uppercase tracking-[0.15em] text-text-secondary group-hover:text-text-primary">
            Numéros matching (moteur / châssis / boîte)
          </span>
        </label>

        <label class="flex items-center gap-3 cursor-pointer group">
          <input type="hidden" name="listing[draft_data][originality][original_interior]" value="0" />
          <input type="checkbox" name="listing[draft_data][originality][original_interior]" value="1" <%= 'checked' if os[:original_interior].to_s == '1' %> class="peer sr-only" />
          <span class="w-4 h-4 border border-line-strong flex items-center justify-center peer-checked:bg-accent-red peer-checked:border-accent-red">
            <svg class="w-3 h-3 text-text-primary opacity-0 peer-checked:opacity-100" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="3"><path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7"/></svg>
          </span>
          <span class="font-ui text-[11px] uppercase tracking-[0.15em] text-text-secondary group-hover:text-text-primary">
            Intérieur d'origine
          </span>
        </label>

        <div>
          <label class="label-small block mb-3" for="paint_pct">Peinture d'origine (%)</label>
          <input id="paint_pct" type="range" min="0" max="100" step="5" name="listing[draft_data][originality][original_paint_pct]" value="<%= os[:original_paint_pct] || 100 %>" class="w-full accent-accent-red" />
          <p class="font-mono text-[11px] text-text-muted mt-2"><span id="paint_pct_out"><%= os[:original_paint_pct] || 100 %></span>% d'origine</p>
        </div>
      </div>
    </div>

    <div>
      <p class="label-small text-accent-red mb-6">Motorisation</p>
      <div class="grid grid-cols-1 sm:grid-cols-2 gap-6">
        <div>
          <label class="label-small block mb-3" for="engine_type">Motorisation</label>
          <input id="engine_type" name="listing[draft_data][mechanics][engine_type]" value="<%= m[:engine_type] %>" class="input-vera" placeholder="1.6 16V 160ch" />
        </div>
        <div>
          <label class="label-small block mb-3" for="transmission">Boîte</label>
          <select id="transmission" name="listing[draft_data][mechanics][transmission]" class="input-vera">
            <% %w[Manuelle Automatique Séquentielle DCT].each do |opt| %>
              <option value="<%= opt %>" <%= 'selected' if m[:transmission] == opt %>><%= opt %></option>
            <% end %>
          </select>
        </div>
        <div class="sm:col-span-2">
          <label class="label-small block mb-3" for="recent_works">Travaux récents</label>
          <textarea id="recent_works" name="listing[draft_data][mechanics][recent_works]" rows="4" class="input-vera" placeholder="Révision complète 2025 — 1200€, pneus neufs Michelin…"><%= m[:recent_works] %></textarea>
        </div>
      </div>
    </div>

    <%= render "listing_wizards/nav",
          listing: listing,
          current_step: 4,
          is_last: false,
          can_go_back: true %>
  <% end %>
</div>
```

- [ ] **Step 8.2 — Controller : persister l'OriginalityScore à step 3**

Dans `ListingWizardsController#save_step` :
```ruby
    if step_index == 3
      persist_originality_score!
    end
```

Private :
```ruby
  def persist_originality_score!
    draft = @listing.draft_data.dig("originality") || {}
    os = @listing.originality_score || @listing.build_originality_score
    os.matching_numbers = draft["matching_numbers"] == "1"
    os.original_interior = draft["original_interior"] == "1"
    os.original_paint_pct = draft["original_paint_pct"].to_i
    os.overall_score = compute_overall_originality(os)
    os.save!
  end

  def compute_overall_originality(os)
    score = 0
    score += 40 if os.matching_numbers
    score += 20 if os.original_interior
    score += (os.original_paint_pct.to_i * 0.4).round
    [score, 100].min
  end
```

- [ ] **Step 8.3 — Commit**

```bash
docker cp app/views/listing_wizards/_step_03_mechanics.html.erb vera-trade-web:/rails/app/views/listing_wizards/_step_03_mechanics.html.erb
docker cp app/controllers/listing_wizards_controller.rb vera-trade-web:/rails/app/controllers/listing_wizards_controller.rb
git add app/views/listing_wizards/_step_03_mechanics.html.erb app/controllers/listing_wizards_controller.rb
git commit -m "feat(wizard): M8 — step 04 Mécanique (originality score + motorisation)"
```

---

## Task 9 — Step 5 Historique (timeline dynamique)

**Files :**
- Create : `app/views/listing_wizards/_step_04_history.html.erb`
- Create : `app/javascript/controllers/provenance_timeline_controller.js`

- [ ] **Step 9.1 — Stimulus controller timeline**

```javascript
// app/javascript/controllers/provenance_timeline_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["list", "template"]

  add() {
    const idx = this.listTarget.children.length
    const html = this.templateTarget.innerHTML.replaceAll("INDEX", idx)
    this.listTarget.insertAdjacentHTML("beforeend", html)
  }

  remove(event) {
    event.currentTarget.closest("[data-provenance-row]").remove()
  }
}
```

Register in `index.js` :
```javascript
import ProvenanceTimelineController from "./provenance_timeline_controller"
application.register("provenance-timeline", ProvenanceTimelineController)
```

- [ ] **Step 9.2 — Vue step 5**

```erb
<%# app/views/listing_wizards/_step_04_history.html.erb %>
<%# Locals: listing %>
<% draft = listing.draft_data.with_indifferent_access %>
<% events = draft[:provenance_events] || [] %>

<div class="max-w-[900px]" data-controller="provenance-timeline">
  <div class="mb-10">
    <h2 class="font-display text-[32px] playfair-italic text-text-primary">Étape 05 — Historique</h2>
    <p class="font-body italic text-[15px] text-text-muted mt-2">Une bonne voiture a une histoire, et une histoire a des dates. Ajoutez les événements marquants du châssis.</p>
  </div>

  <%= form_with url: save_step_listing_wizard_path(listing),
        method: :patch,
        data: { turbo_frame: "wizard_step" },
        html: { id: "wizard-form-step-4", class: "space-y-8", novalidate: true } do |f| %>
    <%= f.hidden_field :step, value: 4 %>

    <ol class="space-y-4" data-provenance-timeline-target="list">
      <% events.each_with_index do |e, i| %>
        <li data-provenance-row class="card-vera p-5 grid grid-cols-12 gap-3 items-end">
          <div class="col-span-2"><label class="label-small block mb-2">Année</label><input type="number" name="listing[draft_data][provenance_events][][event_year]" value="<%= e[:event_year] %>" class="input-vera input-mono" /></div>
          <div class="col-span-3"><label class="label-small block mb-2">Type</label>
            <select name="listing[draft_data][provenance_events][][event_type]" class="input-vera">
              <% %w[purchase service restoration race award exhibition registration].each do |t| %>
                <option value="<%= t %>" <%= 'selected' if e[:event_type] == t %>><%= t.capitalize %></option>
              <% end %>
            </select>
          </div>
          <div class="col-span-6"><label class="label-small block mb-2">Libellé</label><input name="listing[draft_data][provenance_events][][label]" value="<%= e[:label] %>" class="input-vera" placeholder="Livraison neuve Citroën Lyon" /></div>
          <div class="col-span-1"><button type="button" class="btn-vera-secondary !px-3 !py-2 !text-[18px]" data-action="click->provenance-timeline#remove" aria-label="Supprimer">×</button></div>
          <div class="col-span-12"><label class="label-small block mb-2">Description (optionnel)</label><textarea name="listing[draft_data][provenance_events][][description]" rows="2" class="input-vera"><%= e[:description] %></textarea></div>
        </li>
      <% end %>
    </ol>

    <template data-provenance-timeline-target="template">
      <li data-provenance-row class="card-vera p-5 grid grid-cols-12 gap-3 items-end">
        <div class="col-span-2"><label class="label-small block mb-2">Année</label><input type="number" name="listing[draft_data][provenance_events][][event_year]" class="input-vera input-mono" /></div>
        <div class="col-span-3"><label class="label-small block mb-2">Type</label>
          <select name="listing[draft_data][provenance_events][][event_type]" class="input-vera">
            <option value="service">Service</option><option value="purchase">Achat</option><option value="restoration">Restauration</option><option value="race">Course</option><option value="award">Récompense</option><option value="exhibition">Exposition</option><option value="registration">Immatriculation</option>
          </select>
        </div>
        <div class="col-span-6"><label class="label-small block mb-2">Libellé</label><input name="listing[draft_data][provenance_events][][label]" class="input-vera" /></div>
        <div class="col-span-1"><button type="button" class="btn-vera-secondary !px-3 !py-2 !text-[18px]" data-action="click->provenance-timeline#remove">×</button></div>
        <div class="col-span-12"><label class="label-small block mb-2">Description (optionnel)</label><textarea name="listing[draft_data][provenance_events][][description]" rows="2" class="input-vera"></textarea></div>
      </li>
    </template>

    <button type="button" data-action="click->provenance-timeline#add" class="btn-vera-secondary">+ Ajouter un événement</button>

    <%= render "listing_wizards/nav",
          listing: listing,
          current_step: 5,
          is_last: false,
          can_go_back: true %>
  <% end %>
</div>
```

- [ ] **Step 9.3 — Controller : persister les events à step 4**

Dans `save_step` :
```ruby
    if step_index == 4
      persist_provenance_events!
    end
```

Private :
```ruby
  def persist_provenance_events!
    events = @listing.draft_data.dig("provenance_events") || []
    @listing.provenance_events.destroy_all
    events.each_with_index do |e, idx|
      next if e["label"].blank? || e["event_year"].blank?
      @listing.provenance_events.create!(
        event_year: e["event_year"].to_i,
        event_type: e["event_type"].presence || "service",
        label: e["label"],
        description: e["description"],
        position: idx
      )
    end
  end
```

- [ ] **Step 9.4 — Commit**

```bash
docker cp app/views/listing_wizards/_step_04_history.html.erb vera-trade-web:/rails/app/views/listing_wizards/_step_04_history.html.erb
docker cp app/javascript/controllers/provenance_timeline_controller.js vera-trade-web:/rails/app/javascript/controllers/provenance_timeline_controller.js
docker cp app/javascript/controllers/index.js vera-trade-web:/rails/app/javascript/controllers/index.js
docker cp app/controllers/listing_wizards_controller.rb vera-trade-web:/rails/app/controllers/listing_wizards_controller.rb
docker exec vera-trade-web npx yarn build
git add app/views/listing_wizards/_step_04_history.html.erb app/javascript/controllers/provenance_timeline_controller.js app/javascript/controllers/index.js app/controllers/listing_wizards_controller.rb
git commit -m "feat(wizard): M8 — step 05 Historique timeline provenance dynamique"
```

---

## Task 10 — Step 6 Documents

**Files :**
- Create : `app/views/listing_wizards/_step_05_documents.html.erb`

- [ ] **Step 10.1 — Vue step 6**

```erb
<%# app/views/listing_wizards/_step_05_documents.html.erb %>
<%# Locals: listing %>
<% draft = listing.draft_data.with_indifferent_access %>
<% d = draft[:documents] || {} %>

<div class="max-w-[900px]">
  <div class="mb-10">
    <h2 class="font-display text-[32px] playfair-italic text-text-primary">Étape 06 — Documents</h2>
    <p class="font-body italic text-[15px] text-text-muted mt-2">Dernières pièces administratives. Le contrôle technique et les factures vous serviront de bouclier contre les litiges.</p>
  </div>

  <%= form_with url: save_step_listing_wizard_path(listing),
        method: :patch,
        data: { turbo_frame: "wizard_step" },
        html: { id: "wizard-form-step-5", class: "space-y-8", novalidate: true } do |f| %>
    <%= f.hidden_field :step, value: 5 %>

    <div class="grid grid-cols-1 sm:grid-cols-2 gap-6">
      <div>
        <label class="label-small block mb-3">Date du contrôle technique</label>
        <input type="date" name="listing[draft_data][documents][ct_date]" value="<%= d[:ct_date] %>" class="input-vera input-mono" />
      </div>
      <div>
        <label class="label-small block mb-3">Date d'expiration CT</label>
        <input type="date" name="listing[draft_data][documents][ct_expiry]" value="<%= d[:ct_expiry] %>" class="input-vera input-mono" />
      </div>
      <div class="sm:col-span-2">
        <label class="label-small block mb-3">Carnet d'entretien</label>
        <select name="listing[draft_data][documents][service_book]" class="input-vera">
          <% [["Complet", "complete"], ["Partiel", "partial"], ["Absent", "none"]].each do |label, val| %>
            <option value="<%= val %>" <%= 'selected' if d[:service_book] == val %>><%= label %></option>
          <% end %>
        </select>
      </div>
      <div class="sm:col-span-2">
        <label class="label-small block mb-3">Notes sur les documents (optionnel)</label>
        <textarea name="listing[draft_data][documents][notes]" rows="4" class="input-vera" placeholder="Carte grise au nom du vendeur, factures depuis 2015, etc."><%= d[:notes] %></textarea>
      </div>
    </div>

    <%= render "listing_wizards/nav",
          listing: listing,
          current_step: 6,
          is_last: false,
          can_go_back: true %>
  <% end %>
</div>
```

- [ ] **Step 10.2 — Commit**

```bash
docker cp app/views/listing_wizards/_step_05_documents.html.erb vera-trade-web:/rails/app/views/listing_wizards/_step_05_documents.html.erb
git add app/views/listing_wizards/_step_05_documents.html.erb
git commit -m "feat(wizard): M8 — step 06 Documents (contrôle technique + carnet + notes)"
```

---

## Task 11 — Step 7 Revue & Publication

**Files :**
- Create : `app/views/listing_wizards/_step_06_review.html.erb`

- [ ] **Step 11.1 — Vue step 7 review**

```erb
<%# app/views/listing_wizards/_step_06_review.html.erb %>
<%# Locals: listing %>
<% draft = listing.draft_data.with_indifferent_access %>
<% v = draft[:vehicle] || {} %>
<% os = listing.originality_score %>
<% rm = listing.rust_map %>

<div class="max-w-[1000px]">
  <div class="mb-10">
    <h2 class="font-display text-[32px] playfair-italic text-text-primary">Étape 07 — Revue et publication</h2>
    <p class="font-body italic text-[15px] text-text-muted mt-2">Un dernier regard avant que votre annonce ne parte dans le monde.</p>
  </div>

  <div class="card-vera p-8 mb-8">
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
      <div>
        <p class="eyebrow mb-3">Véhicule</p>
        <h3 class="font-display text-[28px] playfair-italic text-text-primary mb-4"><%= v[:make] %> <%= v[:model] %></h3>
        <dl class="space-y-2">
          <div class="flex justify-between font-mono text-[12px]"><dt class="text-text-muted">Année</dt><dd class="text-text-primary"><%= v[:year] %></dd></div>
          <div class="flex justify-between font-mono text-[12px]"><dt class="text-text-muted">Kilométrage</dt><dd class="text-text-primary"><%= v[:kilometers] %> km</dd></div>
          <div class="flex justify-between font-mono text-[12px]"><dt class="text-text-muted">Prix</dt><dd class="text-text-primary"><%= v[:price] %> €</dd></div>
          <div class="flex justify-between font-mono text-[12px]"><dt class="text-text-muted">Localisation</dt><dd class="text-text-primary"><%= v[:location] %></dd></div>
        </dl>
      </div>
      <div class="grid grid-cols-2 gap-6">
        <div>
          <p class="label-micro mb-2">Photos</p>
          <p class="font-mono text-[32px] text-text-primary"><%= listing.photos.count %></p>
        </div>
        <div>
          <p class="label-micro mb-2">Provenance</p>
          <p class="font-mono text-[32px] text-text-primary"><%= listing.provenance_events.count %></p>
        </div>
        <div>
          <p class="label-micro mb-2">Score Rust Map</p>
          <p class="font-mono text-[32px] text-accent-red"><%= rm&.transparency_score || "—" %></p>
        </div>
        <div>
          <p class="label-micro mb-2">Originalité</p>
          <p class="font-mono text-[32px] text-accent-red"><%= os&.overall_score || "—" %></p>
        </div>
      </div>
    </div>
  </div>

  <% unless listing.publishable? %>
    <div class="border-l-2 border-l-accent-red bg-bg-secondary p-5 mb-8">
      <p class="label-small text-accent-red mb-2">Publication bloquée</p>
      <ul class="space-y-1 font-body text-[14px] text-text-secondary">
        <% if listing.vehicle.blank? %><li>— Véhicule manquant</li><% end %>
        <% if listing.photos.none? %><li>— Aucune photo</li><% end %>
        <% if listing.rust_map.blank? %><li>— Rust Map non initialisée</li><% end %>
      </ul>
    </div>
  <% end %>

  <%= render "listing_wizards/nav",
        listing: listing,
        current_step: 7,
        is_last: true,
        can_go_back: true %>
</div>
```

- [ ] **Step 11.2 — Commit**

```bash
docker cp app/views/listing_wizards/_step_06_review.html.erb vera-trade-web:/rails/app/views/listing_wizards/_step_06_review.html.erb
git add app/views/listing_wizards/_step_06_review.html.erb
git commit -m "feat(wizard): M8 — step 07 Revue & publication (récap + CTA publier)"
```

---

## Task 12 — Integration test end-to-end

**Files :**
- Create : `test/integration/listing_wizard_flow_test.rb`

- [ ] **Step 12.1 — Test integration complet**

```ruby
# test/integration/listing_wizard_flow_test.rb
require "test_helper"

class ListingWizardFlowTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:user_one)
    post user_session_path, params: { user: { email: @user.email, password: "password" } }
    # NOTE : adapter si la fixture n'a pas ce password
  end

  test "full happy path: new → step1..7 → publish" do
    get new_listing_wizard_path
    assert_response :redirect
    listing = Listing.order(created_at: :desc).first
    assert listing.draft?

    # Step 1: Vehicle
    patch save_step_listing_wizard_path(listing), params: {
      step: 0,
      listing: { draft_data: { vehicle: { make: "Citroën", model: "BX GTi 16V", year: 1989, kilometers: 142500, price: 18500, location: "Lyon (69)" } } }
    }, as: :turbo_stream
    assert_equal 1, listing.reload.wizard_step
    assert_equal "Citroën", listing.draft_data.dig("vehicle", "make")

    # Step 2: Photos (skip real upload in integration, just advance)
    patch save_step_listing_wizard_path(listing), params: { step: 1, listing: { draft_data: {} } }, as: :turbo_stream

    # Step 3: Rust map
    patch save_step_listing_wizard_path(listing), params: {
      step: 2,
      listing: { draft_data: { rust_map: { silhouette_variant: "sedan", zones: "[{\"x\":42.5,\"y\":68.0,\"status\":\"surface\",\"label\":\"Plancher\",\"note\":\"\"}]" } } }
    }, as: :turbo_stream
    listing.reload
    assert listing.rust_map.present?
    assert_equal 1, listing.rust_map.zones.count
    assert_equal 95, listing.rust_map.transparency_score # 100 - 5 surface

    # Step 4: Mechanics / Originality
    patch save_step_listing_wizard_path(listing), params: {
      step: 3,
      listing: { draft_data: { originality: { matching_numbers: "1", original_interior: "1", original_paint_pct: 85 }, mechanics: { engine_type: "1.6 16V", transmission: "Manuelle", recent_works: "Révision 2025" } } }
    }, as: :turbo_stream
    listing.reload
    assert listing.originality_score.matching_numbers
    assert_equal 85, listing.originality_score.original_paint_pct

    # Step 5: Provenance
    patch save_step_listing_wizard_path(listing), params: {
      step: 4,
      listing: { draft_data: { provenance_events: [
        { event_year: 1989, event_type: "purchase", label: "Livraison neuve", description: "Concessionnaire Lyon" }
      ] } }
    }, as: :turbo_stream
    assert_equal 1, listing.reload.provenance_events.count

    # Step 6: Documents
    patch save_step_listing_wizard_path(listing), params: {
      step: 5,
      listing: { draft_data: { documents: { ct_date: "2025-06-01", ct_expiry: "2027-06-01", service_book: "complete" } } }
    }, as: :turbo_stream

    # Step 7 : needs photos + rust_map to publish — force photo attach
    listing.photos.attach(io: StringIO.new("fake"), filename: "test.jpg", content_type: "image/jpeg")

    patch publish_listing_wizard_path(listing)
    listing.reload
    assert_equal "active", listing.status
    assert_not_nil listing.published_at
  end
end
```

- [ ] **Step 12.2 — Run integration test**

```bash
docker exec vera-trade-web bin/rails test test/integration/listing_wizard_flow_test.rb 2>&1 | tail -20
```

Expected : `1 runs, N assertions, 0 failures, 0 errors`. Si le Devise sign_in fixture ne passe pas, adapter avec `sign_in` helper ou passer par `post user_session_path` avec un mdp connu de fixture.

- [ ] **Step 12.3 — Commit**

```bash
git add test/integration/listing_wizard_flow_test.rb
git commit -m "test(wizard): M8 — integration end-to-end happy path wizard → publish"
```

---

## Task 13 — Seed d'exemple + show update (affichage Rust Map)

**Files :**
- Modify : `db/seeds.rb`
- Modify : `app/views/listings/show.html.erb` (remplacer le stub Rust Map M5 par des vraies données)

- [ ] **Step 13.1 — Ajouter un listing d'exemple complet au seed**

Append to `db/seeds.rb` :
```ruby
# M8 — Seed example listing complet avec wizard data
if Rails.env.development? || Rails.env.production?
  example_user = User.find_by(email: "admin@veratrade.fr")
  if example_user
    seed_listing = example_user.listings.find_or_create_by!(title: "Citroën BX GTi 16V 1989") do |l|
      l.description = "Modèle exemplaire, second main, matching numbers, historique complet."
      l.status = "active"
      l.wizard_step = 6
      l.published_at = Time.current
      l.vehicle = Vehicle.create!(
        make: "Citroën", model: "BX GTi 16V", year: 1989, price: 18500,
        kilometers: 142500, location: "Lyon (69)", fuel_type: "Essence", transmission: "Manuelle"
      )
    end

    rm = seed_listing.rust_map || seed_listing.create_rust_map!(silhouette_variant: "sedan")
    rm.zones.destroy_all
    [
      { x_pct: 42.5, y_pct: 68.0, status: "surface", label: "Plancher arrière droit" },
      { x_pct: 55.1, y_pct: 71.2, status: "ok",      label: "Longeron droit" },
      { x_pct: 68.4, y_pct: 72.9, status: "deep",    label: "Bas de caisse arrière" }
    ].each_with_index { |z, i| rm.zones.create!(z.merge(position: i)) }
    rm.recompute_score!

    (seed_listing.originality_score || seed_listing.build_originality_score).tap do |os|
      os.matching_numbers = true
      os.original_interior = true
      os.original_paint_pct = 85
      os.overall_score = 94
      os.save!
    end

    seed_listing.provenance_events.destroy_all
    [
      { event_year: 1989, event_type: "purchase",    label: "Livraison neuve Citroën Lyon" },
      { event_year: 2012, event_type: "restoration", label: "Restauration cosmétique + peinture ailes" },
      { event_year: 2025, event_type: "service",     label: "Révision complète + pneus neufs" }
    ].each_with_index { |e, i| seed_listing.provenance_events.create!(e.merge(position: i)) }
  end
end
```

- [ ] **Step 13.2 — Run seed**

```bash
docker exec vera-trade-web bin/rails db:seed 2>&1 | tail -20
```

- [ ] **Step 13.3 — Vérifier sur /listings**

```bash
curl -s -o /tmp/l.html http://127.0.0.1:8098/listings
grep -c 'BX GTi' /tmp/l.html
```

Expected : >= 1.

- [ ] **Step 13.4 — (Optionnel) Mettre à jour `app/views/listings/show.html.erb` pour afficher la vraie Rust Map**

Remplacer le stub inline de M5 par un rendu des `listing.rust_map.zones`. Hors scope de M8 initial si temps serré — à traiter en PR suivante.

- [ ] **Step 13.5 — Commit**

```bash
git add db/seeds.rb
git commit -m "chore(seed): M8 — example listing avec Rust Map + provenance + originality"
```

---

## Task 14 — Docker rebuild complet + smoke test final

- [ ] **Step 14.1 — Rebuild l'image**

```bash
docker compose build web 2>&1 | tail -10
```

- [ ] **Step 14.2 — Recréer le container**

```bash
docker compose up -d --force-recreate web
docker ps --format '{{.Names}}\t{{.Status}}' | grep vera
```

- [ ] **Step 14.3 — Smoke test chaque étape**

```bash
# Login
rm -f /tmp/cookies.txt
CSRF=$(curl -s -c /tmp/cookies.txt http://127.0.0.1:8098/users/sign_in | grep -oE 'name="authenticity_token" value="[^"]+"' | head -1 | sed 's/.*value="\([^"]*\)".*/\1/')
curl -s -b /tmp/cookies.txt -c /tmp/cookies.txt -o /dev/null -X POST http://127.0.0.1:8098/users/sign_in \
  --data-urlencode "authenticity_token=$CSRF" \
  --data-urlencode "user[email]=admin@veratrade.fr" \
  --data-urlencode "user[password]=Azerty123!" \
  --data-urlencode "commit=Se connecter"

# Wizard start
curl -s -b /tmp/cookies.txt -L -o /tmp/wz.html -w "wizard new: %{http_code} size=%{size_download}B\n" http://127.0.0.1:8098/listing_wizards/new
echo "  marqueurs M8: $(grep -c 'Étapes de publication\|Étape 01\|data-controller="listing-wizard"' /tmp/wz.html)"
```

- [ ] **Step 14.4 — Regression test M1-M9**

```bash
for url in "/" "/listings" "/users/sign_in" "/users/sign_up" "/users/password/new"; do
  curl -s -o /tmp/r.html -w "$url %{http_code} size=%{size_download}B\n" http://127.0.0.1:8098$url
done
curl -s -b /tmp/cookies.txt -o /tmp/r.html -w "/dashboard %{http_code} size=%{size_download}B\n" http://127.0.0.1:8098/dashboard
```

Expected : tous 200, tailles comparables à M9.

---

## Task 15 — PR finale

- [ ] **Step 15.1 — Push**

```bash
git push -u origin feat/listing-wizard-stitch
```

- [ ] **Step 15.2 — Valider que les tests passent une dernière fois**

```bash
docker exec vera-trade-web bin/rails test 2>&1 | tail -10
```

- [ ] **Step 15.3 — Créer la PR via gh cli**

```bash
gh pr create --base redesign/stitch-cinematic-archivist --head feat/listing-wizard-stitch \
  --title "M8 — Wizard dépôt d'annonce (Cinematic Archivist)" \
  --body "$(cat <<'EOF'
## Summary

Wizard 7 étapes pour le dépôt d'annonce éditorial, aligné sur la refonte Stitch.

- 5 nouveaux modèles : `RustMap`, `RustZone`, `ProvenanceEvent`, `OriginalityScore`, `ListingQuestion`/`Answer`
- Listing gagne `draft_data` jsonb + `wizard_step` + `published_at` + `views_count` + `slug`
- Status Listing gagne la valeur `draft` (initial du wizard, transition → `active` au publish)
- Nouveau controller `ListingWizardsController` avec `new/edit/save_step/publish`
- Routes `resources :listing_wizards` avec member `publish` et `save_step`
- Turbo Frames par étape pour auto-save sans rechargement de page
- Stimulus controllers : `listing-wizard`, `photo-dropzone`, `rust-map-editor`, `provenance-timeline`
- Rust Map éditeur SVG cliquable : place dots, drag, 4 statuts clavier (1/2/3/4), suppression, recompute du score transparence
- 9 SVG silhouettes véhicule (sedan/coupe/wagon/hatch/convertible/suv/motorcycle/van/pickup) — variantes à raffiner en PR suivante
- Tests : modèles (RustMap, RustZone, Provenance, Originality, Question), controller requests, integration happy path

## Test plan

- [ ] `bin/rails test` → suite verte
- [ ] `/listing_wizards/new` → redirige vers edit step 01, Turbo Frame rendu
- [ ] Step 01 Véhicule : sauvegarde draft_data, avance à step 02
- [ ] Step 02 Photos : dropzone Stimulus, preview thumbs, attach Active Storage
- [ ] Step 03 Rust Map : click sur silhouette ajoute dot, drag bouge, clavier change statut, score recomputé
- [ ] Step 04 Mécanique : matching numbers + paint % slider, crée OriginalityScore
- [ ] Step 05 Historique : ajouter/supprimer événements dynamiques, persiste ProvenanceEvents
- [ ] Step 06 Documents : dates CT, carnet, notes
- [ ] Step 07 Revue : récap complet, CTA publish, bloque si non publishable
- [ ] Regression M1-M9 : home / listings / show / dashboard / devise auth restent 200

## TODO hors scope (PR suivantes)

- [ ] Raffiner les 9 silhouettes SVG (pour l'instant toutes identiques à la sedan)
- [ ] Mettre à jour `listings#show` pour afficher la vraie Rust Map (stub M5 à remplacer)
- [ ] i18n Devise FR (devise-i18n gem)
- [ ] Cache Q&A publique sur show (ListingQuestion + ListingAnswer)
- [ ] Système d'approbation modération des annonces publiées
EOF
)"
```

- [ ] **Step 15.4 — Afficher l'URL de la PR**

La commande ci-dessus affiche l'URL. Confirmer qu'elle est accessible et que tous les checks CI sont lancés.

---

## Self-review checklist

- [ ] Toutes les migrations ont bien `reversible` (ici : seulement create_table et add_column, 100% reversibles)
- [ ] Tous les modèles ont un test couvrant au moins associations + validations critiques
- [ ] Chaque step du wizard a sa vue, son partial, et persiste proprement via save_step
- [ ] Le Rust Map editor a : click-to-add, drag, status keyboard, score recompute, persistence JSON
- [ ] Le Turbo Frame tag `wizard_step` est bien le même dans edit.html.erb et save_step.turbo_stream.erb
- [ ] Les noms de méthodes (`persist_rust_map!`, `persist_originality_score!`, `persist_provenance_events!`) sont cohérents entre tasks
- [ ] Aucun `TODO` placeholder sans code — sauf les Step 7.2 (silhouettes duplicatées temporairement) et 13.4 (update show en PR suivante), tous deux explicitement scope-out
- [ ] Les design system classes utilisées existent toutes dans `application.tailwind.css` (vérifié en M1)
- [ ] Les commits sont atomiques et testables indépendamment
- [ ] La PR finale liste clairement les TODO hors scope

---

**Exécution :** inline depuis cette session via `superpowers:executing-plans`, avec commit après chaque Task et smoke-test à chaque étape critique.
