/**
 * Shim legado — reexporta o Catechism do módulo Catequese.
 *
 * App.tsx importa daqui quando VITE_MODULES_CATEQUESE != '1'.
 * Após CQ-1.4 (feature flag removida), remover este arquivo
 * e atualizar o import em App.tsx para apontar direto ao módulo.
 */
export { default } from '@/modules/catequese/reader/Catechism';
