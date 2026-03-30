console.log('TMDB Key:', import.meta.env.VITE_TMDB_READ_ACCESS_TOKEN);
console.log('Project ID:', import.meta.env.VITE_FIREBASE_PROJECT_ID);

import { db } from './firebase.js';
import {
  collection, doc, setDoc, getDocs, deleteDoc, serverTimestamp
} from 'firebase/firestore';

const TMDB_BASE = 'https://api.themoviedb.org/3';
const TMDB_IMG = 'https://image.tmdb.org/t/p/w342';
const TMDB_KEY = import.meta.env.VITE_TMDB_READ_ACCESS_TOKEN;
const USER_ID = 'default';

const searchInput = document.getElementById('searchInput');
const searchBtn = document.getElementById('searchBtn');
const resultsEl = document.getElementById('results');
const shelfEl = document.getElementById('shelfResults');
const statusEl = document.getElementById('status');

let shelfIds = new Set();


// Load shelf on startup
async function loadShelf() {
  const snap = await getDocs(collection(db, 'shelves', USER_ID, 'movies'));
  shelfEl.innerHTML = '';
  shelfIds.clear();
  snap.forEach(d => {
    shelfIds.add(String(d.id));
    renderCard(d.data(), shelfEl, true);
  });
}

// Search TMDB
async function searchMovies(query) {
  const res = await fetch(
    `${TMDB_BASE}/search/multi?query=${encodeURIComponent(query)}&include_adult=false`,
    { headers: { Authorization: `Bearer ${TMDB_KEY}` } }
  );
  const data = await res.json();
  return data.results.filter(r => r.media_type === 'movie' || r.media_type === 'tv');
}

// Render a movie card
function renderCard(movie, container, isShelf = false) {
  const card = document.createElement('div');
  card.className = 'movie-card';
  const title = movie.title || movie.name;
  const date = movie.releaseDate || movie.release_date || movie.first_air_date || '';
  const year = date ? date.substring(0, 4) : '';
  const poster = movie.posterPath || movie.poster_path;

  card.innerHTML = `
    ${poster
      ? `<img src="${TMDB_IMG}${poster}" alt="${title}"/>`
      : `<div style="aspect-ratio:2/3;background:#222;display:flex;align-items:center;justify-content:center;color:#555;font-size:12px;">No Image</div>`
    }
    <div class="info">
      <h3>${title}</h3>
      <p>${year}</p>
      <button class="add-btn ${isShelf ? 'added' : ''}" data-id="${movie.tmdbId || movie.id}">
        ${isShelf ? '✓ In Shelf' : '+ Add to Shelf'}
      </button>
    </div>
  `;

  const btn = card.querySelector('.add-btn');
  btn.addEventListener('click', () => isShelf
    ? removeFromShelf(movie, card)
    : addToShelf(movie, btn)
  );

  container.appendChild(card);
}

// Add to shelf
async function addToShelf(movie, btn) {
  const id = String(movie.id);
  if (shelfIds.has(id)) {
    showStatus('Already in your shelf!');
    return;
  }
  const data = {
    tmdbId: movie.id,
    title: movie.title || movie.name,
    posterPath: movie.poster_path || '',
    backdropPath: movie.backdrop_path || '',
    overview: movie.overview || '',
    releaseDate: movie.release_date || movie.first_air_date || '',
    voteAverage: movie.vote_average || 0,
    addedAt: serverTimestamp(),
    categories: [],
    watched: false
  };
  await setDoc(doc(db, 'shelves', USER_ID, 'movies', id), data);
  shelfIds.add(id);
  btn.textContent = '✓ In Shelf';
  btn.classList.add('added');
  showStatus(`"${data.title}" added to your STASH!`);
  loadShelf();
}

// Remove from shelf
async function removeFromShelf(movie, card) {
  const id = String(movie.tmdbId || movie.id);
  await deleteDoc(doc(db, 'shelves', USER_ID, 'movies', id));
  shelfIds.delete(id);
  card.remove();
  showStatus(`Removed from your STASH`);
}

function showStatus(msg) {
  statusEl.textContent = msg;
  setTimeout(() => statusEl.textContent = '', 3000);
}

// Search handler
searchBtn.addEventListener('click', async () => {
  const query = searchInput.value.trim();
  if (!query) return;
  resultsEl.innerHTML = '<p style="color:#888;padding:16px">Searching...</p>';
  const movies = await searchMovies(query);
  resultsEl.innerHTML = '';
  movies.slice(0, 12).forEach(m => renderCard(m, resultsEl));
});

searchInput.addEventListener('keydown', e => {
  if (e.key === 'Enter') searchBtn.click();
});

// Init
loadShelf();
