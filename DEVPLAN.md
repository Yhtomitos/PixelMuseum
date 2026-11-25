# Pixel Museum Development Plan

## Product goal

Build a 2D online-multiplayer museum game in which each player designs a museum, creates pixel artwork, exhibits it, and participates in a player-driven exchange economy.

The current project contains only a minimal Godot scene, [node_2d.tscn](node_2d.tscn), so the first milestone should establish a small, testable vertical slice before expanding content or persistence.

## Decision log

Architecture, sequencing, and product tradeoffs will be proposed and discussed in the conversation as implementation decisions arise. This section should contain only decisions that have been agreed on, along with the reasoning needed to preserve context.

### Agreed: creative-first prototype

The first playable slice will validate museum creation, pixel-art creation, artwork publishing, and local visitor mode before implementing online multiplayer. This prioritizes the game's distinctive creative loop and keeps the first feedback cycle small.

### Agreed: modular room expansion

The first museum will begin with one room, while the layout and save model will support unlocking and connecting additional rooms later. This establishes the long-term museum-growth loop without requiring a complete multi-room editor in the first slice.

### Agreed: selectable artwork canvas sizes

Artwork canvases will use square power-of-two dimensions: 16x16, 32x32, 64x64, 128x128, and 256x256. The selected size is fixed for an artwork after creation, so rendering, storage, publishing, and future exchange can rely on a stable format.

### Agreed: curated palette with unlockable animated paints

The editor will use a shared curated palette. Some palette entries will be unlocked through in-game currency purchases, with ownership validated by the game services rather than trusted from the client. Certain paints may include animated visual effects, so an artwork must store both its palette references and the approved effect metadata used to render them.

### Agreed: predefined animated effects

Animated paints will use fixed, approved effect definitions associated with palette entries. The first effects should be simple visual treatments such as shimmer, pulse, glow, sparkle, or color shift; players will not author arbitrary animation code or frame data in the initial editor.

### Agreed: essential pixel editor tools

The first editor will include pencil, eraser, fill, eyedropper, palette selection, zoom, undo, and redo. Shape tools, layers, transforms, and other advanced creation workflows will remain out of scope for the initial creative slice.

### Agreed: side-view museum interaction

Museums will use a side-view presentation. Players will navigate horizontally through connected rooms, with artwork and furnishings arranged on wall and floor display zones. Room expansion should preserve a readable left-to-right gallery flow rather than assuming a top-down floor plan.

### Agreed: platformer movement

Players will use side-view platformer movement with horizontal walking, gravity, jumping, collision, and vertical traversal where the room layout supports it. The movement should remain readable and accessible, with museum displays placed so artwork can be viewed without requiring difficult platforming.

### Agreed: room-bounded follow camera

The camera will follow the player while remaining bounded to the active room or gallery section. Room transitions will update the camera bounds so the player can explore without the view drifting into unrelated spaces.

### Agreed: predefined display zones

Artwork and furniture will be placed into authored display zones such as wall slots, shelves, pedestals, and floor positions. The first slice will prioritize clear placement validation and readable gallery composition over unrestricted object positioning.

### Agreed: interact-to-inspect artwork view

Visitors will explicitly interact with a displayed artwork to open a focused inspection panel. The panel will provide pixel zoom and artwork metadata, and will later host social actions such as liking without interrupting normal platformer movement.

### Agreed: draft-to-publish artwork workflow

Players will edit private artwork drafts and explicitly publish a stable artwork version for display. Editing after publication creates a new draft; the displayed version remains unchanged until the player publishes the replacement and it passes the applicable validation.

### Agreed: artwork metadata and creator tracking

Published artwork will include a title, linked creator identity, creator-written description, canvas dimensions, palette references, animated-effect information, publication date, and version details. Creators will have an artwork-tracking view for their own pieces, including drafts, published versions, display locations, and later social or transaction history.

### Agreed: public creator portfolios

Creators will have public portfolio pages containing their published artwork catalog. Drafts and private management data remain creator-only, while visitors can follow creator links from inspected artwork to browse published work and visit the associated museum.

### Agreed: likes and creator follows

The initial social layer will support one active like per visitor per artwork and following creators. Likes provide visible appreciation and can drive creator rewards; follows connect visitors to a creator's public portfolio and future published-work notifications without introducing comments in the first slice.

### Agreed: mutual like rewards and achievement milestones

Eligible likes will reward both the artwork creator and the visiting player with additional achievement progress and associated currency rewards. Rewards must be idempotent and protected by per-artwork limits, cooldowns, daily caps, relationship checks, and abuse detection so reciprocal or automated liking cannot dominate the economy.

### Agreed: capped visit rewards and visit milestones

Visitors will earn capped time-based rewards for validated active time spent in other museums, alongside achievement milestones for visiting museums and reaching meaningful exploration totals. The system will use session validation, idle detection, per-day limits, diminishing returns where appropriate, and idempotent reward records.

### Agreed: one shared in-game currency

The game will use one shared in-game currency for palette unlocks, room expansion, furniture, and player artwork purchases. Achievement points or milestone state may be tracked separately for progression, but they will not act as a second spendable currency.

### Agreed: fixed-price listings and direct trades

Players will be able to sell published artwork through fixed-price listings or exchange artwork and currency through direct trade offers. Both paths must validate ownership and balances server-side and complete atomically, with explicit cancellation, confirmation, and transaction history states.

### Agreed: global marketplace with museum links

Fixed-price listings will be discoverable through a global marketplace and reachable from the corresponding artwork inspection view in a museum. This preserves broad market discovery while retaining the relationship between an artwork, its creator, and its exhibition location.

### Agreed: timed listings with optional relisting

Fixed-price listings will have a defined active period. When a listing expires, the artwork returns to the seller's available inventory and the seller may relist it. Expiration, cancellation, purchase, and relisting must remain visible in transaction history and be safe to retry.

### Agreed: seller-set prices with suggested ranges

Sellers will choose the fixed price for a listing. The marketplace may show a suggested range derived from comparable sales and artwork attributes, but it will not force the seller into a price band. Pricing guidance must be clearly labeled as advisory and should not expose private player data.

### Agreed: no marketplace fee in the initial economy

The initial fixed-price marketplace will not charge listing or transaction fees. Buyers will pay the listed amount and sellers will receive that amount in full, allowing early economy testing to focus on earning, spending, pricing, and ownership behavior before adding a currency sink.

### Agreed: unique original artwork

Each published artwork will represent one unique transferable item with a single owner. Its provenance, displayed location, listing state, and transaction history will follow that item through ownership changes; the system will not create automatic duplicates when artwork is sold or traded.

### Agreed: listed artwork remains displayed until sold

An artwork may remain visible and inspectable in its museum while its fixed-price listing is active. The display will communicate that the work is for sale, and the artwork will be removed from the seller's display or transferred according to the completed transaction only after the server confirms the sale.

### Agreed: purchase from inspection or marketplace

Buyers may initiate a fixed-price purchase from the artwork inspection panel or the global marketplace. Both entry points will call the same server-authoritative atomic purchase operation and display the same price, seller, listing state, and confirmation requirements.

### Agreed: purchased artwork enters buyer inventory

After a successful purchase, the unique artwork transfers to the buyer's inventory and is removed from the seller's display. The buyer must manually place it into one of their valid display zones; the purchase flow will not force an automatic placement.

### Agreed: two-step mutual trade confirmation

Direct trades will require both players to review and independently confirm the complete offer. Any change to the offered artwork or other trade terms will reset both confirmations, and the server will revalidate ownership at completion.

### Agreed: artwork-only direct trades

Direct trades will exchange one unique artwork for another and will not include currency. Currency-based value exchange will use fixed-price marketplace listings instead, keeping each trade flow easy to understand and validate.

### Agreed: chronological following feed

Following a creator will add their newly published artwork to a chronological feed. The first version will focus on transparent recent-publication ordering rather than opaque ranking, while retaining creator and artwork links back to public portfolios and museums.

### Agreed: artwork and portfolio updates in feed

The following feed will contain newly published artwork and public portfolio updates, ordered by publication time. It will not include private drafts, private management events, direct-trade details, or other sensitive account activity.

### Agreed: full creator posts

Creators may publish standalone posts alongside artwork publications and portfolio updates. Posts will appear in the chronological following feed and on the creator's public profile, subject to the game's content, reporting, and moderation rules.

### Agreed: automated moderation pre-checks and player reports

Public creator posts and artwork descriptions will pass basic automated safety checks before publication. Players can report visible content, with flagged items routed to moderator review and supported by takedown, blocking, and appeal workflows.

### Agreed: posts link to governed in-game content

Creator posts will be text-based and may link to published artwork, public portfolios, museums, and collections. The initial system will not support arbitrary image uploads or external media attachments.

### Agreed: short creator posts

Creator posts will be limited to 280 characters in the initial social system. This keeps the chronological feed scannable and limits the moderation surface while still allowing short exhibit notes, announcements, and artwork context.

### Agreed: editable posts with revision history

Creators may edit published posts, while prior versions remain available to moderation and audit systems. Edits will re-enter applicable automated checks, and moderation actions will apply to the current content and its retained history.

### Agreed: permanent post deletion

When a creator deletes a post or moderators remove flagged content, the post and its revision history will be permanently removed from public and internal systems. The implementation should retain only the minimum non-content audit event required for abuse prevention, transaction integrity, or legal compliance.

### Agreed: separate mute and block controls

Muting will hide a player's posts and notifications without ending normal social access. Blocking will additionally prevent direct interaction, follows, trades, and museum visits between the two players, subject to moderation and safety overrides.

### Agreed: web-first platform target

The first playable target will run in the browser with keyboard and mouse controls. The implementation should prioritize browser-compatible rendering, responsive UI scaling, efficient pixel-canvas interaction, and persistence that works across browser sessions.

### Agreed: hybrid local-first persistence

The creative prototype will autosave drafts and museum layouts locally in the browser, while keeping data structures compatible with optional account synchronization when online services are introduced. Local and server versions will require explicit conflict handling rather than silent overwrites.

### Agreed: IndexedDB browser storage

The web prototype will use IndexedDB for local museum layouts, artwork drafts, metadata, revisions, palette entitlements, and local achievement state. A storage abstraction will keep the rest of the game independent from browser database details and prepare the data for future account synchronization.

### Agreed: versioned local-data migrations

IndexedDB records will carry schema/version information and upgrade through explicit migrations rather than being silently discarded. Migration paths will be tested against representative saved museums, artwork drafts, revisions, and player progression data.

### Agreed: GDScript-first implementation

The first playable slice will use GDScript for gameplay, UI, museum construction, pixel editing, local persistence integration, and domain models. The existing .NET configuration will remain unused unless a later decision identifies a clear need for C# interoperability.

### Agreed: separate feature scenes

The project will use dedicated scenes for boot, museum gameplay, pixel editing, artwork inspection, marketplace, portfolio, and menus. Shared data and transition rules will be kept outside individual feature scenes so switching modes does not silently lose drafts, selection state, or pending persistence work.

### Agreed: autoloaded application state and scene router

Autoloaded application services will manage current player data, museum session state, artwork drafts, persistence coordination, and feature-scene transitions. Feature scenes will request state and actions through these services rather than owning long-lived game data or directly coordinating unrelated scenes.

### Agreed: typed domain classes with JSON serialization

Museum, room, display-zone, artwork, draft, palette, effect, inventory, and achievement data will use typed GDScript domain classes. Each class will define explicit serialization and deserialization boundaries so IndexedDB persistence, migrations, and future server APIs do not depend on scene internals.

### Agreed: packed palette-index pixel storage

Artwork canvases will store compact palette-index bytes rather than raw color values or nested JSON pixel arrays. Canvas dimensions, palette version, indexed pixel data, and approved effect references will be serialized separately so editing and rendering remain deterministic through 256x256 layouts.

### Agreed: versioned immutable palette references

Palette definitions will be versioned. Published artwork will retain the palette version and entry definitions needed to preserve its appearance, while newer palette versions may add or retire entries without remapping existing artwork.

### Agreed: permanent palette entitlements

Currency purchases unlock palette entries permanently for the player's account. The entitlement is separate from individual artwork ownership and remains available for future drafts, subject to palette-version compatibility and any approved moderation restrictions.

### Agreed: effects bundled with palette entries

Animated visual effects will be part of specific curated palette entries rather than separate player-configurable assets. Unlocking an animated paint grants access to its fixed color-and-effect behavior, with the effect definition preserved through palette versioning.

### Agreed: per-pixel animated effects

Each pixel using an animated palette entry will render that entry's fixed effect independently. Artwork data will store palette indexes and effect references, while the renderer will derive the visual animation without storing arbitrary frame data.

### Agreed: shared deterministic animation clock

Animated paints will derive their timing from a shared deterministic clock, with optional stable offsets based on artwork or pixel position. The clock will be controllable by application state so previews, scene transitions, pause behavior, and future multiplayer clients remain consistent.

### Agreed: reduced-motion accessibility control

Players will be able to reduce or disable animated paint effects without changing saved artwork data. Reduced-motion rendering will preserve the palette entry's base appearance and remain consistent across editor previews, museum displays, inspection panels, and marketplace previews.

### Agreed: adaptive animated-effect quality

Animated rendering will support full, reduced, and disabled quality tiers, with automatic fallback when browser performance drops. Quality changes affect rendering only and never change the serialized artwork, palette references, or effect ownership state.

### Agreed: responsive desktop-first web layout

The browser UI will adapt to resizable desktop windows while maintaining a minimum usable layout for the museum, editor, inspection panel, and social views. Mobile touch controls are outside the first playable slice.

### Agreed: authored starting room with player-built geometry

The first playable museum will begin with one compact authored room template that establishes safe boundaries, a starting platform layout, display zones, and an exit point. Players may then modify platforms, walls, and display zones as part of museum construction, while exact room dimensions remain an implementation-tuning decision.

### Agreed: player-built room geometry

Museum construction will include player placement of platforms, walls, and display zones rather than limiting players to decoration only. Geometry edits must remain within validated room boundaries and preserve a traversable route to displayed artwork and room exits.

### Agreed: grid-snapped construction

Player-built platforms, walls, and display zones will snap to a fixed construction grid. The grid will be shared by collision, placement validation, save data, and future multiplayer synchronization so room geometry remains deterministic.

### Agreed: dedicated construction mode

Players will switch from platformer/visitor mode into a separate construction mode for structural geometry and display placement. Construction mode will expose editing controls and validation feedback without allowing normal movement or accidental gameplay interactions to modify the museum.

### Agreed: preview, validate, then confirm construction

Construction edits will be applied to a temporary preview layout first. The game will highlight invalid placements and require a successful validation pass plus player confirmation before replacing the active museum layout. Canceling the edit session will leave the active layout unchanged.

### Deferred decision: construction validation scope

The choice between core structural validation, structural-plus-presentation rules, and bounds-only validation is intentionally deferred for a later planning session.

### Agreed: frame-driven painting placement and gallery picker

Players will click any artwork frame, whether empty or occupied, to choose or replace its painting from a gallery-style picker rather than placing only the latest published piece. The picker will support alphabetical-title and latest-publication sorting plus canvas-size filters for 16x16, 32x32, 64x64, 128x128, and 256x256 artwork. Tag filters are deferred until the tag system is designed.

Displayed artwork is unavailable in the gallery picker while assigned to any frame, ensuring one painting cannot be displayed in multiple museum locations at once.

## Milestone 0.5: local creative prototype

Development will begin with a local-only vertical slice containing:

- A base side-view museum room using the authored starting template.
- Platformer movement and a room-bounded follow camera.
- Dedicated construction mode with grid-snapped display-zone placement.
- A pixel editor with selectable 16x16, 32x32, 64x64, 128x128, and 256x256 canvases.
- Essential tools: pencil, eraser, fill, eyedropper, palette selection, zoom, undo, and redo.
- Curated palette entries, including permanent local unlock state and predefined animated paint effects.
- Draft-to-publish artwork workflow with title, creator identity, description, technical details, and local creator tracking.
- Placement of published unique artwork into museum display zones.
- Interact-to-inspect artwork view.
- Local IndexedDB persistence through the planned storage abstraction and versioned migrations.
- No connection services, accounts, multiplayer presence, marketplace transactions, likes, follows, or server-backed economy in this milestone.

Milestone 0.5 verification:

- A player can open the base museum and move through it.
- A player can create a draft artwork at each supported canvas size.
- A player can edit, undo, redo, save, and reload artwork locally.
- A player can publish an artwork and place it in a valid display zone.
- A player can inspect the displayed artwork and see its metadata.
- Reloading the browser preserves the museum layout, artwork draft, published artwork, and local entitlements.
- Connection services remain isolated behind interfaces and are not required to run the prototype.

Implementation status: milestone 0.5 code scaffolded on the `milestone-0.5` branch. Runtime and browser-export validation remain pending until Godot is available in the development environment.

### Agreed: continuously maintained run documentation

The project README must be updated alongside development whenever the run workflow, controls, requirements, export process, or validation status changes. The README is the current entry point for running and evaluating the prototype.

## Product rules to establish early

- Every artwork has an immutable owner ID, stable artwork ID, version, creation timestamp, and moderation status.
- Artwork pixels reference curated palette entries; animated paints reference approved effect definitions rather than arbitrary client code.
- Animated effect definitions are selected by palette entry and rendered deterministically on every client.
- Palette unlocks are account entitlements purchased through server-side currency transactions and cannot be transferred by editing artwork data.
- Artwork edits create a new version or require an explicit re-publish action; an exhibited version must remain reproducible.
- Currency changes are server-side ledger transactions, never client-calculated balances.
- Likes should have clear anti-abuse rules: one active like per player per artwork, cooldowns, rate limits, and suspicious-activity review.
- Visits should reward meaningful presence without encouraging idle farming; use server-tracked session time, daily caps, and diminishing returns.
- Trading and selling must be atomic: either both inventories/currency balances change, or neither changes.
- Museum permissions should distinguish owner, visitor, collaborator, and blocked player.
- Add reporting, mute/block, takedown, and appeal flows before public sharing.

## Milestones

### 0. Foundation and project structure

- Replace the placeholder root scene with a boot scene and clear client-side folder structure.
- Define typed data models for Museum, Artwork, ArtworkVersion, Inventory, Listing, Trade, Like, and VisitSession.
- Define a versioned network/API contract and error format.
- Add configuration for local development, test server, and production server endpoints.
- Add formatting, static analysis, and automated test commands appropriate to the selected Godot version.

Tests:

- Project opens from a clean checkout.
- Data models serialize and deserialize deterministically.
- Invalid network messages are rejected without crashing the client.

### 1. Creative vertical slice

- Implement a tile/grid-based museum room with walls, floor, entrances, and a bounded build area.
- Implement placement, rotation, deletion, undo, redo, and save/load for museum furniture and artwork frames.
- Implement a pixel editor with a fixed canvas, palette, pencil, eraser, fill, eyedropper, undo/redo, and export to a canonical pixel format.
- Create an artwork draft, name it, publish it, and place the published version in the museum.
- Add a basic visitor mode separate from edit mode.

Tests:

- Placement cannot overlap blocked tiles or leave the owned build area.
- Undo/redo restores exact museum and canvas state.
- Published artwork round-trips without pixel changes.
- A visitor cannot modify another player's museum locally or remotely.

### 2. Online museum browsing

- Add player identity and session authentication suitable for a prototype.
- Add server-authoritative museum snapshots and incremental edit commands.
- Add a museum directory, search, player profile, and join/leave flow.
- Show other players in museums with basic movement and presence.
- Handle reconnects, stale snapshots, timeouts, and incompatible client versions.

Tests and smoke checks:

- Two clients can join the same museum and see the same published layout.
- Simultaneous edits resolve according to an explicit server rule.
- Disconnect/reconnect restores the server state.
- Unauthorized edit, duplicate publish, and forged owner actions are rejected.

### 3. Social loop and rewards

- Add likes with visible counts and per-player like state.
- Track visit sessions and award currency from validated time spent in other museums.
- Award currency when eligible displayed artwork receives likes, with caps and an auditable reason code.
- Add notifications for likes, visits, sales, and trade events.
- Add rate limits, cooldowns, daily caps, and abuse telemetry.

Tests:

- Rewards are idempotent when requests are retried.
- Duplicate likes do not duplicate rewards.
- Session time cannot be increased by changing the client clock or reconnecting repeatedly.
- Ledger totals reconcile with inventory and reward events.

### 4. Player economy

- Add artwork listings with fixed-price sale and cancellation.
- Add direct player-to-player trade with confirmation on both sides.
- Add transaction history and a player wallet/inventory screen.
- Make all purchase, trade, cancellation, and reward operations atomic and server-authoritative.
- Add economy telemetry: currency creation, sinks, velocity, price distribution, and fraud signals.

Tests:

- A listing cannot sell twice under concurrent purchase attempts.
- A trade cannot complete with insufficient funds or missing artwork.
- Retry-safe requests do not duplicate currency or artwork.
- Server restart preserves ledger and ownership state.

### 5. Persistence, moderation, and launch hardening

- Persist accounts, museum layouts, artwork versions, social actions, listings, trades, and ledger entries.
- Add backups, migrations, admin inspection, audit logs, and restore procedures.
- Add artwork reporting, content review status, takedown, blocking, muting, and appeal support.
- Add privacy controls for museum visibility and profile discoverability.
- Add load tests for museum browsing, presence, likes, and marketplace contention.
- Add crash reporting, metrics, rate-limit dashboards, and deployment rollback procedures.

## Suggested initial data model

- Player: identity, display name, created time, moderation state.
- Museum: owner, layout version, published snapshot, permissions, visibility.
- Artwork: owner, title, canonical pixel payload/hash, current version, moderation state.
- ArtworkVersion: artwork, pixel payload/hash, palette, dimensions, creator, timestamp.
- WalletLedgerEntry: player, signed amount, reason code, reference ID, timestamp, idempotency key.
- Listing: artwork version, seller, price, state, expiration, transaction reference.
- Trade: participants, offered assets, requested assets, confirmation states, final state.
- Like: player, artwork version, creation time, active state.
- VisitSession: visitor, museum, join/leave times, eligible duration, reward state.

## Immediate implementation sequence

1. Create a development branch from the current main state.
2. Build the local creative vertical slice without economy or networking.
3. Add automated tests around canonical pixel data and museum commands.
4. Add a small authoritative server that supports login, museum snapshots, and publish/visit flows.
5. Add likes and capped rewards only after the ledger and idempotency mechanisms exist.
6. Add marketplace and direct trading after persistence and concurrency tests pass.

## Definition of done for the first playable prototype

- A player can create a small museum, draw a pixel artwork, publish it, and display it.
- A second player can discover and visit that museum online.
- The visitor can like the artwork and receive a capped, server-validated reward.
- The owner can see the like and reward in a history view.
- Restarting the server does not lose museum, artwork, ownership, or ledger state.
- Automated tests cover placement, pixel round-tripping, authorization, idempotency, and reward caps.
