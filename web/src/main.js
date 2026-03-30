console.log('TMDB Key:', import.meta.env.VITE_TMDB_READ_ACCESS_TOKEN);
console.log('Project ID:', import.meta.env.VITE_FIREBASE_PROJECT_ID);

import { db } from './firebase.js';
import {
  collection, doc, setDoc, getDocs, deleteDoc, updateDoc, serverTimestamp
} from 'firebase/firestore';

const TMDB_BASE = 'https://api.themoviedb.org/3';
const TMDB_IMG = 'https://image.tmdb.org/t/p/w342';
const TMDB_KEY = import.meta.env.VITE_TMDB_READ_ACCESS_TOKEN;
const USER_ID = 'default';

const PREDEFINED_CATEGORIES = [
  'Favorites', 'Watch Again', 'Sci-Fi', 'Action', 'Comedy',
  'Drama', 'Horror', 'Thriller', 'Animation', 'Documentary'
];

const searchInput = document.getElementById('searchInput');
const searchBtn = document.getElementById('searchBtn');
const resultsEl = document.getElementById('results');
const shelfEl = document.getElementById('shelfResults');
const statusEl = document.getElementById('status');

let shelfIds = new Set();
let shelfData = {};

// Load shelf on startup
async function loadShelf() {
  const snap = await getDocs(collection(db, 'shelves', USER_ID, 'movies'));
  shelfEl.innerHTML = '';
  shelfIds.clear();
  shelfData = {};
  snap.forEach(d => {
    shelfIds.add(String(d.id));
    shelfData[String(d.id)] = d.data();
    renderShelfCard(d.data(), shelfEl);
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

// Category picker HTML
function categoryPickerHTML(selected = []) {
  const chips = PREDEFINED_CATEGORIES.map(cat => `
    <span class="cat-chip ${selected.includes(cat) ? 'selected' : ''}"
      onclick="toggleChip(this, '${cat}')">${cat}</span>
  `).join('');
  return `
    <div class="cat-picker">
      <div class="cat-chips">${chips}</div>
      <div class="cat-custom">
        <input type="text" class="custom-cat-input" placeholder="Add custom category..."/>
        <button onclick="addCustomCat(this)">Add</button>
      </div>
      <div class="selected-cats">${selected.map(c =>
        `<span class="cat-chip selected" onclick="toggleChip(this,'${c}')">${c}</span>`
      ).join('')}</div>
    </div>
  `;
}

// Render search result card
function renderCard(movie, container) {
  const card = document.createElement('div');
  card.className = 'movie-card';
  const title = movie.title || movie.name;
  const date = movie.release_date || movie.first_air_date || '';
  const year = date ? date.substring(0, 4) : '';
  const poster = movie.poster_path;
  const id = String(movie.id);
  const inShelf = shelfIds.has(id);

  card.innerHTML = `
    ${poster
      ? `<img src="${TMDB_IMG}${poster}" alt="${title}"/>`
      : `<div style="aspect-ratio:2/3;background:#222;display:flex;align-items:center;justify-content:center;color:#555;font-size:12px;">No Image</div>`
    }
    <div class="info">
      <h3>${title}</h3>
      <p>${year}</p>
      ${categoryPickerHTML([])}
      <button class="add-btn ${inShelf ? 'added' : ''}" onclick="handleAdd(this, ${JSON.stringify(movie).replace(/"/g, '&quot;')})">
        ${inShelf ? '✓ In Shelf' : '+ Add to Shelf'}
      </button>
    </div>
  `;
  container.appendChild(card);
}

// Render shelf card
function renderShelfCard(movie, container) {
  const card = document.createElement('div');
  card.className = 'movie-card';
  const title = movie.title || movie.name;
  const year = movie.releaseDate ? movie.releaseDate.substring(0, 4) : '';
  const poster = movie.posterPath;
  const id = String(movie.tmdbId);
  const cats = movie.categories || [];

  card.innerHTML = `
    ${poster
      ? `<img src="${TMDB_IMG}${poster}" alt="${title}"/>`
      : `<div style="aspect-ratio:2/3;background:#222;display:flex;align-items:center;justify-content:center;color:#555;font-size:12px;">No Image</div>`
    }
    <div class="info">
      <h3>${title}</h3>
      <p>${year}</p>
      ${categoryPickerHTML(cats)}
      <button class="save-btn" onclick="saveCategories(this, '${id}')">Save Categories</button>
      <button class="remove-btn" onclick="removeFromShelf('${id}', this)">Remove</button>
    </div>
  `;
  container.appendChild(card);
}

// Toggle category chip
window.toggleChip = function(el, cat) {
  el.classList.toggle('selected');
};

// Add custom category
window.addCustomCat = function(btn) {
  const input = btn.previousElementSibling;
  const val = input.value.trim();
  if (!val) return;
  const picker = btn.closest('.cat-picker');
  const chips = picker.querySelector('.cat-chips');
  const chip = document.createElement('span');
  chip.className = 'cat-chip selected';
  chip.textContent = val;
  chip.onclick = () => chip.classList.toggle('selected');
  chips.appendChild(chip);
  input.value = '';
};

// Get selected categories from a card
function getSelectedCats(card) {
  return [...card.querySelectorAll('.cat-chip.selected')].map(c => c.textContent);
}

// Handle add to shelf
window.handleAdd = async function(btn, movie) {
  const card = btn.closest('.movie-card');
  const categories = getSelectedCats(card);
  const id = String(movie.id);
  if (shelfIds.has(id)) { showStatus('Already in your shelf!'); return; }

  const data = {
    tmdbId: movie.id,
    title: movie.title || movie.name,
    posterPath: movie.poster_path || '',
    backdropPath: movie.backdrop_path || '',
    overview: movie.overview || '',
    releaseDate: movie.release_date || movie.first_air_date || '',
    voteAverage: movie.vote_average || 0,
    addedAt: serverTimestamp(),
    categories: categories,
    watched: false
  };

  await setDoc(doc(db, 'shelves', USER_ID, 'movies', id), data);
  shelfIds.add(id);
  btn.textContent = '✓ In Shelf';
  btn.classList.add('added');
  showStatus(`"${data.title}" added to STASH!`);
  loadShelf();
};

// Save categories for shelf movie
window.saveCategories = async function(btn, id) {
  const card = btn.closest('.movie-card');
  const categories = getSelectedCats(card);
  await updateDoc(doc(db, 'shelves', USER_ID, 'movies', id), { categories });
  showStatus('Categories saved!');
  loadShelf();
};

// Remove from shelf
window.removeFromShelf = async function(id, btn) {
  await deleteDoc(doc(db, 'shelves', USER_ID, 'movies', id));
  shelfIds.delete(id);
  btn.closest('.movie-card').remove();
  showStatus('Removed from STASH');
};

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

loadShelf();