# Simple ERP (Rails)

A compact ERP built with Ruby on Rails as a portfolio project. It covers the core back-office loop of a small trading business: **manage products → buy from suppliers → sell to customers → track stock**.

**Live demo:** https://simple-erp-dhimas-prasetya.netlify.app/

## Features

- **Dashboard** – at-a-glance business overview with charts (ApexCharts).
- **Inventory** – products (SKU, category, unit, cost/selling price), categories, and a full stock movement history (in/out).
- **Procurement** – suppliers and purchase orders with a `draft → ordered → received` workflow. Receiving a PO adds stock.
- **Sales** – customers and sales orders with a `draft → confirmed` workflow, plus a printable invoice. Confirming an order deducts stock.
- **Settings** – currency (IDR / USD / EUR).
- **i18n** – English and Indonesian, switchable at runtime.
- **Authentication** – session-based login and password reset (Rails 8 built-in authentication).

## Tech Stack

| Layer | Choice |
|-------|--------|
| Framework | Rails 8.1, Ruby 4.0 |
| Database | MySQL |
| Views | HAML with a presenter layer (`app/presenters`) |
| Frontend | Vite (`vite_rails`), Tailwind CSS 4, Vue 3, ApexCharts |
| Assets | Propshaft |
| Background / cache / cable | Solid Queue, Solid Cache, Solid Cable |
| Deployment tooling | Docker, Kamal, Thruster |
| Quality | Minitest, Brakeman, bundler-audit, RuboCop (omakase) |

## Architecture Notes

- **Presenters, not view logic** – each resource has a presenter that prepares data for its view, keeping `.haml` templates free of logic.
- **State enums** – order status, movement type, product unit and currency are model enums with validation.
- **Stock integrity** – stock movements require a positive quantity and product stock cannot go negative.

## Getting Started

### Prerequisites

- Ruby 4.0.6 (see `.ruby-version` / `mise.toml`)
- Node.js and npm
- MySQL

### Setup

```bash
bundle install
npm install
bin/rails db:setup      # creates the database, loads the schema and seed data
bin/dev                 # starts Rails and the Vite dev server (Procfile.dev)
```

Open http://localhost:3000.

### Demo login (seed data)

```
Email:    admin@simple-erp.test
Password: password123
```

The seed also creates sample categories, a supplier, a customer and a few products.

### Tests and checks

```bash
bin/rails test
bin/brakeman
bin/bundler-audit
bin/rubocop
```

## Author

Dhimas Prasetya
