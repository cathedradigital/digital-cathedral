# Segurança

## Prioridade P0

- `.env` não deve ser rastreado;
- credenciais privadas devem ser rotacionadas se houver exposição;
- histórico Git deve ser verificado em caso de segredo previamente commitado;
- `.env.example` deve conter somente nomes de variáveis e placeholders.

## Supabase

Auditar RLS tabela por tabela:
- profiles;
- favorites;
- history;
- progress;
- subscriptions;
- dados administrativos;
- conteúdo;
- configurações.

## Edge Functions

Para cada função:
- definir se é pública ou autenticada;
- validar entrada;
- limitar abuso;
- verificar autorização;
- evitar exposição de dados;
- registrar erros sem vazar segredos.

## IA

Não enviar dados privados ao modelo sem necessidade e consentimento apropriado. Não tratar resposta do modelo como autoridade doutrinal.

## CI/CD

Segredos devem viver nos mecanismos de secrets do provedor, nunca no código ou logs.
