# Database Schema

> Database: Supabase PostgreSQL
> Source SQL: `C:\Users\Ritanjay\Desktop\RunApp\backend\schema.sql`
> The database is **shared** between the React Native RunApp and this Flutter app — no changes needed.

---

## Tables

### profiles

Primary user data. One row per user.

| Column | Type | Default | Notes |
|--------|------|---------|-------|
| `id` | uuid | — | Primary key. Matches Supabase Auth user ID. |
| `name` | text | — | Display name |
| `email` | text | — | Unique |
| `avatar` | text | `'🏃'` | Single emoji character |
| `level` | int | `1` | Current level |
| `xp` | int | `0` | XP within current level |
| `xp_to_next` | int | `1000` | XP threshold to next level |
| `streak` | int | `0` | Consecutive active days |
| `territory_percent` | float | `0.0` | % of total zones owned |
| `total_distance_km` | float | `0.0` | Lifetime total |
| `total_steps` | int | `0` | Lifetime total |
| `push_token` | text | null | Expo push token for notifications |
| `created_at` | timestamptz | `now()` | — |

---

### run_sessions

One row per completed run/walk activity.

| Column | Type | Default | Notes |
|--------|------|---------|-------|
| `id` | uuid | `gen_random_uuid()` | Primary key |
| `user_id` | uuid | — | FK → profiles(id) ON DELETE CASCADE |
| `activity_type` | text | — | CHECK: `running` or `walking` |
| `distance_km` | float | — | — |
| `duration_seconds` | int | — | — |
| `steps` | int | — | — |
| `calories` | int | — | — |
| `xp_earned` | int | — | — |
| `territory_captured` | int | `0` | Number of zones captured this session |
| `path_coordinates` | jsonb | `[]` | Array of `{ latitude, longitude }` objects |
| `badges_unlocked` | jsonb | `[]` | Array of badge ID strings |
| `created_at` | timestamptz | `now()` | — |

**Indexes:** `(user_id)`, `(created_at DESC)`

---

### territories

Pre-seeded Bengaluru zones. One row per capturable zone.

| Column | Type | Default | Notes |
|--------|------|---------|-------|
| `id` | uuid | `gen_random_uuid()` | Primary key |
| `name` | text | — | Zone name (e.g., "MG Road") |
| `owner_id` | uuid | null | FK → profiles(id) ON DELETE SET NULL |
| `owner_color` | text | `'#3498DB'` | Hex color of current owner |
| `coordinates` | jsonb | — | Array of `{ latitude, longitude }` forming the polygon |
| `center_lat` | float | — | Zone center (for bounding box queries) |
| `center_lng` | float | — | Zone center |
| `captured_at` | timestamptz | null | Last capture time |
| `created_at` | timestamptz | `now()` | — |

**Indexes:** `(center_lat, center_lng)`

**Pre-seeded rows (6 zones):**
| Name | Center |
|------|--------|
| MG Road | 12.9757, 77.6072 |
| Cubbon Park | 12.9763, 77.5929 |
| Brigade Road | 12.9712, 77.6087 |
| Indiranagar | 12.9719, 77.6412 |
| Koramangala | 12.9352, 77.6245 |
| UB City | 12.9710, 77.5952 |

---

### friendships

Friendship relationships between users.

| Column | Type | Default | Notes |
|--------|------|---------|-------|
| `id` | uuid | `gen_random_uuid()` | Primary key |
| `requester_id` | uuid | — | FK → profiles(id) |
| `addressee_id` | uuid | — | FK → profiles(id) |
| `status` | text | `'pending'` | CHECK: `pending`, `accepted`, `declined` |
| `created_at` | timestamptz | `now()` | — |

**Unique constraint:** `(requester_id, addressee_id)` — prevents duplicate requests.

---

### refresh_tokens

Tracks issued refresh tokens for token rotation.

| Column | Type | Default | Notes |
|--------|------|---------|-------|
| `id` | uuid | `gen_random_uuid()` | Primary key |
| `user_id` | uuid | — | FK → profiles(id) ON DELETE CASCADE |
| `token` | text | — | Unique. UUID v4 string. |
| `expires_at` | timestamptz | — | 30 days from issue |
| `revoked` | bool | `false` | Set true on logout or rotation |
| `created_at` | timestamptz | `now()` | — |

**Indexes:** `(token)` — for fast lookup on refresh.

---

### otp_codes

Temporary OTP codes for password reset.

| Column | Type | Default | Notes |
|--------|------|---------|-------|
| `id` | uuid | `gen_random_uuid()` | Primary key |
| `email` | text | — | Target email address |
| `code` | text | — | 6-digit string |
| `expires_at` | timestamptz | — | 10 minutes from creation |
| `used` | bool | `false` | Set true after successful verify |
| `created_at` | timestamptz | `now()` | — |

**Indexes:** `(email)` — for lookup by email.

---

### achievements

One row per badge earned by a user. `(user_id, badge_id)` is unique — no duplicate awards.

| Column | Type | Default | Notes |
|--------|------|---------|-------|
| `id` | uuid | `gen_random_uuid()` | Primary key |
| `user_id` | uuid | — | FK → profiles(id) ON DELETE CASCADE |
| `badge_id` | text | — | Canonical badge ID e.g. `run_5k`, `streak_7` |
| `earned_at` | timestamptz | `now()` | When the badge was awarded |

**Indexes:** `(user_id)`, unique `(user_id, badge_id)`

**Badge IDs:** `first_run`, `run_5k`, `run_10k`, `run_50k`, `morning_runner`, `speed_demon`, `first_capture`, `zone_lord`, `district_king`, `city_dominator`, `night_raider`, `comeback_king`, `first_friend`, `squad_up`, `social_butterfly`, `community_leader`, `rival`, `mentor`, `streak_3`, `streak_7`, `streak_30`, `streak_100`, `unstoppable`, `legend`

---

## Future Tables (Not Yet Created)

These features use mock data currently and will need tables when backend is implemented:

### challenges

Admin-created challenge definitions. Seeded via SQL.

| Column | Type | Default | Notes |
|--------|------|---------|-------|
| `id` | uuid | `gen_random_uuid()` | Primary key |
| `title` | text | — | Display name |
| `description` | text | null | Short description |
| `emoji` | text | `'🏃'` | Display emoji |
| `type` | text | — | CHECK: `distance`, `territory`, `streak`, `speed`, `leaderboard`, `social` |
| `goal_value` | float | `1` | Numeric target (e.g. 20 for 20 km) |
| `goal_unit` | text | `'km'` | Display unit (km, zones, days, run, rank) |
| `start_date` | timestamptz | — | When challenge becomes active |
| `end_date` | timestamptz | — | When challenge expires |
| `reward_xp` | int | `0` | XP awarded on completion |
| `created_at` | timestamptz | `now()` | — |

### challenge_participants

One row per user per challenge they have joined.

| Column | Type | Default | Notes |
|--------|------|---------|-------|
| `id` | uuid | `gen_random_uuid()` | Primary key |
| `challenge_id` | uuid | — | FK → challenges(id) ON DELETE CASCADE |
| `user_id` | uuid | — | FK → profiles(id) ON DELETE CASCADE |
| `progress` | float | `0` | Current progress toward `goal_value` |
| `completed` | bool | `false` | Set true when progress >= goal_value |
| `joined_at` | timestamptz | `now()` | — |

**Unique constraint:** `(challenge_id, user_id)`
**Indexes:** `(user_id)`, `(challenge_id)`

### notifications (planned)
```sql
CREATE TABLE notifications (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id uuid REFERENCES profiles(id) ON DELETE CASCADE,
  type text NOT NULL,  -- 'capture' | 'friend_request' | 'achievement' | 'challenge' | 'level_up'
  title text NOT NULL,
  body text,
  data jsonb,
  read bool DEFAULT false,
  created_at timestamptz DEFAULT now()
);
```

---

## Row Level Security (RLS)

Supabase RLS is enabled. The backend uses a **service role client** (`supabaseAdmin`) to bypass RLS for all write operations. The anon client is only used for `signInWithPassword()` in login.

This means: all reads/writes from the Express backend go through the service role key and are not subject to RLS policies. No RLS policies need to be configured for the Flutter app to work correctly (all DB access goes through the Express API, never directly from the app).

---

## Connection

The Flutter app **never connects directly to Supabase**. All database access goes through the Express API at `http://localhost:5000/api`.

Backend connection config (in `RunApp/backend/src/config/supabase.js`):
```javascript
const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY)   // user context
const supabaseAdmin = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY)  // bypass RLS
```
