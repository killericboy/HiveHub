// ── AHK bridge ──────────────────────────────────────────────
function ahk(fn, data) {
  try { window.chrome.webview.postMessage(data !== undefined ? fn+':'+JSON.stringify(data) : fn) }
  catch(e) {}
}

// ── AHK → JS API ────────────────────────────────────────────
window.HiveHub = {
  setStats(t)    { $('stats-text').textContent = t },
  setStatus(s)   { const b=$('status-badge'); b.textContent=s; b.className='badge badge-'+s.toLowerCase() },
  setPauseBtn(t) { $('pauseBtn').textContent = t },
  setDetected(n,ok) {
    $('det-name').textContent = n
    $('det-dot').className = 'det-dot'+(ok?' ok':'')
  },
  setProfileFeedback(t,ok) {
    const e=$('profile-feedback')
    e.textContent=t; e.style.color=ok?'var(--lime)':'var(--red)'
    setTimeout(()=>e.textContent='',3000)
  },

  // live speed + buff strip — called every 500ms while running
  setLiveSpeed(spd, buffs) {
    const el = $('speed-display')
    if (el) el.textContent = spd > 0 ? '(' + spd + ')' : '(' + ($('baseSpeed').value||16) + ')'
    const strip = $('buff-strip')
    if (strip) {
      strip.textContent = buffs || ''
      strip.style.display = buffs ? 'inline' : 'none'
    }
  },

  loadState(data) {
    const s = typeof data==='string' ? JSON.parse(data) : data
    sv('baseSpeed',s.baseSpeed??16); sv('direction',s.direction??1)
    sv('width',s.width??3); sv('camAlign',s.camAlign??1); sv('camSteps',s.camSteps??1)
    sc('shiftLock',s.shiftLock??false); sc('autoHarvest',s.autoHarvest??true)
    sv('keyDelay',s.keyDelay??20); sc('hotbarEnable',s.hotbarEnable??false)
    sv('hotbarInterval',s.hotbarInterval??30)
    for(let i=1;i<=7;i++){
      const el=document.querySelector('.key-btn[data-key="'+i+'"]')
      if(el) el.classList.toggle('active',!!(s.hotbarKeys||{})[i])
    }
    lengthIdx=s.lengthIdx??3; updateLengthDisplay()
    $('privServer').value=s.privServer??''
    sv('joinMethod',s.joinMethod??1); sc('reconnectEnable',s.reconnectEnable??false)
    sv('reconnectHours',s.reconnectHours??0); sv('reconnectHH',s.reconnectHH??0); sv('reconnectMM',s.reconnectMM??0)
    sc('fallbackPublic',s.fallbackPublic??true)
    $('pubServer').value=s.pubServer??'https://www.roblox.com/games/15579077077/Hive-Hub'
    onPrivServerChange()
    $('speed-display').textContent='('+(s.baseSpeed??16)+')'
    if(s.profiles) renderProfileList(s.profiles, s.currentProfile)
    if(s.currentProfile) document.title='HiveHub Macro v1.4.0 ['+s.currentProfile+']'
  }
}

// ── Helpers ─────────────────────────────────────────────────
const $ = id => document.getElementById(id)
function sv(id,v){const e=$(id);if(e)e.value=v}
function sc(id,v){const e=$(id);if(e)e.checked=!!v}

// ── Tabs ────────────────────────────────────────────────────
function showTab(name,el){
  document.querySelectorAll('.panel').forEach(p=>p.classList.remove('active'))
  document.querySelectorAll('.tab').forEach(t=>t.classList.remove('active'))
  $('tab-'+name).classList.add('active')
  el.classList.add('active')
  ahk('RefreshRobloxDetected')
}

// ── Steppers ────────────────────────────────────────────────
function stepValue(id,d){
  const el=$(id)
  el.value=Math.min(parseFloat(el.max??1e9),Math.max(parseFloat(el.min??-1e9),parseFloat(el.value||0)+d))
  el.dispatchEvent(new Event('input'))
}
function stepFloat(id,d){stepValue(id,d)}

const sizeNames=['XS','S','M','L','XL']
let lengthIdx=3
function stepLength(d){lengthIdx=Math.min(5,Math.max(1,lengthIdx+d));updateLengthDisplay();save()}
function updateLengthDisplay(){$('lengthDisplay').value=sizeNames[lengthIdx-1]}
function toggleCheck(id){const e=$(id);e.checked=!e.checked;e.dispatchEvent(new Event('change'))}

// ── Hotbar ──────────────────────────────────────────────────
const hotbarState={}
;(function(){
  const c=$('hotbar-keys')
  for(let i=1;i<=7;i++){
    const b=document.createElement('div')
    b.className='key-btn';b.dataset.key=i;b.textContent=i
    b.onclick=()=>{hotbarState[i]=!hotbarState[i];b.classList.toggle('active',hotbarState[i]);save()}
    c.appendChild(b)
  }
})()

// ── Speed ───────────────────────────────────────────────────
function onBaseSpeedChange(){
  $('speed-display').textContent='('+(($('baseSpeed').value)||'16')+')'
  save()
}

// ── Server link ─────────────────────────────────────────────
function onPrivServerChange(){
  const v=$('privServer').value.trim(), el=$('srv-label')
  if(!v){el.textContent='No private link';el.className='srv-badge srv-none'}
  else if(/privateServerLinkCode=[a-z0-9]{32}/i.test(v)||/share\?code=[a-f0-9]{32}/i.test(v)){el.textContent='Valid ✓';el.className='srv-badge srv-ok'}
  else{el.textContent='Invalid';el.className='srv-badge srv-invalid'}
  save()
}
async function pastePrivServer(){
  try{$('privServer').value=await navigator.clipboard.readText();onPrivServerChange()}catch(e){}
}

// ── Profiles ────────────────────────────────────────────────
let selectedProfile=null, existingProfiles=[]
function renderProfileList(profiles,current){
  existingProfiles=profiles||[]
  const c=$('profile-list');c.innerHTML=''
  existingProfiles.forEach(name=>{
    const d=document.createElement('div')
    d.className='profile-item'+(name===current?' selected':'')
    d.textContent=name
    d.onclick=()=>{
      selectedProfile=name
      $('profileName').value=name
      document.querySelectorAll('.profile-item').forEach(x=>x.classList.remove('selected'))
      d.classList.add('selected')
      $('addSaveBtn').textContent=existingProfiles.includes(name)?'💾 Save':'➕ Add'
    }
    c.appendChild(d)
  })
}
function profileFeedback(msg,ok){
  const e=$('profile-feedback')
  e.textContent=msg;e.style.color=ok?'var(--lime)':'var(--red)'
  setTimeout(()=>e.textContent='',2500)
}
function doAddProfile(){
  const name=$('profileName').value.trim()
  if(!name){profileFeedback('Enter a name first',false);return}
  ahk('AddProfile',name)
}
function doLoadProfile(){
  if(!selectedProfile){profileFeedback('Select a profile first',false);return}
  ahk('LoadSelectedProfile',selectedProfile)
}
function doDeleteProfile(){
  if(!selectedProfile){profileFeedback('Select a profile first',false);return}
  ahk('DeleteProfile',selectedProfile)
}

// ── Save ────────────────────────────────────────────────────
function save(){
  const keys={}
  document.querySelectorAll('.key-btn').forEach(b=>{keys[b.dataset.key]=b.classList.contains('active')})
  ahk('Save',{
    baseSpeed:+$('baseSpeed').value, direction:+$('direction').value, lengthIdx,
    width:+$('width').value, camAlign:+$('camAlign').value, camSteps:+$('camSteps').value,
    shiftLock:$('shiftLock').checked, autoHarvest:$('autoHarvest').checked,
    keyDelay:+$('keyDelay').value, hotbarEnable:$('hotbarEnable').checked,
    hotbarInterval:+$('hotbarInterval').value, hotbarKeys:keys,
    privServer:$('privServer').value, joinMethod:+$('joinMethod').value,
    reconnectEnable:$('reconnectEnable').checked, reconnectHours:+$('reconnectHours').value,
    reconnectHH:+$('reconnectHH').value, reconnectMM:+$('reconnectMM').value,
    fallbackPublic:$('fallbackPublic').checked, pubServer:$('pubServer').value,
    profileName:$('profileName').value, selectedProfile,
  })
}

updateLengthDisplay()
ahk('JSReady')
window.addEventListener('load', () => ahk('JSReady'))
