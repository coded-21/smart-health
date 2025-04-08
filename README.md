# Smart Health App

A healthcare application that monitors biometric data from wearable devices. The app consists of a Flutter frontend and a Node.js backend that generates mock biometric data.

## Features

- Real-time biometric data monitoring
- Heart rate tracking
- Skin response (GSR) monitoring
- Motion data tracking
- Auto-refresh functionality
- Clean, modern UI

## Prerequisites

### Backend Requirements
- Node.js (v14 or higher)
- npm (Node Package Manager)

### Frontend Requirements
- Flutter SDK
- Chrome (for web development)
- Android Studio (for Android development)
- Xcode (for iOS development, macOS only)

## Installation

### Backend Setup

1. Navigate to the backend directory:
```bash
cd backend
```

2. Install dependencies:
```bash
npm install
```

3. Start the server:
```bash
npm start
```

The backend server will run on `http://localhost:3000` by default.

### Frontend Setup

1. Navigate to the frontend directory:
```bash
cd frontend
```

2. Install Flutter dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
# For web (Chrome)
flutter run -d chrome

# For Android
flutter run -d android

# For iOS (macOS only)
flutter run -d ios
```

## API Endpoints

The backend provides the following endpoints:

- `GET /api/biometric-data` - Get current biometric readings
- `GET /api/biometric-data/history` - Get historical data (last 10 readings)
- `GET /health` - Health check endpoint

## Project Structure

```
smart-health/
├── backend/
│   ├── src/
│   │   ├── server.js
│   │   └── utils/
│   │       └── mockDataGenerator.js
│   └── package.json
└── frontend/
    ├── lib/
    │   └── main.dart
    └── pubspec.yaml
```

## Development

### Backend Development

The backend uses Express.js and generates mock biometric data. To modify the mock data generation:

1. Edit `backend/src/utils/mockDataGenerator.js`
2. Restart the server to apply changes

### Frontend Development

The frontend is built with Flutter and uses Material Design. To modify the UI:

1. Edit `frontend/lib/main.dart`
2. Hot reload is supported for quick iterations

## Troubleshooting

### Backend Issues

1. If the server fails to start:
   - Check if port 3000 is available
   - Ensure all dependencies are installed
   - Check Node.js version

2. If API calls fail:
   - Verify the server is running
   - Check CORS settings
   - Ensure correct endpoint URLs

### Frontend Issues

1. If Flutter commands fail:
   - Run `flutter doctor` to check setup
   - Ensure Flutter SDK is in PATH
   - Check Flutter version compatibility

2. If the app won't build:
   - Run `flutter clean`
   - Run `flutter pub get`
   - Check for any error messages