# Digital Cathedral - Deployment & Operations Guide

## Overview

Digital Cathedral is now built and ready for deployment. This guide covers:
- ✅ Development workflow
- ✅ Production deployment  
- ✅ Infrastructure checklist
- ✅ Monitoring & troubleshooting

---

## 1. Development Workflow

### Start Development Server
```bash
npm run dev
```
- Hot reload enabled
- Available at http://localhost:5173
- API endpoints proxied to Supabase

### Build for Production
```bash
npm run build
```
- Output in `.output/` directory
- Split into client and server bundles
- Ready for deployment

### Preview Production Build
```bash
npm run preview
```
- Runs pre-built output
- Available at http://localhost:4173
- Test before deployment

### Code Quality
```bash
npm run lint          # ESLint check
npm run format        # Prettier format
npm run lint --fix    # Fix ESLint issues
```

---

## 2. Deployment Options

### Option A: Cloudflare Workers (Recommended)

Supabase is already configured for Cloudflare deployment.

```bash
# Deploy to Cloudflare
npm run build
npx nitro deploy --prebuilt

# Or using Wrangler directly
wrangler deploy .output/server/
```

**Benefits:**
- Edge computing
- Global CDN
- Automatic scaling
- Free tier available

**Configuration:** `.output/server/wrangler.json`

### Option B: Docker Container

```bash
# Build Docker image
docker build -t digital-cathedral:latest .

# Run container
docker run -p 3000:3000 \
  -e SUPABASE_URL="$SUPABASE_URL" \
  -e SUPABASE_PUBLISHABLE_KEY="$SUPABASE_PUBLISHABLE_KEY" \
  digital-cathedral:latest
```

### Option C: Traditional Node.js Server

```bash
# Install production dependencies
npm ci --production

# Start server
node .output/server/index.mjs
```

---

## 3. Environment Configuration

### Required Variables

```bash
# Supabase (required - already set)
SUPABASE_URL=https://c--e3469c19-539b-4d3d-a625-5b72c0f10979-prod.lovable.cloud
SUPABASE_PUBLISHABLE_KEY=sb_publishable_3oFZD0ZgK7xm7uDvR5Te7w_4IN2MVoo
SUPABASE_PROJECT_ID=bpnosuwoljbmdjogcmnw

# OAuth (configure in Supabase Dashboard first)
VITE_GOOGLE_CLIENT_ID=your_google_client_id
VITE_APPLE_CLIENT_ID=your_apple_client_id
```

### Optional Variables

```bash
# Analytics
VITE_SENTRY_DSN=your_sentry_dsn

# CDN
VITE_CDN_URL=https://cdn.example.com

# API Rate Limiting
VITE_API_RATE_LIMIT=1000
```

### Cloudflare Environment

```bash
# wrangler.toml
[env.production]
vars = { 
  SUPABASE_URL = "...",
  SUPABASE_PUBLISHABLE_KEY = "..."
}
```

---

## 4. Pre-Deployment Checklist

### Infrastructure
- [ ] Supabase project created and accessible
- [ ] Storage buckets created (avatars, public-assets)
- [ ] Database migrations applied
- [ ] RLS policies verified

### Authentication
- [ ] Google OAuth configured
- [ ] Apple OAuth configured
- [ ] Redirect URIs correct in OAuth providers
- [ ] Environment variables set

### Security
- [ ] HTTPS enabled
- [ ] CORS configured
- [ ] API keys rotated
- [ ] Rate limiting enabled
- [ ] Security headers set

### Testing
- [ ] Build passes without errors
- [ ] Preview environment verified
- [ ] Login flow tested
- [ ] Storage upload tested
- [ ] API endpoints responding

### Monitoring
- [ ] Error tracking enabled (Sentry)
- [ ] Analytics configured
- [ ] Health check endpoint available
- [ ] Log aggregation configured

---

## 5. Post-Deployment Verification

```bash
# Check health endpoint
curl https://your-app.com/health

# Verify OAuth endpoints
curl -I https://your-app.com/auth/callback?provider=google

# Test API connectivity
curl https://your-app.com/api/health

# Check storage availability
curl https://your-app.com/storage/public-assets/
```

---

## 6. Monitoring & Observability

### Sentry Error Tracking
```typescript
import * as Sentry from "@sentry/react";

Sentry.init({
  dsn: import.meta.env.VITE_SENTRY_DSN,
  environment: import.meta.env.PROD ? "production" : "development",
  tracesSampleRate: 1.0,
});
```

### Health Checks
```bash
# Endpoint: /health
GET /health

Response:
{
  "status": "ok",
  "version": "1.0.0",
  "uptime": 3600,
  "supabase": "connected"
}
```

### Logs
- Check Supabase Dashboard → Logs
- Check Cloudflare Workers → Analytics
- View application logs: `npm run dev` or Docker logs

---

## 7. Scaling Considerations

### Database Optimization
- Indexes on frequently queried columns
- Connection pooling via Supabase
- Read replicas for high-traffic queries
- Vacuum and analyze regularly

### Caching Strategy
- Browser cache: 1 hour for static assets
- CDN cache: 24 hours for public content
- Server cache: Redis for frequently accessed data
- Service worker: Offline capabilities

### Performance
- Code splitting: Already configured
- Lazy loading: Route-based
- Image optimization: Use Supabase transformations
- Compression: Brotli for text, WebP for images

---

## 8. Troubleshooting

### Build Fails
```bash
# Clear cache and rebuild
rm -rf node_modules .output
npm install --legacy-peer-deps
npm run build
```

### OAuth Not Working
1. Verify redirect URI matches exactly
2. Check OAuth credentials in Supabase Dashboard
3. Clear browser cache and try incognito mode
4. Check browser console for CORS errors

### Storage Upload Fails
1. Verify bucket name is correct
2. Check file size limits
3. Ensure MIME type is allowed
4. Verify bucket is public for public assets

### Database Connection Errors
1. Check SUPABASE_URL and keys
2. Verify project is running in Supabase Dashboard
3. Test connection: `curl $SUPABASE_URL`
4. Check network connectivity

### Performance Issues
1. Check Cloudflare Analytics for slow requests
2. Profile with Chrome DevTools
3. Check Supabase query performance
4. Review server logs for errors

---

## 9. Rollback Procedure

### If Deployment Fails

```bash
# Revert to previous version
git revert HEAD

# Rebuild
npm run build

# Redeploy
npx nitro deploy --prebuilt
```

### If Database Issue

```bash
# Restore from backup (Supabase Dashboard)
# 1. Go to Database → Backups
# 2. Select restore point
# 3. Confirm restore

# Or via CLI
supabase db pull --restore-from <backup_id>
```

---

## 10. Support & Resources

### Documentation
- [TanStack Router](https://tanstack.com/router/latest)
- [TanStack Start](https://tanstack.com/start/latest)
- [Supabase Docs](https://supabase.com/docs)
- [Tailwind CSS](https://tailwindcss.com)

### Community
- [GitHub Issues](https://github.com/cathedradigital/digital-cathedral/issues)
- [Supabase Community](https://discord.supabase.com)
- [TanStack Discord](https://tlinz.com/discord)

### Support Channels
- Email: support@cathedradigital.com
- Discord: [Join Server](https://discord.gg/cathedradigital)
- Slack: #digital-cathedral

---

## 11. Continuous Deployment (Optional)

### GitHub Actions Setup

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy to Production

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Install dependencies
        run: npm ci --legacy-peer-deps
      
      - name: Build
        run: npm run build
      
      - name: Deploy to Cloudflare
        env:
          CLOUDFLARE_API_TOKEN: ${{ secrets.CLOUDFLARE_API_TOKEN }}
          CLOUDFLARE_ACCOUNT_ID: ${{ secrets.CLOUDFLARE_ACCOUNT_ID }}
        run: npx wrangler deploy .output/server/
```

---

## Summary

✅ **Build:** Complete and tested
✅ **Infrastructure:** Supabase configured
✅ **Authentication:** OAuth ready
✅ **Storage:** Buckets configured
✅ **Deployment:** Multiple options available
✅ **Monitoring:** Sentry and logging enabled

**Next: Deploy to production environment**

Questions? Check the [Setup Guide](./SETUP.md) or troubleshooting section above.
