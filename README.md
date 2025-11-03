# BloodLink API

An API backend built with Laravel 12 (PHP 8.2) for managing blood donation requests and donations. This repository also contains a sibling smart contracts workspace under `bloodlink-contracts` using Hardhat 3, TypeScript, and OpenZeppelin.

This README consolidates project setup, scripts, environment variables, and how to run tests for both the Laravel API and the contracts package.

## Overview

- REST API exposing user, donation request, and donation endpoints (see Routes below)
- Laravel 12 application (Composer-managed)
- Optional frontend asset pipeline with Vite (via `laravel-vite-plugin`)
- Ethereum smart contracts and tests in `bloodlink-contracts` (Hardhat 3 + viem)

## Tech Stack

- Language: PHP 8.2+
- Framework: Laravel 12
- Package manager (backend): Composer
- Build tooling: Vite (configured), Tailwind CSS plugin (via `@tailwindcss/vite`)
- Authentication packages present: Laravel Passport, Laravel Sanctum
- Blockchain client: web3p/web3.php (PHP) and viem (TypeScript) in contracts workspace
- Contracts workspace: Hardhat 3, TypeScript, OpenZeppelin Contracts

## Requirements

- PHP 8.2+
- Composer 2.x
- SQLite/MySQL/PostgreSQL (choose one and configure .env)
- Node.js 18+ and a Node package manager (npm, pnpm, or yarn) — required for assets/Vite and for `bloodlink-contracts`

## Project Structure (partial)

- app/ — Laravel application code
- routes/
  - api.php — API routes (versioned under `/api/v1`)
  - web.php — Web routes
- resources/ — Frontend assets (Vite inputs at `resources/css/app.css` and `resources/js/app.js`)
- public/ — Public webroot (entry point `public/index.php`)
- database/ — Migrations, seeders, factories
- tests/ — PHP unit/feature tests
- bloodlink-contracts/ — Hardhat workspace for Solidity contracts and tests
- composer.json — PHP dependencies and Composer scripts
- vite.config.js — Vite configuration for the Laravel app

## Routes (API v1)

Defined in `routes/api.php`:
- POST /api/v1/users/register — register a user
- GET /api/v1/users/{id} — get user details
- PUT /api/v1/users/{id}/wallet — update a user's wallet address
- GET /api/v1/donation-requests — list donation requests
- POST /api/v1/donation-requests — create a donation request
- PUT /api/v1/donation-requests/{id}/blockchain — update blockchain hash for a donation request
- POST /api/v1/donations — create a donation
- GET /api/v1/donations/user/{userId} — list donations for a user

## Setup (Backend API)

1. Clone the repo and enter the directory.
2. Copy environment file and generate key:
   - cp .env.example .env
   - php artisan key:generate
3. Install dependencies:
   - composer install
4. Configure your database in `.env` (see Environment Variables below).
5. Run migrations:
   - php artisan migrate
6. Optionally install/build assets (Vite):
   - npm install
   - npm run dev (for development) or npm run build (for production)
7. Start the development server:
   - php artisan serve

You can also use the provided Composer scripts (see Scripts section) to speed up setup and dev.

## Scripts

Composer scripts defined in `composer.json`:
- composer run setup
  - composer install
  - copies .env if missing, generates APP_KEY
  - php artisan migrate --force
  - npm install
  - npm run build
- composer run dev
  - Disables Composer process timeout
  - Runs concurrently:
    - php artisan serve
    - php artisan queue:listen --tries=1
    - php artisan pail --timeout=0 (log viewer)
    - npm run dev (Vite)
- composer run test
  - php artisan config:clear --ansi
  - php artisan test

Note: npm scripts are referenced but a root `package.json` is not present in the repo at the time of writing. See TODOs below.

## Environment Variables

Common Laravel variables to set in `.env` (non-exhaustive):
- APP_NAME, APP_ENV, APP_KEY, APP_DEBUG, APP_URL
- LOG_CHANNEL
- DB_CONNECTION, DB_HOST, DB_PORT, DB_DATABASE, DB_USERNAME, DB_PASSWORD
- CACHE_DRIVER, QUEUE_CONNECTION, SESSION_DRIVER, SESSION_LIFETIME

Project-specific hints:
- Authentication: Both Laravel Passport and Sanctum are required in composer.json. Configure only what you actually use.
  - TODO: Document whether Passport or Sanctum is used for API auth, and provide setup steps (e.g., php artisan passport:install) if applicable.
- Blockchain:
  - PHP package `web3p/web3.php` is included.
  - TODO: Document required chain RPC URL(s), private keys, and any contract addresses or network IDs used by the API (e.g., ETH_RPC_URL, CHAIN_ID, CONTRACT_ADDRESS, etc.).

## Running Tests (Backend)

- PHP tests: composer run test or php artisan test

## Contracts Workspace (bloodlink-contracts)

- Stack: Hardhat 3, TypeScript, viem, OpenZeppelin
- Config: see `bloodlink-contracts/hardhat.config.ts`
- Usage examples are included in `bloodlink-contracts/README.md`

Quick start:
1. cd bloodlink-contracts
2. npm install
3. npx hardhat test

Example deployments (from the contracts README):
- npx hardhat ignition deploy ignition/modules/Counter.ts
- npx hardhat ignition deploy --network sepolia ignition/modules/Counter.ts

Environment/config for deployments:
- Set SEPOLIA_PRIVATE_KEY via `npx hardhat keystore set SEPOLIA_PRIVATE_KEY` or as an env var.

## Development

- Code style: Laravel Pint is included (dev dependency). Run with `./vendor/bin/pint`.
- Local logs: `php artisan pail` (used in dev script).
- Queues: `php artisan queue:listen` (auto-run by `composer run dev`).

## Project Status & TODOs

- TODO: Add/commit a root package.json with Vite scripts (`dev`, `build`) matching vite.config.js, or adjust Composer scripts to not rely on npm.
- TODO: Document authentication choice (Passport vs Sanctum) and add auth endpoints/flows to this README.
- TODO: Document blockchain integration details (RPC URLs, contracts, events) and how API uses them.
- TODO: Provide API docs or OpenAPI/Swagger spec for the endpoints.

## License

This project is licensed under the MIT License (same as the Laravel skeleton). See LICENSE if present; otherwise, the default applies as per composer.json.
