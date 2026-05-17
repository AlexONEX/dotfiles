function usql_connect_mysql() {
  local ENV=$1
  local HOST=$2
  local PROFILE=$3

  if [[ -z $ENV || -z $HOST ]]; then
    echo "Uso: usql_connect <dev|prod> <host> [aws-profile]"
    return 1
  fi

  if [[ -z $PROFILE ]]; then
    PROFILE="${ENV}"
  fi

  local SECRET_RESPONSE=$(aws secretsmanager get-secret-value \
    --secret-id "infra/core-db-master-password" \
    --profile "${PROFILE}" 2>&1)

  if [[ $? -ne 0 ]]; then
    echo "ERROR: Could not get the secret from AWS Secrets Manager"
    echo "$SECRET_RESPONSE"
    return 1
  fi

  local DB_PASSWORD=$(echo "$SECRET_RESPONSE" | jq -r '.SecretString')

  if [[ -z $DB_PASSWORD ]]; then
    echo "ERROR: Could not extract the database password from the secret"
    echo "jq output: $(echo "$SECRET_RESPONSE" | jq '.SecretString')"
    return 1
  fi

  local DB_USERNAME="master"

  usql "mysql://${DB_USERNAME}:${DB_PASSWORD}@${HOST}:3306/core"

  if [[ $? -ne 0 ]]; then
    local ENCODED_PASSWORD=$(printf '%s' "$DB_PASSWORD" | jq -sRr @uri)
    usql "mysql://${DB_USERNAME}:${ENCODED_PASSWORD}@${HOST}:3306/core"
  fi
}

alias db-core-dev='usql_connect_mysql development core.db.internal.allaria.dev development'
alias db-core-prod='usql_connect_mysql production core.db.internal.allaria.cloud production'
