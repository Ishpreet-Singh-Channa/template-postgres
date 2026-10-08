# Template Postgres - [0.0.3]

Simple template for `postgres` database with the pg-vector extenstion.

Exposes `Hasura` for interacting with the database.

## Container Structure

- ### main

    The main postgres database uses pg vector by default.

    Uses the `data/main.sql` file for database initialization on first boot.

    ```bash
    docker compose up -d main
    ```

- ### meta

    A postgres db container for storing hasura meta-data, separate from the main database.

    Uses the `data/meta.sql` file for database initialization on first boot.

    ```bash
    docker compose up -d meta
    ```

- ### Hasura

    Hasura GraphQl engine for interacting with the database.

    enable console to use it as a database admin panel as well.

    ```bash
    docker compose up -d hasura
    ```

## How to use:

- ### Set environment variables

    Fist set up a few environment variables in a `.env` file.

    #### Docker variables
    1. `PROJECT_NAME`: The docker project name used for managing containers.

    #### Main DB variable
    1. `MAIN_POSTGRES_DB`: The name of the main database.
    3. `MAIN_POSTGRES_USER`: The main db user name.
    4. `MAIN_POSTGRES_PASSWORD`: The password for the main db user.

    #### Meta DB variables
    1. `META_POSTGRES_DB`: The name of the meta database.
    2. `MAIN_POSTGRES_USER`: The meta db user name.
    3. `MAIN_POSTGRES_PASSWORD`: The password for the meta db user.

    #### Hasura Variables
    1. `HASURA_ENABLE_CONSOLE`: Boolean, enables the hasura remote console. Recommended to keep <b>false</b> on prodiction.
    2. `HASURA_ADMIN_SECRET`: Should be a <b>'very strong'</b> password for hasura.
    4. `HASURA_DEV_MODE`: Boolean, Recommended for development but not recommned for production.

    #### Example

    ```bash
    # Docker
    PROJECT_NAME=database-template

    # MAIN db
    MAIN_POSTGRES_USER=postgres
    MAIN_POSTGRES_PASSWORD=postgres
    MAIN_POSTGRES_DB=postgres

    # META db
    META_POSTGRES_USER=postgres
    META_POSTGRES_PASSWORD=postgres
    META_POSTGRES_DB=postgres

    # Hasura
    EXPOSED_HASURA_PORT=8000
    HASURA_ADMIN_SECRET=admin
    HASURA_ENABLE_CONSOLE=true
    HASURA_DEV_MODE=false
    ```

- ### Run containers

    After the env are set, start up the docker containers

    ```bash
    docker compose up -d
    ```
