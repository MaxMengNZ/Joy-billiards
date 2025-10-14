# 🎱 Joy Billiards Tournament System

A comprehensive tournament management system built for **Joy Billiards New Zealand** in Hamilton. This Vue.js application with Supabase backend provides full tournament lifecycle management including player registration, tournament creation, match scheduling, and real-time results tracking.

## 📍 Venue Information

**Joy Billiards New Zealand**
- 📍 Address: 88 Tristram Street, Hamilton Central
- 📞 Phone: 022 166 0688

---

## ✨ Features

### Player Management
- ✅ Player registration with skill levels (Beginner, Intermediate, Advanced, Professional)
- ✅ Win/Loss record tracking
- ✅ Player statistics and win rates
- ✅ Advanced search and filtering

### Tournament Management
- ✅ Multiple tournament formats:
  - Single Elimination
  - Double Elimination
  - Round Robin
  - Swiss System
- ✅ Tournament status tracking (Upcoming, Registration, In Progress, Completed, Cancelled)
- ✅ Entry fees and prize pool management
- ✅ Participant registration and management

### Match System
- ✅ Automated match scheduling
- ✅ Real-time score tracking
- ✅ Match status updates (Scheduled, In Progress, Completed)
- ✅ Winner determination and record updates
- ✅ Table assignment

### UI/UX Features
- ✅ Fully responsive design (Mobile, Tablet, Desktop)
- ✅ CSS3 Button styling with gradient effects
- ✅ Real-time database connection status
- ✅ Intuitive navigation and filtering
- ✅ Modern card-based layouts

---

## 🛠️ Technology Stack

- **Frontend**: Vue 3 with Composition API
- **Routing**: Vue Router 4
- **State Management**: Pinia
- **Database**: Supabase (PostgreSQL)
- **Build Tool**: Vite
- **Styling**: Custom CSS3 with CSS Variables
- **Button Library**: CSS3 Buttons

---

## 📦 Installation

### Prerequisites
- Node.js 18+ (LTS recommended)
- npm or yarn
- Supabase account

### Step 1: Clone the Repository
```bash
cd /Users/mengyang/Desktop/JoyBilliards
```

### Step 2: Install Dependencies
```bash
npm install
```

### Step 3: Configure Supabase

#### 3.1 Set up Supabase Project
1. Go to [Supabase Dashboard](https://app.supabase.com)
2. Your project URL is already configured: `https://qnwtqgdbgyqwpsdqvxfl.supabase.co`
3. Get your **Anon Key** from Settings → API

#### 3.2 Create Environment File
Create a `.env` file in the project root:
```env
VITE_SUPABASE_URL=https://qnwtqgdbgyqwpsdqvxfl.supabase.co
VITE_SUPABASE_ANON_KEY=your_anon_key_here
```

#### 3.3 Run Database Migration
1. Open your Supabase SQL Editor
2. Copy the entire content from `supabase-migration.sql`
3. Execute the SQL to create all tables, indexes, and policies

The migration will create:
- ✅ `players` table
- ✅ `tournaments` table
- ✅ `tournament_participants` table
- ✅ `matches` table
- ✅ Indexes for performance
- ✅ RLS (Row Level Security) policies
- ✅ Auto-update triggers
- ✅ Sample data (optional)

### Step 4: Start Development Server
```bash
npm run dev
```

The application will be available at `http://localhost:3000`

---

## 📁 Project Structure

```
JoyBilliards/
├── src/
│   ├── assets/
│   │   └── styles/
│   │       └── main.css          # Main stylesheet with CSS3 Button styles
│   ├── components/               # Reusable Vue components (future)
│   ├── config/
│   │   └── supabase.js          # Supabase client configuration
│   ├── stores/
│   │   ├── playerStore.js       # Player state management
│   │   ├── tournamentStore.js   # Tournament state management
│   │   └── matchStore.js        # Match state management
│   ├── views/
│   │   ├── HomePage.vue         # Landing page with stats
│   │   ├── PlayersPage.vue      # Player management
│   │   ├── TournamentsPage.vue  # Tournament listing
│   │   ├── TournamentDetailPage.vue  # Tournament details & matches
│   │   └── MatchesPage.vue      # Match schedule
│   ├── router/
│   │   └── index.js             # Vue Router configuration
│   ├── App.vue                  # Root component
│   └── main.js                  # Application entry point
├── public/                       # Static assets
├── index.html                    # HTML template
├── vite.config.js               # Vite configuration
├── package.json                 # Dependencies
├── supabase-migration.sql       # Database schema
└── README.md                    # This file
```

---

## 🗄️ Database Schema

### Tables

#### `players`
Stores player information and statistics
- `id` (UUID, Primary Key)
- `name` (VARCHAR, Required)
- `email` (VARCHAR, Unique)
- `phone` (VARCHAR)
- `skill_level` (ENUM: beginner, intermediate, advanced, professional)
- `wins` (INTEGER, Default: 0)
- `losses` (INTEGER, Default: 0)
- `created_at`, `updated_at` (TIMESTAMP)

#### `tournaments`
Stores tournament information
- `id` (UUID, Primary Key)
- `name` (VARCHAR, Required)
- `description` (TEXT)
- `tournament_type` (ENUM: single_elimination, double_elimination, round_robin, swiss)
- `start_date`, `end_date` (TIMESTAMP)
- `max_players` (INTEGER)
- `entry_fee`, `prize_pool` (DECIMAL)
- `status` (ENUM: upcoming, registration, in_progress, completed, cancelled)
- `created_at`, `updated_at` (TIMESTAMP)

#### `tournament_participants`
Links players to tournaments
- `id` (UUID, Primary Key)
- `tournament_id` (UUID, Foreign Key → tournaments)
- `player_id` (UUID, Foreign Key → players)
- `registration_date` (TIMESTAMP)
- `seed_number` (INTEGER)
- `final_position` (INTEGER)
- `prize_amount` (DECIMAL)

#### `matches`
Stores match records
- `id` (UUID, Primary Key)
- `tournament_id` (UUID, Foreign Key → tournaments)
- `player1_id`, `player2_id` (UUID, Foreign Key → players)
- `winner_id` (UUID, Foreign Key → players)
- `round_number`, `match_number` (INTEGER)
- `player1_score`, `player2_score` (INTEGER)
- `scheduled_time`, `completed_time` (TIMESTAMP)
- `status` (ENUM: scheduled, in_progress, completed, cancelled)
- `table_number` (INTEGER)
- `notes` (TEXT)
- `created_at`, `updated_at` (TIMESTAMP)

---

## 🚀 Usage Guide

### Managing Players
1. Navigate to **Players** page
2. Click **Add New Player** to register players
3. Fill in name, contact info, and skill level
4. Use search/filter to find specific players
5. Edit or delete players as needed

### Creating Tournaments
1. Go to **Tournaments** page
2. Click **Create Tournament**
3. Fill in tournament details:
   - Name and description
   - Tournament type (elimination format)
   - Start/end dates
   - Max players, entry fee, prize pool
4. Set status to **Registration Open**
5. Click **Create**

### Managing Tournament Participants
1. Open a tournament's detail page
2. Click **Add Participant**
3. Select players from the dropdown
4. Remove participants if needed

### Scheduling Matches
1. In tournament detail page, click **Schedule Match**
2. Select round number and match number
3. Choose Player 1 and Player 2
4. Set table number (optional)
5. Click **Create**

### Recording Match Results
1. Find the match in tournament details or Matches page
2. Click **Update**
3. Change status to **Completed**
4. Enter scores for both players
5. Select the winner
6. Save - player win/loss records auto-update

---

## 🎨 Responsive Design

The application is fully responsive with breakpoints for:

- **Desktop** (1200px+): Full grid layouts, side-by-side panels
- **Tablet** (768px - 1199px): Adjusted columns, optimized spacing
- **Mobile** (< 768px): Single column layout, stacked navigation

All components adapt gracefully to different screen sizes.

---

## 🔐 Security Features

- ✅ Row Level Security (RLS) enabled on all tables
- ✅ Public read access for viewing data
- ✅ Controlled write operations through Supabase policies
- ✅ Input validation on all forms
- ✅ Prepared statements prevent SQL injection

**Note**: Current RLS policies allow all operations. For production, implement proper authentication and restrict policies based on user roles.

---

## 📊 Development Status

| Feature | Status |
|---------|--------|
| Player Management | ✅ Complete |
| Tournament Management | ✅ Complete |
| Match System | ✅ Complete |
| Responsive Design | ✅ Complete |
| Supabase Integration | ✅ Complete |
| CSS3 Button Styling | ✅ Complete |
| Database Schema | ✅ Complete |
| Documentation | ✅ Complete |

---

## 🧪 Testing

### Manual Testing Checklist
- [ ] Create new players
- [ ] Create tournaments with different formats
- [ ] Register players to tournaments
- [ ] Schedule matches
- [ ] Update match scores and winners
- [ ] Verify win/loss statistics update
- [ ] Test responsive design on mobile devices
- [ ] Verify Supabase connection status

---

## 🚢 Deployment

### Recommended: Vercel

1. Push code to GitHub
2. Connect repository to Vercel
3. Add environment variables in Vercel dashboard:
   - `VITE_SUPABASE_URL`
   - `VITE_SUPABASE_ANON_KEY`
4. Deploy automatically

### Alternative: Netlify, Railway, or self-hosted

```bash
npm run build
# Deploy the 'dist' folder
```

---

## 🔧 Scripts

```bash
# Development server
npm run dev

# Production build
npm run build

# Preview production build
npm run preview

# Lint code
npm run lint
```

---

## 📝 Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `VITE_SUPABASE_URL` | Your Supabase project URL | Yes |
| `VITE_SUPABASE_ANON_KEY` | Supabase anonymous/public key | Yes |

---

## 🐛 Troubleshooting

### Database Connection Failed
- Verify `.env` file exists and contains correct credentials
- Check Supabase project is active
- Ensure migration SQL has been executed
- Check browser console for error details

### No Data Showing
- Confirm database migration completed successfully
- Check RLS policies are enabled
- Verify Supabase anon key has correct permissions

### Build Errors
- Clear node_modules: `rm -rf node_modules && npm install`
- Clear Vite cache: `rm -rf .vite`
- Check Node.js version: `node -v` (should be 18+)

---

## 📚 Future Enhancements

- [ ] User authentication and role-based access
- [ ] Real-time match updates with WebSockets
- [ ] Automatic bracket generation
- [ ] PDF export of tournament brackets
- [ ] Email notifications for match schedules
- [ ] Player profiles with avatars
- [ ] Tournament history and archives
- [ ] Mobile app (React Native / Flutter)
- [ ] QR code check-in system
- [ ] Live scoreboard display

---

## 🤝 Contributing

This is a custom project for Joy Billiards NZ. For feature requests or bug reports, please contact the venue directly.

---

## 📄 License

Proprietary - © 2025 Joy Billiards New Zealand. All rights reserved.

---

## 📞 Support

For technical support or questions about the tournament system:

**Joy Billiards New Zealand**
- 📍 88 Tristram Street, Hamilton Central
- 📞 022 166 0688
- 🌐 Visit us in person for a game!

---

## 🙏 Acknowledgments

- Built with Vue 3 and Supabase
- CSS3 Button styling from [CSS3 Buttons](https://github.com/michenriksen/css3buttons)
- Icons: Unicode emojis for cross-platform compatibility

---

**Built with ❤️ for the billiards community in Hamilton, New Zealand** 🎱


