# Vercel Production Deployment

## Target architecture

```text
GitHub main
   ↓
GitHub Actions
   ↓
npm ci
   ↓
typecheck
   ↓
lint
   ↓
tests
   ↓
build
   ↓
Vercel Production
```

## Required Vercel environment variables

Configure these in the Vercel project settings. Never commit their values to Git.

- `SUPABASE_URL`
- `SUPABASE_PUBLISHABLE_KEY`
- `SUPABASE_SERVICE_ROLE_KEY` — server-only; never expose as `VITE_*`
- `VITE_SUPABASE_URL`
- `VITE_SUPABASE_PUBLISHABLE_KEY`
- OAuth variables actually used by the application
- `VITE_SENTRY_DSN` if Sentry is enabled

## Security rules

- Never configure `SUPABASE_SERVICE_ROLE_KEY` as a `VITE_*` variable.
- Never place production secrets in `.env.example`.
- Do not copy production secrets into GitHub Actions logs.
- Use Preview-specific environment values where the Supabase project requires isolation.

## Verification

A deployment is considered verified only after:

1. GitHub Actions is green.
2. Vercel reports a successful deployment.
3. The production URL loads the application.
4. Authentication is tested.
5. Public content is readable.
6. Private user data remains protected by RLS.
7. No browser bundle contains a service-role key.
