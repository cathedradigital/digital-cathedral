/**
 * Cathedra · Módulo Catequese — rotas (CQ-1.4 stable).
 *
 * Consumido opcionalmente por `src/App.tsx` quando `VITE_MODULES_CATEQUESE=1`.
 * Imports estáticos (não lazy) — chunk dinâmico foi causa de RUNTIME_ERROR em deploy.
 */

import React from 'react';
import { Navigate, Route, Routes } from '@/lib/rr-compat';
import { CatechismSkeleton } from '@/components/cathedra/RouteSkeletons';

// Importações estáticas — evitam chunk dinâmico que falhava no deploy.
import AtriumCatechismReader from './reader/AtriumCatechismReader';
import Catechism from './reader/Catechism';

const CatequeseRoutes: React.FC = () => (
  <Routes>
    <Route
      path="catechism"
      element={<AtriumCatechismReader />}
    />
    <Route
      path="catechism-legacy"
      element={<Catechism />}
    />
    <Route path="catecismo" element={<Navigate to="/catechism" replace />} />
    <Route
      path="catechism-explorer"
      element={<Navigate to="/catechism" replace />}
    />
  </Routes>
);

export default CatequeseRoutes;
