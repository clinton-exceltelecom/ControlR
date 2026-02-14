# Database Configuration Guide

This guide covers database setup and management for ControlR development. ControlR supports multiple database configurations to accommodate different development workflows.

## Database Provider Options

ControlR supports two database providers:

1. **PostgreSQL** (Recommended) - Full-featured relational database with persistent storage
2. **InMemory** - Lightweight in-memory database for quick testing without external dependencies

### When to Use Each Provider

**PostgreSQL**:

- Full-stack development and testing
- Testing migrations and database schema changes
- Multi-session development (data persists across restarts)
- Integration testing with realistic database behavior
- Production-like development environment

**InMemory**:

- Quick iteration on UI or business logic
- Unit testing without database dependencies
- Development without Docker or PostgreSQL installation
- Rapid prototyping

## Configuration

### Selecting Database Provider

Database provider is configured in `ControlR.Web.Server/appsettings.Development.json`:

```json
{
  "DatabaseProvider": "PostgreSQL", // or "InMemory"
  "ConnectionStrings": {
    "PostgreSQL": "Host=${POSTGRES_HOST};Database=controlr;Username=${POSTGRES_USER};Password=${POSTGRES_PASSWORD}"
  },
  "POSTGRES_USER": "postgres",
  "POSTGRES_PASSWORD": "password",
  "POSTGRES_HOST": "localhost"
}
```

Alternatively, set via environment variable:

```bash
export DatabaseProvider=InMemory
```

Or use the `AppOptions:UseInMemoryDatabase` setting:

```json
{
  "AppOptions": {
    "UseInMemoryDatabase": true,
    "InMemoryDatabaseName": "ControlR"
  }
}
```

## Using InMemory Provider

### Setup

1. Update `appsettings.Development.json`:

```json
{
  "DatabaseProvider": "InMemory"
}
```

Or set environment variable:

```bash
export DatabaseProvider=InMemory
```

2. Start the application - no additional setup required!

### Characteristics

- **Data Lifetime**: Data exists only while the application is running
- **Migrations**: Not applied (InMemory provider doesn't support migrations)
- **Performance**: Very fast, no I/O overhead
- **Isolation**: Each application instance has its own database
- **Limitations**:
  - No referential integrity enforcement
  - Limited query capabilities compared to PostgreSQL
  - Data lost on restart

### Use Cases

```bash
# Quick UI development
export DatabaseProvider=InMemory
dotnet run --project ControlR.Web.Server

# Unit testing
# Tests automatically use InMemory when configured
dotnet test
```

## Using Docker PostgreSQL

### Setup

Docker Compose provides the easiest way to run PostgreSQL for development.

#### 1. Configure Environment Variables

Create a `.env` file in the `docker-compose/` directory:

```bash
# docker-compose/.env
ControlR_POSTGRES_USER=postgres
ControlR_POSTGRES_PASSWORD=password
ControlR_ASPIRE_BROWSER_TOKEN=your-token-here
```

Or export them in your shell:

```bash
export ControlR_POSTGRES_USER=postgres
export ControlR_POSTGRES_PASSWORD=password
export ControlR_ASPIRE_BROWSER_TOKEN=your-token-here
```

#### 2. Start PostgreSQL

```bash
# Start all services (PostgreSQL + Aspire Dashboard)
docker compose -f docker-compose/docker-compose.yml up -d

# Or start only PostgreSQL
docker compose -f docker-compose/docker-compose.yml up -d postgres
```

#### 3. Verify PostgreSQL is Running

```bash
# Check container status
docker ps | grep postgres

# Check logs
docker logs postgres

# Test connection
psql -h localhost -U postgres -d controlr
```

#### 4. Configure Application

Update `appsettings.Development.json`:

```json
{
  "DatabaseProvider": "PostgreSQL",
  "POSTGRES_HOST": "localhost",
  "POSTGRES_USER": "postgres",
  "POSTGRES_PASSWORD": "password"
}
```

#### 5. Run Application

```bash
dotnet run --project ControlR.Web.Server
```

Migrations are applied automatically on startup.

### Docker PostgreSQL Management

```bash
# Stop PostgreSQL
docker compose -f docker-compose/docker-compose.yml stop postgres

# Restart PostgreSQL
docker compose -f docker-compose/docker-compose.yml restart postgres

# View logs
docker logs -f postgres

# Stop and remove containers (data persists in volume)
docker compose -f docker-compose/docker-compose.yml down

# Remove containers AND data volume (destructive!)
docker compose -f docker-compose/docker-compose.yml down -v
```

### Data Persistence

PostgreSQL data is stored in a Docker volume named `postgres-data`. This volume persists even when containers are stopped or removed (unless you use `docker compose down -v`).

```bash
# List volumes
docker volume ls | grep postgres

# Inspect volume
docker volume inspect postgres-data

# Backup volume
docker run --rm -v postgres-data:/data -v $(pwd):/backup ubuntu tar czf /backup/postgres-backup.tar.gz /data

# Restore volume
docker run --rm -v postgres-data:/data -v $(pwd):/backup ubuntu tar xzf /backup/postgres-backup.tar.gz -C /
```

## Using Local PostgreSQL

### Installation

**Ubuntu/Debian**:

```bash
sudo apt update
sudo apt install postgresql postgresql-contrib
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

**Fedora/RHEL**:

```bash
sudo dnf install postgresql-server postgresql-contrib
sudo postgresql-setup --initdb
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

**macOS**:

```bash
brew install postgresql@16
brew services start postgresql@16
```

### Database Setup

1. Create database and user:

```bash
# Switch to postgres user
sudo -u postgres psql

# In psql:
CREATE DATABASE controlr;
CREATE USER controlr_dev WITH PASSWORD 'dev_password';
GRANT ALL PRIVILEGES ON DATABASE controlr TO controlr_dev;

# PostgreSQL 15+ requires additional grants
\c controlr
GRANT ALL ON SCHEMA public TO controlr_dev;

\q
```

2. Configure connection string in `appsettings.Development.json`:

```json
{
  "DatabaseProvider": "PostgreSQL",
  "ConnectionStrings": {
    "PostgreSQL": "Host=localhost;Database=controlr;Username=controlr_dev;Password=dev_password"
  }
}
```

Or use environment variables:

```bash
export POSTGRES_HOST=localhost
export POSTGRES_USER=controlr_dev
export POSTGRES_PASSWORD=dev_password
```

3. Run the application:

```bash
dotnet run --project ControlR.Web.Server
```

Migrations are applied automatically on startup.

### Local PostgreSQL Management

```bash
# Check PostgreSQL status
sudo systemctl status postgresql

# Start/stop PostgreSQL
sudo systemctl start postgresql
sudo systemctl stop postgresql

# Connect to database
psql -h localhost -U controlr_dev -d controlr

# View databases
psql -U postgres -c "\l"

# View tables in controlr database
psql -U controlr_dev -d controlr -c "\dt"
```

## Managing Migrations

### Automatic Migration Application

By default, ControlR applies migrations automatically on startup when using PostgreSQL:

```csharp
// In Program.cs
if (appOptions.UseInMemoryDatabase)
{
  await app.AddBuiltInRoles();
}
else
{
  await app.ApplyMigrations();  // Automatic migration
  await app.SetAllDevicesOffline();
  await app.SetAllUsersOffline();
  await app.RemoveEmptyTenants();
}
```

This means you typically don't need to manually apply migrations during development.

### Manual Migration Application

If you need to apply migrations manually (e.g., for troubleshooting):

#### Prerequisites

Install EF Core tools:

```bash
dotnet tool install --global dotnet-ef
# Or update existing installation
dotnet tool update --global dotnet-ef
```

#### Apply Migrations

```bash
# Apply all pending migrations
dotnet ef database update --project ControlR.Web.Server

# Apply migrations with connection string override
dotnet ef database update --project ControlR.Web.Server \
  --connection "Host=localhost;Database=controlr;Username=postgres;Password=password"
```

#### List Migrations

```bash
# View all migrations and their status
dotnet ef migrations list --project ControlR.Web.Server

# Output example:
# 20241113035049_Initial (Applied)
# 20241116201658_Add_Invites (Applied)
# 20241130193555_Add_DataProtectionKeys (Pending)
```

#### View Migration SQL

```bash
# Generate SQL script for all migrations
dotnet ef migrations script --project ControlR.Web.Server

# Generate SQL for specific migration range
dotnet ef migrations script 20241113035049_Initial 20241116201658_Add_Invites \
  --project ControlR.Web.Server
```

### Creating New Migrations

When you modify entity classes or DbContext configuration:

```bash
# Create a new migration
dotnet ef migrations add MigrationName --project ControlR.Web.Server

# Example: Adding a new property
dotnet ef migrations add Add_UserPhoneNumber --project ControlR.Web.Server
```

The migration files are created in `ControlR.Web.Server/Data/Migrations/`.

### Removing Migrations

```bash
# Remove the last migration (if not applied to database)
dotnet ef migrations remove --project ControlR.Web.Server

# If migration was applied, first revert it
dotnet ef database update PreviousMigrationName --project ControlR.Web.Server
dotnet ef migrations remove --project ControlR.Web.Server
```

## Resetting the Database

### Docker PostgreSQL

```bash
# Method 1: Drop and recreate via Docker Compose
docker compose -f docker-compose/docker-compose.yml down -v
docker compose -f docker-compose/docker-compose.yml up -d postgres

# Method 2: Drop database via psql
docker exec -it postgres psql -U postgres -c "DROP DATABASE controlr;"
docker exec -it postgres psql -U postgres -c "CREATE DATABASE controlr;"

# Method 3: Use EF Core tools
dotnet ef database drop --project ControlR.Web.Server --force
dotnet ef database update --project ControlR.Web.Server
```

### Local PostgreSQL

```bash
# Method 1: Use psql
sudo -u postgres psql -c "DROP DATABASE controlr;"
sudo -u postgres psql -c "CREATE DATABASE controlr;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE controlr TO controlr_dev;"

# Method 2: Use dropdb/createdb utilities
dropdb -U postgres controlr
createdb -U postgres controlr
psql -U postgres -d controlr -c "GRANT ALL ON SCHEMA public TO controlr_dev;"

# Method 3: Use EF Core tools
dotnet ef database drop --project ControlR.Web.Server --force
dotnet ef database update --project ControlR.Web.Server
```

### InMemory Database

Simply restart the application - data is automatically cleared.

## Connection String Configuration

ControlR supports multiple sources for connection strings, checked in this priority order:

### 1. ConnectionStrings Section (Recommended)

```json
{
  "ConnectionStrings": {
    "PostgreSQL": "Host=localhost;Database=controlr;Username=dev;Password=dev"
  }
}
```

Supports environment variable placeholders:

```json
{
  "ConnectionStrings": {
    "PostgreSQL": "Host=${POSTGRES_HOST};Database=controlr;Username=${POSTGRES_USER};Password=${POSTGRES_PASSWORD}"
  },
  "POSTGRES_HOST": "localhost",
  "POSTGRES_USER": "postgres",
  "POSTGRES_PASSWORD": "password"
}
```

### 2. Individual Environment Variables

```bash
export POSTGRES_HOST=localhost
export POSTGRES_USER=postgres
export POSTGRES_PASSWORD=password
```

### 3. User Secrets (Recommended for Sensitive Data)

```bash
# Initialize user secrets
dotnet user-secrets init --project ControlR.Web.Server

# Set connection string
dotnet user-secrets set "ConnectionStrings:PostgreSQL" \
  "Host=localhost;Database=controlr;Username=dev;Password=dev" \
  --project ControlR.Web.Server

# Set individual values
dotnet user-secrets set "POSTGRES_PASSWORD" "my-secret-password" \
  --project ControlR.Web.Server
```

### 4. Environment-Specific Configuration Files

Create `appsettings.{Environment}.json` files:

```bash
# appsettings.Development.json - for local development
# appsettings.Staging.json - for staging environment
# appsettings.Production.json - for production (use environment variables instead!)
```

## Troubleshooting

### Connection Refused

**Symptoms**: `Npgsql.NpgsqlException: Connection refused`

**Solutions**:

```bash
# Check if PostgreSQL is running
docker ps | grep postgres
# or
sudo systemctl status postgresql

# Check if port 5432 is listening
netstat -an | grep 5432
# or
ss -tlnp | grep 5432

# Verify connection string
echo $POSTGRES_HOST
echo $POSTGRES_USER

# Test connection manually
psql -h localhost -U postgres -d controlr
```

### Authentication Failed

**Symptoms**: `Npgsql.NpgsqlException: password authentication failed`

**Solutions**:

```bash
# Verify credentials
echo $POSTGRES_USER
echo $POSTGRES_PASSWORD

# Check pg_hba.conf (local PostgreSQL)
sudo cat /etc/postgresql/*/main/pg_hba.conf | grep -v "^#"

# For Docker, recreate with correct credentials
docker compose -f docker-compose/docker-compose.yml down
# Update .env file with correct credentials
docker compose -f docker-compose/docker-compose.yml up -d
```

### Database Does Not Exist

**Symptoms**: `Npgsql.NpgsqlException: database "controlr" does not exist`

**Solutions**:

```bash
# Create database
docker exec -it postgres psql -U postgres -c "CREATE DATABASE controlr;"
# or
sudo -u postgres psql -c "CREATE DATABASE controlr;"

# Or let EF Core create it
dotnet ef database update --project ControlR.Web.Server
```

### Migration Failures

**Symptoms**: `An error occurred while applying migrations`

**Solutions**:

```bash
# Check migration status
dotnet ef migrations list --project ControlR.Web.Server

# View detailed error
dotnet ef database update --project ControlR.Web.Server --verbose

# Reset and reapply
dotnet ef database drop --project ControlR.Web.Server --force
dotnet ef database update --project ControlR.Web.Server

# Or with Docker
docker compose -f docker-compose/docker-compose.yml down -v
docker compose -f docker-compose/docker-compose.yml up -d
dotnet run --project ControlR.Web.Server
```

### InMemory Provider Not Working

**Symptoms**: Application still tries to connect to PostgreSQL

**Solutions**:

```bash
# Verify configuration
cat ControlR.Web.Server/appsettings.Development.json | grep DatabaseProvider

# Set via environment variable (overrides appsettings)
export DatabaseProvider=InMemory

# Or use AppOptions
export AppOptions__UseInMemoryDatabase=true

# Clear any PostgreSQL environment variables
unset POSTGRES_HOST
unset POSTGRES_USER
unset POSTGRES_PASSWORD
```

### Port Already in Use

**Symptoms**: `Docker: port 5432 is already allocated`

**Solutions**:

```bash
# Find process using port 5432
sudo lsof -i :5432
# or
sudo netstat -tlnp | grep 5432

# Stop local PostgreSQL
sudo systemctl stop postgresql

# Or change Docker port mapping in docker-compose.yml
ports:
  - "5433:5432"  # Map to different host port

# Update connection string
export POSTGRES_HOST=localhost:5433
```

## Best Practices

### Development Workflow

1. **Use Docker PostgreSQL** for most development work
2. **Use InMemory** for quick UI iterations or unit tests
3. **Use local PostgreSQL** if you prefer native installations or need advanced PostgreSQL features

### Connection String Security

1. **Never commit passwords** to version control
2. **Use user secrets** for local development:
   ```bash
   dotnet user-secrets set "POSTGRES_PASSWORD" "my-password" --project ControlR.Web.Server
   ```
3. **Use environment variables** for CI/CD and production
4. **Use placeholder syntax** in appsettings.json:
   ```json
   "ConnectionStrings": {
     "PostgreSQL": "Host=${POSTGRES_HOST};Username=${POSTGRES_USER};Password=${POSTGRES_PASSWORD}"
   }
   ```

### Migration Management

1. **Let automatic migrations run** during development (default behavior)
2. **Review migration SQL** before applying to production:
   ```bash
   dotnet ef migrations script --project ControlR.Web.Server > migration.sql
   ```
3. **Test migrations** on a copy of production data before deploying
4. **Keep migrations small** and focused on single changes
5. **Name migrations descriptively**: `Add_UserPhoneNumber` not `Update1`

### Testing

1. **Use InMemory for unit tests** - fast and isolated
2. **Use PostgreSQL for integration tests** - realistic behavior
3. **Reset database between test runs** for consistency
4. **Use transactions** in tests to avoid side effects

## Additional Resources

- [Entity Framework Core Documentation](https://learn.microsoft.com/en-us/ef/core/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Npgsql Documentation](https://www.npgsql.org/doc/)
- [ControlR Setup Guide](SETUP.md)
- [ControlR Troubleshooting Guide](TROUBLESHOOTING.md)
