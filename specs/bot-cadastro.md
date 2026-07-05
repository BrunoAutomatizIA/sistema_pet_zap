# Bot — Fluxo de Cadastro do Cliente

**Status:** 🔴 Pendente  
**Arquivo:** `bot_pet.json`  
**Task:** `tasks.md` → Alta Prioridade

---

## 1. Objetivo
> Registrar um cliente e seu pet no sistema via WhatsApp antes de liberar o menu principal.

---

## 2. Usuários
> Clientes que ainda não têm cadastro no pet shop e acessam o bot via WhatsApp.

---

## 3. Entradas de dados

| Campo | Fonte | Obrigatório | Descrição |
|---|---|---|---|
| `telefone` | WhatsApp | Sim | Número do cliente, extraído de `remoteJid`.
| `nome` | mensagem | Sim | Nome do cliente.
| `pet_nome` | mensagem | Sim | Nome do pet.
| `pet_tipo` | mensagem | Opcional | Espécie ou raça do pet.

---

## 4. Saídas esperadas
> O bot salva o cliente em `clientes`, remove a sessão e envia a mensagem de boas-vindas com o menu.

---

## 5. Regras de negócio
- O cadastro é multi-step: `aguardando_cadastro` → `ok=true`.
- O formato deve aceitar `nome | pet_nome` ou `nome - pet_nome`.
- `telefone` não pode ser duplicado; se já existir, o bot exibe o menu.
- Comandos globais `CANCELAR` e `MENU` funcionam a qualquer momento.

---

## 6. Exceções

| Situação | Tratamento |
|---|---|
| Formato inválido | Reenviar exemplo do formato.
| Texto vazio | Reenviar pedido de nome e pet.
| Cliente já existente | Exibir menu principal.

---

## 7. Critérios de aceite
- [ ] Numero desconhecido entra no fluxo de cadastro.
- [ ] Envio de `nome | pet` cria registro em `clientes`.
- [ ] Ao concluir, sessão é deletada e menu é enviado.
- [ ] `CANCELAR` cancela o fluxo e `MENU` mostra opções.

---

## 8. Riscos
- Mensagens ambíguas podem ser interpretadas como produto ou comando.
- Falha no INSERT do Supabase deve ser capturada e avisar o cliente.

---

## 9. Métricas de sucesso
- Taxa de conclusão do cadastro > 80%.
- Número de sessões pendentes menores que 5%.

---

## 10. Prompt / Agent behavior
- Antes de editar: verificar URLs e chaves do Supabase no bot.
- Padrões obrigatórios: manter `DELETE` + `INSERT` para sessões; não usar `UPSERT`.
- Evitar enviar menu sem ter certeza de que o cliente está cadastrado.
