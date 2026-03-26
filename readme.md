# Template - Postgres

Simple template for `postgres` database. \
Exposes `Hasura` for interacting with the database. \
Also provides a script to `Backup` database onto <b>Cloud</b> storage.

## How to use:

- ### Set environment variables

    Fist set up a few environment variables.

    #### Docker variables
    1. `PROJECT_NAME`: The docker network name, and used for managing containers.
    2. `HASURA_PORT`: This is the exposed port on the machine for connecting to hasura

    #### Postgres Variables
    1. `POSTGRES_VERSION`: This is the version of the postgres to use.
    2. `POSTGRES_DB`: The name of the postgres database.
    3. `POSTGRES_USER`: The postgres user name.
    4. `POSTGRES_PASSWORD`: The password for the user.

    #### Hasura Variables
    1. `HASURA_GRAPHQL_ENABLE_CONSOLE`: Boolean, enables the hasura remote console. Recommended to keep <b>false</b> on prodiction.
    2. `HASURA_GRAPHQL_ADMIN_SECRET`: Should be a <b>'very strong'</b> password for hasura.

    #### Backup Variables
    1. `BACKUP_INTERVAL`: Integer representing backup interval in <b>seconds</b>.
    2. `BACKUP_NUMBERS`: The Number of backups to keep
    3. `AWS_ACCESS_KEY_ID`: AWS Access key id.
    4. `AWS_SECRET_ACCESS_KEY`: Aws Secret key.
    5. `AWS_REGION`: AWS Region.
    6. `AWS_S3_BUCKET`: AWS Bucket, can also attach the prefix for the backups in it.

    #### Example

    ```bash
    # Docker
    PROJECT_NAME=database-template
    HASURA_PORT=8000

    # Postgres
    POSTGRES_USER=postgres
    POSTGRES_PASSWORD=postgres
    POSTGRES_DB=postgres

    # Hasura
    HASURA_GRAPHQL_ADMIN_SECRET=admin   # Should be strong
    HASURA_GRAPHQL_ENABLE_CONSOLE=true

    # Backup
    BACKUP_INTERVAL=3600
    BACKUP_NUMBERS=3
    AWS_ACCESS_KEY_ID=...
    AWS_SECRET_ACCESS_KEY=...
    AWS_REGION=...
    AWS_s3_BUCKET=bucket_1/backups/database
    ```

- ### Run containers
    After the env are set, start up the docker containers
    ```bash
    docker compose up -d
    ```

## Container Structure

- ### Postgres

    The main postgres database uses pg vector by default.

    ```bash
    docker compose up -d postgres
    ```

- ### Hasura

    Hasura GraphQl engine for interacting with the database. \
     enable console to use it as a database admin panel as well.

    ```bash
    docker compose up -d hasura
    ```

- ### Backup

    A Postgres alpine image with the <b>same version</b> as the postgres DB image to prevent version mismatch with `pg_dump`. \
     Runs a bash script to:
    1. Dump database tables and rows only
    2. Upload to S3 for backup

    ```bash
    docker compose up -d backup
    ```
