# Handoff — Pet Zap

**Produto:** Bot de pet shop via WhatsApp (catálogo, agendamento de banho/tosa, atendimento)
**Responsável Automatiz.ia:** Bruno Vargas Joaquim
**Repositório:** https://github.com/BrunoAutomatizIA/sistema_pet_zap
**Data:** 2026-07-05
**URL publicada:** https://brunoautomatizia.github.io/sistema_pet_zap/ (GitHub Pages, branch `main`)

---

## O que foi entregue nesta sessão (2026-07-05)

### 1. Redesenho da página de Produtos (storefront)
Página de Produtos deixou de ser uma tabela e virou uma vitrine estilo e-commerce, inspirada em
`liderdamatilha.com.br/cama-pet-impermeavel` (referência trazida pelo cliente):
- Grid de cards (`.product-grid`/`.product-card`) com imagem (ou ícone placeholder 🐾), badge de
  categoria, badge de estoque colorido (verde/amarelo/vermelho), preço em destaque e botão "Editar".
- Busca por nome (`#produtoSearch`) e filtro por categoria em chips, gerados dinamicamente a partir
  dos produtos carregados.
- Coluna `imagem_url` adicionada em `produtos` (`schema.sql`) para suportar foto do produto.
- Demais páginas (Agendamentos, Clientes, Notificações) permanecem como tabelas admin simples —
  só a vitrine de Produtos foi redesenhada, por decisão explícita do cliente.

### 2. Conexão real com Supabase
- Projeto **Supabase compartilhado "AutomatizIA"** (`ywsobgbpwhykkfolvoml`) — o mesmo já usado por
  Condominio_zap e Escola_zap. Confirmado que os nomes de tabela do Pet_zap (`clientes`, `produtos`,
  `pedidos`, `agendamentos_grooming`, `notificacoes`, `sessoes_petshop`) não colidem com os dos outros
  dois projetos.
- `schema.sql` rodado no projeto; `config.supabaseUrl`/`config.supabaseKey` atualizados em `index.html`
  com o **Publishable key** (nomenclatura nova do Supabase — substitui a antiga "anon key", funciona
  do mesmo jeito).
- Dados de teste inseridos via INSERT manual (6 produtos, 2 clientes, 2 agendamentos, 2 notificações)
  para validar visualmente o dashboard ligado ao banco real.

### 3. Bugs corrigidos
- **Dashboard mostrava `cliente_id` numérico em vez do nome** na tabela "Últimos agendamentos" —
  query não fazia join. Corrigido para `cliente_id(nome)`, igual ao padrão já usado na aba Agendamentos.
- **KPI "Agendamentos" travado em 5** — a mesma query que buscava os 5 registros recentes (com
  `limit=5`) também alimentava a contagem do card. Separada em duas queries: uma só para contagem
  (`select=id`, sem limit) e outra para a lista recente (`limit=5` + join do nome).
- **Sidebar ilegível** — os itens do menu (`<button class="nav-item">`) nunca resetavam a aparência
  nativa do `<button>` (fundo/borda). Em certos navegadores/modos isso fazia o chrome nativo do
  sistema aparecer por cima do CSS (caixas claras, texto ilegível). Corrigido com
  `appearance: none; background: none; border: none; width: 100%; text-align: left;`.

### 4. Paleta de marca Automatiz.ia
Trocada a paleta genérica (azul `#0a84ff` estilo Apple, sidebar `#0b1220`) pela paleta de marca já
estabelecida no Condominio_zap: `--primary: #3D8BFF`, `--primary-dark: #0E2D7A`, `--accent: #F5A623`,
sidebar `#0B1623`. Deixa os três dashboards (Condominio, Escola, Pet) visualmente consistentes.

### 5. Repositório e deploy
Pet_zap virou repositório git próprio (antes vivia solto dentro da pasta `Automatiz.ia`, sem
histórico independente). Criado `BrunoAutomatizIA/sistema_pet_zap` no GitHub, com `.gitignore`
excluindo `.claude/` (config local, não faz parte do produto). GitHub Pages ativado
(`branch main`, path `/`) — mesmo padrão de "CI/CD" usado no Condominio_zap e Escola_zap: qualquer
push em `main` redeploya o dashboard automaticamente em
https://brunoautomatizia.github.io/sistema_pet_zap/.

---

## Pendências e problemas conhecidos

### Alta prioridade

1. **Bot sem persistência no Supabase** — `bot_pet.json` calcula as flags `saveSession`,
   `createCustomer`, `createBooking` no node "Lógica do Bot", mas não existem nós de INSERT/DELETE
   para gravar em `sessoes_petshop`, `clientes` ou `agendamentos_grooming`. O bot responde no
   WhatsApp mas não salva nada ainda. Ver `CLAUDE.md` para o padrão de implementação usado nos
   outros dois bots (DELETE Sessao → IF ok? → INSERT Sessao/INSERT dado final).
2. **Modais de criação/edição não implementados** — botões "Novo produto", "Editar", "Novo
   agendamento", "Novo cliente", "Nova notificação", "Enviar" só mostram toast
   "não implementado ainda". Dashboard hoje é somente leitura na prática.

### Média prioridade

4. **`bot_pet.json` e `notificacao_webhook.json` com URL do Supabase em placeholder**
   (`YOUR_SUPABASE_URL`) — precisa apontar para `ywsobgbpwhykkfolvoml` antes de importar no n8n,
   igual já foi feito em `index.html`.
5. **Sem enum/constraint de status** — `status` em `pedidos`, `agendamentos_grooming` e
   `notificacoes` é `text` livre, sem `CHECK`. Funciona, mas não impede valores inconsistentes.

### Baixa prioridade

6. **Segurança** — chaves hardcoded em `index.html`/`bot_pet.json`. Extrair para variáveis de
   ambiente do n8n antes de produção com múltiplos clientes (mesmo apontamento já feito nos outros
   dois projetos).

---

## Padrões do código (para manutenção)

Ver `CLAUDE.md` para detalhes de infraestrutura, schema e arquitetura do bot. Resumo rápido:
- `fetchJson(url, options)` — fetch + throw em `!res.ok`
- `supaHeaders()` — headers padrão do Supabase (`apikey`, `Authorization: Bearer`)
- Nova página no dashboard: `<section class="page" id="page-NOME">` + `.nav-item[data-page=NOME]` +
  registrar em `switchPage()`
