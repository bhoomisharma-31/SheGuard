/**
 * db/sqlite.js
 * P2 — SheGuard AI
 *
 * Local offline-first storage using expo-sqlite (async API, SDK 57).
 *
 * Tables:
 * - locations   -> FULLY IMPLEMENTED. Used by LocationAgent.js to save every
 *                  30-sec location ping locally before/alongside syncing to Firestore.
 * - alarm_events -> Schema created, minimal insert stub. To be expanded when
 *                  AlarmAgent.js is built.
 * - evidence    -> Schema created, minimal insert stub. To be expanded when
 *                  EvidenceAgent.js is built (audio file references, not the
 *                  audio blobs themselves — those stay on device filesystem).
 *
 * Design note: every row also has a `synced` flag (0/1) so syncQueue.js /
 * backgroundSync.js can find and push any rows that failed to sync when
 * they were first created (e.g. no network at the time).
 */

import * as SQLite from 'expo-sqlite';

const DB_NAME = 'sheguard.db';
let dbInstance = null;

/**
 * Returns a singleton database connection, opening + initializing it on first call.
 */
async function getDb() {
    if (dbInstance) return dbInstance;
    dbInstance = await SQLite.openDatabaseAsync(DB_NAME);
    await _initSchema(dbInstance);
    return dbInstance;
}

async function _initSchema(db) {
    await db.execAsync(`
    PRAGMA journal_mode = WAL;

    CREATE TABLE IF NOT EXISTS locations (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      alert_id TEXT NOT NULL,
      latitude REAL NOT NULL,
      longitude REAL NOT NULL,
      timestamp INTEGER NOT NULL,
      synced INTEGER NOT NULL DEFAULT 0,
      created_at INTEGER NOT NULL DEFAULT (strftime('%s','now'))
    );

    CREATE TABLE IF NOT EXISTS alarm_events (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      alert_id TEXT NOT NULL,
      event_type TEXT NOT NULL,
      timestamp INTEGER NOT NULL,
      synced INTEGER NOT NULL DEFAULT 0,
      created_at INTEGER NOT NULL DEFAULT (strftime('%s','now'))
    );

    CREATE TABLE IF NOT EXISTS evidence (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      alert_id TEXT NOT NULL,
      file_uri TEXT NOT NULL,
      file_type TEXT NOT NULL,
      timestamp INTEGER NOT NULL,
      synced INTEGER NOT NULL DEFAULT 0,
      created_at INTEGER NOT NULL DEFAULT (strftime('%s','now'))
    );
  `);
}

// ---------------------------------------------------------------------
// Locations — FULLY IMPLEMENTED (used by LocationAgent.js)
// ---------------------------------------------------------------------

/**
 * Saves a single location reading locally.
 * @param {Object} params
 * @param {string} params.alertId
 * @param {number} params.latitude
 * @param {number} params.longitude
 * @param {number} params.timestamp
 */
export async function saveLocationLocally({ alertId, latitude, longitude, timestamp }) {
    const db = await getDb();
    await db.runAsync(
        `INSERT INTO locations (alert_id, latitude, longitude, timestamp, synced) VALUES (?, ?, ?, ?, 0);`,
        [alertId, latitude, longitude, timestamp]
    );
}

/**
 * Returns all locally saved locations that have not yet been synced (synced = 0).
 * Used by syncQueue.js / backgroundSync.js to know what still needs pushing.
 */
export async function getUnsyncedLocations() {
    const db = await getDb();
    return db.getAllAsync(`SELECT * FROM locations WHERE synced = 0 ORDER BY timestamp ASC;`);
}

/**
 * Marks a location row as successfully synced.
 * @param {number} id - the local row id
 */
export async function markLocationSynced(id) {
    const db = await getDb();
    await db.runAsync(`UPDATE locations SET synced = 1 WHERE id = ?;`, [id]);
}

/**
 * Returns the single most recent location saved locally.
 * Useful as a fallback if a live fetch fails (e.g. "last known location").
 */
export async function getLastKnownLocation() {
    const db = await getDb();
    const rows = await db.getAllAsync(`SELECT * FROM locations ORDER BY timestamp DESC LIMIT 1;`);
    return rows.length > 0 ? rows[0] : null;
}

// ---------------------------------------------------------------------
// Alarm events — SCHEMA READY, MINIMAL STUB (expand in AlarmAgent.js step)
// ---------------------------------------------------------------------

/**
 * Saves a single alarm event locally (e.g. "armed", "triggered", "disarmed").
 * @param {Object} params
 * @param {string} params.alertId
 * @param {string} params.eventType
 * @param {number} params.timestamp
 */
export async function saveAlarmEventLocally({ alertId, eventType, timestamp }) {
    const db = await getDb();
    await db.runAsync(
        `INSERT INTO alarm_events (alert_id, event_type, timestamp, synced) VALUES (?, ?, ?, 0);`,
        [alertId, eventType, timestamp]
    );
}

// ---------------------------------------------------------------------
// Evidence — SCHEMA READY, MINIMAL STUB (expand in EvidenceAgent.js step)
// ---------------------------------------------------------------------

/**
 * Saves a reference to a locally recorded evidence file (audio).
 * The actual audio file lives on the device filesystem — this just tracks
 * its location + metadata for later syncing.
 * @param {Object} params
 * @param {string} params.alertId
 * @param {string} params.fileUri
 * @param {string} params.fileType - e.g. "audio/m4a"
 * @param {number} params.timestamp
 */
export async function saveEvidenceReferenceLocally({ alertId, fileUri, fileType, timestamp }) {
    const db = await getDb();
    await db.runAsync(
        `INSERT INTO evidence (alert_id, file_uri, file_type, timestamp, synced) VALUES (?, ?, ?, ?, 0);`,
        [alertId, fileUri, fileType, timestamp]
    );
}