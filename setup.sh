#!/data/data/com.termux/files/usr/bin/bash
# ============================================
# CAIXA PRETA - Deploy com sistema de VERSÃO
# ============================================

cd ~/caixa-preta || exit 1

# --- 1. Cria index.html com sistema de versão ---
cat > index.html << 'HTMLEOF'
<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Mapa</title>
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
<style>
*{margin:0;padding:0;box-sizing:border-box}
html,body{width:100%;height:100%;overflow:hidden}
body{font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,Arial,sans-serif}
#mapa{position:fixed;top:0;left:0;width:100vw;height:100vh;background:#d7eaf0;z-index:1}
.pin-personalizado{position:relative;width:60px;height:60px;display:flex;align-items:center;justify-content:center}
.pin-personalizado img{display:block;width:60px;height:60px;object-fit:contain;filter:drop-shadow(0 2px 4px rgba(0,0,0,0.5))}
.badge-novo{position:absolute;top:-6px;right:-6px;width:22px;height:22px;background:#ff4444;color:white;border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:12px;font-weight:bold;box-shadow:0 2px 6px rgba(0,0,0,0.4);animation:pulsar 1.5s infinite}
.badge-novo.oculto{display:none}
@keyframes pulsar{0%{transform:scale(1)}50%{transform:scale(1.2)}100%{transform:scale(1)}}
#overlay-codigo{display:none;position:fixed;inset:0;z-index:10000;background:rgba(0,0,0,0.85);justify-content:center;align-items:center;padding:20px}
.caixa-codigo{background:white;border-radius:16px;padding:30px;max-width:320px;width:100%;text-align:center;box-shadow:0 10px 40px rgba(0,0,0,0.3)}
.caixa-codigo h3{font-size:16px;color:#333;margin-bottom:5px}
.caixa-codigo p{font-size:13px;color:#888;margin-bottom:20px}
.caixa-codigo input{width:100%;padding:14px;border:2px solid #ddd;border-radius:10px;font-size:18px;text-align:center;letter-spacing:3px;margin-bottom:15px;outline:none}
.caixa-codigo input:focus{border-color:#007AFF}
.caixa-codigo button{width:100%;padding:14px;background:#007AFF;color:white;border:none;border-radius:10px;font-size:15px;font-weight:600;cursor:pointer}
.caixa-codigo .erro{color:#ff4444;font-size:13px;margin-top:10px;display:none}
#overlay-msg{display:none;position:fixed;inset:0;z-index:9999;background:rgba(0,0,0,0.9);justify-content:center;align-items:center;padding:20px}
.carta{background:linear-gradient(135deg,#f5f5dc 0%,#e8dcc0 100%);border-radius:12px;padding:35px;max-width:420px;width:100%;max-height:90vh;overflow-y:auto;text-align:center;box-shadow:0 0 50px rgba(212,175,55,0.3);animation:surgir 0.5s ease}
@keyframes surgir{from{transform:scale(0.8);opacity:0}to{transform:scale(1);opacity:1}}
.carta h2{color:#5c3a1e;font-family:"Courier New",monospace;font-size:15px;margin-bottom:5px;text-transform:uppercase;letter-spacing:2px}
.carta .remetente{color:#8b7355;font-size:12px;margin-bottom:20px}
#texto-secreto{color:#3d2817;font-family:"Courier New",monospace;font-size:17px;line-height:1.7;word-break:break-word;margin-bottom:20px;min-height:30px}
.fechar-btn{padding:10px 24px;background:transparent;border:2px solid #8b4513;color:#8b4513;border-radius:8px;cursor:pointer;font-family:"Courier New",monospace;font-size:13px;font-weight:bold}
.resposta-area{margin-top:20px;border-top:1px solid #c4b090;padding-top:15px;text-align:left}
.resposta-area h3{color:#5c3a1e;font-family:"Courier New",monospace;font-size:11px;margin-bottom:8px;text-transform:uppercase}
.resposta-area textarea{width:100%;background:rgba(255,255,255,0.5);color:#3d2817;border:1px solid #8b4513;padding:10px;border-radius:6px;font-family:"Courier New",monospace;font-size:13px;min-height:60px;resize:vertical;margin-bottom:8px}
.btn-enviar{width:100%;padding:10px;background:#8b4513;color:#f5f5dc;border:none;border-radius:6px;font-weight:600;cursor:pointer;font-family:"Courier New",monospace;font-size:13px}
.enviado{color:#228b22;font-family:"Courier New",monospace;font-size:11px;margin-top:8px;display:none;text-align:center}
</style>
</head>
<body>
<div id="mapa"></div>
<div id="overlay-codigo">
  <div class="caixa-codigo">
    <h3>🔐 Caixa Postal Privada</h3>
    <p>Digite o código de acesso</p>
    <input type="text" id="codigo-input" placeholder="••••" autocomplete="off">
    <button id="btn-abrir">Abrir</button>
    <div class="erro" id="erro-codigo">Código incorreto</div>
  </div>
</div>
<div id="overlay-msg">
  <div class="carta">
    <h2>📬 Carta Confidencial</h2>
    <div class="remetente">Remetente: Anônimo</div>
    <p id="texto-secreto"></p>
    <button class="fechar-btn" id="btn-queimar">Queimar carta</button>
    <div class="resposta-area">
      <h3>✍️ Escrever resposta</h3>
      <textarea id="resposta-texto" placeholder="Digite sua resposta aqui..."></textarea>
      <button class="btn-enviar" id="btn-enviar-resposta">Enviar resposta</button>
      <p class="enviado" id="msg-enviado">✅ Resposta enviada!</p>
    </div>
  </div>
</div>
<script>
const CODIGO="cw",REPO="minhasempresasb3/minhasempresasb3.github.io",NTFY_TOPICO="minhasempresasb3-resposta",LAT=-19.057018,LNG=-41.013637;
const LS_KEY="cp_versao_lida";

// Persistência dupla: localStorage + window.name
function storageGet(k){try{const v=localStorage.getItem(k);if(v!==null)return v}catch(e){}try{const d=window.name?JSON.parse(window.name):{};if(d&&d[k]!==undefined)return d[k]}catch(e){}return null}
function storageSet(k,v){try{localStorage.setItem(k,v)}catch(e){}try{const d=window.name?JSON.parse(window.name):{};d[k]=v;window.name=JSON.stringify(d)}catch(e){}}

function decodeBase64UTF8(b){const bin=atob(b),u=new Uint8Array(bin.length);for(let i=0;i<bin.length;i++)u[i]=bin.charCodeAt(i);return new TextDecoder().decode(u)}

const mapa=L.map("mapa",{zoomControl:true}).setView([LAT,LNG],17);
L.tileLayer("https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png",{maxZoom:20,subdomains:"abcd",attribution:"&copy; OpenStreetMap contributors &copy; CARTO"}).addTo(mapa);

const icone=L.divIcon({className:"",html:'<div class="pin-personalizado"><img src="./pin.png" alt="Pin" onerror="this.style.display=\'none\'"><div class="badge-novo">1</div></div>',iconSize:[60,60],iconAnchor:[30,60],popupAnchor:[0,-60]});
const marcador=L.marker([LAT,LNG],{icon:icone,title:"Caixa Postal Privada"}).addTo(mapa);

marcador.on("click",function(){document.getElementById("overlay-codigo").style.display="flex";document.getElementById("codigo-input").value="";document.getElementById("erro-codigo").style.display="none";setTimeout(()=>document.getElementById("codigo-input").focus(),100)});

function resetar(){document.getElementById("overlay-msg").style.display="none";document.getElementById("overlay-codigo").style.display="none";document.getElementById("texto-secreto").textContent="";document.getElementById("codigo-input").value="";document.getElementById("resposta-texto").value="";document.getElementById("msg-enviado").style.display="none";document.getElementById("erro-codigo").style.display="none";mapa.closePopup()}

function getBadge(){const el=marcador.getElement();return el?el.querySelector(".badge-novo"):null}
function setBadgeVisible(v){const b=getBadge();if(!b)return;v?b.classList.remove("oculto"):b.classList.add("oculto")}

// Busca versão atual no servidor
async function fetchVersao(){try{const r=await fetch("https://api.github.com/repos/"+REPO+"/contents/versao.txt?ref=main&_="+Date.now(),{cache:"no-store"});if(!r.ok)return null;const d=await r.json();return atob(d.content).trim()}catch(e){return null}}

// Busca mensagem no servidor
async function fetchMensagem(){try{const r=await fetch("https://api.github.com/repos/"+REPO+"/contents/mensagem.txt?ref=main&_="+Date.now(),{cache:"no-store"});if(!r.ok)return null;const d=await r.json();return decodeBase64UTF8(d.content).trim()}catch(e){return null}}

async function checkBadge(){
  const versaoAtual=await fetchVersao();
  if(!versaoAtual){setBadgeVisible(false);return}
  const versaoLida=storageGet(LS_KEY);
  if(versaoAtual!==versaoLida)setBadgeVisible(true);
  else setBadgeVisible(false);
}

async function mostrarMsg(){
  const msg=await fetchMensagem();
  if(!msg){resetar();return}
  const versaoAtual=await fetchVersao();
  if(versaoAtual)storageSet(LS_KEY,versaoAtual);
  setBadgeVisible(false);
  document.getElementById("overlay-codigo").style.display="none";
  document.getElementById("texto-secreto").textContent=msg;
  document.getElementById("overlay-msg").style.display="flex";
}

function verificarCodigo(){const v=document.getElementById("codigo-input").value.trim().toLowerCase();v===CODIGO?mostrarMsg():document.getElementById("erro-codigo").style.display="block"}

async function enviarResposta(){const t=document.getElementById("resposta-texto").value.trim();if(!t)return;try{const r=await fetch("https://ntfy.sh/"+NTFY_TOPICO,{method:"POST",body:t,headers:{"Title":"Resposta do Mapa"}});if(!r.ok)throw new Error("Falha");document.getElementById("msg-enviado").style.display="block";document.getElementById("resposta-texto").value=""}catch(e){console.error(e);alert("Erro ao enviar.")}}

document.getElementById("btn-abrir").addEventListener("click",verificarCodigo);document.getElementById("codigo-input").addEventListener("keypress",e=>{if(e.key==="Enter")verificarCodigo()});document.getElementById("btn-enviar-resposta").addEventListener("click",enviarResposta);document.getElementById("btn-queimar").addEventListener("click",resetar);document.getElementById("overlay-codigo").addEventListener("click",e=>{if(e.target===e.currentTarget)resetar()});document.getElementById("overlay-msg").addEventListener("click",e=>{if(e.target===e.currentTarget)resetar()});

if(marcador.getElement())checkBadge();else marcador.once("add",checkBadge);setInterval(checkBadge,60000);
</script>
</body>
</html>
HTMLEOF

# --- 2. Padroniza nome da imagem do pino ---
IMG_ATUAL=$(ls -t *.png 2>/dev/null | head -1)
if [ -n "$IMG_ATUAL" ] && [ "$IMG_ATUAL" != "pin.png" ]; then
  mv "$IMG_ATUAL" pin.png
  echo "✅ Imagem renomeada: $IMG_ATUAL -> pin.png"
fi

# --- 3. Cria arquivo versao.txt inicial (se não existir) ---
if [ ! -f versao.txt ]; then
  echo "1" > versao.txt
fi

# --- 4. Cria o comando 'msg' no Termux ---
mkdir -p ~/.shortcuts
cat > ~/.shortcuts/msg << 'MSGEOF'
#!/data/data/com.termux/files/usr/bin/bash
# Comando: msg "sua mensagem aqui"
cd ~/caixa-preta || exit 1

if [ -z "$1" ]; then
  echo "❌ Uso: msg "sua mensagem aqui""
  exit 1
fi

MENSAGEM="$*"

# Codifica em base64 UTF-8
ENCODED=$(printf '%s' "$MENSAGEM" | base64 -w 0)

# Gera nova versão (timestamp em segundos)
NOVA_VERSAO=$(date +%s)

# Salva mensagem e versão
echo "$ENCODED" > mensagem.txt
echo "$NOVA_VERSAO" > versao.txt

git add mensagem.txt versao.txt
git commit -m "nova mensagem v$NOVA_VERSAO" || echo "Nada novo"
git pull origin main --no-edit
git push origin main

echo "✅ Mensagem enviada!"
echo "📝 Versão: $NOVA_VERSAO"
echo "💬 Conteúdo: $MENSAGEM"
MSGEOF

chmod +x ~/.shortcuts/msg

# Adiciona alias no bashrc
if ! grep -q "alias msg=" ~/.bashrc 2>/dev/null; then
  echo 'alias msg="bash ~/.shortcuts/msg"' >> ~/.bashrc
  echo "✅ Alias 'msg' adicionado ao ~/.bashrc"
fi

# --- 5. Commit e push ---
git config pull.rebase false
git add index.html versao.txt mensagem.txt 2>/dev/null
git commit -m "sistema de versao + comando msg" || echo "Nada novo"
git pull origin main --no-edit
git push origin main

echo ""
echo "========================================"
echo "🚀 DEPLOY CONCLUÍDO!"
echo "========================================"
echo ""
echo "📌 Agora é só digitar no Termux:"
echo "   msg "sua mensagem aqui""
echo ""
echo "🔄 Recarregue o bash: source ~/.bashrc"
echo "========================================"
