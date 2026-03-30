# 🎬 STASH
### Streaming Titles All Saved Here

STASH is a personal movie shelf app for Roku TV. Instead of endlessly browsing streaming platforms, STASH gives you a permanent home for the movies and shows you actually love — organized your way, accessible from your couch.

---

## What It Does

- **Your shelf, your rules** — save movies and shows you love and want to rewatch
- **Organized by category** — create custom shelves like *Favorites*, *Sci-Fi*, *Watch Again*, or anything you want
- **Where to watch, right now** — press OK on any title to see which streaming services have it available today
- **Manage from your phone** — add titles to your shelf from a companion web app, they appear on your TV instantly
- **No algorithm, no ads** — just your collection

---

## The Stack

| Layer | Tech |
|---|---|
| TV App | Roku (BrightScript + SceneGraph) |
| Web Companion | Vite + Vanilla JS |
| Database | Firebase Firestore |
| Movie Metadata | TMDB API |
| Streaming Availability | TMDB Watch Providers |
| Hosting | Firebase Hosting |

---

## Project Structure

```
stash-tv/
├── roku/                   # Roku TV app (BrightScript)
│   ├── components/         # SceneGraph XML components
│   │   ├── ShelfScene.xml  # Main shelf screen
│   │   ├── CategoryRow.xml # Individual category shelf
│   │   ├── DetailScene.xml # Movie detail screen
│   │   ├── TMDBTask.xml    # TMDB background task
│   │   ├── FirestoreTask.xml
│   │   └── StreamingTask.xml
│   ├── source/             # BrightScript logic
│   │   ├── main.brs
│   │   ├── ShelfScene.brs
│   │   ├── CategoryRow.brs
│   │   ├── DetailScene.brs
│   │   ├── TMDBService.brs
│   │   ├── FirestoreService.brs
│   │   ├── StreamingService.brs
│   │   └── config.brs      # API keys (not committed)
│   ├── images/
│   └── manifest
├── web/                    # Web companion app
│   ├── src/
│   │   ├── index.html
│   │   ├── main.js
│   │   └── firebase.js
│   ├── .env.local          # Firebase + TMDB keys (not committed)
│   └── package.json
├── docs/
├── .gitignore
├── LICENSE                 # Apache 2.0
└── README.md
```

---

## Getting Started

### Prerequisites

- Roku device with developer mode enabled
- Firebase project (Firestore + Hosting)
- TMDB API account (free)
- Node.js

### Enable Roku Developer Mode

On your Roku remote from the home screen:

```
Home x3 → Up x2 → Right → Left → Right → Left → Right
```

Note your Roku's IP address from `Settings → Network → About`.

### Roku App Setup

1. Clone the repo
```bash
git clone https://github.com/siddhanthsatish/stash-tv.git
cd stash-tv
```

2. Create `roku/source/config.brs` (not committed — keep this private):
```brightscript
function GetConfig() as object
    return {
        tmdb_api_key: "YOUR_TMDB_API_KEY",
        tmdb_read_access_token: "YOUR_TMDB_READ_ACCESS_TOKEN",
        tmdb_base_url: "https://api.themoviedb.org/3",
        tmdb_image_base_url: "https://image.tmdb.org/t/p/w500",
        firebase_project_id: "YOUR_FIREBASE_PROJECT_ID",
        firebase_base_url: "https://firestore.googleapis.com/v1/projects/YOUR_PROJECT_ID/databases/(default)/documents",
        firebase_api_key: "YOUR_FIREBASE_API_KEY",
        user_id: "default"
    }
end function
```

3. Zip and sideload:
```bash
cd roku
zip -r ../../stash.pkg . -x "*.DS_Store"
cd ../..
```

4. Open `http://YOUR_ROKU_IP` in your browser, upload `stash.pkg`

### Web Companion Setup

1. Create `web/.env.local`:
```
VITE_FIREBASE_API_KEY=
VITE_FIREBASE_AUTH_DOMAIN=
VITE_FIREBASE_PROJECT_ID=
VITE_FIREBASE_STORAGE_BUCKET=
VITE_FIREBASE_MESSAGING_SENDER_ID=
VITE_FIREBASE_APP_ID=
VITE_FIREBASE_MEASUREMENT_ID=
VITE_TMDB_READ_ACCESS_TOKEN=
```

2. Install and run:
```bash
cd web
npm install
npm run dev
```

3. Open `http://localhost:5173`

---

## How to Use

### Adding Movies to Your Shelf
1. Open the web companion on your phone or laptop
2. Search for any movie or show
3. Select categories (predefined or custom)
4. Click **Add to Shelf**
5. Relaunch STASH on your Roku — your movie appears

### Navigating on Roku
| Remote | Action |
|---|---|
| Up / Down / Left / Right | Navigate between category shelves |
| OK | Enter a shelf to browse movies |
| Left / Right (in shelf) | Scroll through movies |
| OK (on movie) | Open detail screen |
| Back (in detail) | Return to shelf |
| Back (in shelf) | Return to category navigation |

---

## Firestore Schema

```
shelves/
  {userId}/
    movies/
      {tmdbId}/
        tmdbId:       integer
        title:        string
        posterPath:   string
        backdropPath: string
        overview:     string
        releaseDate:  string
        voteAverage:  float
        addedAt:      timestamp
        categories:   array<string>
        watched:      boolean
```

---

## Roadmap

- [ ] OAuth login with Google (Device Authorization Flow)
- [ ] Multiple user profiles
- [ ] Search directly on Roku
- [ ] Firebase Hosting deploy for web companion
- [ ] Watched / unwatched tracking
- [ ] Sort and filter within categories
- [ ] Fire TV support

---

## License

Apache 2.0 — see [LICENSE](LICENSE)

STASH is a personal open source project. Any future revenue goes to charity.

---

## APIs Used

- [TMDB](https://www.themoviedb.org/documentation/api) — movie metadata and posters
- [TMDB Watch Providers](https://developer.themoviedb.org/reference/movie-watch-providers) — streaming availability
- [Firebase Firestore](https://firebase.google.com/docs/firestore) — shelf persistence