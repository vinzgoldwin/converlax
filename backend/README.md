# Converlax AI Feedback Backend

Small Node/Fastify service that keeps the OpenRouter API key on the server and returns structured speaking feedback to the iOS app.

## Local Setup

```bash
cd backend
npm install
cp .env.example .env
```

Edit `.env` and set:

```bash
OPENROUTER_API_KEY=sk-or-...
```

Run the service:

```bash
npm run dev
```

The backend listens on `http://127.0.0.1:8787` by default. The iOS simulator can call that URL directly.

## Endpoints

Health check:

```bash
curl http://127.0.0.1:8787/health
```

AI feedback:

```bash
curl -X POST http://127.0.0.1:8787/v1/feedback \
  -H "Content-Type: application/json" \
  -d '{
    "transcript": "I go to the store yesterday and buy coffee.",
    "context": {
      "mode": "Free Talk",
      "prompt": "Tell me about your day using one sentence.",
      "targetLanguage": "English",
      "proficiencyLevel": "A2"
    }
  }'
```

Successful responses always use:

```json
{
  "ok": true,
  "feedback": {
    "overallSpeakingConfidence": 82,
    "pronunciationNotes": "Keep the final word clear.",
    "grammarCorrection": "I went to the store yesterday and bought coffee.",
    "naturalVersion": "I went to the store yesterday and picked up a coffee.",
    "vocabularyImprovement": "Use 'picked up' for buying something quickly.",
    "fluencyTip": "Pause after 'yesterday' before adding the detail.",
    "didWell": "You shared a complete idea.",
    "tryNext": "Use past-tense verbs in your next attempt.",
    "suggestedSavedPhrase": "I picked up a coffee.",
    "reviewItemSuggestion": {
      "prompt": "Say this in the past: I go to the store yesterday.",
      "answer": "I went to the store yesterday."
    }
  },
  "meta": {
    "provider": "openrouter",
    "model": "openai/gpt-5.2",
    "requestId": "gen-..."
  }
}
```

Errors always use:

```json
{
  "ok": false,
  "error": {
    "code": "RATE_LIMITED",
    "message": "Too many feedback requests. Please wait a moment and try again.",
    "retryable": true
  }
}
```

## Configuration

Environment variables:

- `OPENROUTER_API_KEY`: required for `/v1/feedback`.
- `OPENROUTER_MODEL`: defaults to `openai/gpt-5.2`.
- `OPENROUTER_BASE_URL`: defaults to `https://openrouter.ai/api/v1`.
- `OPENROUTER_TIMEOUT_MS`: defaults to `15000`.
- `PORT`: defaults to `8787`.
- `RATE_LIMIT_MAX`: defaults to `30`.
- `RATE_LIMIT_WINDOW`: defaults to `1 minute`.
- `CORS_ORIGIN`: optional browser origin allowlist.

No secrets should be committed. `.env` is ignored.

## Production Notes

- Deploy this service where environment variables can be stored securely.
- Set `OPENROUTER_API_KEY` in the deployment environment, not in the iOS app.
- Put the service behind HTTPS before using it from a physical device or production build.
- Keep logs at request metadata level. The service logs transcript length and context labels, not transcript content.
- Tune `RATE_LIMIT_MAX` and `RATE_LIMIT_WINDOW` for your expected traffic.

OpenRouter API reference: https://openrouter.ai/docs/api/api-reference/chat/send-chat-completion-request
