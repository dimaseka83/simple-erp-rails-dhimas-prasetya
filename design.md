# Design.md — simple-erp

Dokumen ini adalah rujukan desain sebelum ngoding UI baru. Tujuannya: setiap halaman terasa
dibuat khusus untuk app inventory/procurement/sales ini, bukan template generik.

## 1. Subjek & Audiens

- **Subjek**: ERP sederhana untuk UMKM trader — alur beli-stok-jual (Purchase Order → Inventory → Sales Order).
- **Audiens utama**: staff gudang/admin toko yang kerja cepat, banyak angka, banyak input harian. Bukan orang yang "menikmati" tampilan, tapi butuh cepat baca status & angka.
- **Audiens sekunder (portofolio)**: recruiter/klien yang demo dalam 30 detik — harus langsung kelihatan "ini software kerja beneran", bukan landing page marketing.
- **Pekerjaan utama desain**: bikin data (stok, status PO/SO, angka) gampang dipindai mata, bukan bikin halaman "cantik" yang kosong.

## 2. Palet Warna

Hindari cream #F4F1EA + aksen terracotta #D97757 (default AI). Ground dari dunia gudang/ledger:

| Token | Hex | Pemakaian |
|---|---|---|
| `--bg` | #F5F6F5 | Background utama, abu-putih netral (bukan cream) |
| `--surface` | #FFFFFF | Card/table surface |
| `--ink` | #1E2A2F | Teks utama, dark slate (bukan hitam pekat / near-black generik) |
| `--ink-muted` | #5C6B70 | Teks sekunder, label |
| `--line` | #D8DDDD | Border, divider |
| `--accent` | #2F6F5E | Aksen utama — hijau tua kepetian, asosiasi "stok aman/tersedia" |
| `--warn` | #B5772E | Stok rendah / PO pending — amber gudang, bukan oranye terracotta terang |
| `--danger` | #B23A34 | Stok habis / SO gagal — merah bata, bukan merah alert generik |

Prinsip: warna status (aman/rendah/habis) itu bagian dari *informasi*, bukan dekorasi — dipakai konsisten di badge, angka stok, dan grafik dashboard.

## 3. Tipografi

Bukan kombinasi serif-display + sans generik. Karena app ini padat kode (SKU) dan angka:

- **UI/body**: IBM Plex Sans — netral, jelas dibaca padat, tidak terkesan "branding kece"
- **Angka & kode**: IBM Plex Mono — dipakai khusus untuk SKU, harga, qty, nomor PO/SO. Tabular figures bikin kolom angka rapi sejajar (penting untuk tabel inventory)
- Satu ukuran heading yang tegas untuk judul halaman (misal "Inventory"), sisanya body text konsisten — jangan bikin banyak level heading dekoratif

## 4. Layout

Alur kerja gudang/admin itu **tabel dan form**, bukan kartu grid ala SaaS marketing:

```
[Sidebar nav tetap]  [Header halaman + action button kanan]
                      [Filter/search bar tipis]
                      [Tabel data padat, baris jelas, kolom angka rata kanan]
                      [Pagination sederhana bawah]
```

- Sidebar kiri untuk navigasi modul (Inventory, Procurement, Sales, Dashboard) — tetap terlihat, bukan hamburger tersembunyi
- Tabel adalah komponen utama, bukan card. Card cuma dipakai untuk ringkasan angka di Dashboard
- Border-radius kecil (4px) di semua elemen — kesan software fungsional, bukan rounded-pill ala mobile app konsumen
- Rata kiri untuk teks, rata kanan untuk kolom angka (harga, qty, stok) — standar akuntansi, bukan estetika

## 5. Komponen Kunci

- **Status badge** (Draft/Ordered/Received, atau Pending/Confirmed): kotak kecil border-radius 4px, warna dari token status di atas, teks singkat huruf biasa (bukan ALL CAPS)
- **Angka stok**: selalu pakai font mono, warna berubah otomatis sesuai threshold (aman/rendah/habis) — ini pengganti badge yang lebih halus
- **Tombol aksi utama** satu warna aksen konsisten (misal "Buat PO", "Konfirmasi SO"), tombol sekunder outline saja

## 6a. Light Mode & Dark Mode

Jangan cuma invert warna section 2 secara matematis (bg jadi hitam, teks jadi putih) — itu yang bikin dark mode kelihatan tempelan. Geser lightness & saturation-nya biar tetap enak dibaca:

| Token | Light | Dark |
|---|---|---|
| `--bg` | #F5F6F5 | #14181A |
| `--surface` | #FFFFFF | #1D2224 |
| `--ink` | #1E2A2F | #E7EAEA |
| `--ink-muted` | #5C6B70 | #93A0A3 |
| `--line` | #D8DDDD | #2B3335 |
| `--accent` | #2F6F5E | #4C9C82 *(dinaikkan lightness-nya, versi gelap dari accent kalau dipertahankan sama persis akan low-contrast di background gelap)* |
| `--warn` | #B5772E | #D99145 |
| `--danger` | #B23A34 | #D65F58 |

Aturan: `--bg-dark` bukan hitam pekat (#000/#0B0B0B) — itu salah satu tanda paling gampang ketahuan generic/AI. Pakai ink gelap yang sedikit ke abu-biru (#14181A) supaya card & border masih kebaca kontrasnya.

Toggle light/dark taruh di header, ikon simpel (bukan animasi switch yang berlebihan), dan preferensi disimpan (localStorage/cookie) supaya persist antar sesi.

## 6b. Kenapa (dan bagaimana) ini beda dari Metronic

Metronic instan dikenali dari pola-pola ini — kalau app-mu masih punya salah satu, orang yang pernah lihat Metronic bakal langsung notice:

- **Font Inter/Poppins** → app ini pakai IBM Plex Sans/Mono (section 3), sudah beda dari awal
- **KPI card grid dengan icon bulat berwarna-warni** (biru/ungu/oranye) di Dashboard → ganti jadi angka besar + sparkline kecil, tanpa icon-in-circle, warna cuma dari token status (accent/warn/danger), bukan palet warna-warni bebas per card
- **Sidebar dua-tingkat (menu + submenu berjenjang) dengan banyak icon generic** → sidebar app ini flat, cuma 4 modul utama (Inventory/Procurement/Sales/Dashboard), tanpa submenu bertingkat
- **Navbar atas dengan search bar di tengah + notification bell + avatar dropdown** → search taruh di dalam masing-masing halaman tabel (contextual, bukan global search bar), skip notification bell kalau memang belum ada fitur notifikasi beneran
- **Badge status warna-warni generik** (biru=info, ungu=custom, dst) → badge di app ini cuma 3 warna semantik (aman/rendah/habis), konsisten dengan makna bisnis, bukan estetika bebas
- **Shadow lembut + border-radius besar di semua card** → radius kecil (4px), shadow nyaris tidak ada, garis tipis (`--line`) sebagai pemisah — lebih terasa "alat kerja", bukan "dashboard SaaS kece"

Prinsip umumnya: ambil dari Metronic *strukturnya* yang memang teruji (sidebar + topbar + tabel data), tapi ganti *bahasa visualnya* (font, warna, radius, kepadatan) dengan yang di-ground dari konteks ERP UMKM-mu sendiri, bukan dari referensi visual dashboard SaaS pada umumnya.

## 6. Motion

Minim. Hanya animasikan **perubahan state nyata**:
- Baris tabel highlight sebentar saat status PO berubah jadi "Received" (menunjukkan stok baru saja bertambah)
- Toast konfirmasi muncul-hilang halus saat SO disimpan

Tidak ada fade-slide-up di setiap section saat scroll, tidak ada hover animation di semua card — itu tanda paling gampang ketahuan generic AI design.

## 7. Bahasa UI (microcopy)

- Bahasa Indonesia, aktif, spesifik: "Stok tidak cukup" bukan "Terjadi kesalahan"
- Tombol menyebut aksi persis: "Simpan PO", bukan "Submit"
- Empty state mengarahkan aksi: "Belum ada produk. Tambah produk pertama →" bukan sekadar "Data kosong"

## 8. Yang harus dihindari (checklist sebelum push UI baru)

- [ ] Tidak pakai background cream + aksen terracotta
- [ ] Tidak semua card punya shadow abu-abu + border-radius sama rata
- [ ] Tidak ada label ALL CAPS di atas tiap heading
- [ ] Tidak ada angka bergaya "01 / 02 / 03" kecuali memang urutan proses (misal step PO: Draft→Ordered→Received, ini SAH karena memang sequence)
- [ ] Tidak setiap section punya animasi fade-in saat scroll
