# Sweets

## setup
`swift build` in the project root builds static and dynamic libraries.

### tests
Before running tests, a PostgreSQL user and database have to be created.

```
sudo -u postgres psql
```
```
CREATE USER sweets;
ALTER USER sweets WITH ENCRYPTED PASSWORD 'sweets';
CREATE DATABASE sweets;
GRANT ALL PRIVILEGES ON DATABASE sweets TO sweets;
```

`swift run` in the project root runs all tests.
