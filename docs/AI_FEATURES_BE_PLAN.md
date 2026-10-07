# Sasacation — Rangkuman Lengkap: Review Fitur, 14 Referensi Modern & Rencana BE

> Disusun: 2026-10-07 | Sumber: inventarisasi `lib/`, `pubspec.yaml`, `AUDIT_PO_2026-10-04.md`, kontrak FE-BE
> Target bagian rencana: MVP demo | Tim: 1 FE (Flutter) + 1 BE (Node.js) | Total: 44–56 person-days (~5–6 minggu)
> **Status eksekusi 2026-10-07: A–F selesai diimplementasi (MVP). BE: 12/12 tests pass. FE: analyze bersih (sisa info lint pre-existing); `flutter test` gagal hanya pada template counter test pre-existing yang tidak terkait.**
> **Lanjutan 2026-10-07 (putaran 2): entry Compare dari wishlist (mode pilih 2–3 + bottom bar → `/compare`); parser F.1 dipindah ke modul kanonis `searchFilterService.js` (pure, ter-test); eval harness `tests/ai-features.test.js` hijau 17/17; full suite BE 29/29 pass.**
> **Putaran 3 (Flutter sinkron BE baru): layar Travel Profile (`/travel-profile`, repo `preferences_repository`, entry di menu Profil) baca/tulis `GET /preferences/profile` + `PUT /preferences` termasuk kolom baru (budgetTier, tripTypes, amenityPrefs, locationPrefs, styles, interests); See-All reviews paginasi `GET /:id/reviews` (fallback inline); badge `contoh/sample` bila `isSeeded`; vibe chips di kartu smart search; `dart analyze` 0 error/0 warning.**
> **Putaran 4: progres bertahap trip planner (Timer 1s + 5 pesan tahap ID/EN + mm:ss + bar tahap; tahap = estimasi alur agent, dinyatakan jujur di komentar); `dart analyze` tetap 0 error/0 warning.**

---

## BAGIAN A — Referensi: 14 Fitur Modern (Booking.com / Agoda / Expedia / Traveloka)

Arah industri bergeser dari "cari → booking" ke **AI Travel Companion / Travel OS**: `DISCOVER → PLAN → BOOK → TRIP (Navigate + Concierge + Disruption)`.

| # | Fitur | Inti |
|---|---|---|
| 1 | AI Hotel Search | Cari pakai bahasa natural ("staycation Jakarta weekend, 1,5jt, tenang, bathtub, dekat cafe, couple") → AI jadi filter + ranking |
| 2 | AI Hotel Comparison | A vs B vs C: tabel harga/lokasi/kamar/breakfast/pool/couple-fit/value + verdict personal |
| 3 | AI Property Expert | "Ask AI about this hotel" (honeymoon? parkir? kedap suara? dekat makan? kebersihan?) berbasis info+review+foto+lokasi |
| 4 | AI Review Summary | Dari ribuan review → disukai vs dikeluhkan + baris personal |
| 5 | Personalized Recommendation | "Paling cocok untuk kamu" dari histori, budget, tipe trip, fasilitas, persona |
| 6 | Group Trip Decision | Tiap orang input preferensi → AI cari kompromi terbaik |
| 7 | Search dari foto/screenshot | Upload Reels/IG → kenali hotel / cari yang mirip di bawah budget |
| 8 | Map + Neighborhood Intelligence | "Apa di sekitar hotel?" (cafe, resto, mall, beach, nightlife, spot) + hotel paling efisien untuk 2 hari |
| 9 | AI Trip Planner | "Bali 4 hari 5jt" → itinerary day-by-day, tiap aktivitas bisa Book |
| 10 | AI Price Intelligence | "Good time to book" vs rata-rata historis |
| 11 | AI Price Alert | Pantau hotel + room type + policy, beri tahu bila < target |
| 12 | Smart Check-in | Digital check-in/key, room service, towel, late checkout dari aplikasi |
| 13 | AI Travel Concierge | In-trip: "baru sampai hotel dan hujan, dinner jalan kaki?" → rekomendasi + Navigate/Reserve |
| 14 | Travel Disruption Assistant | Delay/cancel/overbooking/cuaca → opsi late check-in, reschedule transport, contact hotel |

**5 prioritas yang disepakati:** (1) AI Trip Planner, (2) AI Hotel Search, (3) AI Hotel Compare, (4) AI Review Summary, (5) Personalized Traveler Profile.

---

## BAGIAN B — Yang Sudah Ada di Sasacation (hasil inventarisasi kode)

### B.1 Arsitektur

- Flutter (`lib/`, SDK `^3.11.4`): `UI (go_router ~26 routes)` → `BLoC/Cubit` → `Repository (Dio)` → `ApiClient` → backend eksternal `:5001/api` (repo terpisah, tidak ada di repo ini). State lokal: `SharedPreferences`, `WishlistCubit`, `ForexService`.
- `lib/`: `core/` (theme, locale, notif, lokasi), `data/api|model(12)|repo(15)`, `route/approuter.dart`, `ui/(12 fitur)+widget+home`, `viewmodel/(10 bloc/cubit)`, `utils/money.dart (ForexService)`, `l10n` (505 key ID/EN).
- Firebase (`sasacation-25b57`): Auth (email/Google/Apple → tukar JWT backend), Messaging + local notifications, tanpa Firestore/Analytics/Crashlytics.
- Deps kunci: `dio, flutter_bloc, go_router, firebase_*, google_sign_in, sign_in_with_apple, geolocator, image_picker, url_launcher, intl`.

### B.2 Funnel OTA inti — sudah utuh

- Auth + guest mode (browse tanpa login, gate saat checkout/AI) — `lib/ui/login/login_page.dart`, `lib/data/repo/auth_repository.dart`, `lib/route/approuter.dart`
- Home/Discover + Featured + Nearby GPS — `lib/ui/home/home_page.dart`, `lib/ui/hotels/featured_hotel_page.dart`, `lib/ui/hotels/nearby_hotel_page.dart`
- Search + filter amenities AND + sort + Recent + AI Pick — `lib/ui/search/search_results_page.dart`, `lib/viewmodel/search/hotel_search_cubit.dart`
- Hotel Detail (galeri, amenities, review section yang hidden bila API kosong — prinsip no-fake-data) — `lib/ui/hotels/detail_hotels_page.dart`, `lib/data/model/hotel_model.dart`
- Checkout 2-step + Midtrans Snap + polling + resume pending (`expiresAt` countdown) — `lib/ui/checkout/checkout_screen.dart`, `lib/ui/booking/booking_page.dart`, `lib/viewmodel/checkout|booking/`
- Reschedule/refund policy, invoice PDF, payment history + loyalty-points wallet — `lib/ui/payment/payment_history_screen.dart`
- Wishlist (guest-lokal + sync), Notifikasi FCM, Trip management (itinerary backend-owned), Group + Poll voting, Travel Tasks, bilingual + kurs — `lib/ui/groups|poll|trip|tasks|notification/`, `lib/utils/money.dart`

### B.3 AI — fondasi ada, kualitas belum teruji

- AI Chat Sasa (`POST /ai/chat`, sessionId, Agent Workflow) — `lib/ui/ai/ai_chat_screen.dart`, `lib/data/repo/ai_repository.dart:10-50`
- AI Smart Search (`POST /ai/search` → `SmartSearchResult`) — `lib/ui/ai/smart_search_screen.dart`
- AI Trip Planner (`POST /ai/trip-plan`) — `lib/ui/ai/trip_planner_screen.dart`, `lib/ui/ai/agent_trip_plan_result_screen.dart`
- Personalized recommendation pgvector (`GET /recommendations`) — `lib/data/repo/recommendation_repository.dart`
- Belum ada backend di repo ini (0 hits `backend/**/*`, tanpa `package.json`/Dockerfile); komentar FE merujuk `aiController.js` (Ollama llama3.1/qwen, `num_predict/topK`).

---

## BAGIAN C — Mapping 14 Fitur vs Status Sasacation

| # | Fitur | Status | Bukti / catatan |
|---|---|---|---|
| 1 | AI Hotel Search | 🟡 Parsial | `/ai/search` + smart screen ada; belum smart-filter/ranking/explanation sekelas Booking |
| 2 | AI Hotel Compare | 🔴 Belum | Nol kode compare |
| 3 | AI Property Expert | 🔴 Belum | Chat umum ada, Q&A kontekstual per-hotel belum |
| 4 | AI Review Summary | 🟡 Parsial | Model `HotelReview` + `_ReviewCard` siap, tapi backend belum kirim `reviews[]` |
| 5 | Personalized Recommendation | 🟡 Parsial | pgvector + AI Pick ada; belum ada Travel Profile eksplisit di UI |
| 6 | Group Trip Decision | 🟡 Parsial (pembeda) | Group + Poll/voting sudah ada; belum ada AI compromise engine |
| 7 | Search dari foto | 🔴 Belum | — |
| 8 | Map + Neighborhood | 🔴 Belum | Tanpa Map SDK; detail hanya placeholder; nearby hanya jarak km (`location_service.dart`) |
| 9 | AI Trip Planner | 🟢 Ada (perlu quality fix) | Fungsional tapi audit: tanggal 2023 + tema meleset; `tripPlan` chat hilang saat restore |
| 10 | Price Intelligence | 🔴 Belum | Tanpa price history |
| 11 | Price Alert | 🔴 Belum | `grep priceAlert` nol |
| 12 | Smart Check-in | 🔴 Belum | Check-in hanya field tanggal; satu-satunya `flight_checkin` hanya task card |
| 13 | Concierge in-trip | 🔴 Belum | — |
| 14 | Disruption Assistant | 🔴 Belum | — |

**Kesimpulan:** ~2 fungsional (search dasar, planner v1), ~4 parsial, ~8 belum ada. Lima prioritas yang dipilih tepat: 2 tinggal dimatangkan, 3 greenfield bernilai tinggi.

---

## BAGIAN D — Kelebihan vs Booking/Agoda/Traveloka + Gap Jujur

### Kelebihan Sasacation (posisi, bukan inventori)

1. **AI-first sejak awal, bukan tempelan.** `AiBloc` + agent workflow + smart-search + planner + pgvector sebagai warga kelas satu — fondasi "AI Travel OS".
2. **Group + Poll + Trip + Task satu atap.** OTA besar tidak punya ini terintegrasi (grup + gap banner, voting, itinerary backend-owned, tasks). Tambah AI compromise → pembeda fitur #6.
3. **Domestik-first yang jujur.** ID primer (505 key parity), urutan bayar QRIS→e-wallet→transfer→kartu→PayPal, Rp + estimasi, countdown pending, no-fake-data.
4. **Guest mode + auth ringan.** Browse tanpa login, wishlist lokal, Firebase → JWT. Friksi discovery rendah.
5. **Transaksi tetap milik sendiri.** Midtrans + invoice + reschedule/refund + loyalty — AI sebagai otak, Sasacation tempat transaksi terpercaya (sejalan riset Expedia 2026: ~70% traveler tetap pilih brand terpercaya untuk transaksi).

### Gap / utang P0 (dari `AUDIT_PO_2026-10-04.md`)

1. Transfer rupiah hidup di UI (`POST /wallet/transfer` USD, saldo selalu 0) — harusnya loyalty points; sembunyikan sampai `POST /loyalty/transfer` ada.
2. Tamu masih lihat USD (`GET /settings` butuh auth) — perlu endpoint kurs publik atau selipkan rate di respons hotel.
3. Kualitas AI planner belum diuji 10 query (tanggal 2023, tema meleset) — perlu tanggal relatif + uji mutu BE.
4. Nol analytics + crash reporting — semua optimasi buta tanpanya.
5. Tanpa review data → summary mati; tanpa price history → price intel/alert mati; tanpa Map SDK → neighborhood mati.

---

## BAGIAN E — Ringkasan Estimasi 5 Prioritas (MVP demo, 2 dev paralel)

| # | Fitur | BE | FE | Eval | Total | Kalender* |
|---|---|---|---|---|---|---|
| 1 | AI Hotel Search (matangkan) | 5–6 pd | 4–5 pd | 2 pd | 11–13 pd | ~6–7 hari |
| 2 | AI Review Summary | 5–6 pd | 3–4 pd | 1–2 pd | 9–12 pd | ~5–6 hari |
| 3 | AI Hotel Compare | 4–5 pd | 4–5 pd | 1–2 pd | 9–12 pd | ~5–6 hari |
| 4 | Traveler Profile | 3–4 pd | 3–4 pd | 1 pd | 7–9 pd | ~4–5 hari |
| 5 | Trip Planner (quality fix) | 4–5 pd | 2–3 pd | 2 pd | 8–10 pd | ~4–5 hari |

\* Kalender per fitur BE+FE paralel. Total program ~5–6 minggu. Critical path: 1 → 2 → 3 → 5 (4 paralel dengan 1).

```text
Minggu 1:   [1 Search BE+FE] ──paralel── [4 Profile BE+FE]
Minggu 2:   1 selesai/eval → [2 Summary BE] + [2 Summary FE]
Minggu 3:   [3 Compare BE+FE] (reuse summary #2 + profil #4)
Minggu 4-5: [5 Planner fix] + polish demo + eval 10-query + regression
```

---

## BAGIAN F — Rencana Pengembangan Sisi BE (detail per fitur)

### F.0 Kontrak existing (jangan diubah tanpa koordinasi FE)

- Base `:5001/api` via `lib/data/api/api_client.dart` (JWT Bearer, timeout AI 60–220s).
- `POST /ai/chat` (220s, sessionId + tripPlan) — `lib/data/repo/ai_repository.dart:10-50`
- `POST /ai/search` (60s) → `SmartSearchResult` — `ai_repository.dart:79-96`, `ai_model.dart:201-224`
- `POST /ai/trip-plan` (180s) — `ai_repository.dart:129-162`
- `GET /recommendations` (pgvector wishlist+history bila login) — `recommendation_repository.dart`
- `GET /hotels/:id` belum kirim `reviews[]`; kontrak ditunggu: `{id, user_name, avatar, rating, stayed, date, text}` — `hotel_model.dart:7-49`
- Search existing: amenities AND + sort server-side — `hotel_search_cubit.dart`

### F.1 AI Hotel Search — BE 5–6 pd (pertama)

**Goal:** *"staycation Jakarta weekend, 1,5jt, tenang, bathtub, dekat cafe, couple"* → interpretasi + ranking + alasan + chips tweakable.
1. NL → JSON terstruktur (2–3 pd): tambah parsing di `POST /ai/search`, schema `{maxPrice, city, amenities[], vibe[], tripType, dates{checkIn, nights}}`; tanggal relatif → konkret; tolak tahun basi; fallback `needsClarification` bila confidence rendah.
2. Hybrid retrieval + ranking (2 pd): filter SQL (price/city/amenities AND) + pgvector untuk vibe/deskripsi; `results[] += {score, explanation}` 1 kalimat grounding.
3. Cache + eval (1–2 pd): cache query populer TTL 1 jam; eval 20 query (typo, ID/EN campur, "murah/mewah", vibe abstrak).
- **Skema (bila belum ada, +1–2 pd):** `hotel_tags TEXT[]` atau `hotel_vibes(hotel_id, vibe)` untuk tenang/romantis/keluarga/nightlife. Tanpa ini LLM mengarang.
- FE: `smart_search_screen.dart`, `hotel_search_cubit.dart`.

### F.2 AI Review Summary — BE 5–6 pd (prasyarat Compare)

**Goal:** `⭐ 4.7 (2.381)` + disukai vs dikeluhkan + 1 baris personal.
1. Data review (1–2 pd + keputusan produk): baru `GET /hotels/:id/reviews?page&limit` sesuai kontrak FE; MVP demo boleh seed 30–50/hotel (labeli bila dummy — tanpa ini fitur mati).
2. Summarizer batch (3–4 pd): tabel `review_summaries(hotel_id PK, pros[], cons[], avg_rating, review_count, summary_text, updated_at)`; summarize 1x per hotel + re-run bila N review baru / >7 hari (**jangan per-request**, Ollama 120s+); baru `GET /hotels/:id/review-summary → {avgRating, count, pros[], cons[], summaryText, personalizedLine?}` (`personalizedLine` butuh profil F.4; null bila belum ada).
- FE: `detail_hotels_page.dart` (`_ReviewCard` kini hidden bila kosong).

### F.3 AI Hotel Compare — BE 4–5 pd

**Goal:** tabel A vs B vs C (harga, lokasi, kamar, breakfast, pool, couple-fit, value) + verdict 2–3 kalimat.
1. Baru `POST /ai/compare {hotelIds[2..3], profileId?}` → `{matrix[], verdict, tradeoffs[]}` (contoh matrix: `{hotelId, price, locationScore, roomScore, breakfast, pool, coupleFit, value}`).
2. **Wajib grounding:** skor dari DB + `review_summaries`; LLM hanya untuk `verdict`/`tradeoffs`. Reuse cache summary (hemat 3x LLM call).
3. Eval 10 kombinasi: cek halusinasi skor + konsistensi verdict vs profil.
- Tergantung F.2 + sebagian F.4.

### F.4 Traveler Profile — BE 3–4 pd (paralel dengan F.1)

**Goal:** "Profil Travel Guntur" + home "Paling cocok untuk kamu" + edit manual.
1. Baru `GET/PUT /preferences → {travelStyles[], budgetTier, tripTypes[], amenityPrefs[], locationPrefs[]}` (2 pd).
2. Derivasi otomatis (1–2 pd): wishlist + history → query pgvector (reuse `/recommendations`); selipkan `profile` ke response `/recommendations` dan `/ai/search`.
- FE: kartu profil + kuis onboarding 5 pertanyaan.

### F.5 Trip Planner Quality Fix — BE 4–5 pd

**Goal:** 10 query lolos (tanggal benar, budget konsisten, `itemId` valid); hasil chat persisten setelah restart.
1. Prompt/composer (2–3 pd): `startDate` relatif → konkret; validasi `totalEstimatedCost ≈ sum(dailyCost)`; tambah kolom persistensi (keterbatasan v1 di `ai_model.dart:152-160`):
   ```sql
   ALTER TABLE chat_messages ADD COLUMN trip_plan JSONB NULL;
   ```
   Sertakan di `GET /chat/sessions/latest`.
2. Eval harness 10 query + regression tiap ganti prompt/`num_predict`/`topK` (2 pd). Jangan naikkan timeout (180–220s) — kecilkan `num_predict/topK` / pecah composer. Streaming/SSE di luar MVP (+~2 minggu).
- FE: `trip_planner_screen.dart`, `agent_trip_plan_result_screen.dart`, `ai_chat_screen.dart`.

### F.6 Risiko BE (ranking)

1. Latensi Ollama 60–220s → cache + batch + prompt ramping.
2. Taksonomi vibe butuh kolom/tag baru.
3. Sumber review riil vs dummy — putuskan sebelum F.2.
4. Kurs publik guest — endpoint publik atau selipkan `pricing.fx`.
5. Tanpa analytics — eval harness wajib di tiap fitur.

### F.7 Di luar MVP (tambah estimasi bila production)

Map SDK + neighborhood, price history/alert, smart check-in/key, concierge, disruption, search foto, streaming AI, guest USD publik, analytics/crash reporting.
