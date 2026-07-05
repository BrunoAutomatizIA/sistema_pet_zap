# Pet_zap

Projeto Pet Zap: dashboard administrativo e bot WhatsApp para pet shop, inspirado no fluxo do Escola_zap.

## O que está incluído

- `index.html` — dashboard SPA para gerenciar produtos, grooming, agendamentos e clientes.
- `schema.sql` — script de criação de tabelas Supabase para clientes, produtos, pedidos e agendamentos.
- `bot_pet.json` — workflow n8n inicial do bot WhatsApp.
- `notificacao_webhook.json` — workflow n8n de webhook para envio de mensagens WhatsApp a partir do dashboard.
- `specs/` — specs de produto e bot para guiar a implementação.
- `tasks.md` — backlog inicial de prioridades.

## Como usar

1. Abra `index.html` no browser para visualizar o dashboard.
2. Importe `bot_pet.json` e `notificacao_webhook.json` no n8n.
3. Crie o schema no Supabase com `schema.sql`.
4. Ajuste as URLs e chaves no dashboard e no bot para seu projeto Supabase/Evolution API.
