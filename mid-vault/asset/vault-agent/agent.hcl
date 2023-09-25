exit_after_auth = VAULT_AGENT_EXIT_AFTER_AUTH
pid_file        = "./vault-agent.pid"

auto_auth {
  method "approle" {
    config = {
      role_id_file_path = "VAULT_AGENT_ROLE_ID_FILE"
      secret_id_file_path = "VAULT_AGENT_SECRET_ID_FILE"
      remove_secret_id_file_after_reading = VAULT_AGENT_REMOVE_AFTER_AUTH
    }
  }
}

vault {
  address = "VAULT_AGENT_SERVER_ADDR"
}

cache {
  use_auto_auth_token = true
}

listener "tcp" {
  address = "127.0.0.1:8200"
  tls_disable = true
}

