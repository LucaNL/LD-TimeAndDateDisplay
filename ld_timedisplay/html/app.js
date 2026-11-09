// LD TimeDisplay: the on-screen clock. Ticks locally every second; the game only sends changes.
'use strict';

const state = {
    config: null,
    skew: 0,          // server clock minus PC clock, in seconds ('server' time only)
    tz: 0,            // server time zone offset from UTC, in seconds
    server: '', player: '', id: '', players: 0, maxplayers: 0, gametime: '',
    visible: false,   // the game says when to show it (no flash for players who turned it off)
};

const POSITIONS = ['top-left', 'top-center', 'top-right', 'bottom-left', 'bottom-center', 'bottom-right'];
const THEMES = ['shadow', 'plain', 'pill', 'glass'];
const num = (v, fallback) => (typeof v === 'number' && isFinite(v) ? v : fallback);

const pad = (n) => String(n).padStart(2, '0');

/** Date parts for "now", in the server's time zone or the player's own. */
function clockParts(nowMs, cfg, st) {
    if (cfg.source === 'server') {
        const d = new Date(nowMs + (st.skew + st.tz) * 1000);
        return { d, utc: true, Y: d.getUTCFullYear(), M: d.getUTCMonth() + 1, D: d.getUTCDate(),
            h: d.getUTCHours(), m: d.getUTCMinutes(), s: d.getUTCSeconds() };
    }
    const d = new Date(nowMs);
    return { d, utc: false, Y: d.getFullYear(), M: d.getMonth() + 1, D: d.getDate(),
        h: d.getHours(), m: d.getMinutes(), s: d.getSeconds() };
}

const nameCache = new Map();
/** Day/month name in any language through Intl (falls back to English for an unknown code). */
function dateName(d, locale, utc, opts) {
    const key = `${locale}|${utc}|${JSON.stringify(opts)}`;
    let fmt = nameCache.get(key);
    if (!fmt) {
        const o = Object.assign({}, opts, utc ? { timeZone: 'UTC' } : {});
        try { fmt = new Intl.DateTimeFormat(locale, o); } catch (e) { fmt = new Intl.DateTimeFormat('en', o); }
        nameCache.set(key, fmt);
    }
    return fmt.format(d);
}

function formatTime(p, cfg) {
    const sec = cfg.seconds ? ':' + pad(p.s) : '';
    if (cfg.clock === '12h') {
        const h = p.h % 12 === 0 ? 12 : p.h % 12;
        return `${h}:${pad(p.m)}${sec} ${p.h < 12 ? 'AM' : 'PM'}`;
    }
    return `${pad(p.h)}:${pad(p.m)}${sec}`;
}

function formatDate(p, fmt) {
    const map = { YYYY: String(p.Y), YY: String(p.Y).slice(-2), MM: pad(p.M), DD: pad(p.D) };
    return String(fmt || 'DD-MM-YYYY').replace(/YYYY|YY|MM|DD/g, (t) => map[t]);
}

/** All placeholder values for one moment. */
function values(nowMs, cfg, st) {
    const p = clockParts(nowMs, cfg, st);
    const loc = cfg.locale || 'en';
    return {
        time: formatTime(p, cfg),
        date: formatDate(p, cfg.dateFormat),
        weekday: dateName(p.d, loc, p.utc, { weekday: 'long' }),
        wd: dateName(p.d, loc, p.utc, { weekday: 'short' }),
        day: String(p.D),
        month: dateName(p.d, loc, p.utc, { month: 'long' }),
        mon: dateName(p.d, loc, p.utc, { month: 'short' }),
        year: String(p.Y),
        server: st.server || '',
        player: st.player || '',
        id: st.id === undefined || st.id === null ? '' : String(st.id),
        players: st.maxplayers ? String(st.players) : '',
        maxplayers: st.maxplayers ? String(st.maxplayers) : '',
        gametime: st.gametime || '',
    };
}

/**
 * Fill one line. Returns null when the line has placeholders and all of them are empty
 * (e.g. "© {server}" without a server name), so it is left out.
 */
function renderLine(template, vals) {
    let tokens = 0, filled = 0;
    const out = String(template).replace(/\{(\w+)\}/g, (all, key, offset) => {
        if (!(key in vals)) return all;
        tokens++;
        let v = vals[key];
        if (v !== '') filled++;
        // a name at the start of a line gets a capital ("maandag 9 november" -> "Maandag 9 november")
        if (offset === 0 && v && ['weekday', 'wd', 'month', 'mon'].includes(key)) v = v.charAt(0).toUpperCase() + v.slice(1);
        return v;
    });
    if (tokens > 0 && filled === 0) return null;
    return out;
}

function renderLines(nowMs, cfg, st) {
    const vals = values(nowMs, cfg, st);
    const lines = Array.isArray(cfg.lines) ? cfg.lines : (cfg.lines ? [String(cfg.lines)] : []);
    return lines.map((l) => renderLine(l, vals)).filter((l) => l !== null && l.trim() !== '');
}

// ---------------------------------------------------------------------------------------------
// Page (only in the browser)
// ---------------------------------------------------------------------------------------------
const escapeHtml = (s) => s.replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));

function applyConfig(el, cfg) {
    el.className = '';
    el.classList.add(POSITIONS.includes(cfg.position) ? cfg.position : 'top-right');
    el.classList.add(THEMES.includes(cfg.theme) ? cfg.theme : 'shadow');
    if (cfg.bold) el.classList.add('bold');
    if (!state.visible) el.classList.add('hidden');
    const offset = cfg.offset || {};
    el.style.setProperty('--size', String(num(cfg.fontSize, 1.4)));
    el.style.setProperty('--color', cfg.color || '#ffffff');
    el.style.setProperty('--accent', cfg.accent || '#5ec8ff');
    el.style.setProperty('--x', `${num(offset.x, 1.2)}vw`);
    el.style.setProperty('--y', `${num(offset.y, 1.2)}vh`);
    if (cfg.font) el.style.fontFamily = cfg.font;
}

let lastHtml = null;
let lastError = null;
function draw(el) {
    if (!state.config) return;
    try {
        const html = renderLines(Date.now(), state.config, state).map((l) => `<div class="line">${escapeHtml(l)}</div>`).join('');
        if (html !== lastHtml) { el.innerHTML = html; lastHtml = html; }
    } catch (e) {
        // a bad config must never stop the clock for good; log once per different error
        if (String(e) !== lastError) { lastError = String(e); console.error('[ld_timedisplay]', e); }
    }
}

function start() {
    const el = document.getElementById('clock');
    let initialised = false;

    const tick = () => {
        setTimeout(tick, 1000 - (Date.now() % 1000) + 5); // right after each new second (scheduled first)
        draw(el);
    };

    window.addEventListener('message', (event) => {
        const msg = event.data || {};
        if (msg.type === 'init') {
            initialised = true;
            state.config = msg.config || {};
            if (typeof msg.visible === 'boolean') state.visible = msg.visible;
            applyConfig(el, state.config);
            lastHtml = null;
        } else if (msg.type === 'sync') {
            state.skew = Number(msg.serverNow) - Date.now() / 1000;
        } else if (msg.type === 'set') {
            state[msg.key] = msg.value;
            if (msg.key === 'visible') el.classList.toggle('hidden', !msg.value);
        }
        draw(el);
    });

    tick();

    // Tell the game we're loaded. Retried until the game answers with 'init': on a resource (re)start the
    // page can load before the game script has registered the callback.
    if (typeof GetParentResourceName === 'function') {
        const hello = () => {
            if (initialised) return;
            fetch(`https://${GetParentResourceName()}/ready`, { method: 'POST', body: '{}' }).catch(() => {});
            setTimeout(hello, 1000);
        };
        hello();
    }
}

if (typeof module !== 'undefined' && module.exports) {
    module.exports = { clockParts, formatTime, formatDate, values, renderLine, renderLines };
} else {
    start();
}
