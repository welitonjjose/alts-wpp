#!/bin/bash

ENV_FILE=".env"

# Verifica se o arquivo .env existe
if [ ! -f "$ENV_FILE" ]; then
    echo "Erro: Arquivo $ENV_FILE não encontrado."
    exit 1
fi

echo "======================================================================"
echo "Configuração de E-mail (SMTP)"
echo "======================================================================"
echo "Este script irá configurar as credenciais de e-mail no arquivo .env"
echo "Pressione Enter para manter o valor atual (se existir)."
echo "----------------------------------------------------------------------"

# Função para ler entrada do usuário com valor padrão
read_input() {
    local prompt="$1"
    local var_name="$2"
    local current_value=$(grep "^$var_name=" "$ENV_FILE" | cut -d'=' -f2-)
    
    if [ -n "$current_value" ]; then
        echo -n "$prompt [$current_value]: "
    else
        echo -n "$prompt: "
    fi
    
    read input_value
    
    if [ -z "$input_value" ]; then
        echo "$current_value"
    else
        echo "$input_value"
    fi
}

# Função para atualizar o arquivo .env
update_env() {
    local key="$1"
    local value="$2"
    
    # Escapa caracteres especiais para o sed
    # Escapando / e & que são comuns em URLs e senhas
    escaped_value=$(echo "$value" | sed 's/[\/&]/\\&/g')
    
    if grep -q "^$key=" "$ENV_FILE"; then
        # Se a chave existe, substitui
        # Usando um delimitador diferente (#) para o sed para evitar conflitos com barras
        sed -i.bak "s#^$key=.*#$key=$escaped_value#" "$ENV_FILE"
    else
        # Se a chave não existe, adiciona no final
        echo "$key=$value" >> "$ENV_FILE"
    fi
}

# Coleta de dados
MAILER_SENDER_EMAIL=$(read_input "Email do Remetente (ex: noreply@seudominio.com)" "MAILER_SENDER_EMAIL")
SMTP_ADDRESS=$(read_input "Endereço SMTP (ex: smtp.sendgrid.net)" "SMTP_ADDRESS")
SMTP_PORT=$(read_input "Porta SMTP (ex: 587)" "SMTP_PORT")
SMTP_USERNAME=$(read_input "Usuário SMTP" "SMTP_USERNAME")
SMTP_PASSWORD=$(read_input "Senha SMTP" "SMTP_PASSWORD")
SMTP_AUTHENTICATION=$(read_input "Autenticação (login/plain/cram_md5)" "SMTP_AUTHENTICATION")
if [ -z "$SMTP_AUTHENTICATION" ]; then SMTP_AUTHENTICATION="login"; fi

SMTP_ENABLE_STARTTLS_AUTO=$(read_input "Habilitar STARTTLS (true/false)" "SMTP_ENABLE_STARTTLS_AUTO")
if [ -z "$SMTP_ENABLE_STARTTLS_AUTO" ]; then SMTP_ENABLE_STARTTLS_AUTO="true"; fi

echo "----------------------------------------------------------------------"
echo "Atualizando arquivo .env..."

update_env "MAILER_SENDER_EMAIL" "$MAILER_SENDER_EMAIL"
update_env "SMTP_ADDRESS" "$SMTP_ADDRESS"
update_env "SMTP_PORT" "$SMTP_PORT"
update_env "SMTP_USERNAME" "$SMTP_USERNAME"
update_env "SMTP_PASSWORD" "$SMTP_PASSWORD"
update_env "SMTP_AUTHENTICATION" "$SMTP_AUTHENTICATION"
update_env "SMTP_ENABLE_STARTTLS_AUTO" "$SMTP_ENABLE_STARTTLS_AUTO"

# Remove arquivo de backup criado pelo sed no Mac/BSD
rm -f "$ENV_FILE.bak"

echo "✅ Configuração de e-mail atualizada com sucesso!"
echo "Para aplicar as alterações, execute: docker-compose down && docker-compose up -d"
