# Test Application

This is a sample Node.js/React application used to demonstrate the Blue-Green deployment pipeline. The application consists of a Express.js backend API and a React frontend client.

## 🏗️ Architecture

- **Backend**: Express.js server with AWS X-Ray tracing
- **Frontend**: React application built with modern JavaScript
- **Testing**: Jest test framework
- **Containerization**: Docker with multi-stage builds

## 🚀 Quick Start

### Prerequisites

- Node.js >= 14.x
- Yarn package manager
- Docker (for containerization)

### Installation

1. **Install dependencies**
   ```bash
   yarn install
   yarn frontend-install
   ```

2. **Build the frontend**
   ```bash
   yarn frontend-build
   ```

3. **Run all installation steps at once**
   ```bash
   yarn all-install
   ```

### Running the Application

1. **Start the server**
   ```bash
   yarn start
   ```

2. **Access the application**
   - Frontend: `http://localhost:3000`
   - Backend API: `http://localhost:3000/api`

### Testing

Run the test suite:
```bash
yarn test
```

## 🐳 Docker

The application is containerized using Docker with a multi-stage build:

1. **Build the Docker image**
   ```bash
   docker build -t test-app .
   ```

2. **Run the container**
   ```bash
   docker run -p 3000:3000 test-app
   ```

## 📁 Project Structure

```
Test_App/
├── buildspec.yml          # AWS CodeBuild specification
├── Dockerfile             # Docker configuration
├── index.js               # Express.js server
├── package.json           # Backend dependencies
├── client/                # React frontend
│   ├── package.json       # Frontend dependencies
│   ├── public/
│   │   └── index.html      # HTML template
│   └── src/
│       ├── App.jsx         # Main React component
│       ├── App.css         # Application styles
│       ├── index.js        # React entry point
│       └── index.css       # Global styles
└── tests/
    └── index.test.js       # Test files
```

## 🔧 CI/CD Integration

This application is designed to work with AWS CodePipeline:

- **buildspec.yml**: Defines build and test phases for CodeBuild
- **Dockerfile**: Multi-stage build for optimized container images
- **Tests**: Automated testing during the build process

## 🧪 Features

- Health check endpoint (`/health`)
- AWS X-Ray integration for distributed tracing
- Concurrent frontend and backend development
- Automated testing with Jest
- Docker containerization
- Production-ready build process

## 🤝 Development

### Available Scripts

- `yarn start` - Start the production server
- `yarn test` - Run tests
- `yarn frontend-install` - Install frontend dependencies
- `yarn frontend-build` - Build frontend for production
- `yarn all-install` - Install and build everything

### Adding New Features

1. Backend changes go in `index.js`
2. Frontend changes go in `client/src/`
3. Add tests in `tests/`
4. Update Docker configuration if needed

## 📝 Environment Variables

The application supports the following environment variables:

- `PORT` - Server port (default: 3000)
- `NODE_ENV` - Environment mode (development/production)

## 🐛 Troubleshooting

### Common Issues

1. **Port already in use**
   ```bash
   lsof -ti:3000 | xargs kill
   ```

2. **Dependencies not installing**
   ```bash
   rm -rf node_modules client/node_modules
   yarn cache clean
   yarn all-install
   ```

3. **Docker build fails**
   - Check Dockerfile syntax
   - Ensure all dependencies are properly specified