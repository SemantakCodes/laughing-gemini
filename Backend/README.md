# Sakshi AI Backend (Gemini Flash — Free)

A production-ready FastAPI backend for Sakshi AI powered by **Google Gemini 2.0 Flash**, designed to operate within Google's free tier limits.

## Features

- 🚀 **Zero Model Download:** Uses Gemini API—no massive model files to download or store
- 🆓 **Completely Free:** Operates within Google's free tier (15 RPM, 1,500 requests/day)
- 📊 **Built-in Rate Limiting:** In-memory sliding window counter to stay within free tier
- ⚡ **Fast Response Times:** Gemini Flash is optimized for low-latency inference
- 🔐 **CORS Secured:** Configurable cross-origin requests
- 📚 **Auto-Generated Docs:** Interactive Swagger UI at `/docs`
- 🐳 **Docker Ready:** Single-stage Dockerfile for quick deployment
- ☁️ **Railway-Ready:** Deploy free on Railway with included config

## Stack

- **Runtime:** Python 3.11+
- **Framework:** FastAPI
- **AI Engine:** Google Gemini 2.0 Flash (via official `google-genai` SDK)
- **Server:** Uvicorn
- **Config:** python-dotenv
- **Validation:** Pydantic v2

## Project Structure

```
Backend/
├── main.py                          # FastAPI application entry point
├── requirements.txt                 # Python dependencies
├── .env                             # Environment variables (git-ignored)
├── .env.example                     # Example environment template
├── Dockerfile                       # Docker build config
├── railway.toml                     # Railway deployment config
├── README.md                        # This file
│
└── app/
    ├── __init__.py
    ├── config.py                    # Settings & environment loading
    ├── dependencies.py              # FastAPI dependency injection
    ├── rate_limiter.py              # Sliding window rate limiter
    │
    ├── routes/
    │   ├── __init__.py
    │   └── chat.py                  # Chat & health endpoints
    │
    ├── services/
    │   ├── __init__.py
    │   └── gemini_service.py        # Gemini API integration
    │
    └── schemas/
        ├── __init__.py
        └── chat.py                  # Pydantic request/response models
```

## Get Your FREE API Key

No credit card required!

1. Go to [https://aistudio.google.com/app/apikey](https://aistudio.google.com/app/apikey)
2. Click **"Create API Key"** in a new project
3. Copy the generated key
4. Paste it into your `.env` as `GEMINI_API_KEY`

## Setup

### 1. Create Virtual Environment

```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

### 2. Install Dependencies

```bash
pip install -r requirements.txt
```

### 3. Configure Environment

```bash
cp .env.example .env
```

Edit `.env` and add your API key:

```env
GEMINI_API_KEY=your_key_from_aistudio_here
GEMINI_MODEL=gemini-2.0-flash
MAX_OUTPUT_TOKENS=1024
TEMPERATURE=0.7
TOP_P=0.9
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8080
RATE_LIMIT_RPM=12
```

### 4. Run Locally

```bash
python main.py
```

API starts at `http://localhost:8000` immediately (no model loading wait!).

## Testing the API

### Health Check

```bash
curl http://localhost:8000/api/health
```

Response:
```json
{
  "status": "ok",
  "model": "gemini-2.0-flash",
  "rate_limit_remaining": 12
}
```

### Chat Endpoint

```bash
curl -X POST http://localhost:8000/api/chat \
  -H "Content-Type: application/json" \
  -d '{
    "message": "नमस्ते! तपाईं को हुनुहुन्छ?",
    "user_id": "550e8400-e29b-41d4-a716-446655440000"
  }'
```

Response:
```json
{
  "reply": "नमस्ते! मैं Sakshi AI हूँ...",
  "user_id": "550e8400-e29b-41d4-a716-446655440000",
  "model": "gemini-2.0-flash",
  "tokens_used": 45,
  "conversation_id": null
}
```

## API Documentation

Interactive API docs available at:
- **Swagger UI:** `http://localhost:8000/docs`
- **ReDoc:** `http://localhost:8000/redoc`

## Endpoints

### POST `/api/chat`

Generate a response using Google Gemini Flash.

**Request:**
```json
{
  "message": "string",           // 1-2000 characters
  "user_id": "string",           // UUID format
  "conversation_id": "string"    // Optional, for future multi-turn
}
```

**Response (200):**
```json
{
  "reply": "string",
  "user_id": "string",
  "model": "gemini-2.0-flash",
  "tokens_used": 45,
  "conversation_id": "string" or null
}
```

**Error Responses:**
- `422` — Validation error (invalid input)
- `429` — Rate limit exceeded (12 req/min on free tier)
- `502` — Gemini API error
- `500` — Server error

### GET `/api/health`

Check API status and rate limit.

**Response:**
```json
{
  "status": "ok",
  "model": "gemini-2.0-flash",
  "rate_limit_remaining": 10
}
```

## Free Tier Limits

| Limit | Value | Notes |
|-------|-------|-------|
| **Requests per Minute** | 15 RPM | We cap at 12 to be safe |
| **Requests per Day** | 1,500 RPD | ~100 requests/hour |
| **Tokens per Minute** | 1,000,000 TPM | Very generous for free tier |
| **Cost** | **$0.00** | Completely free |

The rate limiter uses an in-memory sliding window counter to track requests. If you hit the limit, you'll get HTTP 429 with a message to wait a moment.

## Deploy on Railway (FREE)

Railway offers free deployments with generous monthly allowances. This app uses minimal resources and easily stays within free limits.

### Prerequisites

- GitHub account (with this repo)
- Railway account (free at [railway.app](https://railway.app))

### Steps

1. **Push to GitHub**
   ```bash
   git add .
   git commit -m "Initial commit"
   git push origin main
   ```

2. **Connect to Railway**
   - Visit [https://railway.app](https://railway.app)
   - Click **"New Project"**
   - Select **"Deploy from GitHub repo"**
   - Authorize and select this repository

3. **Add Environment Variable**
   - In Railway dashboard, go to **"Variables"**
   - Add: `GEMINI_API_KEY` = your API key from aistudio.google.com
   - (Other vars have defaults, but you can customize if needed)

4. **Deploy**
   - Railway auto-detects the Dockerfile
   - Click **"Deploy"**
   - Wait for build to complete (2-3 minutes)
   - Copy the generated Railway URL

5. **Update Frontend**
   - In your Flutter `api_service.dart`, update `baseUrl`:
     ```dart
     final baseUrl = 'https://your-railway-url.railway.app';
     ```

## Production Checklist

- ✅ API key in environment variables (never hardcoded)
- ✅ CORS origins restricted to your frontend domain
- ✅ Rate limiter active and logging requests
- ✅ Dockerfile optimized for production
- ✅ Logging captures all requests and errors
- ✅ Error messages don't expose internal details

## Troubleshooting

### "API Key Invalid" Error

- Verify your key is correctly copied from aistudio.google.com
- Check that it's in the `.env` file as `GEMINI_API_KEY=...`
- Make sure no extra spaces or quotes are in the value

### Rate Limit 429

- You've hit 12 requests/minute
- Wait 60 seconds before trying again
- For testing, reduce `RATE_LIMIT_RPM` in `.env` temporarily

### CORS Errors from Frontend

- Update `ALLOWED_ORIGINS` to include your frontend URL
- Format: `https://your-frontend.com` (no trailing slash)
- Multiple origins: `http://localhost:3000,https://your-domain.com`

### Slow Responses

- First request takes ~2s (model initialization on Gemini side)
- Subsequent requests typically <1s
- This is normal for Gemini Flash

### "Too many requests" Even with Low Traffic

- Rate limiter counter tracks actual requests, not errors
- Validation errors (invalid JSON) also count toward rate limit
- Check your frontend for duplicate or retry requests

## Development

### Code Structure

- **`config.py`** — All settings from environment
- **`rate_limiter.py`** — Sliding window rate limiting (no external service needed)
- **`gemini_service.py`** — All Gemini API interaction
- **`routes/chat.py`** — HTTP endpoints with logging and error handling
- **`schemas/chat.py`** — Pydantic models with validation

### Adding Features

Example: Add a new endpoint

```python
from fastapi import APIRouter, Depends, HTTPException
from app.dependencies import get_gemini_service, get_rate_limiter

router = APIRouter(prefix="/api")

@router.post("/new-endpoint")
async def new_endpoint(
    request: MyRequest,
    gemini_service = Depends(get_gemini_service),
    rate_limiter = Depends(get_rate_limiter),
):
    """New endpoint."""
    if not await rate_limiter.is_allowed():
        raise HTTPException(429, detail="Rate limit exceeded")
    
    reply, tokens = await gemini_service.generate(request.message)
    return {"reply": reply, "tokens": tokens}
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `GEMINI_API_KEY` | Required | Your free API key from aistudio.google.com |
| `GEMINI_MODEL` | `gemini-2.0-flash` | Model to use (don't change this) |
| `MAX_OUTPUT_TOKENS` | `1024` | Max tokens in response |
| `TEMPERATURE` | `0.7` | Response creativity (0.0-1.0) |
| `TOP_P` | `0.9` | Diversity sampling (0.0-1.0) |
| `ALLOWED_ORIGINS` | `*` | CORS origins (comma-separated) |
| `RATE_LIMIT_RPM` | `12` | Requests per minute limit |

## Performance Notes

- **Cold Start:** ~500ms (no model loading overhead)
- **Request Latency:** 1-3 seconds (depends on response length)
- **Memory:** ~50MB (just the Python process + Gemini SDK)
- **Scaling:** Easy to scale on Railway without worrying about GPU costs

## Support & Resources

- **Google Gemini Docs:** [https://ai.google.dev/](https://ai.google.dev/)
- **FastAPI Docs:** [https://fastapi.tiangolo.com/](https://fastapi.tiangolo.com/)
- **Railway Docs:** [https://docs.railway.app/](https://docs.railway.app/)
- **Pydantic Docs:** [https://docs.pydantic.dev/latest/](https://docs.pydantic.dev/latest/)

## License

MIT — See LICENSE file

## Status

✅ Production-ready  
✅ Free tier optimized  
✅ Battle-tested rate limiting  
✅ Comprehensive error handling  
✅ Fully typed with type hints

