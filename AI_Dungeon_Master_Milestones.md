# AI Dungeon Master — MVP Plan & Database + Milestones (ASP.NET 8 + Gemini)

**Tổng quan:** Tài liệu này tóm tắt cơ sở dữ liệu đề xuất, milestone backend & frontend chi tiết cho dự án _AI Dungeon Master (mini RPG)_. Công nghệ chính: **.NET 8**, **SQLite (EF Core)** cho dev/local, **Gemini key** làm AI provider (thay thế OpenAI). Nội dung ở đây phù hợp để copy vào project README hoặc lưu lại để tiếp tục trong chat mới.

---

## 1. Thông tin kỹ thuật & Environment
- Backend: **.NET 8 (ASP.NET Core Web API)**
- ORM: **Entity Framework Core** (provider: Microsoft.EntityFrameworkCore.Sqlite)
- Database dev: **SQLite** (file-based) — dễ migrate sang Postgres for prod
- AI Provider: **Gemini** (sử dụng Gemini API key) — lưu key vào biến môi trường `GEMINI_API_KEY`
- Auth: **JWT Bearer** (access token ngắn hạn, refresh token tuỳ chọn)
- Storage: SQLite file: `data/app.db`
- Local secret (dev): `dotnet user-secrets` hoặc `.env` (không commit)
- Docker: dockerfile cho backend
- Rate limiting: middleware (throttle per user)

---

## 2. Database schema (EF Core models) — đề xuất
> Use EF Core migrations to create tables. Dưới đây là schema tóm tắt (các kiểu dữ liệu phù hợp với EF Core).

### Users
- `Id` (GUID) PK
- `Username` (string, unique)
- `Email` (string, unique)
- `PasswordHash` (string)
- `CreatedAt` (DateTime)

### Themes
- `Id` (int) PK
- `Key` (string, unique) e.g. "classic_high_fantasy"
- `Name` (string)
- `PersonaPrompt` (text) — prompt system template
- `Temperature` (float) — default sampling temperature for Gemini
- `MaxTokens` (int)
- `CreatedAt` (DateTime)

### StorySessions
- `Id` (GUID) PK
- `UserId` (GUID) FK -> Users.Id
- `Title` (string)
- `ThemeId` (int) FK -> Themes.Id
- `IsPinned` (bool)
- `CreatedAt` (DateTime)
- `LastUpdated` (DateTime)

### SessionMessages
- `Id` (GUID) PK
- `SessionId` (GUID) FK -> StorySessions.Id
- `Role` (string) // "player" | "dm" | "system" | "hint"
- `Content` (text)
- `TokenCount` (int?) optional
- `CreatedAt` (DateTime)

### UserSettings
- `UserId` (GUID) PK, FK -> Users.Id
- `HintEnabled` (bool)
- `DefaultThemeId` (int?) FK -> Themes.Id

### RefreshTokens (optional)
- `Id` (GUID) PK
- `UserId` (GUID) FK
- `TokenHash` (string)
- `ExpiresAt` (DateTime)
- `CreatedAt` (DateTime)

---

## 3. Milestone chi tiết — Backend (focus đầu tiên)
Mỗi milestone có mục tiêu, endpoints cần implement, deliverables, acceptance criteria.

### Milestone B1 — Project skeleton & configs
**Mục tiêu:** Tạo skeleton, cấu hình .NET 8, EF Core, CORS, logging, secrets.  
**Tasks:**  
- `dotnet new webapi -n AIDungeonBackend`  
- Add packages: EFCore.Sqlite, EFCore.Tools, Microsoft.AspNetCore.Authentication.JwtBearer, Swashbuckle.AspNetCore, Polly (retry), RateLimit hộp thư (tuỳ chọn).  
- Cấu hình `appsettings.Development.json` với connection string: `Data Source=data/app.db`.  
- Configure CORS để allow origin dev (Flutter localhost: e.g. http://localhost:3000 hoặc  http://10.0.2.2:xxxxx).  
**Acceptance:** `GET /health` trả về 200.

### Milestone B2 — Auth (JWT)
**Mục tiêu:** Register/login + JWT.  
**Endpoints:**  
- `POST /api/auth/register` — body: { username, email, password } → returns 201.  
- `POST /api/auth/login` — body: { usernameOrEmail, password } → returns { accessToken, refreshToken? }.  
**Implementation notes:**  
- Hash password with BCrypt or Argon2 (nuget `BCrypt.Net-Next` or `Konscious.Security.Cryptography` for Argon2).  
- JWT secret from env: `JWT_SIGNING_KEY`, expiry short (e.g., 15m). Store refresh tokens if implementing refresh.  
**Acceptance:** Postman: register + login → get Bearer token; protected endpoint `/api/me` returns user info.

### Milestone B3 — Session & Message persistence (SQLite)
**Mục tiêu:** EF Core models + CRUD sessions + messages, per-user persistence.  
**Endpoints:**  
- `POST /api/sessions` { title, themeKey } → create session.  
- `GET /api/sessions` → list sessions (paged).  
- `GET /api/sessions/{id}` → return session meta + last N messages.  
- `DELETE /api/sessions/{id}` → delete.  
- `POST /api/sessions/{id}/messages` { content } → store player message.  
**Acceptance:** Messages persist; retrieval returns last N messages.

### Milestone B4 — AI integration (Gemini) + Chat endpoint
**Mục tiêu:** Tích hợp Gemini key, xây dựng chat flow.  
**Endpoints:**  
- `POST /api/sessions/{id}/chat` { playerInput, includeHint? } → server: store player message -> collect last K messages -> build system+messages prompt (use theme) -> call Gemini -> persist DM reply -> (optional) generate hint -> return { dmReply, hint? }.
**Implementation notes:**  
- Use IHttpClientFactory + Polly retry.  
- Put Gemini API wrapper in `Services/GeminiService.cs`. Read `GEMINI_API_KEY` from env.  
- Limit context by trimming to last K (configurable K=8). For older history consider summarization step later.  
**Acceptance:** Chat returns coherent DM response and stores DM message.

### Milestone B5 — Themes & seeding (9 themes)
**Mục tiêu:** Seed 9 theme records and theme endpoints.  
**Endpoints:**  
- `GET /api/themes` → list themes.  
- `GET /api/themes/{key}` → get theme detail.  
**Deliverables:** SQL seed or EF Core DataSeed to create 9 entries with `PersonaPrompt` templates and default parameters.  
**Acceptance:** New sessions can be created specifying themeKey and chat uses that persona.

### Milestone B6 — Hint generation + UserSettings
**Mục tiêu:** Per-user hint toggle + hint generation.  
**Endpoints:**  
- `PATCH /api/users/settings` { hintEnabled }  
- Chat endpoint accepts `includeHint` boolean.  
**Acceptance:** API returns `hint` when requested.

### Milestone B7 — Rate limiting, costs control, token tracking
**Mục tiêu:** Avoid runaway cost.  
**Tasks:**  
- Track token usage per request (if provider returns token usage).  
- Rate-limit per user endpoints (e.g., 60 req/hour).  
- Implement daily quota field in DB if needed.
**Acceptance:** Requests exceeding limits return 429.

### Milestone B8 — Deployment & production hardening
**Mục tiêu:** Dockerfile, CI, secret management, monitoring.  
**Tasks:** Dockerfile, GitHub Actions build/test, configure Azure/Render secrets, KeyVault or env vars.  
**Acceptance:** Backend deployable & secrets not in repo.

---

## 4. Milestone chi tiết — Frontend (Flutter) (sau backend ổn định)
Mỗi milestone front-end tương ứng với backend features.

### Milestone F1 — Flutter skeleton + Auth UI
**Mục tiêu:** Login/register screens, store JWT in secure storage.  
**Tasks:**  
- Screens: Login, Register, Splash (check token).  
- Packages: `dio` or `http`, `flutter_secure_storage`, `provider`/`riverpod`.  
**Acceptance:** Login obtains token and stores it securely; subsequent API calls include Bearer token.

### Milestone F2 — Sessions UI + Theme selector
**Mục tiêu:** Session list, create session, choose theme.  
**Screens:** SessionsList, NewSession modal (title & theme selection).  
**Acceptance:** Create session -> shows in list (calls backend).

### Milestone F3 — Chat UI (core)
**Mục tiêu:** Chat screen with message bubbles, input, send, loading indicator.  
**Features:**  
- Show messages (player vs DM).  
- Send button disabled while waiting.  
- Handle errors and retries.  
- Hint toggle button in chat UI.  
**Acceptance:** End-to-end chat works with backend.

### Milestone F4 — Session management & export
**Mục tiêu:** Rename, delete, export transcripts.  
**Acceptance:** Export downloads a Markdown/JSON transcript.

### Milestone F5 — Themes UI polish & offline caching
**Mục tiêu:** Theme preview, avatar, offline view of sessions (read-only).  
**Tasks:** caching session list + messages for offline reading.

### Milestone F6 — Learning features (phase 1)
**Mục tiêu:** Vocabulary extraction & flashcards basics (The Grimoire).
**Backend (New `LearningController`):**
*   [x] `POST /api/learning/extract`: Analyze text via Gemini to identify B2+ vocabulary (JSON output).
*   [x] `GET /api/learning/cards`: List saved flashcards.
*   [x] `POST /api/learning/cards`: Save a new flashcard (Word, Definition, Context, Source).
**Frontend:**
*   [x] **Chat UI**: Add "Inspect Knowledge" (Magic Wand / Book) button to AI messages to trigger extraction.
*   [x] **Extraction UI**: Bottom sheet displaying extracted words with "Save" capability.
*   [x] **Grimoire Screen**: List view of saved vocab cards.

### Milestone F7 — Learning Phase 2: Spaced Repetition (SRS)
**Goal:** Efficient review system.
**Backend:** Logic to calculate `NextReviewDate` based on user ratings (Again, Hard, Good, Easy).
**Frontend:** SRS Review UI (Flashcards with rating buttons) & Daily Review Schedule notification.

### Milestone F8 — Learning Phase 3: Gamification
**Goal:** Reward learning.
**Backend:** Track `LearningXP`, award badges/achievements.
**Frontend:** Profile screen stats ("Words Mastery", "Streak"), level up animations.

### Milestone F9 — Learning Phase 4: Active Usage
**Goal:** Make the story adapt to the user's learning list.
**Backend:** Inject "Target Vocabulary" into System Prompt: *"Try to weave the following words into the narrative: [ephemeral, serendipity...]"*.
**Frontend:** Highlight target words in Chat UI.

---

## 5. API Contract (core endpoints summary)
- `POST /api/auth/register`
- `POST /api/auth/login` => { accessToken, refreshToken? }
- `GET /api/themes`
- `POST /api/sessions` => { id, title, themeId }
- `GET /api/sessions`
- `GET /api/sessions/{id}`
- `POST /api/sessions/{id}/messages`
- `POST /api/sessions/{id}/chat` => body: { playerInput, includeHint? } => returns { dmReply, hint? }
- `PATCH /api/users/settings`
- `POST /api/sessions/{id}/export` => returns file/url

---

## 6. Prompt templates — 9 themes (copy-ready short prompts)
> Keep prompts concise to control token usage. Use as `system` message for Gemini and append conversation messages.

1. **classic_high_fantasy**:  
```
You are an epic High Fantasy Dungeon Master. Use vivid medieval imagery: torches, stone halls, and distant chanting. Speak poetically but concisely (2–4 sentences). End with 2–3 numbered action suggestions.
```
2. **grimdark_noir**:  
```
You are a grim noir Dungeon Master. Keep tone dark, terse, and morally ambiguous. Focus on atmosphere and consequences.
```
3. **comedy_capers**:  
```
You are a whimsical, comedic DM, describing absurd situations, playful NPCs, and silly outcomes. Keep it light and give humorous action options.
```
4. **mystery_investigator**:  
```
You are an investigative DM. Present clues, red herrings, and encourage deduction. Provide subtle hints but don't reveal solutions.
```
5. **survival_horror**:  
```
You are a tense survival-horror DM. Emphasize scarcity, sound, smell, and fear. Keep descriptions terse and unsettling.
```
6. **sci_fi_exploration**:  
```
You are a sci-fi exploration DM. Emphasize alien landscapes, strange tech, and wonder mixed with isolation.
```
7. **mythic_eastern**:  
```
You are inspired by Eastern myth: poetic, spirit-world, honor and duty themes. Use symbolic imagery and calm pacing.
```
8. **sword_and_sorcery**:  
```
You are an action-first sword-&-sorcery DM. Fast, punchy descriptions focused on combat and daring deeds.
```
9. **dreamlike_surreal**:  
```
You are a surreal, dreamlike DM. Use abstract imagery, symbolic events, and open-ended prompts to encourage imagination.
```
(Adjust phrasing for Gemini tokens if needed).

---

## 7. Dev notes: Gemini Key usage & best practices
- Store `GEMINI_API_KEY` in environment variables, never commit.  
- Use `IHttpClientFactory` and add `Authorization: Bearer {GEMINI_API_KEY}` header.  
- Implement exponential backoff (Polly) on API calls.  
- Prefer a single wrapper `IGeminiService` to isolate provider changes.  
- If provider returns usage (tokens), persist counts to `SessionMessages.TokenCount`.

---

## 8. Sample appsettings.json (dev)
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Data Source=data/app.db"
  },
  "Jwt": {
    "Key": "<dev-secret-or-use-user-secrets>",
    "Issuer": "AIDungeon",
    "Audience": "AIDungeonClients",
    "ExpireMinutes": 15
  },
  "Gemini": {
    "ApiKey": "",
    "Model": "gemini-medium" 
  }
}
```

---

## 9. Commands & quick-start (backend)
```bash
# scaffold
dotnet new webapi -n AIDungeonBackend
cd AIDungeonBackend

# add packages
dotnet add package Microsoft.EntityFrameworkCore.Sqlite
dotnet add package Microsoft.EntityFrameworkCore.Design
dotnet add package Microsoft.AspNetCore.Authentication.JwtBearer
dotnet add package BCrypt.Net-Next
dotnet add package Polly
dotnet add package Swashbuckle.AspNetCore

# enable user-secrets (dev)
dotnet user-secrets init
dotnet user-secrets set "Jwt:Key" "your-dev-jwt-secret"
dotnet user-secrets set "Gemini:ApiKey" "your_gemini_key"

# create EF migrations
dotnet ef migrations add InitialCreate
dotnet ef database update

# run
dotnet run
```

---

## 10. Testing & QA suggestions (backend)
- Unit test: AuthController, Geminiservice mocked, SessionService.
- Integration tests: endpoints using test server (Microsoft.AspNetCore.Mvc.Testing).
- Mock Gemini responses for test to avoid cost.
- Include Postman collection / OpenAPI (Swagger) for manual QA.

---

## 11. Export & next steps
- Sao chép dữ liệu trong file này vào README.md hoặc tài liệu dự án.  
- Bắt đầu từ Milestone B1 → B2 → B3 là thứ tự hợp lý.  

---