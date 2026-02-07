#!/bin/bash

# Verifica se o domínio foi fornecido
if [ -z "$1" ]; then
  echo "Erro: Nenhum domínio fornecido."
  echo "Uso: ./generate-cert.sh <dominio>"
  echo "Exemplo: ./generate-cert.sh meudominio.com"
  exit 1
fi

DOMAIN=$1
EMAIL="admin@$DOMAIN"
CERTS_DIR="$(pwd)/letsencrypt"

echo "======================================================================"
echo "Iniciando geração de certificado SSL para: $DOMAIN"
echo "Email de registro: $EMAIL"
echo "Diretório de saída: $CERTS_DIR"
echo "----------------------------------------------------------------------"
echo "IMPORTANTE:"
echo "1. A porta 80 deve estar livre neste servidor."
echo "2. O domínio $DOMAIN deve estar apontando para o IP deste servidor."
echo "======================================================================"

# Cria os diretórios locais se não existirem
mkdir -p "$CERTS_DIR/etc"
mkdir -p "$CERTS_DIR/lib"

# Executa o container do Certbot
# --rm: Remove o container após a execução
# -p 80:80: Usa a porta 80 para validação HTTP
# -v: Mapeia os diretórios para persistir os certificados
docker run -it --rm --name certbot-generator \
  -v "$CERTS_DIR/etc:/etc/letsencrypt" \
  -v "$CERTS_DIR/lib:/var/lib/letsencrypt" \
  -p 80:80 \
  certbot/certbot certonly \
  --standalone \
  --non-interactive \
  --agree-tos \
  --email "$EMAIL" \
  -d "$DOMAIN"

EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
  echo ""
  echo "✅ SUCESSO! Certificado gerado com sucesso."
  echo "Os arquivos estão localizados em:"
  echo " -> $CERTS_DIR/etc/live/$DOMAIN/fullchain.pem"
  echo " -> $CERTS_DIR/etc/live/$DOMAIN/privkey.pem"
else
  echo ""
  echo "❌ ERRO! Falha ao gerar o certificado."
  echo "Verifique se a porta 80 está livre e se o domínio aponta corretamente para este IP."
fi
