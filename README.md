# OdontoClinica Universitária - Sistema de Gestão Clínica Escola

Sistema profissional completo para gerenciamento de clínicas escola odontológicas, desenvolvido com tecnologias de ponta e focado em escalabilidade, segurança (LGPD) e alta disponibilidade acadêmica.

## 🚀 Tecnologias Utilizadas

### Frontend (Flutter)
- **Framework**: Flutter 3.x (Material 3)
- **Estado**: Flutter Riverpod (Generator)
- **Navegação**: GoRouter
- **Persistência Local**: Drift (SQLite) - Offline First
- **Rede**: Dio + SignalR (Real-time)
- **Segurança**: Flutter Secure Storage (JWT & Refresh Token)
- **Arquitetura**: Clean Architecture + DDD + MVVM

### Backend (ASP.NET Core)
- **Framework**: .NET 9
- **ORM**: Entity Framework Core
- **Banco de Dados**: PostgreSQL
- **Segurança**: JWT Authentication + Refresh Token Rotation + BCrypt
- **Auditoria**: Filtros de Auditoria Automática (LGPD)
- **Comunicação**: SignalR Hubs
- **Arquitetura**: DDD + Repository Pattern + SOLID

## 📂 Estrutura do Projeto

```text
├── backend/
│   ├── DentalClinic.Api/          # Controllers, Middlewares e Filtros
│   ├── DentalClinic.Application/  # Serviços e Casos de Uso
│   ├── DentalClinic.Core/         # Entidades de Domínio e Value Objects
│   └── DentalClinic.Infrastructure/# Persistência, Segurança e Storage
└── frontend/
    ├── lib/core/                  # Configurações globais, Rede e Temas
    └── lib/features/              # Módulos de negócio (Auth, Agenda, Prontuário, etc)
```

## 🛠️ Como Executar

### Pré-requisitos
- SDK .NET 9
- Flutter SDK (versão estável)
- Docker ou Instância PostgreSQL

### 1. Configuração do Backend
1. Navegue até `backend/DentalClinic.Api/`.
2. Configure a string de conexão no `appsettings.json`.
3. Execute as migrações:
   ```bash
   dotnet ef database update
   ```
4. Inicie a API:
   ```bash
   dotnet run
   ```

### 2. Configuração do Frontend
1. Navegue até a raiz do projeto.
2. Instale as dependências:
   ```bash
   flutter pub get
   ```
3. Gere os arquivos de código (Freezed/Riverpod):
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
4. Execute o app:
   ```bash
   flutter run
   ```

## 🔒 Conformidade LGPD
O sistema implementa nativamente:
- **Anonimização**: Direito ao esquecimento via endpoint administrativo.
- **Log de Auditoria**: Registro de cada acesso a dados sensíveis de prontuário.
- **Controle de Consentimento**: Registro de aceite do paciente para coleta de dados.
- **RBAC**: Permissões baseadas em papéis (Admin, Professor, Aluno, Secretaria).

## 📄 Licença
Este projeto é de uso exclusivo institucional.
