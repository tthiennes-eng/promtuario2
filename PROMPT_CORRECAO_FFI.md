# Prompt para Correção do Erro de Compilação FFI (InvalidType / FunctionType)

Copie e cole o prompt abaixo na IA que você utilizará para corrigir o projeto:

---

Você é um engenheiro Flutter/Dart sênior. O projeto em `/workspace` falha ao compilar com o seguinte erro:

```
Crash when compiling:
type 'InvalidType' is not a subtype of type 'FunctionType' in type cast

#0  _FfiUseSiteTransformer._verifyAndReplaceNativeCallable (package:vm/modular/transformations/ffi/use_sites.dart:1317:31)
...
```

Esse erro ocorre na transformação FFI do compilador (geralmente associado aos pacotes `sqlite3_flutter_libs` / `drift` / `ffi`) e costuma ser causado por cache de compilação corrompido, lockfile desatualizado ou incompatibilidade de versões entre `dart:ffi`, `ffi` e os bindings nativos.

Corrija o problema seguindo rigorosamente estes passos:

1. **Verifique as dependências no `pubspec.yaml`:**
   - Garanta que `ffi: ^2.1.0` esteja listado explicitamente em `dependencies`.
   - Garanta compatibilidade entre `drift` (>=2.16.0), `sqlite3_flutter_libs` e `drift_dev` (mesma versão major/minor do `drift`).
   - Se necessário, fixe `sqlite3_flutter_libs: 0.5.35` para evitar versões problemáticas.

2. **Limpe todo o estado de build:**
   ```bash
   flutter clean
   rm -rf .dart_tool build
   ```

3. **Resolva as dependências novamente:**
   ```bash
   flutter pub get
   ```

4. **Regenere os arquivos code-gen (drift/freezed/riverpod):**
   ```bash
   dart run build_runner clean
   dart run build_runner build --delete-conflicting-outputs
   ```

5. **Valide a correção compilando o projeto:**
   ```bash
   flutter build apk --debug   # ou: flutter run -d windows / chrome
   ```

6. **Se o erro persistir após os passos acima:**
   - Atualize o SDK: `flutter upgrade` (versões antigas do Dart têm bugs conhecidos no `_FfiUseSiteTransformer`).
   - Inspecione chamadas de `NativeCallable.*` / `Pointer.fromFunction` no código gerado pelo drift (`lib/data/local/*.g.dart`) — se houver, regenere com uma versão mais recente do `drift_generator`.
   - Verifique se há dois pacotes instalando a mesma biblioteca nativa SQLite (ex.: `sqlite3_flutter_libs` junto de `sqlite3` avulso) e remova o duplicado.

Entregáveis esperados:
- O `pubspec.yaml` atualizado (se alguma alteração foi necessária).
- O comando final de build executado com sucesso, sem o crash de compilação.
- Um resumo curto explicando qual causa específica foi identificada (cache, versão de pacote ou bug do SDK).

Não altere a lógica de negócio nem a arquitetura do app; atue apenas nas dependências, no cache de build e nos arquivos gerados.
