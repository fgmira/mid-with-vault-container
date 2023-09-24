FROM eclipse-temurin:8-jdk-alpine AS download_verification

RUN apk -q update && \
    apk add bash && \
    apk add -q wget && \
    rm -rf /tmp/*

ARG MID_INSTALLATION_URL=https://install.service-now.com/glide/distribution/builds/package/app-signed/mid/2023/06/23/mid.utah-12-21-2022__patch4-hotfix2-06-23-2023_06-23-2023_2224.linux.x86-64.zip
ARG MID_INSTALLATION_FILE
ARG MID_SIGNATURE_VERIFICATION="TRUE"

WORKDIR /opt/snc_mid_server/

COPY asset/mid-server/validate_signature.sh asset/mid-server/download.sh /opt/snc_mid_server/

# download.sh and validate_signature.sh
RUN chmod 6750 /opt/snc_mid_server/*.sh

RUN echo "Check MID installer URL: ${MID_INSTALLATION_URL} or Local installer: ${MID_INSTALLATION_FILE}"

# Download the installation ZIP file or using the local one
RUN if [ -z "$MID_INSTALLATION_FILE" ] ; \
    then /opt/snc_mid_server/download.sh $MID_INSTALLATION_URL ; \
    else echo "Use local file: $MID_INSTALLATION_FILE" && ls -alF /opt/snc_mid_server/ && mv /opt/snc_mid_server/$MID_INSTALLATION_FILE /tmp/mid.zip ; fi

# Verify mid.zip signature
RUN if [ "$MID_SIGNATURE_VERIFICATION" = "TRUE" ] || [ "$MID_SIGNATURE_VERIFICATION" = "true" ] ; \
    then echo "Verify the signature of the installation file" && /opt/snc_mid_server/validate_signature.sh /tmp/mid.zip; \
    else echo "Skip signature validation of the installation file "; fi

RUN unzip -d /opt/snc_mid_server/ /tmp/mid.zip && rm -f /tmp/mid.zip

FROM alpine:latest

# ##########################
# INSTALLATION OF COMMON UTILITIES
# ##########################

# Install common utilities and clean up

RUN apk add --no-cache \
    alpine-keys \
    bash \
    build-base \
    ca-certificates \
    curl \
    gcompat \
    iputils \
    libc6-compat \
    libgcc \
    net-tools \
    procps \
    shadow \
    unzip \
    xmlstarlet \
    wget \
    && apk add --update alpine-sdk \
    && rm -rf /tmp/*

ENV CHECK_MODE "false"

# ##########################
# INSTALATION OF VAULT AGENT
# ##########################

# RUNTIME ENV VAR DEFINITION

ENV VAULT_VERSION=1.14.2
ENV VAULT_AGENT_EXIT_AFTER_AUTH ""
ENV VAULT_ROLE ""
ENV TARGET_FILE_NAME ""
ENV VAULT_ADDR ""
ENV VAULT_AGENT_TEMPLATE_FILE "/vault-agent/secret.j2"

# INSTALLATION OF VAULT AGENT

# Download and install Vault
RUN curl -sSLo /tmp/vault.zip https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip && \
    unzip /tmp/vault.zip -d /usr/local/bin && \
    rm /tmp/vault.zip

# Create a directory to store Vault data
RUN mkdir -p /vault-agent

# Copy the Vault files
COPY asset/vault-agent/* /vault-agent/

# Make the Vault files executable
RUN chmod 6750 /vault-agent/*

# ##########################
# INSTALATION OF MID SERVER
# ##########################

# ARGUMENTS DEFINITION

ARG MID_USERNAME=mid
ARG GROUP_ID=1001
ARG USER_ID=1001

# RUNTIME ENV VAR DEFINITION

# Ensure UTF-8 Encoding
ENV LANG en_US.UTF-8

# Mandatory Env Var
ENV MID_INSTANCE_URL ""
ENV MID_INSTANCE_USERNAME ""
ENV MID_INSTANCE_PASSWORD ""
ENV MID_SERVER_NAME ""
# Optional Env Var
ENV MID_PROXY_HOST ""
ENV MID_PROXY_PORT ""
ENV MID_PROXY_USERNAME ""
ENV MID_PROXY_PASSWORD ""
ENV MID_SECRETS_FILE ""
ENV MID_MUTUAL_AUTH_PEM_FILE ""
ENV MID_SSL_BOOTSTRAP_CERT_REVOCATION_CHECK ""
ENV MID_SSL_USE_INSTANCE_SECURITY_POLICY ""



# COPY DONLOADED MID SERVER AND SCRIPTS

# Copy the MID server files and set the user and group ownership
# COPY --chown=$MID_USERNAME:$MID_USERNAME --from=download_verification /opt/snc_mid_server/ /opt/snc_mid_server/
COPY --from=download_verification /opt/snc_mid_server/ /opt/snc_mid_server/

# Copy the MID assets
COPY asset/mid-server/* /opt/snc_mid_server/

# Make the scripts executable and set the user and group ownership
# RUN chmod 6750 /opt/snc_mid_server/* && chown -R $MID_USERNAME:$MID_USERNAME /opt/snc_mid_server/
RUN chmod 6750 /opt/snc_mid_server/* 

# ##########################
# STARTUP SCRIPT
# ##########################
# CREATE USER AND GROUP

# Check if the group and user id are set, if not set them to default
# RUN if [[ -z "${GROUP_ID}" ]]; then GROUP_ID=1001; fi && \
#     if [[ -z "${USER_ID}" ]]; then USER_ID=1001; fi && \
#     echo "Add GROUP id: ${GROUP_ID}, USER id: ${USER_ID} for username: ${MID_USERNAME}"

# Create the group and user
# RUN addgroup -g $GROUP_ID $MID_USERNAME && \
#     adduser -c "MID container user" -r -m -u $USER_ID -G $MID_USERNAME $MID_USERNAME

# copy the startup script and health check script
COPY asset/healt-check.sh asset/entrypoint.sh /
RUN chmod 6750 /*.sh

# SET USER AT ROOT
# RUN addgroup -g 0 rootgroup && adduser -D -u 1000 -G rootgroup $MID_USERNAME
# USER $MID_USERNAME

# Set the health check script
HEALTHCHECK --interval=5m --start-period=3m --retries=3 --timeout=15s \
    CMD bash /healt-check.sh || exit 1

WORKDIR /

# Set the entrypoint
ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]




