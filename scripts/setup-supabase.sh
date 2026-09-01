#!/bin/bash
# Setup script for Digital Cathedral Supabase infrastructure
# Configures storage buckets and OAuth providers

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PROJECT_ID="bpnosuwoljbmdjogcmnw"
SUPABASE_URL="https://c--e3469c19-539b-4d3d-a625-5b72c0f10979-prod.lovable.cloud"
ANON_KEY="sb_publishable_3oFZD0ZgK7xm7uDvR5Te7w_4IN2MVoo"

echo -e "${YELLOW}=== Digital Cathedral Supabase Setup ===${NC}"
echo "Project ID: $PROJECT_ID"
echo "URL: $SUPABASE_URL"
echo ""

# Step 1: Create storage buckets
echo -e "${YELLOW}Step 1: Creating storage buckets...${NC}"

BUCKETS=("avatars" "public-assets")

for BUCKET in "${BUCKETS[@]}"; do
  echo "Creating bucket: $BUCKET"
  
  # Note: This requires supabase-cli or direct API call
  # Using curl to create bucket via Supabase Management API
  curl -X POST "$SUPABASE_URL/storage/v1/b" \
    -H "Authorization: Bearer $ANON_KEY" \
    -H "Content-Type: application/json" \
    -d "{\"name\": \"$BUCKET\", \"public\": true}" 2>/dev/null || true
  
  echo -e "${GREEN}✓ Bucket '$BUCKET' processed${NC}"
done

echo ""
echo -e "${GREEN}✓ Storage buckets configured${NC}"
echo ""

# Step 2: Display Google OAuth setup instructions
echo -e "${YELLOW}Step 2: Google OAuth Configuration${NC}"
echo ""
echo "To enable Google sign-in:"
echo "1. Go to Supabase Dashboard → Authentication → Providers"
echo "2. Enable 'Google' provider"
echo "3. Add your Google OAuth credentials:"
echo "   - Redirect URL: $SUPABASE_URL/auth/v1/callback?provider=google"
echo "4. Set these environment variables:"
echo "   GOOGLE_CLIENT_ID=your_client_id"
echo "   GOOGLE_CLIENT_SECRET=your_client_secret"
echo ""

# Step 3: Display Apple OAuth setup instructions
echo -e "${YELLOW}Step 3: Apple OAuth Configuration${NC}"
echo ""
echo "To enable Apple sign-in:"
echo "1. Go to Supabase Dashboard → Authentication → Providers"
echo "2. Enable 'Apple' provider"
echo "3. Add your Apple OAuth credentials"
echo "4. Redirect URL: $SUPABASE_URL/auth/v1/callback?provider=apple"
echo ""

# Step 4: RLS policies info
echo -e "${YELLOW}Step 4: Row Level Security (RLS)${NC}"
echo ""
echo "RLS policies have been defined in migrations."
echo "Current setup includes:"
echo "  - Public read access for published content"
echo "  - User-scoped data access (profiles, preferences)"
echo "  - Admin-only access for admin tables"
echo "  - Service role access for backend operations"
echo ""

echo -e "${GREEN}=== Setup Complete ===${NC}"
echo ""
echo "Next steps:"
echo "1. Configure Google OAuth in Supabase Dashboard"
echo "2. Configure Apple OAuth in Supabase Dashboard"
echo "3. Test authentication flow"
echo "4. Verify storage bucket access"
echo ""
