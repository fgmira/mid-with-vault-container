FROM hashicorp/vault:1.14.2

# VARIALBE FOR TESTING MODE, IF SET TO TRUE
# VAULT SERVER WILL NOT BE STARTED
# BUT THE CONTAINER UP
ENV CHECK_MODE "false"

# VARIABLES TO CREATE A KV SECRET IN VALUT SERVER
ENV SECRET_USER_NAME ""
ENV SECRET_USER_PWD ""

RUN apk add jq

COPY ./asset/* /vault

RUN chmod 6750 /vault/*

ENTRYPOINT [ "sh", "-c", "/vault/entrypoint.sh" ]
# ENTRYPOINT [ "sh", "-c", "tail -f /dev/null" ]