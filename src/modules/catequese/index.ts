/**
 * Cathedra · Módulo Catequese — barrel canônico.
 *
 * Usado por App.tsx via feature flag VITE_MODULES_CATEQUESE.
 * Quando a flag é 0, App.tsx usa o shim legado em
 * src/components/cathedra/Catechism.tsx (que reexporta daqui).
 */

export { default as Catechism } from './reader/Catechism';
export { default as AtriumCatechismReader } from './reader/AtriumCatechismReader';
export { default as CatechismExplorer } from './explorer/CatechismExplorer';

// Admin
// O import dinâmico em App.tsx usa .then(m => ({ default: m.CatechismImportQueue }))
// que funciona porque é uma reexport default.
export { default as CatechismImportQueue } from './admin/CatechismImportQueue';
