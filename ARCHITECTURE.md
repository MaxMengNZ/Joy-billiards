# 🏗️ System Architecture - Joy Billiards Tournament System

## 📐 Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         USER INTERFACE                          │
│                      (Vue 3 Components)                         │
├─────────────────────────────────────────────────────────────────┤
│  HomePage  │  Players  │  Tournaments  │  Tournament  │ Matches │
│            │   Page    │     Page      │   Detail     │  Page   │
└──────┬──────────────────────────────────────────────────────────┘
       │
       │ Vue Router (Navigation)
       │
┌──────▼──────────────────────────────────────────────────────────┐
│                      STATE MANAGEMENT                           │
│                          (Pinia)                                │
├─────────────────────────────────────────────────────────────────┤
│  playerStore  │  tournamentStore  │  matchStore                 │
│  - players[]  │  - tournaments[]  │  - matches[]                │
│  - CRUD ops   │  - CRUD ops       │  - CRUD ops                 │
└──────┬──────────────────────────────────────────────────────────┘
       │
       │ Supabase Client (API Layer)
       │
┌──────▼──────────────────────────────────────────────────────────┐
│                       SUPABASE BACKEND                          │
│                      (PostgreSQL + API)                         │
├─────────────────────────────────────────────────────────────────┤
│  players  │  tournaments  │  tournament_participants  │ matches │
│  Table    │  Table        │  Table                    │ Table   │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔄 Data Flow

### 1. User Action → Component → Store → Supabase

```
User clicks "Add Player"
    ↓
PlayersPage.vue (Component)
    ↓
playerStore.createPlayer() (Pinia Action)
    ↓
supabase.from('players').insert() (Supabase Client)
    ↓
PostgreSQL Database (Supabase)
    ↓
Success Response
    ↓
Store Updates State
    ↓
Component Re-renders
    ↓
User sees new player
```

### 2. Page Load → Fetch Data

```
User navigates to Players Page
    ↓
PlayersPage.vue mounted()
    ↓
playerStore.fetchPlayers() (Pinia Action)
    ↓
supabase.from('players').select() (Supabase Client)
    ↓
PostgreSQL Database Query
    ↓
Data Response
    ↓
Store: players[] = data
    ↓
Component displays list
```

---

## 🗂️ Component Structure

```
App.vue (Root Component)
├── Header
│   ├── Logo
│   └── Navigation (Vue Router Links)
├── Main (Router View)
│   ├── HomePage.vue
│   │   ├── Hero Section
│   │   ├── Stats Cards
│   │   └── Info Cards
│   ├── PlayersPage.vue
│   │   ├── Page Header
│   │   ├── Filter Section
│   │   ├── Players Table
│   │   └── Modal (Create/Edit)
│   ├── TournamentsPage.vue
│   │   ├── Page Header
│   │   ├── Status Tabs
│   │   ├── Tournament Grid
│   │   └── Modal (Create/Edit)
│   ├── TournamentDetailPage.vue
│   │   ├── Tournament Header
│   │   ├── Info Section
│   │   ├── Participants Section
│   │   ├── Matches Section
│   │   └── Modals (Add Participant, Schedule Match)
│   └── MatchesPage.vue
│       ├── Page Header
│       ├── Status Tabs
│       └── Matches Grid
└── Footer
    ├── Contact Info
    └── Connection Status
```

---

## 📦 Store Architecture

### playerStore.js

```javascript
State:
  - players: []
  - loading: boolean
  - error: string | null

Getters:
  - sortedPlayers: Players sorted by wins
  - getPlayerById(id): Find player
  - playersBySkillLevel(level): Filter by skill

Actions:
  - fetchPlayers(): GET all players
  - createPlayer(data): POST new player
  - updatePlayer(id, data): PATCH player
  - deletePlayer(id): DELETE player
```

### tournamentStore.js

```javascript
State:
  - tournaments: []
  - currentTournament: object | null
  - participants: []
  - loading: boolean
  - error: string | null

Getters:
  - upcomingTournaments: Filter by status
  - activeTournaments: Filter by status
  - completedTournaments: Filter by status

Actions:
  - fetchTournaments(): GET all tournaments
  - fetchTournamentById(id): GET single tournament
  - createTournament(data): POST tournament
  - updateTournament(id, data): PATCH tournament
  - deleteTournament(id): DELETE tournament
  - fetchParticipants(tournamentId): GET participants
  - addParticipant(tournamentId, playerId): POST participant
  - removeParticipant(tournamentId, playerId): DELETE participant
```

### matchStore.js

```javascript
State:
  - matches: []
  - loading: boolean
  - error: string | null

Getters:
  - scheduledMatches: Filter by status
  - inProgressMatches: Filter by status
  - completedMatches: Filter by status
  - matchesByTournament(id): Filter by tournament

Actions:
  - fetchMatches(): GET all matches
  - fetchMatchesByTournament(id): GET tournament matches
  - createMatch(data): POST match
  - updateMatch(id, data): PATCH match
  - deleteMatch(id): DELETE match
  - updatePlayerRecords(): Update win/loss stats
```

---

## 🗄️ Database Relationships

```
players (玩家表)
    ├── 1:N → tournament_participants (Many tournaments)
    ├── 1:N → matches (as player1)
    ├── 1:N → matches (as player2)
    └── 1:N → matches (as winner)

tournaments (比赛表)
    ├── 1:N → tournament_participants (Many players)
    └── 1:N → matches (Many matches)

tournament_participants (玩家参赛表)
    ├── N:1 → tournaments (Belongs to tournament)
    └── N:1 → players (Belongs to player)

matches (对战记录表)
    ├── N:1 → tournaments (Belongs to tournament)
    ├── N:1 → players (player1)
    ├── N:1 → players (player2)
    └── N:1 → players (winner)
```

### SQL Relationship Diagram

```sql
players
    ↓ (tournament_participants.player_id)
tournament_participants
    ↑ (tournament_participants.tournament_id)
tournaments
    ↓ (matches.tournament_id)
matches
    ↑ (matches.player1_id, player2_id, winner_id)
players
```

---

## 🎨 CSS Architecture

```
main.css (500+ lines)
├── CSS Variables
│   ├── Colors (primary, secondary, danger, etc.)
│   ├── Spacing (xs, sm, md, lg, xl, xxl)
│   ├── Typography (font sizes, family)
│   ├── Border Radius (sm, md, lg)
│   └── Shadows (sm, md, lg)
├── Base Styles
│   ├── Reset & Normalize
│   ├── Typography
│   └── Layout
├── Components
│   ├── Header & Footer
│   ├── Navigation
│   ├── Cards
│   ├── Buttons (CSS3 with gradients)
│   ├── Forms
│   ├── Tables
│   ├── Badges
│   ├── Alerts
│   └── Modals
├── Utilities
│   ├── Spacing (margin, padding)
│   ├── Text alignment
│   ├── Flexbox utilities
│   └── Grid utilities
└── Responsive Breakpoints
    ├── Desktop (1200px+)
    ├── Tablet (768px-1199px)
    └── Mobile (<768px)
```

---

## 🔐 Security Layers

```
User Request
    ↓
1. Frontend Validation (Vue component)
    ↓
2. Pinia Store (Business logic)
    ↓
3. Supabase Client (API layer)
    ↓
4. Row Level Security (Supabase)
    ↓
5. Database Constraints (PostgreSQL)
    ↓
Response
```

### Security Features

1. **Frontend Validation**
   - Required fields
   - Input sanitization
   - Type checking

2. **API Layer**
   - Environment variables
   - Secure connections (HTTPS)
   - CORS policies

3. **Database Layer**
   - Row Level Security (RLS)
   - Foreign key constraints
   - Check constraints
   - Unique constraints

---

## 📡 API Endpoints (Supabase)

### Players API

```
GET    /rest/v1/players                    # Fetch all players
GET    /rest/v1/players?id=eq.{id}        # Fetch single player
POST   /rest/v1/players                    # Create player
PATCH  /rest/v1/players?id=eq.{id}        # Update player
DELETE /rest/v1/players?id=eq.{id}        # Delete player
```

### Tournaments API

```
GET    /rest/v1/tournaments                       # Fetch all tournaments
GET    /rest/v1/tournaments?id=eq.{id}           # Fetch single tournament
POST   /rest/v1/tournaments                       # Create tournament
PATCH  /rest/v1/tournaments?id=eq.{id}           # Update tournament
DELETE /rest/v1/tournaments?id=eq.{id}           # Delete tournament
```

### Tournament Participants API

```
GET    /rest/v1/tournament_participants?tournament_id=eq.{id}  # Fetch participants
POST   /rest/v1/tournament_participants                        # Add participant
DELETE /rest/v1/tournament_participants?tournament_id=eq.{tid}&player_id=eq.{pid}  # Remove
```

### Matches API

```
GET    /rest/v1/matches                          # Fetch all matches
GET    /rest/v1/matches?tournament_id=eq.{id}   # Fetch tournament matches
POST   /rest/v1/matches                          # Create match
PATCH  /rest/v1/matches?id=eq.{id}              # Update match
DELETE /rest/v1/matches?id=eq.{id}              # Delete match
```

---

## 🚀 Build & Deploy Process

```
Development
    ├── npm run dev (Vite Dev Server)
    ├── Hot Module Replacement
    └── Source Maps

Production Build
    ├── npm run build
    ├── Tree Shaking
    ├── Minification
    ├── Code Splitting
    └── dist/ folder

Deployment
    ├── Option 1: Vercel
    │   ├── Git Push
    │   ├── Auto Build
    │   └── CDN Distribution
    ├── Option 2: Netlify
    │   ├── Git Push
    │   ├── Auto Build
    │   └── Edge Network
    └── Option 3: VPS
        ├── Build Locally
        ├── Upload dist/
        └── Nginx Serving
```

---

## 🔄 State Management Flow

### Pinia Store Pattern

```
Component
    ↓ Call Action
Store Action
    ↓ Set loading = true
Supabase API Call
    ↓ Async Request
Database Operation
    ↓ Response
Store Updates
    ├── State (data)
    ├── loading = false
    └── error = null
    ↓ Reactive Update
Component Re-renders
```

---

## 📊 Performance Optimizations

### Frontend
- ✅ Vue 3 Composition API (Better performance)
- ✅ Lazy loading routes (Code splitting)
- ✅ Computed properties (Cached calculations)
- ✅ CSS transitions (Hardware accelerated)
- ✅ Minimal dependencies (~200KB gzipped)

### Database
- ✅ Indexed columns (Fast queries)
- ✅ Foreign key constraints (Referential integrity)
- ✅ Connection pooling (Supabase)
- ✅ Prepared statements (Query optimization)

### Network
- ✅ Supabase CDN (Edge locations)
- ✅ Gzip compression (Smaller payloads)
- ✅ HTTP/2 (Multiplexing)
- ✅ Caching headers (Browser cache)

---

## 🧪 Testing Strategy

```
Unit Tests (Future)
    ├── Store Actions
    ├── Getters
    └── Utilities

Integration Tests (Future)
    ├── Component + Store
    ├── API Calls
    └── Form Submissions

E2E Tests (Future)
    ├── User Flows
    ├── CRUD Operations
    └── Navigation

Manual Testing (Current)
    ├── Browser Testing
    ├── Responsive Testing
    └── Database Verification
```

---

## 📈 Scalability Considerations

### Horizontal Scaling
- Frontend: Static assets on CDN (Vercel/Netlify)
- Backend: Supabase auto-scales
- Database: Connection pooling enabled

### Vertical Scaling
- Supabase: Upgrade plan for more resources
- Database: Add read replicas
- Caching: Implement Redis for frequent queries

### Future Enhancements
- WebSocket for real-time updates
- Service Workers for offline support
- Image optimization and lazy loading
- Virtual scrolling for large lists

---

## 🛠️ Development Workflow

```
1. Local Development
   ├── npm run dev
   ├── Edit code
   └── Hot reload

2. Testing
   ├── Manual testing
   ├── Browser DevTools
   └── Supabase Dashboard

3. Build
   ├── npm run build
   └── Verify dist/

4. Deployment
   ├── Git push
   └── Auto deploy (Vercel/Netlify)

5. Monitoring
   ├── Check logs
   ├── Monitor performance
   └── User feedback
```

---

## 📞 Maintenance & Support

### Regular Tasks
- **Daily**: Monitor error logs
- **Weekly**: Check performance metrics
- **Monthly**: Update dependencies
- **Quarterly**: Security audit

### Backup Strategy
- **Automatic**: Supabase daily backups
- **Manual**: Export database monthly
- **Testing**: Restore test quarterly

---

## ✅ Architecture Best Practices

- ✅ **Separation of Concerns**: Components, Stores, API
- ✅ **Single Source of Truth**: Pinia stores
- ✅ **Reactive Data Flow**: Vue reactivity system
- ✅ **Modular Design**: Reusable components
- ✅ **Error Handling**: Try-catch in all async operations
- ✅ **Loading States**: User feedback during operations
- ✅ **Responsive Design**: Mobile-first approach
- ✅ **Security First**: RLS, validation, sanitization
- ✅ **Documentation**: Comprehensive guides
- ✅ **Scalable Structure**: Easy to extend

---

**System Architecture Designed for Production** ✅

*Robust, Scalable, and Maintainable* 🏗️


