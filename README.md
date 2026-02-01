# Chatwoot Builder - Docker Setup

Esta pasta contém os arquivos necessários para buildar e executar o projeto Chatwoot usando Docker Compose.

## Estrutura de Arquivos

- `Dockerfile` - Arquivo de build da imagem Docker
- `docker-compose.yml` - Configuração dos serviços (app, sidekiq, postgres, redis)
- `entrypoint.sh` - Script de inicialização dos containers
- `.env.example` - Exemplo de variáveis de ambiente
- `README.md` - Este arquivo

## Pré-requisitos

- Docker instalado
- Docker Compose instalado
- Pelo menos 4GB de RAM disponível para o Docker

## Build e Publicação no Docker Hub

### Build e Push da Imagem

Para fazer build da versão 1.5.0 e publicar no Docker Hub:

```bash
cd builder
./build-and-push.sh
```

Este script irá:
1. Fazer build da imagem com a tag `welitonjjose/alts-wpp:1.5.0`
2. Tagear também como `latest`
3. Fazer login no Docker Hub (você precisará das credenciais)
4. Publicar ambas as tags no Docker Hub

**Nota**: Certifique-se de ter feito login no Docker Hub antes:
```bash
docker login
```

### Build Manual (sem publicar)

Se você quiser apenas fazer o build local sem publicar:

```bash
docker build -f builder/Dockerfile -t welitonjjose/alts-wpp:1.5.0 .
```

## Instalação e Execução

### 1. Configurar Variáveis de Ambiente

Copie o arquivo de exemplo e configure suas variáveis:

```bash
cd builder
cp .env.example .env
```

Edite o arquivo `.env` e configure:
- Senhas do banco de dados e Redis
- `SECRET_KEY_BASE` (gere uma string aleatória longa)
- Configurações de email/SMTP se necessário
- Outras configurações conforme sua necessidade

### 2. Iniciar os Serviços

A imagem já está publicada no Docker Hub, então não precisa buildar localmente:

```bash
docker-compose pull  # Baixa a imagem do Docker Hub
docker-compose up -d
```

Se você modificou o código e quer buildar localmente, descomente as linhas de `build` no docker-compose.yml e execute:

```bash
docker-compose build
docker-compose up -d
```

### 3. Verificar Download/Inicialização

```bash
docker-compose up -d
```

Ou para ver os logs em tempo real:

```bashConfigurar Banco de Dados (Primeira Execução)

Na primeira vez, você precisará preparar o banco de dados:

```bash
docker-compose exec app bundle exec rails db:prepare
docker-compose exec app bundle exec rails db:seed
```

### 5. 
docker-compose up
```

### 4. Verificar os Serviços

Verifique se todos os containers estão rodando:

```bash
dock6r-compose ps
```

Você deve ver 4 serviços em execução:
- `builder-app-1` - Aplicação Rails principal
- `builder-sidekiq-1` - Worker para jobs em background
- `builder-postgres-1` - Banco de dados PostgreSQL
- `builder-redis-1` - Cache e filas Redis

### 5. Acessar a Aplicação

Abra seu navegador e acesse:

```
http://localhost:4000
```

## Comandos Úteis

### Ver logs dos serviços

```bash
# Todos os serviços
docker-compose logs -f

# Apenas a aplicação
docker-compose logs -f app

# Apenas o sidekiq
docker-compose logs -f sidekiq
```

### Executar comandos Rails

```bash
# Console Rails
docker-compose exec app bundle exec rails console

# Executar migrations
docker-compose exec app bundle exec rails db:migrate

# Criar um usuário admin
docker-compose exec app bundle exec rails db:seed
```

### Parar os Serviços

```bash
docker-compose down
```

### Parar e Remover Volumes (atenção: apaga dados!)

```bash
docker-compose down -v
```

### Rebuildar após mudanças no código

```bash
docker-compose build --no-cache
docker-compose up -d
```

## Troubleshooting

### Container não inicia

Verifique os logs:
```bash
docker-compose logs app
```

### Erro de conexão com banco de dados

Certifique-se que o PostgreSQL está rodando:
```bash
docker-compose ps postgres
docker-compose logs postgres
```

### Erro de permissão

O entrypoint.sh precisa ter permissão de execução:
```bash
chmod +x entrypoint.sh
```

### Assets não carregam

Verifique se os assets foram compilados durante o build:
```bash
docker-compose exec app ls -la /app/public/vite
```

## Volumes Persistentes

Os dados são armazenados em volumes Docker:
- `storage_data` - Arquivos de upload e storage
- `postgres_data` - Dados do banco PostgreSQL
- `redis_data` - Dados do Redis

Para fazer backup:
```bash
docker-compose exec postgres pg_dump -U postgres chatwoot_production > backup.sql
```

## Variáveis de Ambiente Importantes

| Variável | Descrição | Obrigatória |
|----------|-----------|-------------|
| `SECRET_KEY_BASE` | Chave secreta do Rails | Sim |
| `POSTGRES_PASSWORD` | Senha do PostgreSQL | Sim |
| `REDIS_PASSWORD` | Senha do Redis | Sim |
| `FRONTEND_URL` | URL pública da aplicação | Sim |
| `SMTP_*` | Configurações de email | Não* |

*Necessário se você pretende enviar emails

## Produção

Para usar em produção:

1. Configure `FORCE_SSL=true` no `.env`
2. Use um domínio real em `FRONTEND_URL`
3. Configure SSL/HTTPS (nginx, traefik, etc)
4. Use senhas fortes e únicas
5. Configure backups automáticos
6. Monitore os logs e recursos

## Suporte

Para mais informações, consulte a documentação oficial do Chatwoot:
https://www.chatwoot.com/docs
