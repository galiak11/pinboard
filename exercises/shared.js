/* PinBoard Course — Shared JS */

const STORAGE_KEY = 'pinboard-repo';
const COMPLETION_KEY = 'pinboard-completed';

const BRANCHES = {
  'e01': 'solution/e01-scaffold',
  'e02': 'solution/e02-networking',
  'e03': 'solution/e03-models',
  'e04': 'solution/e04-coordinators',
  'e05': 'solution/e05-feed-viewmodel',
  'e06': 'solution/e06-feed-ui',
  'e07': 'solution/e07-image-loading',
  'e08': 'solution/e08-pagination',
  'e09': 'solution/e09-pin-detail',
  'e10': 'solution/e10-tab-bar',
  'e11': 'solution/e11-combine',
  'e12': 'solution/e12-state-errors',
  'e13': 'solution/e13-deep-linking',
  'e14': 'solution/e14-swift-testing',
};

/* --- Repo URL --- */

function getRepoUrl() {
  const raw = localStorage.getItem(STORAGE_KEY) || '';
  // Accept "owner/repo" or full URL
  if (raw.startsWith('https://github.com/')) return raw.replace(/\/$/, '');
  if (raw.match(/^[\w.-]+\/[\w.-]+$/)) return `https://github.com/${raw}`;
  return '';
}

function setRepoUrl(value) {
  localStorage.setItem(STORAGE_KEY, value.trim());
  updateAllLinks();
  updateStatus();
}

/* --- Link Construction --- */

function branchTreeUrl(exerciseId) {
  const base = getRepoUrl();
  const branch = BRANCHES[exerciseId];
  if (!base || !branch) return '';
  return `${base}/tree/${branch}`;
}

function fileUrl(exerciseId, filePath) {
  const base = getRepoUrl();
  const branch = BRANCHES[exerciseId];
  if (!base || !branch) return '';
  return `${base}/blob/${branch}/${filePath}`;
}

function diffUrl(fromExerciseId, toExerciseId) {
  const base = getRepoUrl();
  const fromBranch = BRANCHES[fromExerciseId];
  const toBranch = BRANCHES[toExerciseId];
  if (!base || !fromBranch || !toBranch) return '';
  return `${base}/compare/${fromBranch}...${toBranch}`;
}

function updateAllLinks() {
  const repo = getRepoUrl();

  document.querySelectorAll('a[data-branch]').forEach(a => {
    const exerciseId = a.dataset.branch;
    const filePath = a.dataset.path;
    if (repo) {
      a.href = filePath ? fileUrl(exerciseId, filePath) : branchTreeUrl(exerciseId);
      a.classList.remove('disabled');
    } else {
      a.href = '#';
      a.classList.add('disabled');
    }
  });

  document.querySelectorAll('a[data-diff]').forEach(a => {
    const [from, to] = a.dataset.diff.split('..');
    if (repo) {
      a.href = diffUrl(from, to);
      a.classList.remove('disabled');
    } else {
      a.href = '#';
      a.classList.add('disabled');
    }
  });

  document.querySelectorAll('.no-repo').forEach(el => {
    el.style.display = repo ? 'none' : 'block';
  });
}

function updateStatus() {
  const status = document.querySelector('.settings-bar .status');
  if (!status) return;
  const repo = getRepoUrl();
  if (repo) {
    status.textContent = '✓ Configured';
    status.className = 'status';
  } else {
    status.textContent = 'Enter your repo';
    status.className = 'status error';
  }
}

/* --- Completion Tracking --- */

function getCompleted() {
  try { return JSON.parse(localStorage.getItem(COMPLETION_KEY) || '{}'); }
  catch { return {}; }
}

function setCompleted(exerciseId, done) {
  const completed = getCompleted();
  completed[exerciseId] = done;
  localStorage.setItem(COMPLETION_KEY, JSON.stringify(completed));
}

function isCompleted(exerciseId) {
  return !!getCompleted()[exerciseId];
}

function updateCheckboxes() {
  document.querySelectorAll('.check[data-exercise]').forEach(el => {
    const id = el.dataset.exercise;
    if (isCompleted(id)) {
      el.classList.add('done');
      el.textContent = '✓';
    } else {
      el.classList.remove('done');
      el.textContent = '';
    }
  });
}

/* --- Init --- */

function initSettings() {
  const input = document.querySelector('.settings-bar input[type="text"]');
  if (input) {
    input.value = localStorage.getItem(STORAGE_KEY) || '';
    input.addEventListener('input', () => setRepoUrl(input.value));
  }
  updateStatus();
  updateAllLinks();
  updateCheckboxes();

  document.querySelectorAll('.check[data-exercise]').forEach(el => {
    el.addEventListener('click', () => {
      const id = el.dataset.exercise;
      setCompleted(id, !isCompleted(id));
      updateCheckboxes();
    });
  });
}

document.addEventListener('DOMContentLoaded', initSettings);
