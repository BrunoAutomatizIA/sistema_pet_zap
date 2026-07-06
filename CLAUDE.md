# Pet Zap — Bot de Pet Shop para WhatsApp

Produto da **Automatiz.ia** que automatiza atendimento, catálogo e agendamentos de um pet shop via WhatsApp. Composto por três artefatos:

| Arquivo | O que é |
|---|---|
| `bot_pet.json` | Workflow n8n principal (bot WhatsApp) — **esqueleto inicial, ver "Pendências"** |
| `notificacao_webhook.json` | Workflow n8n auxiliar — webhook de notificação disparado pelo dashboard |
| `index.html` | Dashboard admin SPA (HTML/CSS/JS puro, sem build) |

---

## Infraestrutura

| Serviço | Uso | Credencial no projeto |
|---|---|---|
| **n8n** | Plataforma de automação que roda os workflows | host: `n8n.automacaopme.com.br` |
| **Evolution API** | Gateway WhatsApp | host: `evolution.automacaopme.com.br`, instance: `Bot_PetShop` |
| **Supabase** | Banco PostgreSQL via REST | projeto compartilhado **AutomatizIA** (mesmo projeto do Condominio_zap e Escola_zap) — ref `ywsobgbpwhykkfolvoml`, URL `https://ywsobgbpwhykkfolvoml.supabase.co` |

> O projeto Supabase é **compartilhado** entre Pet_zap, Condominio_zap e Escola_zap. Ao criar uma tabela nova, sempre conferir contra os `CLAUDE.md`/`schema.sql` dos outros dois projetos para evitar colisão de nome (convenção: sufixar com `_petshop`/`_escola` quando o nome for genérico o suficiente para colidir).
>
> As credenciais estão hardcoded em `index.html` (bloco `config`, início da tag `<script>`) e em `bot_pet.json`/`notificacao_webhook.json`. Ao escalar ou entregar para outros clientes, extraí-las para variáveis de ambiente no n8n.

---

## Schema do Banco (Supabase)

```
clientes             — id, nome, telefone, pet_nome, pet_tipo
sessoes_petshop      — telefone (PK), etapa, dados (JSONB), updated_at
produtos             — id, nome, categoria, preco, preco_original, estoque, descricao, imagem_url, avaliacao, destaque
pedidos              — id, cliente_id (FK→clientes), produto_id (FK→produtos), quantidade, total, status
agendamentos_grooming— id, cliente_id (FK→clientes), pet_nome, tipo_servico, data, horario, status, notas
notificacoes         — id, cliente_id (FK→clientes), titulo, mensagem, status
```

**Status de pedido:** `pendente` → (definir fluxo — ainda não implementado no dashboard)

**Status de agendamento:** `agendado` → `concluído` (usado livremente, sem enum/constraint no banco)

**Status de notificação:** `pendente` → `enviado`

Script completo em `schema.sql`. Rodar no SQL Editor do projeto Supabase `AutomatizIA`; ao final, sempre confirmar:
```sql
GRANT ALL ON ALL TABLES IN SCHEMA public TO anon;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon;
```
Sem isso, INSERT/UPDATE/DELETE retornam 403 para o role `anon`.

---

## Workflow n8n — Arquitetura do Bot (`bot_pet.json`)

### Fluxo atual (esqueleto)
```
Webhook (POST /petshop-bot)
  ├─► Respond 200
  └─► Parsear Mensagem → GET Cliente → GET Sessao → Consolidar → Cliente existe? (IF)
        └─► Lógica do Bot (Code) → Enviar WhatsApp (Evolution API, instance Bot_PetShop)
```

**Lógica do Bot** já cobre, em JS puro:
- Cadastro inicial (`nome | nome do pet`) quando cliente não existe
- Menu principal (`MENU` ou `0`)
- Roteamento por dígito: `1` produtos, `2` reserva de tosa, `3` reserva de banho, `4` meus pedidos, `5` atendimento
- Fluxo multi-step de reserva (tosa/banho): pergunta serviço → pergunta data/horário → confirma
- Comando global `CANCELAR`

### ⚠️ Gap conhecido — sem persistência
O Code node **calcula** as flags `saveSession`, `createCustomer`, `createBooking` e os payloads (`customerData`, `bookingData`), mas o workflow **não tem nós de INSERT/DELETE** para de fato gravar em `sessoes_petshop`, `clientes` ou `agendamentos_grooming`. Ou seja, hoje o bot responde no WhatsApp mas não persiste nada no Supabase. Isso é o item de maior prioridade em `tasks.md`:
> "Criar fluxo de cadastro no bot (`bot_pet.json`) e testar com Supabase."

Ao implementar, seguir o padrão já validado no Condominio_zap/Escola_zap: `DELETE Sessao → Fluxo OK? (IF) → [em andamento] INSERT Sessao / [ok] INSERT dado final`.

---

## Webhook de Notificação (`notificacao_webhook.json`)

Workflow n8n auxiliar importado junto com o bot principal. Permite que o dashboard envie WhatsApp sem bloqueio de CORS (browser não pode chamar Evolution API diretamente).

**Endpoint:** `GET https://n8n.automacaopme.com.br/webhook/notificar-petshop?number=55...&text=...`

**Fluxo:** Webhook (GET) → Enviar WhatsApp (POST Evolution API `Bot_PetShop`)

---

## Dashboard Admin (`index.html`)

SPA pura: nenhum framework, nenhum build. Abre direto no browser. Navegação client-side via atributos `data-page`.

### Páginas

| Página | Conteúdo |
|---|---|
| **Dashboard** | KPIs (produtos, agendamentos, clientes, notificações) + tabela dos últimos agendamentos (com nome do cliente via join `cliente_id(nome)`) |
| **Produtos** | Vitrine estilo e-commerce: grid de cards com imagem/placeholder, badge de categoria, badge de estoque (verde "Em estoque" / amarelo "Últimas N" / vermelho "Sem estoque"), badge de desconto (laranja, `-XX%` calculado a partir de `preco_original`), avaliação por estrelas (`avaliacao`), coração de "destaque" (`destaque`, toggle via PATCH), busca por nome e filtro por categoria (chips) |
| **Agendamentos** | Tabela simples (cliente, pet, serviço, data, horário, status) |
| **Clientes** | Tabela simples (nome, telefone, pet, tipo) |
| **Notificações** | Tabela simples (título, mensagem, status) |

> Botões "Novo produto" / "Editar" / "Novo agendamento" / "Novo cliente" / "Nova notificação" / "Enviar" ainda são placeholders (`showToast('...não implementado ainda')`) — nenhum modal de criação/edição foi implementado.

### Identidade visual

Paleta alinhada à marca **Automatiz.ia**, mesma usada no Condominio_zap:
```css
--primary:      #3D8BFF  /* azul de marca */
--primary-dark: #0E2D7A
--accent:       #F5A623  /* laranja */
--sidebar bg:   #0B1623  /* navy de marca */
```
Fonte do sistema (`-apple-system, BlinkMacSystemFont, "Segoe UI"`), cards com `border-radius: 20px` e sombra suave — estilo "Apple Store" já usado no Escola_zap.

**Exceção: vitrine de Produtos** usa uma segunda paleta, inspirada em `breeds.com.br` (referência trazida
pelo cliente), aplicada **só** dentro do escopo da página de Produtos — sidebar e demais páginas
continuam na paleta Automatiz.ia acima:
```css
--shop-green:  #0A4F42  /* verde-escuro — preço, badge de categoria, botões da vitrine */
--shop-orange: #F57F45  /* laranja — badge de desconto, coração de destaque ativo */
```
Escopar sempre via seletor (`.produtos-toolbar .button`, `.product-card-actions .button`, `.filter-chip.active`)
em vez de trocar `--primary` global, para não vazar a paleta da vitrine para o resto do dashboard.

**Cuidado com `<button>` sem classe de fundo** (ex.: `.nav-item`): sempre resetar `appearance: none; background: none; border: none;` explicitamente — sem isso, o navegador pode renderizar o chrome nativo do botão por cima do CSS (bug já corrigido no sidebar em 2026-07-05).

### Helper de dados
```js
fetchJson(url, options)      // fetch + throw em !res.ok
supaHeaders()                 // { apikey, Authorization: Bearer, Content-Type }
config.supabaseUrl/supabaseKey // topo do <script>, projeto AutomatizIA compartilhado
```

### Como editar o dashboard
`index.html` é auto-contido. Ao adicionar uma nova página:
1. Criar `<section class="page" id="page-NOME">` dentro de `<main class="main">`
2. Adicionar `<button class="nav-item" data-page="NOME">` no `.sidebar-nav`
3. Registrar `if (page === 'NOME') loadNOME();` em `switchPage()`
