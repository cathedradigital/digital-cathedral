/**
 * Cathedra · Módulo Catequese — barrel canônico.
 *
 * Usado por App.tsx via feature flag VITE_MODULES_CATEQUESE.
 * CatequeseExport é o export canônico do módulo — mantém compatibilidade
 * com quem usava o shim AtriumCatechismReader como landing do Catecismo.
 *
 * Shim removido em CQ-1.4: AtriumCatechismReader agora é import estático
 * dentro do próprio módulo (a lazy import causava falha de chunk dinâmico).
 */

// Landing + reader do Catecismo (via AtriumCatechismReader)
export { default as Catechism } from './reader/Catechism';
export { default as AtriumCatechismReader } from './reader/AtriumCatechismReader';
export { default as CatechismExplorer } from './explorer/CatechismExplorer';

// Admin
export { default as CatechismImportQueue } from './admin/CatechismImportQueue';
