# 手錶庫存管理 — GitHub Pages 部署 ＋ Gist 雲端同步

這個資料夾是**要推上 GitHub 的內容**（只有程式碼，沒有任何業務資料）：
- `index.html` — 手錶庫存管理網頁（＝ `../watch/watch-inventory.html` 的複本）
- `deploy.sh` — 一鍵更新＋推送腳本
- `.gitignore` — 已擋掉 `*.json`／`*.bak`，避免把庫存／客戶資料推上 GitHub
- `README.md` — 本說明

> 為什麼不直接用 Gist 開網頁？Gist 的 raw 網址只會顯示原始碼，要靠第三方渲染服務（gisthost／htmlpreview／raw.githack）才能顯示網頁；而那些服務**網域是與他人共用的**，localStorage（放 token、放你的資料）會跟別人同源，不安全也不穩定。用你自己的 GitHub Pages 才是乾淨的專屬網址。

---

## 〇、先看這裡：資料夾位置與狀態

**已經幫你準備好的部分**
- `watch-deploy/` 內已放好 `index.html`（最新版網頁）、`.gitignore`、`deploy.sh`、`README.md`
- 已在本機初始化 git repo（分支 `main`）並把這 4 個檔案加入待提交（staged）
- `.gitignore` 已排除 `*.json`／`*.bak`／雲端同步暫存檔 → **你的庫存備份 `watch-inventory-backup.json` 不會被推上 GitHub**

**你只需要做**：設定 git 身分 → commit → 建立 GitHub repo → 加 remote → push → 開 Pages（下方第一～三節）。

**⚠️ 關於這個資料夾的位置**
目前 `watch-deploy/` 位於「同步空間」（百度同步盤）底下，雲端同步會連 `.git` 一起上傳，偶爾會產生「衝突文件」。兩個選擇：
- **（A）就地使用**：最省事，若之後看到 `*冲突*` 檔就刪掉即可（`.gitignore` 已忽略它們）。
- **（B）建議**：把 git repo 放到不同步的位置，例如：
  ```bash
  cp -R "/Users/wingching/Downloads/同步空间/deepseek/watch-deploy" ~/Documents/watch-deploy
  cd ~/Documents/watch-deploy
  ```
  之後用 `WATCH_SRC` 指向來源檔即可照常更新：
  ```bash
  WATCH_SRC="/Users/wingching/Downloads/同步空间/deepseek/watch/watch-inventory.html" ./deploy.sh
  ```

---

## 一、部署（約 5 分鐘，只需做一次）

### 1. 建立 repo
到 GitHub → 右上 `+` → **New repository**
- Repository name：例如 `watch`（會變成網址的一部分）
- 選 **Public**（免費方案的 Pages 只支援 public repo）
- 不要勾 Add README / .gitignore（本機已有）

### 2. 推送這個資料夾
打開「終端機」，一行一行執行（把 `<你的帳號>`／`<repo名稱>` 換成你的）：

```bash
cd "/Users/wingching/Downloads/同步空间/deepseek/watch-deploy"
git config user.name  "你的名字"          # 只需設定一次（這台電腦）
git config user.email "你的Email"        # 只需設定一次
git commit -m "deploy watch inventory"
git remote add origin https://github.com/<你的帳號>/<repo名稱>.git
git push -u origin main
```
（`git init` 與 `git add` 已經幫你做好了；若你想自己重來一次，就依序 `git init -b main` → `git add .` → `git commit …`。）

> 第一次 push 會要你登入。密碼欄請用 **Personal Access Token**（classic，勾 `repo`），或先用 GitHub Desktop／Xcode 登入快取。
> 之後若顯示 `fatal: Authentication failed`，改用 HTTPS token 或 `gh auth login`（需先安裝 GitHub CLI）。

### 3. 開啟 GitHub Pages
Repo → **Settings** → 左側 **Pages**
- **Source**：`Deploy from a branch`
- **Branch**：`main` ／ `/(root)` → **Save**

等 1–5 分鐘，網址就是：

```
https://<你的帳號>.github.io/<repo名稱>/
```

（例如 `https://chen.github.io/watch/`）

### 4. iPad 使用
1. iPad 用 **Chrome** 開啟上面的網址
2. 分享鈕 → **加到主畫面**（之後就像 App 一樣點開）
3. 第一次開啟即為最新版；資料存在這個網址的瀏覽器儲存（localStorage）

### 5. 之後每次改版
我（或你）改完 `watch/watch-inventory.html` 後，只要執行：

```bash
cd "/Users/wingching/Downloads/同步空间/deepseek/watch-deploy"
./deploy.sh          # 會自動複製最新檔案 → commit → push
```

iPad 重新整理即可（Pages 有快取，通常 1–10 分鐘；急用可加 `?v=123456` 強制更新）。

---

## 二、設定 Gist 雲端同步（讓 Mac 與 iPad 共用同一份資料）

### 1. 產生 token（只要 Gists 權限）
GitHub → 右上頭像 → **Settings** → 左側 **Developer settings** → **Personal access tokens** → **Fine-grained tokens** → **Generate new token**
- Token name：例如 `watch-inventory-sync`
- Expiration：自選（例如 90 天，到期再換）
- **Account permissions** → 找到 **Gists** → 設為 **Read and write**（其他都不要給）
- Generate → 複製 `github_pat_…`

> 也可以用 classic token：只勾 **`gist`** 這一項權限就好（不要勾 `repo`、`workflow` 等）。

### 2. 在 Mac 上設定
1. 開網頁 → **備份**頁 → 最下方「☁️ 雲端同步（GitHub Gist）」
2. 貼上 token
3. 按 **🧩 自動建立資料 Gist** → 會自動建立一個 **secret gist**（檔名 `watch-inventory-data.json`）並把目前資料上傳
4. 按 **🔌 連線測試** 確認成功
5. 按 **🔁 自動同步：關** → 切成「開」

之後：任何修改約 2.5 秒後自動上傳；開網頁時自動下載雲端最新資料。

### 3. 在 iPad 上設定
同樣開「備份」頁的雲端同步卡 → 貼上**同一個 token**、填入**同一個 Gist ID**（token 不會自動同步，每台裝置各輸入一次）→ 開啟自動同步。

現在 Mac 與 iPad 就是同一份資料：一邊改，另一邊重新整理（或重開）就會看到。

---

## 三、安全與資料保護

| 項目 | 說明 |
|---|---|
| repo 內容 | 只有 `index.html` 等程式碼，**不含**你的庫存／客戶資料（`.gitignore` 已擋 `*.json`） |
| 資料位置 | 各裝置的瀏覽器 localStorage ＋ 你 Gist 上的 `watch-inventory-data.json`（secret gist＝不被搜尋，但知道 Gist ID 的人可讀） |
| token | 只給 Gists 讀寫、只存在該裝置的 localStorage、不會寫進備份檔；隨時可在 GitHub 撤銷 |
| 網址外洩 | Pages 網址公開等於程式碼公開（沒關係）；資料要看 Gist ID＋token，請勿外流 |
| iPad 儲存限制 | iPad 的 Chrome **不支援**「自動備份到資料夾」（File System Access API），所以雲端同步就是 iPad 的主要備份方式；仍建議偶爾用「⬇ 下載備份檔」留存到「檔案」App |
| 裝置不同步的設定 | 進入密碼、主題、字型、Excel 偽裝、同步 token 都是**每台裝置各自設定**（不隨資料同步） |

---

## 四、疑難排解

- **Pages 網址開不起來 / 404**：確認 Settings → Pages 顯示「Your site is live at …」；剛設定好請等 1–10 分鐘。
- **改了程式碼但 iPad 還是舊版**：Pages 快取；在網址後加 `?v=任意數字` 或等幾分鐘；主畫面上的捷徑可刪掉重新加。
- **雲端同步失敗 401**：token 失效／打錯 → 重新產生 token 並貼上。
- **403**：token 權限不足 → 需 **Gists: Read and write**。
- **404（同步時）**：Gist ID 打錯，或該 gist 已被刪除 → 重新按「🧩 自動建立資料 Gist」。
- **兩邊都有改動**：自動下載會**先不行動**並提示；按「⬇️ 立即下載」會詢問要用雲端覆蓋本機，或按「⬆️ 立即上傳」用本機覆蓋雲端。
- **想換掉某台裝置的同步設定**：按「清除此裝置的 token」（雲端資料不會被刪）。
