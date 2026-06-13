# Frontend-Backend Connection Guide

## Overview

The Flutter frontend is now connected to your FastAPI backend. The connection is configured in `lib/services/api_service.dart`.

## Backend URL Configuration

### Local Development

#### For Android Emulator
The default URL is already configured for Android emulator development:
```dart
http://10.0.2.2:8000
```

This is the special IP address that Android emulators use to refer to `localhost` on your development machine.

**Steps:**
1. Ensure your backend is running: `python main.py`
2. Run the Flutter app on Android emulator: `flutter run`
3. The app will automatically connect to your local backend

#### For iOS Simulator
iOS simulator uses `localhost` directly:
```dart
http://localhost:8000
```

**To switch to iOS:**
1. Edit `lib/services/api_service.dart`
2. Change the default value in `_baseUrl` getter:
   ```dart
   defaultValue: 'http://localhost:8000',
   ```
3. Run: `flutter run -d <iOS simulator ID>`

#### For Physical Android Device
If testing on a real Android device, you need your development machine's IP address:

1. Find your machine's local IP:
   ```powershell
   ipconfig
   ```
   Look for IPv4 Address (e.g., `192.168.1.100`)

2. Edit `lib/services/api_service.dart`:
   ```dart
   defaultValue: 'http://192.168.1.100:8000',
   ```

3. Make sure your backend is accessible from the device (same network)

### Production Deployment

Once you deploy your backend to Railway or another hosting service:

1. Get your deployed backend URL (e.g., `https://himalayagpt-api.railway.app`)

2. Edit `lib/services/api_service.dart`:
   ```dart
   defaultValue: 'https://himalayagpt-api.railway.app',
   ```

3. Or use compile-time environment variables:
   ```bash
   flutter run --dart-define=BACKEND_URL=https://himalayagpt-api.railway.app
   ```

## Testing the Connection

### 1. Verify Backend is Running

```bash
curl http://localhost:8000/api/health
```

Expected response:
```json
{
  "status": "ok",
  "model": "gemini-2.0-flash",
  "rate_limit_remaining": 12
}
```

### 2. Test API from Flutter

In the Flutter app:
1. Open the chat screen
2. Send a message
3. Check the terminal logs for any errors

### 3. Check Backend Logs

Look for log entries like:
```
2026-06-07 10:30:45 | INFO | app.routes.chat | Chat request | user_id: 550e8400 | message_length: 20
2026-06-07 10:30:47 | INFO | app.routes.chat | Chat response | user_id: 550e8400 | tokens_used: 45 | elapsed_ms: 1234.56
```

## Troubleshooting

### "Network error. Please check your connection."

**Causes & Solutions:**

1. **Backend not running**
   - Ensure `python main.py` is executing in the backend directory
   - Check that it says "API ready" in the logs

2. **Wrong URL for your device**
   - Android emulator: Use `http://10.0.2.2:8000`
   - iOS simulator: Use `http://localhost:8000`
   - Physical device: Use your machine's local IP (e.g., `http://192.168.1.100:8000`)

3. **Firewall blocking connection**
   - Windows: Allow Python through Windows Firewall
   - macOS: Check System Preferences > Security & Privacy

4. **Backend API key not set**
   - Backend needs `GEMINI_API_KEY` in `.env`
   - Without it, the backend won't start properly

### "Rate limit reached. Please wait a moment..."

The free tier Gemini API allows 15 requests per minute. The backend caps at 12 to be safe.

**Solution:** Wait 60 seconds before sending the next message.

### "Backend API error. Please try again."

**Causes:**
1. Invalid Gemini API key
2. Gemini API service unavailable
3. Network issue between backend and Google's API

**Solutions:**
1. Verify API key in backend `.env`: `GEMINI_API_KEY=your_actual_key`
2. Test health endpoint: `curl http://localhost:8000/api/health`
3. Check backend logs for detailed error messages

### Android Emulator Can't Connect to Backend

**Problem:** `Network error` when trying to send messages

**Solutions:**
1. Verify backend port: `netstat -ano | findstr :8000` (Windows)
2. Change emulator network settings:
   - Android Studio > AVD Manager > Edit > Show Advanced Settings > Network
   - Try different network modes

3. Use a different approach:
   ```bash
   # Forward a port from emulator to your machine
   adb forward tcp:8000 tcp:8000
   # Then use: http://localhost:8000
   ```

## API Response Structure

The backend now sends structured responses:

```json
{
  "reply": "नमस्ते! यो HimalayaGPT को जवाफ हो।",
  "user_id": "550e8400-e29b-41d4-a716-446655440000",
  "model": "gemini-2.0-flash",
  "tokens_used": 45,
  "conversation_id": null
}
```

The frontend extracts:
- **reply**: Displayed in the chat UI
- **tokens_used**: Available for future stats display
- **model**: Identifies which model generated the response

## CORS Configuration

The backend is configured to accept requests from:
- `http://localhost:3000`
- `http://localhost:8080`
- Any address (in development with `ALLOWED_ORIGINS=*`)

If you change `ALLOWED_ORIGINS` in the backend `.env`, the frontend will still work since Flutter apps don't use browser CORS rules.

## Environment-Specific Configuration

### Development

Backend `.env`:
```env
GEMINI_API_KEY=your_dev_key
DEVICE=cpu
RATE_LIMIT_RPM=12
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8080
```

Frontend `api_service.dart`:
```dart
defaultValue: 'http://10.0.2.2:8000',  // Android emulator
// OR
defaultValue: 'http://localhost:8000',  // iOS simulator
```

### Production

Backend `.env`:
```env
GEMINI_API_KEY=your_prod_key
DEVICE=cpu
RATE_LIMIT_RPM=12
ALLOWED_ORIGINS=https://your-flutter-domain.com
```

Frontend `api_service.dart`:
```dart
defaultValue: 'https://your-railway-url.railway.app',
```

## Next Steps

1. ✅ Backend is running at `http://localhost:8000`
2. ✅ Frontend is configured to connect
3. 🔲 Add your Gemini API key to backend `.env`
4. 🔲 Run Flutter app and test sending messages
5. 🔲 Deploy backend to Railway
6. 🔲 Update frontend URL to production
7. 🔲 Deploy Flutter app to app stores

## Quick Start

```bash
# Terminal 1: Start Backend
cd d:\Projects\HimalyanGPT\Backend
python main.py

# Terminal 2: Start Frontend
cd d:\Projects\HimalyanGPT\Frontend\himalyangpt
flutter run
```

Then open a message and start chatting! 🎉
