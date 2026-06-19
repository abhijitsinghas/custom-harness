#!/usr/bin/env node
/**
 * extract_design_tokens.js — deterministic Stitch HTML → design_tokens.json
 *
 * Zero external dependencies. Parses every code.html under a Stitch mockup
 * directory, extracts each <script id="tailwind-config"> block, evaluates it
 * in a sandboxed Node `vm` (so JS object literals with single quotes / nested
 * arrays are handled correctly), merges tokens across screens (value-matching
 * dedup), infers light/dark palettes from `-dark` suffixed screens, extracts
 * per-screen layout summaries from the HTML, and writes a canonical
 * `design_tokens.json` conforming to design-tokens-schema.md.
 *
 * Usage:
 *   node extract_design_tokens.js <stitch_mockups_dir> [output_json_path]
 *
 * Exit codes: 0 = success (with or without warnings), 2 = fatal error.
 */
"use strict";

const fs = require("fs");
const path = require("path");
const vm = require("vm");

function fatal(msg) {
  console.error(`✗ ${msg}`);
  process.exit(2);
}

function warn(msg) {
  console.error(`⚠ ${msg}`);
}

const root = process.argv[2];
const outPath = process.argv[3] || "docs/design_tokens.json";
if (!root) {
  console.error("Usage: node extract_design_tokens.js <stitch_mockups_dir> [output_json_path]");
  process.exit(2);
}
if (!fs.existsSync(root) || !fs.statSync(root).isDirectory()) {
  fatal(`Stitch mockups directory not found or not a directory: ${root}`);
}

// ── helpers ────────────────────────────────────────────────────────────────
function readText(p) {
  try {
    return fs.readFileSync(p, "utf8");
  } catch (e) {
    return null;
  }
}

/** Extract the inner text of <script id="tailwind-config">…</script> */
function extractTailwindConfigScript(html) {
  if (!html) return null;
  const m = html.match(
    /<script[^>]*id=["']tailwind-config["'][^>]*>([\s\S]*?)<\/script>/i
  );
  return m ? m[1] : null;
}

/** Find tailwind config object in arbitrary script text (handles `tailwind.config = {...}` or `module.exports = {...}`). */
function evalTailwindConfig(scriptText) {
  if (!scriptText) return null;
  const sandbox = {
    tailwind: {},
    module: { exports: {} },
    exports: {},
    require: () => ({ handler: () => ({}), addDefaults: () => ({}) }),
    window: {},
  };
  try {
    vm.createContext(sandbox);
    vm.runInContext(scriptText, sandbox, { timeout: 1000 });
  } catch (e) {
    return { __error: e.message };
  }
  const cfg =
    (sandbox.tailwind && sandbox.tailwind.config) ||
    sandbox.module.exports ||
    sandbox.exports ||
    null;
  return cfg;
}

function deepGet(obj, ...path) {
  let cur = obj;
  for (const k of path) {
    if (cur == null || typeof cur !== "object") return undefined;
    cur = cur[k];
  }
  return cur;
}

/** Normalize a color value to `#RRGGBB` / `#RRGGBBAA` if possible. */
function normalizeColor(v) {
  if (v == null) return null;
  if (typeof v === "string") {
    let s = v.trim();
    if (s === "current" || s === "inherit" || s === "transparent") return null;
    if (s.startsWith("#")) {
      let hex = s.slice(1);
      if (hex.length === 3) hex = hex.split("").map((c) => c + c).join("");
      if (hex.length === 4) hex = hex.split("").map((c) => c + c).join("");
      if (hex.length === 6 || hex.length === 8) return `#${hex.toUpperCase()}`;
    }
    const rgb = s.match(/rgba?\(\s*([\d.]+)\s*,\s*([\d.]+)\s*,\s*([\d.]+)\s*(?:,\s*([\d.]+))?\s*\)/i);
    if (rgb) {
      const to = (n) => Math.round(parseFloat(n)).toString(16).padStart(2, "0");
      const r = to(rgb[1]), g = to(rgb[2]), b = to(rgb[3]);
      const a = rgb[4] ? Math.round(parseFloat(rgb[4]) * 255).toString(16).padStart(2, "0") : "";
      return `#${r}${g}${b}${a}`.toUpperCase();
    }
  }
  return null;
}

/** Normalize a length value like "16px" / "1rem" / 16 → number (px) or raw string. */
function normalizeLength(v) {
  if (v == null) return null;
  if (typeof v === "number") return v;
  if (typeof v === "string") {
    const s = v.trim();
    const px = s.match(/^([\d.]+)px$/i);
    if (px) return parseFloat(px[1]);
    const rem = s.match(/^([\d.]+)rem$/i);
    if (rem) return Math.round(parseFloat(rem[1]) * 16);
    const num = s.match(/^([\d.]+)$/);
    if (num) return parseFloat(num[1]);
  }
  if (Array.isArray(v)) return normalizeLength(v[0]);
  return null;
}

function normalizeFontWeight(w) {
  if (w == null) return null;
  if (typeof w === "number") return `w${w}`;
  if (typeof w === "string") {
    const m = w.match(/(\d{3})/);
    if (m) return `w${m[1]}`;
    return w;
  }
  return null;
}

/** Extract a compact set of color/typography/spacing/radius tokens from a tailwind config. */
function tokensFromConfig(cfg, warnings) {
  const out = { colors: {}, typography: {}, spacing: {}, borderRadius: {} };
  if (!cfg || typeof cfg !== "object") return out;
  const extend = deepGet(cfg, "theme", "extend") || {};
  const colors = extend.colors || deepGet(cfg, "theme", "colors") || {};
  for (const [k, v] of Object.entries(colors)) {
    const c = normalizeColor(v);
    if (c) out.colors[k] = c;
    else if (typeof v === "object") {
      for (const [shade, sv] of Object.entries(v)) {
        const sc = normalizeColor(sv);
        if (sc) out.colors[`${k}.${shade}`] = sc;
      }
    } else {
      warnings.push(`Unresolvable color "${k}": ${JSON.stringify(v)}`);
    }
  }
  const fontFamily = extend.fontFamily || deepGet(cfg, "theme", "fontFamily") || {};
  const fontSize = extend.fontSize || deepGet(cfg, "theme", "fontSize") || {};
  // typography: pair family + size by best-effort name; emit per-size entries
  const families = {};
  for (const [k, v] of Object.entries(fontFamily)) {
    const arr = Array.isArray(v) ? v : [v];
    families[k] = typeof arr[0] === "string" ? arr[0].split(",")[0].trim().replace(/['"]/g, "") : String(arr[0]);
  }
  for (const [k, v] of Object.entries(fontSize)) {
    if (Array.isArray(v)) {
      const size = normalizeLength(v[0]);
      const opts = v[1] || {};
      out.typography[k] = {
        size,
        lineHeight: normalizeLength(opts.lineHeight),
        weight: normalizeFontWeight(opts.weight),
        family: families[k] || families.sans || undefined,
      };
    } else {
      out.typography[k] = { size: normalizeLength(v) };
    }
  }
  const spacing = extend.spacing || deepGet(cfg, "theme", "spacing") || {};
  for (const [k, v] of Object.entries(spacing)) {
    const n = normalizeLength(v);
    if (n != null) out.spacing[k] = n;
  }
  const radius = extend.borderRadius || deepGet(cfg, "theme", "borderRadius") || {};
  for (const [k, v] of Object.entries(radius)) {
    const n = normalizeLength(v);
    if (n != null) out.borderRadius[k] = n;
  }
  return out;
}

/** Merge a screen's tokens into the accumulator (value-match dedup for colors). */
function mergeTokens(acc, screen) {
  for (const [k, v] of Object.entries(screen.colors)) {
    if (!(k in acc.colors.light)) acc.colors.light[k] = v;
    else if (acc.colors.light[k] !== v) acc._colorConflicts[k] = (acc._colorConflicts[k] || []).concat(v);
  }
  for (const [k, v] of Object.entries(screen.typography)) {
    if (!(k in acc.typography)) acc.typography[k] = v;
  }
  for (const [k, v] of Object.entries(screen.spacing)) {
    if (!(k in acc.spacing)) acc.spacing[k] = v;
    else if (acc.spacing[k] !== v) acc._spacingConflicts[k] = (acc._spacingConflicts[k] || []).concat(v);
  }
  for (const [k, v] of Object.entries(screen.borderRadius)) {
    if (!(k in acc.borderRadius)) acc.borderRadius[k] = v;
  }
}

/** Crude HTML structure scan for a per-screen layout summary. */
function summarizeLayout(html, warnings) {
  const summary = {
    layout: null,
    key_components: [],
    notes: [],
  };
  if (!html) return summary;
  const lower = html.toLowerCase();
  const has = (re) => re.test(lower);
  if (has(/class="[^"]*grid[^"]*grid-cols-2/) || has(/grid-cols-2/)) summary.layout = "2-column grid";
  else if (has(/grid-cols-3/)) summary.layout = "3-column grid";
  else if (has(/grid-cols-4/)) summary.layout = "4-column grid";
  else if (has(/class="[^"]*flex[^"]*flex-col/) || has(/flex flex-col/)) summary.layout = "single column";
  else if (has(/<ul\b/) || has(/<li\b/)) summary.layout = "list";
  if (has(/aspect-\[3\/4\]/)) summary.key_components.push("card-3-4");
  if (has(/rounded-full/) && has(/search/)) summary.key_components.push("searchBar");
  if (has(/bottom-sheet|<sheet/) || has(/class="[^"]*rounded-t-\[/)) summary.key_components.push("bottomSheet");
  if (has(/<nav\b/) || has(/bottom-nav|bottomnav/)) summary.key_components.push("bottomNav");
  if (has(/<header\b/) || has(/top-app-bar|appbar/)) summary.key_components.push("topAppBar");
  if (has(/<button\b/)) summary.key_components.push("button");
  if (has(/<input\b.*type="search"/)) summary.key_components.push("searchInput");
  return summary;
}

// ── main ───────────────────────────────────────────────────────────────────
function findCodeHtml(dir) {
  const results = [];
  function walk(d) {
    let entries;
    try {
      entries = fs.readdirSync(d, { withFileTypes: true });
    } catch {
      return;
    }
    for (const e of entries) {
      const full = path.join(d, e.name);
      if (e.isDirectory()) walk(full);
      else if (e.name === "code.html") results.push(full);
    }
  }
  walk(dir);
  return results;
}

const files = findCodeHtml(root);
if (files.length === 0) {
  fatal(`No */code.html files found under ${root}. Is this a Stitch mockup directory?`);
}

const warnings = [];
const acc = {
  colors: { light: {}, dark: {} },
  typography: {},
  spacing: {},
  borderRadius: {},
  _colorConflicts: {},
  _spacingConflicts: {},
};
const screens = [];
let screensWithConfig = 0;
let screensWithDark = 0;

for (const file of files) {
  const screenDir = path.basename(path.dirname(file));
  const isDark = /-dark$/.test(screenDir);
  const html = readText(file);
  const script = extractTailwindConfigScript(html);
  let cfg = null;
  if (script) {
    cfg = evalTailwindConfig(script);
    if (cfg && cfg.__error) {
      warnings.push(`Failed to evaluate tailwind-config in ${screenDir}: ${cfg.__error}`);
      cfg = null;
    }
  } else {
    warnings.push(`No <script id="tailwind-config"> found in ${screenDir}/code.html`);
  }
  const screenTokens = tokensFromConfig(cfg || {}, warnings);
  // Route colors into light/dark based on screen suffix
  const paletteTarget = isDark ? acc.colors.dark : acc.colors.light;
  for (const [k, v] of Object.entries(screenTokens.colors)) {
    if (!(k in paletteTarget)) paletteTarget[k] = v;
  }
  // Typography/spacing/radius merge (light screens primarily; dark inherits)
  if (!isDark) {
    for (const [k, v] of Object.entries(screenTokens.typography)) if (!(k in acc.typography)) acc.typography[k] = v;
    for (const [k, v] of Object.entries(screenTokens.spacing)) {
      if (!(k in acc.spacing)) acc.spacing[k] = v;
      else if (acc.spacing[k] !== v) acc._spacingConflicts[k] = (acc._spacingConflicts[k] || []).concat(v);
    }
    for (const [k, v] of Object.entries(screenTokens.borderRadius)) if (!(k in acc.borderRadius)) acc.borderRadius[k] = v;
  }
  if (isDark) screensWithDark++;
  if (cfg) screensWithConfig++;
  const screenPng = path.join(path.dirname(file), "screen.png");
  screens.push({
    id: screenDir,
    name: screenDir.replace(/-/g, " ").replace(/\b\w/g, (c) => c.toUpperCase()),
    html_path: path.relative(root, file),
    screen_path: fs.existsSync(screenPng) ? path.relative(root, screenPng) : null,
    dark_variant: isDark,
    ...summarizeLayout(html, warnings),
  });
}

// If no dedicated dark screens, flag it
if (screensWithDark === 0) {
  warnings.push("No `-dark` suffixed screens found; dark palette is empty.");
}

// Spacing scale normalization to standard names if raw numeric keys present
function normalizeSpacingScale(spacing, warnings) {
  const named = {};
  const scale = { xs: 4, sm: 8, md: 12, lg: 16, xl: 24, xxl: 32 };
  // If keys already look like named tokens, keep them
  const keys = Object.keys(spacing);
  const allNamed = keys.every((k) => /^[a-z]+$/i.test(k));
  if (allNamed && keys.length > 0) return spacing;
  // Otherwise map numeric px values to nearest scale name
  for (const [k, v] of Object.entries(spacing)) {
    const n = typeof v === "number" ? v : normalizeLength(v);
    if (n == null) {
      named[k] = v;
      continue;
    }
    let best = null;
    let bestDist = Infinity;
    for (const [name, val] of Object.entries(scale)) {
      const d = Math.abs(val - n);
      if (d < bestDist) {
        bestDist = d;
        best = name;
      }
    }
    if (best && bestDist <= 2) named[best] = n;
    else named[k] = n;
  }
  return named;
}
acc.spacing = normalizeSpacingScale(acc.spacing, warnings);

// Surface conflicts as warnings
for (const [k, vs] of Object.entries(acc._colorConflicts)) {
  warnings.push(`Color token "${k}" has conflicting values across screens: ${[acc.colors.light[k]].concat(vs).join(", ")}`);
}
for (const [k, vs] of Object.entries(acc._spacingConflicts)) {
  warnings.push(`Spacing token "${k}" has conflicting values: ${[acc.spacing[k]].concat(vs).join(", ")}`);
}

const output = {
  schema_version: "1.0",
  source: "stitch-html",
  source_directory: path.resolve(root),
  generated_at: new Date().toISOString(),
  parser: "tools/extract_design_tokens.js",
  screens_extracted: screens.length,
  screens_with_config: screensWithConfig,
  screens_with_dark: screensWithDark,
  warnings,
  colors: {
    light: acc.colors.light,
    dark: acc.colors.dark,
  },
  typography: acc.typography,
  spacing: acc.spacing,
  borderRadius: acc.borderRadius,
  components: {}, // component inference left to the design-token-extractor skill (semantic step)
  screens,
};

const outDir = path.dirname(outPath);
if (outDir && !fs.existsSync(outDir)) fs.mkdirSync(outDir, { recursive: true });
fs.writeFileSync(outPath, JSON.stringify(output, null, 2) + "\n", "utf8");

console.log(`✓ Wrote ${outPath}`);
console.log(`  screens: ${screens.length} (config: ${screensWithConfig}, dark: ${screensWithDark})`);
console.log(`  colors:  light=${Object.keys(acc.colors.light).length} dark=${Object.keys(acc.colors.dark).length}`);
console.log(`  typography: ${Object.keys(acc.typography).length}  spacing: ${Object.keys(acc.spacing).length}  radius: ${Object.keys(acc.borderRadius).length}`);
console.log(`  warnings: ${warnings.length}`);
if (warnings.length) for (const w of warnings.slice(0, 20)) console.log(`    - ${w}`);
process.exit(0);
