# Janza Bet

A personal sports betting bankroll manager built with Rails 8. Track your books, bets, deposits, withdrawals, and daily balances — all in one place, with cumulative profit charts to keep you honest.

---

## What it does

| Feature | Description |
|---|---|
| **Books** | Each betting account (Bet365, Betfair, etc.) is a "book". Track its balance over time. |
| **Bets** | Log individual bets with stake, odd, status and tipster. Profit/loss is calculated automatically. |
| **Transactions** | Record deposits and withdrawals per book. |
| **Daily Balances** | Snapshot your total balance each day across all books. |
| **Monthly Bank** | Monthly bankroll overview with cumulative profit chart and cash-in-hand calculation. |
| **Tipsters** | Manage tipsters and associate bets with them for performance tracking. |

---

## Tech stack

- **Ruby** 3.4.2 / **Rails** 8.0.2
- **MySQL** — primary database
- **Hotwire** (Turbo + Stimulus) — SPA-like UX without a JS framework
- **Tailwind CSS** — utility-first styling via importmap (no webpack)
- **Chartkick + Chart.js** — cumulative profit charts
- **Kaminari** — pagination
- **SolidCache / SolidQueue / SolidCable** — Rails 8 database-backed adapters (no Redis needed)
- **bcrypt** + Rails 8 Authentication Generator — session-based auth with email confirmation
- **Kamal** — deployment
- **RSpec + FactoryBot + Guard** — test suite
- **RuboCop + Brakeman** — linting and security scanning

---

## Getting started

### Prerequisites

- Ruby 3.4.2 (`rbenv install 3.4.2` or `rvm install 3.4.2`)
- MySQL 5.6.4+
- Bundler (`gem install bundler`)

### 1. Clone and install dependencies

```bash
git clone <repo-url>
cd janza-bet
bundle install
```

### 2. Configure environment variables

The app reads database credentials from environment variables. Copy the example below into your shell profile or a `.env` file (with a tool like `direnv`):

```bash
export MYSQLUSER=your_mysql_user
export MYSQLPASSWORD=your_mysql_password
export MYSQLHOST=127.0.0.1
export MYSQLPORT=3306
export DB_NAME=janza_bet_development
```

### 3. Set up the database

```bash
bin/rails db:create db:schema:load
```

### 4. Start the development server

```bash
bin/dev
```

This starts both the Rails server and the Tailwind CSS watcher via `Procfile.dev`.

The app will be available at `http://localhost:3000`.

---

## How to use

1. **Register** an account and confirm your email.
2. **Create books** — one per betting account you hold.
3. **Record transactions** — add deposits and withdrawals as they happen.
4. **Log bets** — with stake, odd and tipster. The result is calculated on save:

| Status | Result formula |
|---|---|
| Won | `stake × odd` |
| Lost | `0` |
| Void | `stake` (returned) |
| Half Won | `stake + (stake × (odd − 1) / 2)` |
| Half Lost | `stake / 2` |

5. **Enter daily balances** — log the balance of each book at the end of the day.
6. **Check your bank** — the monthly bank screen shows deposits, withdrawals, current balance and a cumulative profit chart.

---

## Running the tests

```bash
bundle exec rspec
```

To run tests automatically on file changes:

```bash
bundle exec guard
```

To run the security scanner:

```bash
bundle exec brakeman
```

To run the linter:

```bash
bundle exec rubocop
```

---

## Domain model

```
User
 ├── Books (betting accounts)
 │    ├── Transactions (deposits / withdrawals)
 │    └── DailyBalances (date → balance snapshot)
 ├── Bets (belongs to Book and optional Tipster)
 └── Banks (monthly bankroll records)

Tipsters (global — not scoped per user)
```

---

## Project structure

```
app/
  controllers/     # One controller per resource, all scoped to current_user
  models/          # ActiveRecord models with validations and business logic
  views/           # ERB templates + Turbo Stream partials
  javascript/      # Stimulus controllers via importmap
config/
  routes.rb        # RESTful resources + nested books/transactions
db/
  schema.rb        # Source of truth for the database schema
  migrate/         # Incremental migrations
spec/
  models/          # Model unit tests
  requests/        # Controller integration tests
  factories/       # FactoryBot definitions
```

---

## Deployment

The app is configured for deployment with [Kamal](https://kamal-deploy.org). Review `config/deploy.yml` and `.kamal/secrets` before deploying.

```bash
kamal deploy
```

---

## License

[Mozilla Public License 2.0](LICENSE)
