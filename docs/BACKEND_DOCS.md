# Backend API Documentation

> Backend source: `C:\Users\Ritanjay\Desktop\RunApp\backend`
> Base URL (dev): `http://10.0.2.2:5000/api` (Android emulator → localhost)
> Base URL (device): `http://<your-machine-ip>:5000/api`

The backend is **reused unchanged** from the React Native RunApp project.
This document serves as the reference for Flutter service files.

---

## Authentication

All protected routes require:
```
Authorization: Bearer <accessToken>
```

Access token lifetime: **15 minutes**
Refresh token lifetime: **30 days** (rotates on each refresh)

---

## Auth Routes — `/api/auth`

### POST /signup
Creates a new user account.

**Request**
```json
{
  "name": "Ritanjay",
  "email": "user@example.com",
  "password": "minlength8",
  "avatar": "🏃"
}
```

**Response 201**
```json
{
  "accessToken": "eyJ...",
  "refreshToken": "uuid-v4",
  "user": {
    "id": "uuid",
    "name": "Ritanjay",
    "email": "user@example.com",
    "avatar": "🏃",
    "level": 1,
    "xp": 0,
    "xp_to_next": 1000,
    "streak": 0,
    "territory_percent": 0.0,
    "total_distance_km": 0.0,
    "total_steps": 0
  }
}
```

**Errors:** `400` missing fields · `409` email already exists

---

### POST /login

**Request**
```json
{ "email": "user@example.com", "password": "password123" }
```

**Response 200** — same shape as `/signup`

**Errors:** `401` invalid credentials

---

### POST /refresh

**Request**
```json
{ "refreshToken": "uuid-v4" }
```

**Response 200**
```json
{ "accessToken": "eyJ...", "refreshToken": "new-uuid-v4" }
```

**Errors:** `401` invalid / revoked / expired token

---

### POST /logout

**Request**
```json
{ "refreshToken": "uuid-v4" }
```

**Response 204** No Content

---

### POST /google

**Request**
```json
{ "googleAccessToken": "ya29...." }
```

**Response 200** — same shape as `/signup`

---

### POST /forgot-password/send-otp

**Request**
```json
{ "email": "user@example.com" }
```

**Response 200** — always returns 200 (prevents email enumeration)
```json
{ "message": "If this email exists, an OTP has been sent." }
```

---

### POST /forgot-password/verify-otp

**Request**
```json
{ "email": "user@example.com", "otp": "123456" }
```

**Response 200**
```json
{ "resetToken": "eyJ..." }
```

**Errors:** `400` invalid / expired OTP

---

### POST /forgot-password/reset

**Request**
```json
{ "resetToken": "eyJ...", "newPassword": "newpassword123" }
```

**Response 200**
```json
{ "message": "Password updated successfully" }
```

**Errors:** `400` invalid token · `404` user not found

---

## Fitness Routes — `/api/fitness`

All routes require auth.

### POST /sessions
Saves a completed run/walk session. Also updates user's profile XP, level, total distance, total steps.

**Request**
```json
{
  "activity_type": "running",
  "distance_km": 5.2,
  "duration_seconds": 1800,
  "steps": 6760,
  "calories": 420,
  "xp_earned": 284,
  "territory_captured": 2,
  "path_coordinates": [
    { "latitude": 12.9716, "longitude": 77.5946 }
  ],
  "badges_unlocked": ["first_5k"]
}
```

**Response 201**
```json
{ "session": { "id": "uuid", "user_id": "uuid", ...all fields... } }
```

---

### GET /sessions?limit=20&offset=0
Returns paginated run history (newest first).

**Response 200**
```json
{ "sessions": [ ...session objects... ] }
```

---

### GET /stats/weekly
Returns last 7 days aggregated by day of week.

**Response 200**
```json
{
  "days": [
    { "day": "Mon", "steps": 6500, "distanceKm": 4.8, "calories": 380 },
    { "day": "Tue", "steps": 0, "distanceKm": 0, "calories": 0 },
    ...7 days
  ],
  "totals": {
    "runs": 4,
    "steps": 28000,
    "distanceKm": 21.3,
    "calories": 1680
  }
}
```

---

### GET /stats/today
Returns aggregated stats from midnight today.

**Response 200**
```json
{
  "steps": 4200,
  "distanceKm": 3.1,
  "calories": 210,
  "activeMinutes": 28
}
```

---

## Territory (Map) Routes — `/api/map`

All routes require auth.

### GET /territories?minLat=&maxLat=&minLng=&maxLng=
Returns territories within a bounding box (or all if no params).

**Response 200**
```json
{
  "territories": [
    {
      "id": "uuid",
      "name": "MG Road",
      "ownerColor": "#E94560",
      "coordinates": [ { "latitude": 12.975, "longitude": 77.607 }, ... ],
      "owner_id": "uuid",
      "isOwn": false
    }
  ]
}
```

> Note: `isOwn` is always `false` from backend. Flutter client sets it by comparing `owner_id` to current user's ID.

**Pre-seeded zones:** MG Road, Cubbon Park, Brigade Road, Indiranagar, Koramangala, UB City

---

### POST /territories/capture

**Request**
```json
{ "zone_id": "uuid" }
```

**Response 200**
```json
{ "territory": { ...updated territory object... } }
```

---

### GET /territories/user/:userId

**Response 200**
```json
{ "territories": [ ...territory objects owned by user... ] }
```

---

### GET /territories/stats/:userId

**Response 200**
```json
{ "stats": { "owned": 2, "total": 6, "percent": 33.33 } }
```

---

## Leaderboard Routes — `/api/leaderboard`

All routes require auth.

### GET /city?period=week|all

**Response 200**
```json
{
  "entries": [
    {
      "id": "uuid",
      "rank": 1,
      "name": "Ritanjay",
      "avatar": "🏃",
      "level": 5,
      "xp": 4800,
      "distanceKm": 42.5,
      "territoryPercent": 66.6,
      "isYou": true
    }
  ]
}
```

---

### GET /friends?period=week|all
Same response shape as `/city` but filtered to accepted friends + self.

---

### GET /nearby
Same response shape. Returns top 20 by all-time XP.

---

## Social Routes — `/api/social`

All routes require auth.

### GET /friends

**Response 200**
```json
{
  "friends": [
    { "id": "uuid", "name": "Arjun", "avatar": "⚡", "level": 3, "streak": 7, "territory_percent": 16.6 }
  ]
}
```

---

### GET /friends/requests

**Response 200**
```json
{
  "requests": [
    { "id": "friendship-uuid", "name": "Priya", "avatar": "🦅", "level": 2 }
  ]
}
```

> `id` here is the **friendship row UUID** — used for accept/decline calls.

---

### POST /friends/request

**Request**
```json
{ "toId": "target-user-uuid" }
```

**Response 200**
```json
{ "message": "Friend request sent" }
```

---

### POST /friends/accept

**Request**
```json
{ "requestId": "friendship-uuid" }
```

**Response 200**
```json
{ "message": "Friend request accepted" }
```

---

### POST /friends/decline

**Request**
```json
{ "requestId": "friendship-uuid" }
```

**Response 200**
```json
{ "message": "Friend request declined" }
```

---

### GET /feed
Returns 30 most recent run sessions from accepted friends.

**Response 200**
```json
{
  "feed": [
    {
      "id": "session-uuid",
      "friendName": "Arjun",
      "friendAvatar": "⚡",
      "type": "running",
      "distanceKm": 5.1,
      "xpEarned": 282,
      "when": "2026-05-07T08:30:00Z"
    }
  ]
}
```

---

### GET /profile/:userId

**Response 200**
```json
{ "user": { ...full profile object... } }
```

---

### PUT /profile/:userId

**Request** (all fields optional)
```json
{ "name": "New Name", "avatar": "🦅", "push_token": "ExponentPushToken[...]" }
```

**Response 200**
```json
{ "user": { ...updated profile... } }
```

**Errors:** `403` if userId does not match authenticated user

---

### GET /search?query=arj

**Response 200**
```json
{
  "users": [
    { "id": "uuid", "name": "Arjun", "avatar": "⚡", "level": 3 }
  ]
}
```

Max 20 results. Excludes the requesting user.

---

## Notification Routes — `/api/notifications`

All routes require auth.

### POST /register

**Request**
```json
{ "pushToken": "ExponentPushToken[...]" }
```

**Response 200**
```json
{ "message": "Push token registered" }
```

---

### POST /send

**Request**
```json
{
  "toUserId": "uuid",
  "title": "Your zone was captured!",
  "body": "Arjun just took MG Road.",
  "data": { "screen": "Map" }
}
```

**Response 200**
```json
{ "result": { ...Expo push API response... } }
```

---

## Error Response Format

All errors return:
```json
{ "error": "Human readable message" }
```

With appropriate HTTP status code (400, 401, 403, 404, 409, 500).

---

## Health Check

### GET /health
No auth required.

**Response 200**
```json
{ "status": "ok" }
```

---

## XP & Leveling Algorithm (backend — POST /fitness/sessions)

```
Starting: level=1, xp=0, xp_to_next=1000

On session save:
  xp += xp_earned
  while xp >= xp_to_next:
    xp -= xp_to_next
    level += 1
    xp_to_next = round(xp_to_next * 1.3)

Example:
  Level 1, 800 XP, earn 500 → total 1300
  1300 >= 1000 → level up to 2, xp = 300, xp_to_next = 1300
  300 < 1300 → stop
  Result: Level 2, 300/1300 XP
```

---

## Token Storage (Flutter)

Use `flutter_secure_storage`:
- Key `runworld_access_token` → JWT (15min)
- Key `runworld_refresh_token` → UUID v4 (30 days, rotates)

Dio interceptor: on 401, call POST /auth/refresh, store new tokens, retry original request.
