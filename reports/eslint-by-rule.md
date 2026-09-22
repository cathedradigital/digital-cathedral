# ESLint report grouped by rule

- ESLint exit code: 1
- Raw report: [eslint.json](./eslint.json)
- Generated: 2026-09-22T01:36:51Z

## Summary

- Total diagnostics: 1227
- Errors: 1068
- Warnings: 159
- Rules with diagnostics: 14

## By rule

| Rule | Total | Errors | Warnings | Files |
|---|---:|---:|---:|---:|
| `@typescript-eslint/no-explicit-any` | 937 | 937 | 0 | 243 |
| `react-hooks/exhaustive-deps` | 92 | 0 | 92 | 61 |
| `prettier/prettier` | 73 | 73 | 0 | 2 |
| `react-refresh/only-export-components` | 43 | 0 | 43 | 25 |
| `no-empty` | 34 | 34 | 0 | 11 |
| `unknown` | 24 | 0 | 24 | 16 |
| `react-hooks/rules-of-hooks` | 8 | 8 | 0 | 5 |
| `@typescript-eslint/no-unused-expressions` | 4 | 4 | 0 | 4 |
| `@typescript-eslint/no-empty-object-type` | 3 | 3 | 0 | 3 |
| `prefer-const` | 3 | 3 | 0 | 3 |
| `@typescript-eslint/no-require-imports` | 2 | 2 | 0 | 2 |
| `no-control-regex` | 2 | 2 | 0 | 1 |
| `@typescript-eslint/ban-ts-comment` | 1 | 1 | 0 | 1 |
| `no-useless-escape` | 1 | 1 | 0 | 1 |

## Examples

### `@typescript-eslint/no-explicit-any`

- `src/App.tsx:90:31` — Unexpected any. Specify a different type.
- `src/App.tsx:95:35` — Unexpected any. Specify a different type.
- `src/App.tsx:100:31` — Unexpected any. Specify a different type.
- `src/App.tsx:461:34` — Unexpected any. Specify a different type.
- `src/components/admin/DoctorReviewQueue.tsx:123:78` — Unexpected any. Specify a different type.
- `src/components/admin/DoctorReviewQueue.tsx:135:78` — Unexpected any. Specify a different type.
- `src/components/admin/DoctorReviewQueue.tsx:137:32` — Unexpected any. Specify a different type.
- `src/components/admin/LandingAnalyticsDashboard.tsx:20:31` — Unexpected any. Specify a different type.
- `src/components/admin/LandingAnalyticsDashboard.tsx:30:43` — Unexpected any. Specify a different type.
- `src/components/admin/LeadsDashboard.tsx:31:36` — Unexpected any. Specify a different type.

### `react-hooks/exhaustive-deps`

- `src/components/admin/pg-stats/IntervalCompareCard.tsx:140:59` — React Hook useMemo has a missing dependency: 'filterByRange'. Either include it or remove the dependency array.
- `src/components/admin/pg-stats/IntervalCompareCard.tsx:141:59` — React Hook useMemo has a missing dependency: 'filterByRange'. Either include it or remove the dependency array.
- `src/components/cathedra/AZFaithPage.tsx:43:9` — The 'allTerms' logical expression could make the dependencies of useEffect Hook (at line 75) change on every render. To fix this, wrap the initialization of 'allTerms' in its own useMemo() Hook.
- `src/components/cathedra/AZFaithPage.tsx:43:9` — The 'allTerms' logical expression could make the dependencies of useMemo Hook (at line 91) change on every render. To fix this, wrap the initialization of 'allTerms' in its own useMemo() Hook.
- `src/components/cathedra/AZFaithPage.tsx:53:6` — React Hook useMemo has a missing dependency: 'alphabet'. Either include it or remove the dependency array.
- `src/components/cathedra/AchievementsPage.tsx:22:6` — React Hook useEffect has a missing dependency: 'loadAchievements'. Either include it or remove the dependency array.
- `src/components/cathedra/AdminCrmRetention.tsx:394:6` — React Hook useMemo has a missing dependency: 'MONTH_ABBR'. Either include it or remove the dependency array.
- `src/components/cathedra/AdminDashboard.tsx:78:9` — The 'users' logical expression could make the dependencies of useMemo Hook (at line 146) change on every render. To fix this, wrap the initialization of 'users' in its own useMemo() Hook.
- `src/components/cathedra/AdminGuard.tsx:37:6` — React Hook useEffect has a missing dependency: 'user'. Either include it or remove the dependency array.
- `src/components/cathedra/AudioContentPlayer.tsx:70:6` — React Hook useEffect has missing dependencies: 'isPlaying', 'lastPosition', and 'wasPlayingBeforeSilence'. Either include them or remove the dependency array.

### `prettier/prettier`

- `public/sw-push.js:19:19` — Replace `⏎····self.registration.showNotification(data.title·||·"Cathedra",·options)⏎··` with `self.registration.showNotification(data.title·||·"Cathedra",·options)`
- `public/sw-push.js:33:7` — Insert `,`
- `tailwind.config.legacy.ts:5:13` — Replace `"./pages/**/*.{ts,tsx}",·"./components/**/*.{ts,tsx}",·"./app/**/*.{ts,tsx}",·"./src/**/*.{ts,tsx}"` with `⏎····"./pages/**/*.{ts,tsx}",⏎····"./components/**/*.{ts,tsx}",⏎····"./app/**/*.{ts,tsx}",⏎····"./src/**/*.{ts,tsx}",⏎··`
- `tailwind.config.legacy.ts:107:9` — Replace `'spacing-0':·'0px'` with `"spacing-0":·"0px"`
- `tailwind.config.legacy.ts:108:9` — Replace `'spacing-px':·'1px'` with `"spacing-px":·"1px"`
- `tailwind.config.legacy.ts:109:9` — Replace `'spacing-3xs':·'var(--spacing-3xs)'` with `"spacing-3xs":·"var(--spacing-3xs)"`
- `tailwind.config.legacy.ts:110:9` — Replace `'spacing-2xs':·'var(--spacing-2xs)'` with `"spacing-2xs":·"var(--spacing-2xs)"`
- `tailwind.config.legacy.ts:111:9` — Replace `'spacing-xs':·'var(--spacing-xs)'` with `"spacing-xs":·"var(--spacing-xs)"`
- `tailwind.config.legacy.ts:112:9` — Replace `'spacing-sm':·'var(--spacing-sm)'` with `"spacing-sm":·"var(--spacing-sm)"`
- `tailwind.config.legacy.ts:113:9` — Replace `'spacing-md':·'var(--spacing-md)'` with `"spacing-md":·"var(--spacing-md)"`

### `react-refresh/only-export-components`

- `src/components/PreviewRecoveryControls.tsx:33:23` — Fast refresh only works when a file only exports components. Use a new file to share constants or functions between components.
- `src/components/cathedra/BubbleTag.tsx:62:14` — Fast refresh only works when a file only exports components. Use a new file to share constants or functions between components.
- `src/components/cathedra/BubbleTag.tsx:67:14` — Fast refresh only works when a file only exports components. Use a new file to share constants or functions between components.
- `src/components/cathedra/GlossaryPage.tsx:32:17` — Fast refresh only works when a file only exports components. Use a new file to share constants or functions between components.
- `src/components/cathedra/NexusDebugPanel.tsx:23:17` — Fast refresh only works when a file only exports components. Use a new file to share constants or functions between components.
- `src/components/cathedra/PricingPage.tsx:32:14` — Fast refresh only works when a file only exports components. Use a new file to share constants or functions between components.
- `src/components/cathedra/SpiritualQuiz.tsx:36:14` — Fast refresh only works when a file only exports components. Use a new file to share constants or functions between components.
- `src/components/cathedra/StaggeredList.tsx:57:33` — Fast refresh only works when a file only exports components. Use a new file to share constants or functions between components.
- `src/components/editorial/index.tsx:20:1` — This rule can't verify that `export *` only exports components.
- `src/components/landing/LandingFAQ.tsx:16:14` — Fast refresh only works when a file only exports components. Use a new file to share constants or functions between components.

### `no-empty`

- `src/components/MaintenanceGate.tsx:28:11` — Empty block statement.
- `src/components/MaintenanceGate.tsx:37:11` — Empty block statement.
- `src/components/MaintenanceGate.tsx:41:11` — Empty block statement.
- `src/components/PreviewRecoveryControls.tsx:18:11` — Empty block statement.
- `src/components/PreviewRecoveryControls.tsx:37:11` — Empty block statement.
- `src/components/PreviewRecoveryControls.tsx:41:11` — Empty block statement.
- `src/components/cathedra/Bible.tsx:306:21` — Empty block statement.
- `src/components/cathedra/Bible.tsx:2444:63` — Empty block statement.
- `src/components/cathedra/MissaContinuousReader.tsx:329:15` — Empty block statement.
- `src/components/cathedra/MissaContinuousReader.tsx:338:13` — Empty block statement.

### `unknown`

- `src/components/cathedra/AppErrorBoundary.tsx:32:5` — Unused eslint-disable directive (no problems were reported from 'no-console').
- `src/components/cathedra/AppErrorBoundary.tsx:77:7` — Unused eslint-disable directive (no problems were reported from 'no-console').
- `src/components/cathedra/BibleCacheTimeseriesDashboard.tsx:241:3` — Unused eslint-disable directive (no problems were reported from 'react-hooks/exhaustive-deps').
- `src/components/cathedra/SaintsFilters.tsx:89:5` — Unused eslint-disable directive (no problems were reported from 'react-hooks/exhaustive-deps').
- `src/features/collections/adminHooks.ts:148:7` — Unused eslint-disable directive (no problems were reported from '@typescript-eslint/no-explicit-any').
- `src/features/collections/collectionAnalytics.ts:80:7` — Unused eslint-disable directive (no problems were reported from 'no-console').
- `src/features/collections/searchCollections.ts:42:5` — Unused eslint-disable directive (no problems were reported from 'no-console').
- `src/hooks/useFuzzySearch.ts:143:5` — Unused eslint-disable directive (no problems were reported from 'react-hooks/exhaustive-deps').
- `src/hooks/useRenderPerf.ts:32:7` — Unused eslint-disable directive (no problems were reported from 'no-console').
- `src/hooks/useRenderPerf.ts:37:5` — Unused eslint-disable directive (no problems were reported from 'react-hooks/exhaustive-deps').

### `react-hooks/rules-of-hooks`

- `src/components/admin/SaintsAuditPanel.tsx:82:17` — React Hook "useMemo" is called conditionally. React Hooks must be called in the exact same order in every component render. Did you accidentally call a React Hook after an early return?
- `src/components/cathedra/MagisteriumDiagnosticPanel.tsx:175:21` — React Hook "useMemo" is called conditionally. React Hooks must be called in the exact same order in every component render.
- `src/components/cathedra/PrayerEngineReader.tsx:1087:23` — React Hook "useMemo" is called conditionally. React Hooks must be called in the exact same order in every component render. Did you accidentally call a React Hook after an early return?
- `src/components/nexus/NexusMetricsOverlay.tsx:68:27` — React Hook "React.useState" is called conditionally. React Hooks must be called in the exact same order in every component render.
- `src/components/nexus/NexusMetricsOverlay.tsx:69:27` — React Hook "React.useState" is called conditionally. React Hooks must be called in the exact same order in every component render.
- `src/components/nexus/NexusMetricsOverlay.tsx:77:3` — React Hook "React.useEffect" is called conditionally. React Hooks must be called in the exact same order in every component render.
- `src/components/nexus/NexusMetricsOverlay.tsx:79:3` — React Hook "React.useEffect" is called conditionally. React Hooks must be called in the exact same order in every component render.
- `src/pages/admin/MissionControl.tsx:168:59` — React Hook "useEditorialSummary" cannot be called inside a callback. React Hooks must be called in a React function component or a custom React Hook function.

### `@typescript-eslint/no-unused-expressions`

- `src/components/bible-perf/SqlBreakdownSection.tsx:95:5` — Expected an assignment or function call and instead saw an expression.
- `src/pages/admin/BibleGatePendencies.tsx:206:7` — Expected an assignment or function call and instead saw an expression.
- `src/pages/admin/BibleImportMissing.tsx:155:7` — Expected an assignment or function call and instead saw an expression.
- `src/pages/admin/IntegrationsStatus.tsx:212:5` — Expected an assignment or function call and instead saw an expression.

### `@typescript-eslint/no-empty-object-type`

- `src/components/cathedra/AdminDashboard.tsx:40:11` — An interface declaring no members is equivalent to its supertype.
- `src/components/cathedra/BibleVersePopover.tsx:46:11` — An interface declaring no members is equivalent to its supertype.
- `src/components/editorial/primitives.tsx:538:18` — An interface declaring no members is equivalent to its supertype.

### `prefer-const`

- `src/integrations/supabase/previewAuthStorage.ts:54:11` — 'timer' is never reassigned. Use 'const' instead.
- `src/lib/design-system-audit.ts:35:7` — 'colors' is never reassigned. Use 'const' instead.
- `src/scripts/generate-compliance-report.ts:348:5` — 'html' is never reassigned. Use 'const' instead.

### `@typescript-eslint/no-require-imports`

- `src/components/cathedra/BibleKnowledgeAudit.tsx:2305:63` — A `require()` style import is forbidden.
- `tailwind.config.legacy.ts:231:13` — A `require()` style import is forbidden.

### `no-control-regex`

- `src/lib/glossary/sanitizeFaq.ts:295:7` — Unexpected control character(s) in regular expression: \x00, \x08, \x0b, \x0c, \x0e, \x1f.
- `src/lib/glossary/sanitizeFaq.ts:345:23` — Unexpected control character(s) in regular expression: \x00, \x08, \x0b, \x0c, \x0e, \x1f.

### `@typescript-eslint/ban-ts-comment`

- `src/hooks/useWakeLock.ts:24:7` — Use "@ts-expect-error" instead of "@ts-ignore", as "@ts-ignore" will do nothing if the following line is error-free.

### `no-useless-escape`

- `src/lib/nexusContent.ts:51:76` — Unnecessary escape character: \\-.
