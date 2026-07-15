# Arquitetura do Sistema - OdontoClinica Universitária

## 1. Visão Geral
O sistema é uma solução robusta para gerenciamento de clínicas escola de odontologia, focado em escalabilidade, segurança (LGPD) e alta disponibilidade.

## 2. Tecnologias
- **Frontend:** Flutter 3.x, Riverpod (Estado), GoRouter (Navegação), Drift (Persistência Local), Dio (HTTP).
- **Backend:** ASP.NET Core 9, EF Core, PostgreSQL, JWT + Refresh Token.
- **Arquitetura:** Clean Architecture + DDD (Domain Driven Design).

## 3. Estrutura de Módulos (Frontend)
O projeto segue os princípios da Clean Architecture divididos por features:

```text
lib/
├── core/
│   ├── network/          # Cliente Dio, Interceptors
│   ├── database/         # Configuração Drift (SQLite)
│   ├── security/         # Storage seguro para Tokens
│   ├── theme/            # Material 3 Design System
│   └── error/            # Exceções globais
├── features/
│   ├── auth/             # Login e Sessão
│   ├── agenda/           # Gestão de horários
│   ├── prontuario/       # Histórico clínico e Odontograma
│   └── ...
└── main.dart             # Entry point
```

## 4. Fluxo de Dados (MVVM + Clean Arch)
1. **View:** UI (Widgets Flutter).
2. **ViewModel (Notifier):** Gerencia o estado da tela usando Riverpod.
3. **Use Case:** Regras de negócio específicas.
4. **Repository (Interface):** Contrato de dados.
5. **Data Source:** Implementação real (Remote/Local).

## 5. Backend (DDD Layers)
- **API:** Controllers e Middlewares.
- **Application:** Commands, Handlers e DTOs (CQRS Lite).
- **Domain:** Entidades, Value Objects e Interfaces de Repositório.
- **Infrastructure:** Persistência (EF Core), Criptografia e Serviços externos.

## 6. Segurança e LGPD
- **RBAC:** Role-Based Access Control (Admin, Professor, Aluno, etc).
- **Auditoria:** Registro de quem acessou qual prontuário e quando.
- **Criptografia:** Dados sensíveis e senhas (BCrypt).
- **Tokens:** JWT com expiração curta e Refresh Tokens seguros.
