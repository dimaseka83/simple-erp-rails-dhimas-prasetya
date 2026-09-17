# simple-erp — Architecture Rules

Project ini WAJIB mengikuti alur arsitektur berikut untuk setiap fitur baru. Jangan menyimpang
dari urutan ini kecuali diminta eksplisit.

## Alur wajib

```
Model/DB → Service/Manager → Controller → Presenter → HAML (pure HTML)
```

## Aturan per layer

### 1. Model (`app/models/`)
- Minim logic. Isi hanya: association, validation, scope sederhana, dan `enum`.
- TIDAK boleh ada business logic multi-step, kalkulasi kompleks, atau logic yang melibatkan model lain secara aktif (memanggil `.save` model lain, dsb).
- Kalau sebuah method model mulai butuh tahu tentang proses bisnis (bukan cuma data), pindahkan ke Service.

### 2. Service / Manager (`app/services/`)
- Semua business logic dan write ke database (create/update/destroy) lewat sini — controller TIDAK BOLEH panggil `Model.create`/`.save`/`.update` langsung.
- Satu class = satu tanggung jawab. Namespace per domain, contoh:
  - `app/services/inventory/adjust_stock.rb`
  - `app/services/procurement/receive_purchase_order.rb`
  - `app/services/sales/confirm_sales_order.rb`
- Konvensi: class dengan method `call`, dipanggil `Namespace::ActionName.new(params).call`.
- Return value konsisten — pakai object hasil sederhana (misal `OpenStruct.new(success:, record:, errors:)`) supaya controller gampang cek hasilnya.

### 3. Controller (`app/controllers/`)
- Hanya boleh: terima params, panggil SATU service, redirect/render berdasarkan hasil service.
- TIDAK BOLEH ada query ActiveRecord langsung untuk write (create/update/destroy).
- Query read sederhana (`Model.find`, `Model.where(...)` untuk index/show) masih boleh di controller SELAMA tidak ada logic bisnis di dalamnya. Query kompleks tetap pindah ke Query Object atau Service.

### 4. Presenter (`app/presenters/`)
- Semua logic tampilan (formatting angka/tanggal, kondisi tampil-tidak elemen, label status, dsb) taruh di sini.
- Satu presenter per resource utama, contoh: `app/presenters/product_presenter.rb`, `app/presenters/purchase_order_presenter.rb`.
- Presenter menerima model/data di constructor, expose method yang dipanggil langsung dari view.

### 5. HAML (`app/views/`)
- Pure HTML + pemanggilan method presenter. TIDAK BOLEH ada:
  - `if/else` untuk logic bisnis (boleh untuk struktur HTML sederhana seperti render partial kondisional)
  - kalkulasi atau formatting manual (`number_to_currency` dsb dipanggil dari presenter, bukan langsung di view)
  - query database langsung dari view
- Kalau ketemu logic yang "ribet" di HAML, itu tanda harus dipindah ke Presenter.

## Prinsip tambahan (wajib di semua layer)

### DRY (Don't Repeat Yourself)
- Sebelum menulis kode baru, cek dulu apakah sudah ada method/partial/helper/service yang melakukan hal serupa — reuse, jangan duplikat.
- Logic yang muncul di 2+ tempat (misal validasi format SKU, kalkulasi subtotal) harus diekstrak ke satu tempat (concern untuk model, method shared di service, partial untuk view).

### YAGNI (You Aren't Gonna Need It)
- Jangan bikin abstraksi, opsi konfigurasi, atau field database "buat jaga-jaga di masa depan" kalau belum ada kebutuhan nyata sekarang.
- Kalau ragu antara solusi sederhana vs generic/fleksibel, pilih yang sederhana dulu sesuai kebutuhan MVP saat ini.

### Hindari N+1 Query
- Setiap kali me-load association di loop (index page, presenter yang iterasi record), WAJIB pakai `includes`/`preload`/`eager_load` di query awal (biasanya di controller atau query object), bukan lazy-load per baris.
- Contoh: `PurchaseOrder.includes(:supplier, :purchase_order_items).all`, bukan `PurchaseOrder.all` lalu akses `po.supplier.name` di view/presenter tanpa eager load.
- Kalau memungkinkan, cek query dengan `bullet` gem atau log SQL development untuk verifikasi tidak ada N+1 sebelum dianggap selesai.

### Localization (i18n)
- Semua teks yang tampil ke user (label, pesan error, status, button) HARUS lewat `I18n.t` / `t()`, tidak boleh hardcode string di view/presenter/service.
- Sebelum menambah key baru di `config/locales/id.yml` (atau file locale lain), WAJIB cek dulu apakah key dengan makna serupa sudah ada — jangan bikin duplikat (misal jangan ada `status.draft` dan `po.status_draft` dengan isi sama).
- Kalau file locale untuk suatu namespace belum ada, buat baru dengan struktur konsisten mengikuti yang sudah ada (nested by model/feature, bukan flat semua di root).
- Struktur locale yang konsisten, contoh:
  ```yaml
  id:
    activerecord:
      attributes:
        product:
          name: "Nama Produk"
    purchase_order:
      status:
        draft: "Draft"
        ordered: "Dipesan"
        received: "Diterima"
  ```

## Checklist sebelum commit fitur baru

- [ ] Model cuma berisi association/validation/scope
- [ ] Semua write ke DB lewat Service, bukan langsung dari Controller
- [ ] Controller cuma manggil 1 service + render/redirect
- [ ] Semua formatting/kondisi tampilan ada di Presenter, bukan di HAML
- [ ] HAML tidak ada logic bisnis atau kalkulasi manual
- [ ] Tidak ada logic/kode yang terduplikasi (DRY)
- [ ] Tidak ada abstraksi/field/opsi yang belum dibutuhkan sekarang (YAGNI)
- [ ] Query yang load association di loop sudah pakai `includes`/`preload` (no N+1)
- [ ] Semua teks user-facing pakai `I18n.t`, key locale dicek dulu supaya tidak duplikat

## Referensi desain UI

Untuk styling/UI, ikuti `design.md` di root project ini — token warna, tipografi, dan prinsip layout sudah didefinisikan di sana, jangan generate ulang gaya generic.
