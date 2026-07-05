-- ============================================================
-- Pet_zap — Schema Supabase para Pet Shop
-- ============================================================

-- 1. CLIENTES
CREATE TABLE IF NOT EXISTS clientes (
  id bigint generated always as identity primary key,
  nome text NOT NULL,
  telefone text NOT NULL,
  pet_nome text,
  pet_tipo text,
  created_at timestamptz DEFAULT now()
);
ALTER TABLE clientes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "anon all" ON clientes USING (true) WITH CHECK (true);

-- 2. SESSÕES DO BOT
CREATE TABLE IF NOT EXISTS sessoes_petshop (
  telefone text PRIMARY KEY,
  etapa text,
  dados jsonb DEFAULT '{}',
  updated_at timestamptz DEFAULT now()
);
ALTER TABLE sessoes_petshop ENABLE ROW LEVEL SECURITY;
CREATE POLICY "anon all" ON sessoes_petshop USING (true) WITH CHECK (true);

-- 3. PRODUTOS
CREATE TABLE IF NOT EXISTS produtos (
  id bigint generated always as identity primary key,
  nome text NOT NULL,
  categoria text,
  preco numeric(10,2) NOT NULL DEFAULT 0,
  estoque int DEFAULT 0,
  descricao text,
  imagem_url text,
  created_at timestamptz DEFAULT now()
);
ALTER TABLE produtos ENABLE ROW LEVEL SECURITY;
CREATE POLICY "anon all" ON produtos USING (true) WITH CHECK (true);

-- 4. PEDIDOS
CREATE TABLE IF NOT EXISTS pedidos (
  id bigint generated always as identity primary key,
  cliente_id bigint REFERENCES clientes(id) ON DELETE SET NULL,
  produto_id bigint REFERENCES produtos(id) ON DELETE SET NULL,
  quantidade int NOT NULL DEFAULT 1,
  total numeric(10,2) NOT NULL DEFAULT 0,
  status text DEFAULT 'pendente',
  created_at timestamptz DEFAULT now()
);
ALTER TABLE pedidos ENABLE ROW LEVEL SECURITY;
CREATE POLICY "anon all" ON pedidos USING (true) WITH CHECK (true);

-- 5. AGENDAMENTOS DE GROOMING / BANHO
CREATE TABLE IF NOT EXISTS agendamentos_grooming (
  id bigint generated always as identity primary key,
  cliente_id bigint REFERENCES clientes(id) ON DELETE SET NULL,
  pet_nome text,
  tipo_servico text NOT NULL,
  data date NOT NULL,
  horario text NOT NULL,
  status text DEFAULT 'agendado',
  notas text,
  created_at timestamptz DEFAULT now()
);
ALTER TABLE agendamentos_grooming ENABLE ROW LEVEL SECURITY;
CREATE POLICY "anon all" ON agendamentos_grooming USING (true) WITH CHECK (true);

-- 6. NOTIFICAÇÕES
CREATE TABLE IF NOT EXISTS notificacoes (
  id bigint generated always as identity primary key,
  cliente_id bigint REFERENCES clientes(id) ON DELETE SET NULL,
  titulo text NOT NULL,
  mensagem text NOT NULL,
  status text DEFAULT 'pendente',
  created_at timestamptz DEFAULT now()
);
ALTER TABLE notificacoes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "anon all" ON notificacoes USING (true) WITH CHECK (true);

-- IMPORTANTE: permissões para o role anon
GRANT ALL ON ALL TABLES IN SCHEMA public TO anon;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon;
