import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';

const read = (path) => fs.readFileSync(new URL(`../${path}`, import.meta.url), 'utf8');

test('service-role client is server-only and uses a non-VITE secret', () => {
  const source = read('src/integrations/supabase/client.server.ts');
  assert.match(source, /SUPABASE_SERVICE_ROLE_KEY/);
  assert.doesNotMatch(source, /VITE_SUPABASE_SERVICE_ROLE_KEY/);
  assert.match(source, /persistSession:\s*false/);
});

test('browser Supabase client uses only publishable credentials', () => {
  const source = read('src/integrations/supabase/client.ts');
  assert.match(source, /VITE_SUPABASE_PUBLISHABLE_KEY/);
  assert.doesNotMatch(source, /SERVICE_ROLE_KEY/);
});

test('environment template contains no concrete secret values', () => {
  const source = read('.env.example');
  assert.match(source, /SUPABASE_SERVICE_ROLE_KEY=/);
  assert.doesNotMatch(source, /SUPABASE_SERVICE_ROLE_KEY=\S+/);
  assert.doesNotMatch(source, /VITE_SUPABASE_PUBLISHABLE_KEY=\S+/);
});

test('security hardening migration centralizes admin checks on user_roles', () => {
  const files = fs.readdirSync(new URL('../supabase/migrations/', import.meta.url));
  const hardening = files.find((name) => name.includes('security_hardening'));
  assert.ok(hardening, 'security hardening migration must exist');
  const source = read(`supabase/migrations/${hardening}`);
  assert.match(source, /FROM public\.user_roles/);
  assert.match(source, /auth_internal\.has_role\(auth\.uid\(\), 'admin'/);
  assert.match(source, /user_sensitive_data_select_own/);
  assert.match(source, /REVOKE ALL ON public\.user_sensitive_data FROM anon/);
});
