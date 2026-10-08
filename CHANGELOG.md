# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/)
and this project adheres to [Semantic Versioning](https://semver.org/).

## [0.0.3] - 2026-10-08

### Added

- `.env.example` for example setup

### Fixed

- included empty `data/main.sql` and `data/meta.sql` to prevent docker mount error from fresh template copy

## [0.0.2] - 2026-10-08

### Added

- docker service `meta` to store hasura meta-data in a separate database instance entirely.
- docker healthcheck for service `main`.

### Changed

- `postgres`: Service postgres received the following changes:
    - changed service from `postgres` to `main`
    - image changed from `pgvector/pgvector:pg${POSTGRES_VERSION}` to `pgvector/pgvector:pg18@sha256:2358fcba361ed2233a5ed81b5fe4ca779ccb304120ce531a3bf51c0ed7e2bc11`.
    - service name changed from `${PROJECT_NAME}-db` to `${PROJECT_NAME}-main`.
    - Env variable names from `POSTGRES_...` to `MAIN_POSTGRES_...`.
    - Volume mount location changed from `./database/data/:var/lib/postgresql/data` and `./database/init.sql:/docker-entrypoint-initdb.d/init.sql` to `./data/main:/var/lib/postgresql/18` and `./data/main.sql:/docker-entrypoint-initdb.d/init.sql`
- `.gitignore`: to ignore only main/ and meta/ directory and .env file
- `hasura`:Service received the following changes:
    - image changed to `hasura/graphql-engine:v2.51.0@sha256:5d435a6756de53709bf48c15b822cabab38d57acd22e656cf633cc2df67df150`
    - Service hasura received extra env variable configuration for more control, README.md for more info.

### Removed

- `backup`: Docker service backup is removed.
- `POSTGRES_VERSION`: Env variable POSTGRES_VERSION has been removed in favor of strict database version
- `dockerignore`: no longer needed.

## [0.0.1]

### Added

- `docker-compose.yaml`: Created docker-compose.yaml file with various services.
- `postgres`: docker compose service postgres as the database.
- `hasura`: docker compose service hasura as the graphQl engine.
- `backup`: docker compose service backup to create timely dump of database.
- `README.md`: Instructions to get the services working.

<!-- 
## [2.0.10] - 2026-10-07

### Fixed

- package.json not including CHANGELOG.md in files.

## [2.0.9] - 2026-10-07

### Added

- [CHANGELOG.md](./CHANGELOG.md) To keep track of changes

### Changed

- Print colour for environment variable names during initialization from `gray` to `orange`.
- README.md environment variables from list to tables
- Dependency [@divine-lab/cache](https://npmjs.com/package/@divine-lab/cache) from version `1.1.1` to version `1.1.2`. -->