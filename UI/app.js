// ── AHK bridge ──────────────────────────────────────────────
function ahk(fn, data) {
  try {
    const msg = data !== undefined
      ? JSON.stringify({ cmd: fn, data: data })
      : JSON.stringify({ cmd: fn })
    window.chrome.webview.postMessage(msg)
  } catch(e) {}
}

const $ = id => document.getElementById(id)
function sv(id, v) { const e=$(id); if(e) e.value = v }
function sc(id, v) { const e=$(id); if(e) e.checked = !!v }
function toggleCheck(id) { const e=$(id); if(e){ e.checked=!e.checked; e.dispatchEvent(new Event('change')) } }

// ── Logo click counter → 5 clicks unlocks dev tab ────────────
let _logoClicks = 0, _logoTimer = 0
document.addEventListener('DOMContentLoaded', () => {
  const logo = $('logoBtn')
  if (!logo) return
  logo.addEventListener('click', () => {
    clearTimeout(_logoTimer)
    _logoClicks++
    if (_logoClicks >= 5) { _logoClicks = 0; window.PS99.unlockDevTab() }
    _logoTimer = setTimeout(() => { _logoClicks = 0 }, 3000)
  })
})

// ── Tab switching ─────────────────────────────────────────────
function showTab(name, el) {
  document.querySelectorAll('.panel').forEach(p => p.classList.remove('active'))
  document.querySelectorAll('.tab').forEach(t => t.classList.remove('active'))
  $('tab-' + name).classList.add('active')
  el.classList.add('active')
  ahk('RefreshDetected')
}

// ── Steppers ─────────────────────────────────────────────────
function stepInt(id, d) {
  const el = $(id)
  el.value = Math.max(parseFloat(el.min ?? -1e9), Math.min(parseFloat(el.max ?? 1e9), parseInt(el.value||0)+d))
  save()
}
function stepFlt(id, d) {
  const el = $(id)
  el.value = (Math.round((parseFloat(el.value||0)+d)*10)/10).toFixed(1)
  save()
}

// ── Keybind definitions  [key, label, tooltip] ───────────────
const KEYBIND_DEFS = [
  ['keyLuckyBlock',   '🍀 Lucky Block',      'Spawns a Lucky Block. Macro pixel-hunts it and clicks until it breaks.'],
  ['keyCoinJar',      '🫙 Coin Jar',          'Spawns a Coin Jar. Macro waits for it to finish collecting coins.'],
  ['keyComet',        '☄️ Comet',             'Spawns a Comet. Macro scans for the blue comet pixel and clicks it.'],
  ['keyPinata',       '🎉 Piñata',            'Spawns a Piñata. Macro scans for pink pixels and clicks to break it.'],
  ['keySprinkler',    '💧 Sprinkler',         'Drops a Sprinkler in your best zone to boost diamond earn rate.'],
  ['keyPartyBox',     '🎁 Party Box',         'Spawns a Party Box for bonus rewards. Used when entering best zone.'],
  ['keyQuestFlag',    '🚩 Quest Flag',        'Places a Flag for the "Use Flags" quest. Used in each of the 5 flag zones.'],
  ['keyFlagLastZone', '🏁 Zone Flag',         'Drops a Flag boost in your best zone at the start of each zone visit.'],
  ['keyPotion3',      '🧪 Tier 3 Potion',    'Uses a Tier III Potion. Assigned to the "Use Tier 3 Potions" quest.'],
  ['keyPotion4',      '🧪 Tier 4 Potion',    'Uses a Tier IV Potion. Assigned to the "Use Tier 4 Potions" quest.'],
  ['keyPotion5',      '🧪 Tier 5 Potion',    'Uses a Tier V Potion. Assigned to the "Use Tier 5 Potions" quest.'],
]

// ── Timing definitions  [key, label, tooltip] ────────────────
const TIMING_DEFS = [
  ['timePinata',        '🎉 Piñata',          'Seconds to hunt and click the Piñata after spawning it.'],
  ['timeLuckyBlock',    '🍀 Lucky Block',      'Seconds to hunt and click Lucky Blocks after spawning.'],
  ['timeCoinJar',       '🫙 Coin Jar',          'Seconds to wait for the Coin Jar to finish collecting.'],
  ['timeComet',         '☄️ Comet',             'Seconds to hunt and click the Comet after spawning.'],
  ['timeMiniChests',    '📦 Mini-Chests',      'Seconds to farm Mini-Chests in the best zone per loop.'],
  ['timeBreakables',    '🧱 Breakables',       'Seconds to farm Breakables in the best zone per loop.'],
  ['timeSuperiorChests','📦 Superior Chests',  'Seconds to farm Superior Mini-Chests in the best zone.'],
  ['timeDiamonds',      '💎 Earn Diamonds',    'Seconds to idle in best zone for the Earn Diamonds quest.'],
  ['timeDiamondBreak',  '💎 Diamond Break',    'Seconds to farm Diamond Breakables in the VIP area (requires VIP pass).'],
]

// ── Helper: tooltip icon HTML ─────────────────────────────────
function tipIcon(text) {
  const safe = text.replace(/'/g, "&#39;").replace(/"/g, '&quot;')
  return `<span class="tip-wrap"><span class="tip-icon">ℹ</span><span class="tip-text">${safe}</span></span>`
}

// ── Build equipment (keybind) grid ────────────────────────────
;(function buildKeybindGrid() {
  const grid = $('keybind-grid')
  KEYBIND_DEFS.forEach(([key, label]) => {
    const row = document.createElement('div')
    row.className = 'kb-row'
    row.innerHTML =
      `<span class="kb-label">${label}</span>` +
      `<input class="kb-input" id="${key}" type="text" maxlength="3" value="" oninput="save()">`
    grid.appendChild(row)
  })
})()

// ── Build timing grid ─────────────────────────────────────────
;(function buildTimingGrid() {
  const grid = $('timing-grid')
  TIMING_DEFS.forEach(([key, label]) => {
    const row = document.createElement('div')
    row.className = 'timing-row'
    row.innerHTML =
      `<span class="timing-label">${label}</span>` +
      `<div class="stepper">` +
        `<button onclick="stepInt('${key}',-5)">−</button>` +
        `<input type="number" id="${key}" value="10" min="1" max="999" oninput="save()">` +
        `<button onclick="stepInt('${key}',5)">+</button>` +
      `</div>`
    grid.appendChild(row)
  })
})()

// ── Dev settings save ─────────────────────────────────────────
function saveDevSettings() {
  const d = {
    debugMode:       !!($('debugMode')?.checked),
    ocrLogEnabled:   !!($('ocrLogEnabled')?.checked),
    debugLogEnabled: !!($('debugLogEnabled')?.checked),
  }
  ahk('SaveDevSettings', d)
}

function clearLog() {
  const box = $('log-box')
  if (box) box.innerHTML = ''
}

// ── Public API ────────────────────────────────────────────────
window.PS99 = {

  unlockDevTab() {
    const btn = $('devTabBtn')
    if (!btn) return
    if (btn.classList.contains('dev-hidden')) {
      btn.classList.remove('dev-hidden')
      btn.style.color = 'var(--lime)'
      setTimeout(() => btn.style.color = '', 1500)
    }
  },

  setStatus(s) {
    const b = $('status-badge')
    b.textContent = s
    b.className = 'badge badge-' + s.toLowerCase()
  },

  setPauseBtn(t) { $('pauseBtn').textContent = t },
  setStats(t)    { $('stats-text') && ($('stats-text').textContent = t) },

  setDetected(name, ok) {
    $('det-name').textContent = name
    $('det-dot').className = 'det-dot' + (ok ? ' ok' : '')
    const icon = $('det-icon')
    if (icon) icon.style.background = ok ? '#1d6fcc' : '#e8232a'
  },

  setActivity(loop, zone, area, quest, action, rank) {
    $('act-loop').textContent   = loop   ?? '-'
    $('act-rank').textContent   = rank   ?? '-'
    $('act-zone').textContent   = zone   ?? '-'
    $('act-area').textContent   = area   ?? '-'
    $('act-quest').textContent  = quest  ?? '-'
    $('act-action').textContent = action ?? '-'
  },

  addLog(line) {
    const box = $('log-box')
    const el = document.createElement('div')
    el.className = 'log-line' + (line.includes('▶') || line.includes('⚠') ? ' highlight' : '')
    el.textContent = line
    box.appendChild(el)
    if (box.children.length > 60) box.removeChild(box.firstChild)
    box.scrollTop = box.scrollHeight
  },

  loadQuestSlots(slots) {
    const tbody = $('quest-slots')
    tbody.innerHTML = ''
    slots.forEach((slot, i) => {
      const stars = '★'.repeat(slot.stars || 1)
      const statusCls = slot.status === 'Active' ? 'qs-active' : 'qs-unknown'
      const tr = document.createElement('tr')
      if (!slot.enabled) tr.style.opacity = '0.45'
      tr.innerHTML = `
        <td style="font-size:11px;color:var(--gold)">${stars}</td>
        <td>
          <div class="qt-name">${slot.icon || '❓'} ${slot.questName || 'Unknown'}</div>
          <div class="qt-id">ID: ${slot.questId || '?'}</div>
        </td>
        <td style="color:#fff">${slot.amount ?? '-'}</td>
        <td style="color:var(--accent)">${slot.priority ?? '-'}</td>
        <td><span class="quest-status ${statusCls}">${slot.status || 'Unknown'}</span></td>
        <td style="color:var(--muted);font-size:10px">${slot.zone || '-'}</td>
        <td>
          <label class="check-row" style="justify-content:center" onclick="toggleQuestSlot(${i+1},this)">
            <input type="checkbox" ${slot.enabled ? 'checked' : ''}>
            <div class="check-box"></div>
          </label>
        </td>`
      tbody.appendChild(tr)
    })
  },

  setProfileFeedback(t, ok) {
    const e = $('profile-feedback')
    e.textContent = t
    e.style.color = ok ? 'var(--lime)' : 'var(--red)'
    setTimeout(() => e.textContent = '', 3000)
  },

  loadState(data) {
    const s = typeof data === 'string' ? JSON.parse(data) : data

    sv('numberOfLoops',    s.numberOfLoops  ?? 20)
    sv('eggsAtOnce',       s.eggsAtOnce     ?? 73)
    sv('delayModifier',    s.delayModifier  ?? 1.2)
    sc('eatFruit',         s.eatFruit       ?? true)

    sc('hasVip',             s.hasVip            ?? false)
    sc('hasAutoFarm',        s.hasAutoFarm        ?? false)
    sc('hasDoubleStars',     s.hasDoubleStars     ?? false)
    sc('hasShinyHoverboard', s.hasShinyHoverboard ?? false)

    sc('do1Star', s.do1Star ?? true)
    sc('do2Star', s.do2Star ?? true)
    sc('do3Star', s.do3Star ?? true)
    sc('do4Star', s.do4Star ?? true)

    sc('reconnectAfterLoops', s.reconnectAfterLoops ?? true)
    sv('reconnectSeconds',    s.reconnectSeconds    ?? 45)
    sv('privateServerCode',   s.privateServerCode   ?? '')
    sc('useFlagBestZone',      s.useFlagBestZone      ?? true)
    sc('useSprinklerBestZone', s.useSprinklerBestZone ?? true)

    TIMING_DEFS.forEach(([key]) => sv(key, s[key] ?? 10))
    KEYBIND_DEFS.forEach(([key]) => sv(key, s[key] ?? ''))

    sc('debugMode',       s.debugMode       ?? false)
    sc('ocrLogEnabled',   s.ocrLogEnabled   ?? true)
    sc('debugLogEnabled', s.debugLogEnabled ?? true)

    if (s.devModeForce) this.unlockDevTab()
    if (s.profiles) renderProfileList(s.profiles, s.currentProfile)
    if (s.currentProfile) document.title = 'RankBlitz Macro [' + s.currentProfile + ']'
  }
}

function toggleQuestSlot(slotIndex, labelEl) {
  const cb = labelEl.querySelector('input[type=checkbox]')
  cb.checked = !cb.checked
  ahk('SetQuestEnabled', slotIndex + ':' + cb.checked)
  const row = labelEl.closest('tr')
  if (row) row.style.opacity = cb.checked ? '1' : '0.45'
}

function save() {
  const d = {}
  const nums = [
    'numberOfLoops','eggsAtOnce','reconnectSeconds','potionsPerUpgrade',
    'enchantsPerUpgrade','stdPetsForGolden','goldenPetsForRainbow','rareEggHatches',
    ...TIMING_DEFS.map(t => t[0])
  ]
  nums.forEach(id => { const e=$(id); if(e) d[id] = parseFloat(e.value)||0 })
  const flt = ['delayModifier']
  flt.forEach(id => { const e=$(id); if(e) d[id] = parseFloat(e.value)||1 })
  const bools = ['eatFruit','hasVip','hasAutoFarm','hasDoubleStars','hasShinyHoverboard',
                 'do1Star','do2Star','do3Star','do4Star',
                 'reconnectAfterLoops','useFlagBestZone','useSprinklerBestZone']
  bools.forEach(id => { const e=$(id); if(e) d[id] = e.checked })
  const strs = ['privateServerCode','profileName','selectedProfile',
                ...KEYBIND_DEFS.map(k=>k[0])]
  strs.forEach(id => { const e=$(id); if(e) d[id] = e.value })
  ahk('Save', d)
}

let selectedProfile = null

function renderProfileList(profiles, current) {
  const c = $('profile-list')
  c.innerHTML = ''
  profiles.forEach(name => {
    const d = document.createElement('div')
    d.className = 'profile-item' + (name === current ? ' selected' : '')
    d.textContent = name
    d.onclick = () => {
      selectedProfile = name
      sv('profileName', name)
      $('addSaveBtn').textContent = '💾 Save'
      document.querySelectorAll('.profile-item').forEach(x => x.classList.remove('selected'))
      d.classList.add('selected')
    }
    c.appendChild(d)
  })
}

function doAddProfile() {
  const name = ($('profileName').value || '').trim()
  if (!name) { window.PS99.setProfileFeedback('Enter a name first', false); return }
  ahk('AddProfile', name)
}
function doLoadProfile() {
  if (!selectedProfile) { window.PS99.setProfileFeedback('Select a profile first', false); return }
  ahk('LoadSelectedProfile', selectedProfile)
}
function doDeleteProfile() {
  if (!selectedProfile) { window.PS99.setProfileFeedback('Select a profile first', false); return }
  ahk('DeleteProfile', selectedProfile)
}

window.addEventListener('load', () => ahk('RefreshDetected'))