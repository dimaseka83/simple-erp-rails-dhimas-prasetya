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
- **1 controller = 1 Service/Manager class.** Semua action di controller yang sama (create, update, destroy, dst) masuk ke satu file service yang sama, sebagai method berbeda — bukan bikin service terpisah per action.
  - Contoh: `PurchaseOrdersController` → `app/services/purchase_order_manager.rb` dengan method `create(params)`, `update(po, params)`, `receive(po)`, dst — semua di satu class.
- Namespace per domain kalau perlu, contoh: `app/services/procurement/purchase_order_manager.rb` untuk `Procurement::PurchaseOrdersController`.
- Konvensi: controller panggil `PurchaseOrderManager.new.create(params)` atau method yang sesuai action.
- Return value konsisten — pakai object hasil sederhana (misal `OpenStruct.new(success:, record:, errors:)`) supaya controller gampang cek hasilnya.

### 3. Controller (`app/controllers/`)
- Hanya boleh: terima params, panggil SATU service, redirect/render berdasarkan hasil service.
- TIDAK BOLEH ada query ActiveRecord langsung untuk write (create/update/destroy).
- Query read sederhana (`Model.find`, `Model.where(...)` untuk index/show) masih boleh di controller SELAMA tidak ada logic bisnis di dalamnya. Query kompleks tetap pindah ke Query Object atau Service.

### 4. Presenter (`app/presenters/`)
- Semua logic tampilan (formatting angka/tanggal, kondisi tampil-tidak elemen, label status, dsb) taruh di sini.
- **Berbeda dari Service/Manager: presenter BOLEH lebih dari satu file per controller**, dipecah per action/view kalau kebutuhan tampilannya beda jauh.
  - Contoh: `PurchaseOrdersController` bisa punya `app/presenters/purchase_order_index_presenter.rb` (untuk list/index) dan `app/presenters/purchase_order_form_presenter.rb` (untuk create/edit form) — dipisah karena data & logic yang dibutuhkan beda.
  - Kalau logic tampilan index & form/show cukup mirip, boleh digabung jadi satu `app/presenters/purchase_order_presenter.rb` — pecah hanya kalau memang beda kebutuhan (YAGNI, jangan pecah dari awal kalau belum perlu).
- Presenter menerima model/data di constructor, expose method yang dipanggil langsung dari view.
- **Controller assign SATU instance variable `@presenter` (bukan banyak variable terpisah per data).** HAML memanggil method dari `@presenter` itu, bukan memanggil class presenter langsung dengan `self`/params sebagai argumen.

  **Salah** (manggil class presenter langsung di HAML, `self` sebagai argumen):
  ```haml
  = StockMovementPresenter.type_options(self)
  ```

  **Salah juga** (instance variable kebanyakan, satu per data):
  ```ruby
  # controller
  @movement_type_options = StockMovementPresenter.new(@movement).type_options
  @movement_status_label = StockMovementPresenter.new(@movement).status_label
  ```

  **Benar** (satu `@presenter`, HAML panggil method-nya):
  ```ruby
  # controller
  def new
    @movement = StockMovement.new
    @presenter = StockMovementPresenter.new(@movement)
  end
  ```
  ```haml
  = f.select :movement_type, @presenter.type_options
  %span= @presenter.status_label
  ```
- Method di presenter tetap dinamai jelas sesuai isinya (`type_options`, `status_label`, `formatted_total`) — lihat aturan Penamaan.

### 5. HAML (`app/views/`)
- Pure HTML + pemanggilan method dari `@presenter` (lihat aturan Presenter di atas). TIDAK BOLEH ada:
  - Pemanggilan class presenter langsung di HAML (`= SomePresenter.method(...)` atau `SomePresenter.new(...).method`) — harus lewat `@presenter` yang sudah di-assign controller
  - `if/else` untuk logic bisnis (boleh untuk struktur HTML sederhana seperti render partial kondisional)
  - kalkulasi atau formatting manual (`number_to_currency` dsb dipanggil dari presenter, bukan langsung di view)
  - query database langsung dari view
- Kalau ketemu logic yang "ribet" di HAML, itu tanda harus dipindah jadi method baru di Presenter, dipanggil lewat `@presenter.method_baru`.

## CSS Class Naming

- HAML TIDAK BOLEH pakai utility class Tailwind mentah langsung di elemen (`class="bg-blue-500 px-4 py-2 rounded"`). Itu bikin style tersebar di banyak file dan susah reusable/maintain.
- Semua elemen pakai nama class semantik sesuai fungsinya, contoh:
  ```haml
  .alert-notice
  .btn-primary
  .stock-badge--low
  ```
- Utility Tailwind tetap dipakai, tapi di-compose satu kali di file CSS pakai `@apply`, bukan ditulis berulang di tiap HAML:
  ```css
  /* app/assets/stylesheets/components/_alert.css */
  .alert-notice {
    @apply bg-blue-50 text-blue-800 border border-blue-200 rounded px-4 py-3;
  }
  ```
- Penamaan class ikuti BEM sederhana: `.block`, `.block__element`, `.block--modifier` — contoh `.stock-badge`, `.stock-badge--low`, `.stock-badge--out`.
- Kalau sebuah kombinasi utility dipakai 2+ kali di file berbeda, itu tanda harus diekstrak jadi class semantik baru (prinsip DRY berlaku juga di CSS).

## Penamaan (naming convention)

- Semua nama file, class, method, variable, dan key locale WAJIB Bahasa Inggris — konsisten dengan konvensi Ruby/Rails community, jangan campur Bahasa Indonesia (misal jangan `def buat_po`, harus `def create_purchase_order`).
- Nama method harus jelas dan spesifik sesuai fungsinya, hindari nama ambigu atau generik:
  - **Salah**: `process`, `handle`, `do_stuff`, `check`, `update_data`
  - **Benar**: `receive_purchase_order`, `calculate_available_stock`, `validate_sufficient_stock`, `mark_as_confirmed`
- Method boolean/predicate diawali `is_`/`has_`/berakhiran `?` sesuai konteks: `sufficient_stock?`, `fully_received?` — bukan `check_stock` yang gak jelas return-nya apa.
- Nama variable instance dari presenter deskriptif sesuai isinya (lihat aturan Presenter), bukan generik seperti `@data`, `@result`, `@presenter`.
- Nama service/manager method sesuai action bisnisnya, bukan CRUD generik polos: lebih baik `confirm(sales_order)` atau `mark_as_confirmed(sales_order)` daripada `update(sales_order, params)` kalau memang maksudnya spesifik satu aksi bisnis (tapi untuk CRUD standar seperti create/update murni, nama `create`/`update` tetap boleh dipakai — yang penting konsisten satu pola dalam satu service).

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
- [ ] Semua formatting/kondisi tampilan ada di Presenter, dipanggil lewat satu `@presenter` di HAML (bukan banyak instance variable atau manggil class presenter langsung)
- [ ] HAML tidak ada logic bisnis atau kalkulasi manual
- [ ] Tidak ada logic/kode yang terduplikasi (DRY)
- [ ] Tidak ada abstraksi/field/opsi yang belum dibutuhkan sekarang (YAGNI)
- [ ] Query yang load association di loop sudah pakai `includes`/`preload` (no N+1)
- [ ] Semua teks user-facing pakai `I18n.t`, key locale dicek dulu supaya tidak duplikat

## Referensi desain UI

Untuk styling/UI, ikuti `design.md` di root project ini — token warna, tipografi, dan prinsip layout sudah didefinisikan di sana, jangan generate ulang gaya generic.
