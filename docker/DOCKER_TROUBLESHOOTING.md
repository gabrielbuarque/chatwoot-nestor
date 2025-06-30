# Docker Build Troubleshooting Guide

Este guia ajuda a resolver problemas comuns durante o build do Docker, especialmente relacionados à compilação de assets.

## Problemas Comuns de Asset Compilation

### 1. Erro: "exit code 1" durante assets:precompile

**Sintomas:** O build falha na etapa de asset precompilation com erro genérico.

**Soluções aplicadas:**

1. **Aumento do limite de memória do Node.js:**
   ```
   NODE_OPTIONS="--openssl-legacy-provider --max-old-space-size=4096"
   ```

2. **Variáveis de ambiente otimizadas:**
   - `RAILS_LOG_TO_STDOUT=enabled`
   - `DISABLE_SPRING=1`
   - `SKIP_STORAGE_VALIDATION=true`
   - `SKIP_DATABASE_VALIDATIONS=true`

3. **Criação de diretórios necessários:**
   - `tmp/cache/webpacker`
   - `public/packs`

### 2. Debug de Problemas

**Script de debug disponível:**
```bash
# Execute dentro do container para debugar problemas
./bin/debug_assets
```

**Rake task personalizada:**
```bash
# Use esta task em vez do assets:precompile padrão
bundle exec rake docker:assets_precompile
```

### 3. Configurações de Webpack Otimizadas

O arquivo `config/webpack/production.js` foi otimizado com:
- Hints de performance desabilitados
- Limite de memória aumentado
- Estatísticas de build otimizadas

### 4. Configurações de Assets Otimizadas

O arquivo `config/initializers/assets_optimization.rb` inclui:
- Skip de validações desnecessárias durante precompilation
- Configurações otimizadas para production
- Melhor tratamento de arquivos estáticos

## Como Testar o Build Local

```bash
# Build completo
docker build -f docker/Dockerfile -t chatwoot-local .

# Build apenas até a etapa de assets (para debug)
docker build -f docker/Dockerfile --target pre-builder -t chatwoot-debug .

# Debug do container
docker run -it chatwoot-debug /bin/sh
```

## Logs Úteis

Durante o build, procure por:

1. **Início da compilação:**
   ```
   Starting asset precompilation with enhanced error handling...
   ```

2. **Sucesso:**
   ```
   Asset precompilation completed successfully
   ```

3. **Informações de debug:**
   - Versões do Node.js, Yarn, Ruby
   - Status dos diretórios
   - Variáveis de ambiente

## Variáveis de Ambiente Importantes

| Variável | Valor | Descrição |
|----------|-------|-----------|
| `NODE_OPTIONS` | `--openssl-legacy-provider --max-old-space-size=4096` | Otimizações do Node.js |
| `RAILS_ENV` | `production` | Ambiente Rails |
| `NODE_ENV` | `production` | Ambiente Node.js |
| `RAILS_SERVE_STATIC_FILES` | `true` | Habilita servir arquivos estáticos |
| `DISABLE_SPRING` | `1` | Desabilita Spring durante build |
| `SKIP_STORAGE_VALIDATION` | `true` | Pula validações de storage |

## Estrutura de Arquivos Importantes

```
├── docker/
│   ├── Dockerfile (otimizado)
│   └── DOCKER_TROUBLESHOOTING.md (este arquivo)
├── bin/
│   └── debug_assets (script de debug)
├── config/
│   ├── webpack/
│   │   └── production.js (otimizado)
│   └── initializers/
│       └── assets_optimization.rb (novo)
└── lib/
    └── tasks/
        └── docker_assets.rake (rake task personalizada)
```

## Dicas Adicionais

1. **Memory Issues:** Se ainda houver problemas de memória, aumente o valor em `--max-old-space-size`

2. **Network Issues:** Verifique se o yarn install está funcionando corretamente

3. **Dependency Issues:** Certifique-se de que package.json e yarn.lock estão sincronizados

4. **Platform Issues:** Verifique se está usando a versão correta do Node.js (20.x)

## Rollback

Se as mudanças causarem problemas, você pode reverter para o comando original:

```dockerfile
# No Dockerfile, substitua:
bundle exec rake docker:assets_precompile

# Por:
SECRET_KEY_BASE=precompile_placeholder \
RAILS_LOG_TO_STDOUT=enabled \
bundle exec rake assets:precompile --trace
``` 