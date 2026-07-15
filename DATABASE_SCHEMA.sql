-- Esquema de Banco de Dados PostgreSQL - OdontoClinica Universitária
-- Foco em LGPD, Auditoria e RBAC

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. SEGURANÇA E ACESSO (RBAC)
CREATE TABLE perfis (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nome VARCHAR(50) NOT NULL UNIQUE, -- Admin, Professor, Aluno, Recepcionista, etc.
    descricao TEXT,
    criado_em TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE permissoes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    chave VARCHAR(100) NOT NULL UNIQUE, -- ex: 'prontuario.editar', 'agenda.cancelar'
    descricao TEXT
);

CREATE TABLE perfil_permissoes (
    perfil_id UUID REFERENCES perfis(id),
    permissao_id UUID REFERENCES permissoes(id),
    PRIMARY KEY (perfil_id, permissao_id)
);

CREATE TABLE usuarios (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nome_completo VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    senha_hash TEXT NOT NULL,
    perfil_id UUID REFERENCES perfis(id),
    ativo BOOLEAN DEFAULT TRUE,
    bloqueado_ate TIMESTAMP WITH TIME ZONE,
    tentativas_falhas INT DEFAULT 0,
    ultimo_login TIMESTAMP WITH TIME ZONE,
    criado_em TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 2. CLÍNICA E ESTRUTURA
CREATE TABLE clinicas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nome VARCHAR(100) NOT NULL, -- Endodontia, Cirurgia, etc.
    especialidade VARCHAR(100)
);

-- 3. PACIENTES E LGPD
CREATE TABLE pacientes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nome_completo VARCHAR(255) NOT NULL,
    cpf VARCHAR(14) NOT NULL UNIQUE,
    data_nascimento DATE NOT NULL,
    sexo CHAR(1),
    telefone VARCHAR(20),
    email VARCHAR(255),
    endereco_json JSONB, -- Armazenamento flexível de endereço
    consentimento_lgpd BOOLEAN DEFAULT FALSE,
    data_consentimento TIMESTAMP WITH TIME ZONE,
    criado_em TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 4. PRONTUÁRIO E ATENDIMENTO
CREATE TABLE prontuarios (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    paciente_id UUID REFERENCES pacientes(id),
    data_abertura TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'Ativo'
);

CREATE TABLE evolucoes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    prontuario_id UUID REFERENCES prontuarios(id),
    aluno_id UUID REFERENCES usuarios(id),
    professor_id UUID REFERENCES usuarios(id),
    clinica_id UUID REFERENCES clinicas(id),
    descricao TEXT NOT NULL,
    data_atendimento TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    assinatura_professor_digital TEXT -- Hash ou referência de assinatura
);

-- 5. IMAGENS E DOCUMENTOS (URLs para Object Storage)
CREATE TABLE anexos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    paciente_id UUID REFERENCES pacientes(id),
    tipo VARCHAR(50), -- 'Radiografia', 'Foto', 'Documento'
    nome_arquivo VARCHAR(255),
    url_storage TEXT NOT NULL,
    meta_data JSONB,
    criado_em TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    criado_por UUID REFERENCES usuarios(id)
);

-- 6. AUDITORIA (LGPD)
CREATE TABLE logs_auditoria (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    usuario_id UUID REFERENCES usuarios(id),
    acao VARCHAR(100) NOT NULL, -- 'ACESSO_PRONTUARIO', 'LOGIN', 'EDICAO_PACIENTE'
    recurso VARCHAR(100), -- Tabela ou ID do recurso
    detalhes JSONB,
    ip_address VARCHAR(45),
    user_agent TEXT,
    data_hora TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ÍNDICES PARA PERFORMANCE
CREATE INDEX idx_usuarios_email ON usuarios(email);
CREATE INDEX idx_pacientes_cpf ON pacientes(cpf);
CREATE INDEX idx_logs_data ON logs_auditoria(data_hora);
CREATE INDEX idx_evolucao_prontuario ON evolucoes(prontuario_id);
