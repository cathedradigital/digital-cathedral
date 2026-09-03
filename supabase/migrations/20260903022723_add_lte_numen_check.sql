-- Adiciona CHECK LTE (numero >= 0) na tabela user_reading_progress
ALTER TABLE public.user_reading_progress
ADD CONSTRAINT lte_numen CHECK (numero >= 0);
