# School Manager API

Rails API for School Manager, a role-based school administration system. The server owns authentication, school data, user roles, dashboards, search, and CRUD APIs consumed by the React client in `../client`.

## Features

- JSON API under `/api/v1`.
- JWT authentication via `/api/v1/login`.
- Role-scoped endpoints for admins, principals, and teachers.
- School, teacher, student, classroom, academic year, subject assignment, mark, and dashboard data models.
- MySQL persistence with Rails Active Record.
- CORS enabled for browser clients.
- Elasticsearch-backed search integration.
- Seed data generator for local development and demos.

## Tech Stack

- Ruby on Rails 8.1 in API-only mode
- MySQL with the `mysql2` adapter
- Puma web server
- JWT and bcrypt for authentication
- Pagy and jsonapi-serializer for API responses
- Rack CORS
- Elasticsearch Rails integrations
- Solid Cache, Solid Queue, and Solid Cable
- Brakeman, Bundler Audit, and RuboCop Rails Omakase for quality checks

## Prerequisites

- Ruby compatible with Rails 8.1. The Dockerfile currently uses Ruby `4.0.1`; keep `.ruby-version`, Docker, and local tooling aligned.
- Bundler
- MySQL 5.6.4 or newer
- Elasticsearch, if using the search endpoint locally

## Getting Started

1. Install dependencies:

   ```bash
   bundle install
   ```

2. Configure environment variables:

   ```bash
   cp .env .env.local
   ```

   The application reads these variables:

   ```env
   DB_USERNAME=your_mysql_user
   DB_PASSWORD=your_mysql_password
   SUPERADMIN_EMAIL=admin@school.com
   SUPERADMIN_PASSWORD=password
   ELASTICSEARCH_URL=http://elastic:password@localhost:9200
   ```

   `SUPERADMIN_EMAIL` and `SUPERADMIN_PASSWORD` are used by `db/seeds.rb`. `ELASTICSEARCH_URL` is optional and defaults to the local value configured in `config/initializers/elasticsearch.rb`.

3. Prepare the database:

   ```bash
   bin/rails db:prepare
   ```

4. Seed development data when needed:

   ```bash
   bin/rails db:seed
   ```

   The seed task creates a superadmin account and a large sample dataset. It may take time because it generates schools, staff, students, enrollments, assignments, and marks.

5. Start the API server:

   ```bash
   bin/rails server
   ```

   The API is available at `http://localhost:3000`.

You can also run the setup script:

```bash
bin/setup --skip-server
```

Omit `--skip-server` if you want the script to start the development server after setup.

## Environment Variables

| Variable | Required | Description |
| --- | --- | --- |
| `DB_USERNAME` | Yes | MySQL username for development and test databases. |
| `DB_PASSWORD` | Yes | MySQL password for development and test databases. |
| `SUPERADMIN_EMAIL` | No | Email for the seeded superadmin account. Defaults to `admin@school.com`. |
| `SUPERADMIN_PASSWORD` | No | Password for the seeded superadmin account. Defaults to `password`. |
| `ELASTICSEARCH_URL` | No | Elasticsearch connection URL. Defaults to the local URL in the initializer. |
| `RAILS_MASTER_KEY` | Production | Rails credentials key used by Docker and production deployments. |
| `SCHOOL_MANAGER_DATABASE_PASSWORD` | Production | Production database password used by `config/database.yml`. |

Do not commit real secret values. Keep local overrides in untracked environment files or your shell profile.

## API Overview

Health check:

- `GET /up`

Authentication and search:

- `POST /api/v1/login`
- `GET /api/v1/search`

Admin endpoints:

- `/api/v1/admin/schools`
- `/api/v1/admin/teachers`
- `/api/v1/admin/students`
- `/api/v1/admin/classrooms`
- `/api/v1/admin/academic_years`
- `/api/v1/admin/teacher_subject_assignments`
- `/api/v1/admin/marks`
- `/api/v1/admin/dashboard_stats`

Principal endpoints:

- `/api/v1/principal/teachers`
- `/api/v1/principal/students`
- `/api/v1/principal/classrooms`
- `/api/v1/principal/marks`
- `/api/v1/principal/teacher_subject_assignments`
- `/api/v1/principal/dashboard_stats`

Teacher endpoints:

- `/api/v1/teacher/classrooms`
- `/api/v1/teacher/students`
- `/api/v1/teacher/marks`
- `/api/v1/teacher/teacher_subject_assignments`
- `/api/v1/teacher/dashboard_stats`

Authenticated requests should send:

```http
Authorization: Bearer <jwt>
Accept: application/json
```

## Project Structure

```text
app/controllers/       API controllers and authorization concerns
app/models/            Active Record models
app/serializers/       JSON serializers
app/services/          Application services, including JWT handling
config/                Rails, database, CORS, queue, cache, and search config
db/migrate/            Database migrations
db/seeds.rb            Development seed data generator
bin/                   Rails, setup, CI, lint, security, and deployment commands
```

## Quality Checks

Run the configured CI checks locally with:

```bash
bin/ci
```

The CI script currently runs setup, RuboCop, Bundler Audit, and Brakeman. Rails test unit is not enabled in `config/application.rb`, and no application test suite is currently configured.

Individual checks:

```bash
bin/rubocop
bin/bundler-audit
bin/brakeman --quiet --no-pager --exit-on-warn --exit-on-error
```

## Database Tasks

Common development commands:

```bash
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed
bin/rails db:reset
```

`db:reset` drops, recreates, migrates, and seeds the database. Use it only when you are comfortable replacing local data.

## Docker

The included `Dockerfile` is intended for production-style builds.

```bash
docker build -t school_manager .
docker run -p 80:80 \
  -e RAILS_MASTER_KEY=<rails-master-key> \
  -e SCHOOL_MANAGER_DATABASE_PASSWORD=<database-password> \
  school_manager
```

Use local Rails commands for day-to-day development unless you intentionally want a production-like container.

## Client Integration

The React client expects this API at:

```env
VITE_API_BASE_URL=http://localhost:3000/api/v1
```

CORS currently allows all origins in `config/initializers/cors.rb`, which is convenient for local development. Restrict allowed origins before deploying to production.
