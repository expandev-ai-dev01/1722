# LoveCakes Backend

Backend API for LoveCakes - Cake ordering and sales platform.

## Technology Stack

- **Runtime**: Node.js
- **Language**: TypeScript
- **Framework**: Express.js
- **Database**: Microsoft SQL Server
- **Validation**: Zod

## Project Structure

```
src/
├── api/                    # API controllers
│   └── v1/                 # API version 1
│       ├── external/       # Public endpoints
│       └── internal/       # Authenticated endpoints
├── routes/                 # Route definitions
│   └── v1/                 # Version 1 routes
├── middleware/             # Express middleware
├── services/               # Business logic
├── utils/                  # Utility functions
├── constants/              # Application constants
├── instances/              # Service instances
├── config/                 # Configuration
├── tests/                  # Global test utilities
└── server.ts               # Application entry point
```

## Getting Started

### Prerequisites

- Node.js 18+
- SQL Server
- npm or yarn

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   npm install
   ```

3. Copy `.env.example` to `.env` and configure:
   ```bash
   cp .env.example .env
   ```

4. Update database credentials in `.env`

### Development

Run development server:
```bash
npm run dev
```

### Build

Build for production:
```bash
npm run build
```

### Start Production

Start production server:
```bash
npm start
```

### Testing

Run tests:
```bash
npm test
```

Run tests in watch mode:
```bash
npm run test:watch
```

### Linting

Run linter:
```bash
npm run lint
```

Fix linting issues:
```bash
npm run lint:fix
```

## API Endpoints

### Health Check

```
GET /health
```

Returns server health status.

### API Versioning

All API endpoints are versioned:

- External (public): `/api/v1/external/...`
- Internal (authenticated): `/api/v1/internal/...`

## Environment Variables

See `.env.example` for all available configuration options.

## Database

Database scripts are located in the `database/` directory following the schema-based organization:

- `config/` - Configuration schema
- `functional/` - Business logic schema
- `security/` - Security schema
- `subscription/` - Subscription schema

## Contributing

Follow the established coding standards and patterns documented in the knowledge base.

## License

ISC