# UNSTABLE Backend Hosting

## 1) Local test
```powershell
cd C:\Users\arjun\Desktop\unstable-backend
$env:PORT="8081"
npm start
```
Health check:
`http://127.0.0.1:8081/health`

## 2) VPS deploy (Ubuntu)
1. Point `proxy.yourdomain.com` DNS `A` record to your VPS.
2. Upload this folder to VPS.
3. Run:
```bash
chmod +x setup-vps.sh
./setup-vps.sh proxy.yourdomain.com
```

## 3) Frontend config
Edit:
`C:\Users\arjun\Desktop\Unstable-Static\config.js`

Set production URL:
```js
const productionWisp = "wss://proxy.yourdomain.com/wisp/";
```

## 4) Verify
- `https://proxy.yourdomain.com/health` returns `{"ok":true}`
- Browser WebSocket to `/wisp/` connects successfully
