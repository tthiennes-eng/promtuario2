# 🚀 QUICK START - INICIANDO O DESENVOLVIMENTO

## 📖 Leia Primeiro (em 30 minutos)

1. **RESUMO_EXECUTIVO.md** (10 min)
   - Visão geral do projeto
   - Objetivos alcançados
   - Próximos passos

2. **ARCHITECTURE.md - Seção 1** (10 min)
   - Estrutura de pastas
   - Diagrama de módulos

3. **DEVELOPMENT_PLAN.md - Fases 1 & 2** (10 min)
   - Core Setup
   - Autenticação

---

## 🛠️ Setup do Backend (ASP.NET Core 9 + PostgreSQL)

### 1. Instalar Pré-requisitos
```bash
# .NET 9 SDK
dotnet --version  # Deve ser 9.0+

# PostgreSQL 15+
psql --version  # Deve ser 15+

# Git
git --version  # Deve ser 2.30+
```

### 2. Criar Solução
```bash
cd C:\Dev
mkdir ClinicaEscola
cd ClinicaEscola

# Criar diretórios de projetos
mkdir src
mkdir tests

# Criar solução
dotnet new sln -n ClinicaEscola
```

### 3. Criar Projetos
```bash
# Domain Layer
dotnet new classlib -n ClinicaEscola.Domain -o src/Domain
dotnet sln add src/Domain/ClinicaEscola.Domain.csproj

# Application Layer
dotnet new classlib -n ClinicaEscola.Application -o src/Application
dotnet sln add src/Application/ClinicaEscola.Application.csproj

# Infrastructure Layer
dotnet new classlib -n ClinicaEscola.Infrastructure -o src/Infrastructure
dotnet sln add src/Infrastructure/ClinicaEscola.Infrastructure.csproj

# API (Presentation)
dotnet new webapi -n ClinicaEscola.API -o src/API
dotnet sln add src/API/ClinicaEscola.API.csproj

# Tests
dotnet new xunit -n ClinicaEscola.Tests -o tests/ClinicaEscola.Tests
dotnet sln add tests/ClinicaEscola.Tests/ClinicaEscola.Tests.csproj
```

### 4. Adicionar Dependências
```bash
cd src/API

# EF Core
dotnet add package Microsoft.EntityFrameworkCore
dotnet add package Microsoft.EntityFrameworkCore.PostgreSQL
dotnet add package Microsoft.EntityFrameworkCore.Tools

# JWT
dotnet add package System.IdentityModel.Tokens.Jwt
dotnet add package Microsoft.AspNetCore.Authentication.JwtBearer

# Security
dotnet add package BCrypt.Net-Next

# Validation
dotnet add package FluentValidation
dotnet add package FluentValidation.DependencyInjectionExtensions

# Swagger
dotnet add package Swashbuckle.AspNetCore

# Logging
dotnet add package Serilog
dotnet add package Serilog.AspNetCore

# AutoMapper
dotnet add package AutoMapper
dotnet add package AutoMapper.Extensions.Microsoft.DependencyInjection
```

### 5. Criar Database
```bash
# Conectar ao PostgreSQL
psql -U postgres

# Criar database
CREATE DATABASE clinica_escola;
CREATE USER clinica_user WITH ENCRYPTED PASSWORD 'SecurePassword123!';
ALTER ROLE clinica_user WITH CREATEDB;
GRANT ALL PRIVILEGES ON DATABASE clinica_escola TO clinica_user;

# Sair
\q
```

### 6. Executar Schema
```bash
# Conectar como clinica_user
psql -U clinica_user -d clinica_escola -f C:\Users\Thiago\AndroidStudioProjects\promt\DATABASE_SCHEMA.sql

# Verificar tabelas
\dt
```

### 7. Estrutura de Pastas Esperada
```
src/
├── API/
│   ├── Controllers/
│   │   ├── AuthController.cs
│   │   ├── PatientsController.cs
│   │   └── ...
│   ├── Middleware/
│   │   ├── AuthMiddleware.cs
│   │   └── ErrorHandlingMiddleware.cs
│   ├── Program.cs
│   ├── appsettings.json
│   └── appsettings.Development.json
│
├── Domain/
│   ├── Entities/
│   │   ├── UserEntity.cs
│   │   ├── PatientEntity.cs
│   │   └── ...
│   ├── ValueObjects/
│   │   ├── EmailVO.cs
│   │   ├── PasswordVO.cs
│   │   └── ...
│   ├── Repositories/
│   │   ├── IUserRepository.cs
│   │   ├── IPatientRepository.cs
│   │   └── ...
│   └── Exceptions/
│       └── DomainException.cs
│
├── Application/
│   ├── UseCases/
│   │   ├── Login/
│   │   │   ├── LoginRequest.cs
│   │   │   ├── LoginResponse.cs
│   │   │   └── LoginHandler.cs
│   │   └── ...
│   ├── DTOs/
│   │   ├── UserDTO.cs
│   │   ├── PatientDTO.cs
│   │   └── ...
│   └── Services/
│       ├── IAuthService.cs
│       └── ...
│
└── Infrastructure/
    ├── Data/
    │   ├── Context/
    │   │   └── ClinicaEscolaDbContext.cs
    │   └── Repositories/
    │       ├── UserRepository.cs
    │       ├── PatientRepository.cs
    │       └── ...
    ├── Security/
    │   ├── JwtService.cs
    │   ├── PasswordHasher.cs
    │   └── TokenValidator.cs
    └── Logging/
        └── Logger.cs
```

---

## 📱 Setup do Frontend (Flutter)

### 1. Pré-requisitos
```bash
# Flutter 3.24+
flutter --version  # Deve ser 3.24+

# Android SDK / iOS SDK (conforme target)
flutter doctor
```

### 2. Criar Projeto Flutter
```bash
flutter create clinica_escola

cd clinica_escola

# Remover exemplos padrão
rm -r lib/main.dart
```

### 3. Configurar pubspec.yaml
```yaml
name: clinica_escola
description: Sistema de Gerenciamento de Clínica Escola Odontológica
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.5.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  riverpod: ^2.4.0
  flutter_riverpod: ^2.4.0
  
  # Navigation
  go_router: ^13.0.0
  
  # Database
  drift: ^2.14.0
  sqlite3_flutter_libs: ^0.5.0
  
  # API Client
  dio: ^5.4.0
  
  # Serialization
  freezed_annotation: ^2.4.0
  json_annotation: ^4.8.0
  
  # Security
  flutter_secure_storage: ^9.0.0
  cryptography: ^2.1.0
  
  # UI
  flutter_material_3: ^0.0.0
  intl: ^0.19.0
  
  # Calendar
  table_calendar: ^3.1.0
  
  # Image handling
  image_picker: ^1.0.0
  cached_network_image: ^3.3.0
  
  # Utils
  equatable: ^2.0.5
  uuid: ^4.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  
  build_runner: ^2.4.0
  freezed: ^2.4.0
  json_serializable: ^6.7.0
  drift_dev: ^2.14.0
  custom_lint: ^4.1.0
  riverpod_generator: ^2.3.0

flutter:
  uses-material-design: true
  
  assets:
    - assets/images/
    - assets/icons/
    - assets/translations/
  
  fonts:
    - family: Roboto
      fonts:
        - asset: assets/fonts/Roboto-Regular.ttf
        - asset: assets/fonts/Roboto-Bold.ttf
          weight: 700
```

### 4. Instalar Dependências
```bash
flutter pub get
flutter pub global activate melos  # Para monorepo (opcional)
```

### 5. Estrutura de Pastas
```
lib/
├── main.dart
├── main_prod.dart
│
├── core/
│   ├── config/
│   ├── di/
│   ├── error/
│   ├── extensions/
│   ├── network/
│   ├── security/
│   ├── storage/
│   └── utils/
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── dashboard/
│   ├── patients/
│   ├── schedule/
│   └── ...
│
├── shared/
│   ├── models/
│   ├── providers/
│   ├── widgets/
│   └── theme/
│
test/
└── ...
```

### 6. Gerar Código Automático
```bash
# Freezed, Json Serializable, Drift
flutter pub run build_runner build

# Watch mode (durante desenvolvimento)
flutter pub run build_runner watch
```

### 7. Rodar Aplicação
```bash
# Debug
flutter run

# Release
flutter run --release

# Web
flutter run -d chrome

# Android
flutter run -d android
```

---

## 🔐 Configurar Variáveis de Ambiente

### Backend: appsettings.Development.json
```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft": "Warning"
    }
  },
  "ConnectionStrings": {
    "DefaultConnection": "User ID=clinica_user;Password=SecurePassword123!;Host=localhost;Port=5432;Database=clinica_escola;"
  },
  "Jwt": {
    "Secret": "your-256-bit-secret-key-here-at-least-32-characters-long",
    "Issuer": "ClinicaEscola",
    "Audience": "ClinicaEscolaAPI",
    "ExpirationMinutes": 15,
    "RefreshTokenExpirationDays": 7
  },
  "AllowedHosts": "*"
}
```

### Frontend: lib/core/config/env_config.dart
```dart
class EnvConfig {
  static const String apiBaseUrl = 'http://localhost:5000';
  static const String apiVersion = '/api/v1';
  static const Duration requestTimeout = Duration(seconds: 30);
  static const bool debugMode = true;
}
```

---

## ✅ Verificação Inicial

### Backend
```bash
# 1. Compilar
dotnet build

# 2. Rodar testes
dotnet test

# 3. Rodar API
cd src/API
dotnet run

# 4. Acessar Swagger
# Abrir: http://localhost:5000/swagger/index.html
```

### Frontend
```bash
# 1. Analisar código
flutter analyze

# 2. Rodar testes
flutter test

# 3. Rodar app
flutter run
```

---

## 📋 Próximos Passos

### Módulo 1: Core Setup (1 semana)

#### Backend:
- [ ] DbContext e migrations
- [ ] JWT Service implementation
- [ ] Password Hashing Service
- [ ] Dependency Injection setup
- [ ] Error Handling Middleware
- [ ] Logging with Serilog

#### Frontend:
- [ ] Service Locator setup
- [ ] Dio client com interceptors
- [ ] Secure Storage integration
- [ ] Theme setup (Material 3)
- [ ] Navigation structure

### Módulo 2: Autenticação (2 semanas)

#### Backend:
- [ ] User Entity & Migrations
- [ ] Login Endpoint
- [ ] Token Refresh Endpoint
- [ ] Login validation
- [ ] Audit logging
- [ ] Unit tests

#### Frontend:
- [ ] Login page
- [ ] Splash screen
- [ ] Session management
- [ ] Auto-refresh tokens
- [ ] Unit tests

---

## 📚 Documentação Referência

| Arquivo | Para | Tempo |
|---------|------|-------|
| RESUMO_EXECUTIVO.md | Overview | 10 min |
| ARCHITECTURE.md | Estrutura completa | 20 min |
| DATABASE_SCHEMA.sql | DB setup | - |
| DEVELOPMENT_PLAN.md | Roadmap | 30 min |
| ENTITIES_AND_DDD.md | DDD patterns | 30 min |
| VALIDATION_CHECKLIST.md | Validação | 30 min |

---

## 🐛 Troubleshooting

### PostgreSQL Connection Error
```bash
# Verificar se está rodando
sudo service postgresql status

# Reiniciar
sudo service postgresql restart

# Conectar diretamente
psql -U clinica_user -d clinica_escola
```

### Flutter Build Error
```bash
# Limpar cache
flutter clean

# Reconstruir
flutter pub get
flutter pub run build_runner build

# Rodar novamente
flutter run
```

### .NET Build Error
```bash
# Limpar soluções
dotnet clean

# Restaurar dependências
dotnet restore

# Reconstruir
dotnet build
```

---

## 📞 Recursos

- **Flutter Docs**: https://flutter.dev/docs
- **Riverpod Docs**: https://riverpod.dev
- **ASP.NET Core**: https://docs.microsoft.com/en-us/aspnet/core
- **PostgreSQL**: https://www.postgresql.org/docs
- **Entity Framework**: https://learn.microsoft.com/en-us/ef/core

---

## ✨ Bom Desenvolvimento!

Siga a arquitetura, mantenha a qualidade, e escreva código pronto para produção.

**Próxima parada**: Módulo 1 - Core Setup ✅

---
