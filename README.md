# Sweets

## setup

`swift build Sweets` in the project root builds static and dynamic libraries.

### tests
The tests require a PostgreSQL user and database.

```
sudo -u postgres psql
```
```
CREATE USER sweets;
ALTER USER sweets WITH ENCRYPTED PASSWORD 'sweets';
CREATE DATABASE sweets;
GRANT ALL PRIVILEGES ON DATABASE sweets TO sweets;
```

`swift run Tests` in the project root runs all tests.
