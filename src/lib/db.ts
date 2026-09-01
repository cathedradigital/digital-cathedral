/**
 * Ponte de tipagem da clonagem do Catedra Digital.
 *
 * O schema original (159 tabelas) está sendo aplicado no Lovable Cloud em 20
 * lotes de migração. Enquanto ele não estiver completo, o `Database` gerado em
 * `src/integrations/supabase/types.ts` não conhece as tabelas ainda ausentes e
 * o supabase-js resolve `.from('x')` como `never`, travando o build inteiro.
 *
 * Este módulo reexporta o MESMO cliente gerado, apenas com a tipagem relaxada,
 * para que as ~300 telas clonadas compilem durante a migração. Não há mudança
 * de runtime: é exatamente o cliente de `@/integrations/supabase/client`, com
 * a mesma sessão, a mesma chave publicável e a mesma RLS.
 *
 * Quando os 20 lotes estiverem aplicados, o tipo `Database` passa a cobrir todo
 * o schema e este arquivo pode voltar a reexportar o cliente tipado — trocando
 * o `as unknown as LooseClient` por `generatedClient` — sem tocar nas telas.
 */
import { supabase as generatedClient } from '../integrations/supabase/client';

/* eslint-disable @typescript-eslint/no-explicit-any */

/** Cliente com nomes de tabela/RPC ainda não presentes no schema gerado. */
type LooseClient = Omit<typeof generatedClient, 'from' | 'rpc'> & {
  from: (table: string) => any;
  rpc: (fn: string, args?: Record<string, any>, opts?: Record<string, any>) => any;
};

export const supabase = generatedClient as unknown as LooseClient;

export default supabase;
