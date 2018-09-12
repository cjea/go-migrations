CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

BEGIN;

-- Users ---------------------------------------------------
DROP TABLE IF EXISTS users;
CREATE TABLE users (
	    id uuid PRIMARY KEY default uuid_generate_v4(),
	    -- used to log in
    email VARCHAR(64) NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL,
    last_accessed_at TIMESTAMP,
    updated_at TIMESTAMP,
    deleted_at TIMESTAMP
);
DROP INDEX IF EXISTS users__id_index;
CREATE INDEX users__id_index ON users (id);
COMMIT;
