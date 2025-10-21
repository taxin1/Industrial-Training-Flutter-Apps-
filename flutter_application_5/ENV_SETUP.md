# Environment Setup

This project uses environment variables to store sensitive configuration like API keys.

## Setup Instructions

1. **Copy the example environment file:**
   ```bash
   cp .env.example .env
   ```

2. **Edit the `.env` file and add your actual Supabase credentials:**
   ```
   SUPABASE_URL=your_actual_supabase_url
   SUPABASE_ANON_KEY=your_actual_supabase_anon_key
   ```

3. **Get your Supabase credentials:**
   - Go to [Supabase Dashboard](https://supabase.com/dashboard)
   - Select your project
   - Go to Settings → API
   - Copy the "Project URL" and "anon/public" key

## Important Notes

- **Never commit `.env` file to version control**
  - The `.env` file is already added to `.gitignore`
  - Only commit `.env.example` as a template

- **Share credentials securely**
  - Don't share credentials via email or public channels
  - Use secure methods like password managers or encrypted channels

- **Validate environment variables**
  - The app validates required environment variables on startup
  - If validation fails, you'll see an error in the console

## File Structure

```
├── .env                 # Your actual environment variables (not in git)
├── .env.example         # Template for environment variables (in git)
├── lib/
│   └── config/
│       └── env_config.dart  # Environment configuration helper
```

## Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `SUPABASE_URL` | Your Supabase project URL | Yes |
| `SUPABASE_ANON_KEY` | Your Supabase anonymous/public key | Yes |
