# !/bin/bash
# test_user
# kxX1xZ-pKGWTU;fD

logInfo () {
  msg="[VAULT SERVER - entrypoint script] $(date '+%Y-%m-%dT%T.%3N') ${1}"
  echo "$msg" | tee -a ${LOG_FILE}
}

startVaultServer() {
  # start vault server
  logInfo "Starting vault server"
  export VAULT_ADDR='http://127.0.0.1:8200'
  export VAULT_TOKEN=root
  vault server -dev -log-level=trace &
}

createSecret(){
  logInfo "Enembling the KV secrets engine"
  vault secrets enable -path=kv-service-now kv
  logInfo "Secret engine enabled"
  logInfo "Creatind a KV secret"
  vault kv put kv-service-now/${SECRET_USER_NAME} username=${SECRET_USER_NAME} password=${SECRET_USER_PWD}

  logInfo "Setting SECRET_USER_NAME = '${SECRET_USER_NAME}' in /vault/01-mid-policy.hcl"
  sed -i "s~VAULT_AGENT_SERVER_ADDR~${SECRET_USER_NAME}~g" /vault/01-mid-policy.hcl

  logInfo "Secret created"
  logInfo "Creating a policies"
  vault policy write mid-vault-policy /vault/01-mid-policy.hcl
  logInfo "Policy mid-vault-policy created"
  vault policy write vai-brasil /vault/02-admin-policy.hcl
  logInfo "Policy created"
}

enableAppRole() {
  logInfo "Enabling the AppRole auth method and create credentials to vault agent"
  # Enable the AppRole auth method:
  vault auth enable approle
  logInfo "AppRole auth method enabled"
  # Create a Role for Mid Server:
  vault write auth/approle/role/midserver-role \
    secret_id_ttl=1h \
    secret_id_num_uses=99 \
    token_ttl=1h \
    token_max_ttl=4h \
    policies="midserver-policy,vai-brasil"
  logInfo "Role for Mid Server created"
  # write out a Role ID and Secret ID:
  logInfo "Writing out a Role ID and Secret ID in /vault/role/"
  vault read -format=json auth/approle/role/midserver-role/role-id | jq -r '.data.role_id' > /vault/role/role_id.txt
  vault write -format=json -f auth/approle/role/midserver-role/secret-id | jq -r '.data.secret_id' > /vault/role/secret_id.txt
  logInfo "Role ID and Secret ID written"
}

createLogDevice(){
  logInfo "Creating log device"
  # Create a log device
  vault audit enable file file_path=/vault/logs/vault_audit.log
  logInfo "Log device created"
  logInfo "Sleeping for 10 seconds to change permission in log file" &&  sleep 10 ;
  touch /vault/logs/vault_audit.log
  logInfo "Log file created"
  chmod 644 /vault/logs/vault_audit.log
  logInfo "Log file permissions changed"
}

letsGo(){
  if [ "${SECRET_USER_NAME}" == "" ] || [ "${SECRET_USER_PWD}" == "" ] ;
    then
      logInfo "SECRET_USER_NAME or SECRET_USER_PWD is not set. Exiting ..." && exit 1 ;
  fi
  # start vault server
  startVaultServer ;
  logInfo "Sleeping for 10 seconds to server up" &&  sleep 10 ;
  # create log device
  createLogDevice ;
  # create policy and store secret
  createSecret ;
  # enable approle
  enableAppRole ;
}


if [ "${CHECK_MODE}" == "true" ] || [ "${CHECK_MODE}" == "TRUE" ] ;
  then
    logInfo "CHECK_MODE is set to true. Waiting ..." ;
  else
  # start vault server
  logInfo "CHECK_MODE is set to false. Starting vault server" && letsGo ;
fi

tail -f /dev/null