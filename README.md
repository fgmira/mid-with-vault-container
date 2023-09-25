# MID-Vault

### Descrição:
Este projeto tem como objetivo criar um ambiente de teste para o uso do [MID Server](https://docs.servicenow.com/bundle/paris-servicenow-platform/page/product/mid-server/concept/mid-server-overview.html) da plataforma ServiceNow, utilizando o credential resolver da [Hashicorp](https://www.hashicorp.com/). Esta solução permite que as credenciais de acesso aos servidores sejam armazenadas de forma segura, utilizando o [Vault](https://www.vaultproject.io/) e que a instância [Service Now](https://www.servicenow.com/) possa acessar essas credenciais de forma segura, utilizando o [Credential Resolver](https://docs.servicenow.com/bundle/paris-servicenow-platform/page/product/mid-server/concept/mid-server-credential-resolver.html).


### Requisitos:
- Ter instalado na maquina os seguintes programas:
    * [Docker](https://docs.docker.com/get-docker/)
    * [Docker Compose](https://docs.docker.com/compose/install/)
    * [Git](https://git-scm.com/downloads)

- Ter uma PDI (Personal Developer Instance) da plataforma ServiceNow. Para criar uma PDI, acesse o link: [https://developer.servicenow.com/dev.do](https://developer.servicenow.com/dev.do)

### Procedimentos e configurações a serem realizados:
0. Clone este repositório:
    - Abra o terminal
    - Navegue até a pasta onde deseja clonar o repositório
    - Execute o comando:
    ```
        git clone https://github.com/fgmira/mid-with-vault-container.git
    ```

1. Instale os plugins necessários:
    - Acesse o site [developer.servicenow.com](https://developer.servicenow.com/dev.do)
    - Na barra superior, clique no avatar de seu usuário, na coluna instance actions clique em `Activate Plugin`
    - Na caixa de pesquisa, digite `External Credential Storage` e clique em `Activate`
    - Na caixa de pesquisa, digite `ServiceNow IntegrationHub Installer` e clique em `Activate`
    - Aguarde a instalação dos plugins. Você receberá uns e-mails quando as instalações forem concluídas.

2. Crie os **usuários necessários**:
    - Acesse sua ***PDI*** e faça login com o usuário `admin` e crie os seguintes usuários:
        - Usuário que será utilizado pelo **MID Server** para acessar o ServiceNow:
            * Acesse o menu `System Security > Users`
            * Clique em `New`
            * Preencha os campos:
                - `First name`: `MID`
                - `Last name`: `Server`
                - `User name`: `mid_server`
                - `Email`: `mid_server@mid_server.com`
                - `Active`: `true`
            * Clique em `Submit`
            * Clique em `Set Password`
                - Clique em `Generate`
                - Copie a senha gerada
                - Clique em `Save Password` e depois em `OK`
            * Ao voltar para o registro do usuário, desmarque a opção `Password needs reset` e salve o registro
            * Na releated list de `Roles`, clique em `New` e selecione a role `mid_server`
        - Usuário que será utilizado como uma **credendial de exemplo a ser recuperada do Vault**:
            * Acesse o menu `System Security > Users`
            * Clique em `New`
            * Preencha os campos:
                - `First name`: `Test`
                - `Last name`: `User`
                - `User name`: `test_user`
                - `Email`: `test_user@test_user.com`
                - `Active`: `true`
            * Clique em `Submit`
            * Clique em `Set Password`
                - Clique em `Generate`
                - Copie a senha gerada
                - Clique em `Save Password` e depois em `OK`
            * Ao voltar para o registro do usuário, desmarque a opção `Password needs reset` e salve o registro
    
3. Criar a **credencial**:
    - Acesse sua ***PDI*** e faça login com o usuário `admin`
    - Acesse o menu `Connections & Credentials > Credentials`
        - Clique em `New`
        - No interseptor selecione `Basic Auth Credentials`
        - Preencha os campos:
            - `Name`: `test_user`
        - Clique em `Submit`
        - Acesse o menu de conexto e troque a view para `External Credential Store`
        - Limpe o campo `Password`
        - Marque a opção `External Credential Store`
        - No campo `Credential storage` selecione `None`
        - No campo `Credential ID` digite o seguinte path:
        ```
            secret/midserver
        ```
        - Clique em `Submit`

4. Criar uma **connection**:
    - Acesse o Menu `Connections & Credentials > Connections`:
        - Clique em `New`
        - No interseptor selecione `HTTP(s) Connection`
        - Preencha os campos:
            - `Name`: `Get User List`
            - `Credential`: `test_user`
            
        - Clique em `Submit`

4. Instale o `JAR` do `Credential Resolver`:
    - Acesse [releses](https://releases.hashicorp.com/vault-servicenow-credential-resolver/) da Vault Hashicorp
        - Baixe a versão mais recente do `JAR` (neste projeto foi utilizado a versão `0.1.0`)
        - Descompacte o arquivo baixado para obter o `JAR`
    - Na sua ***PDI***, acesse o menu `MID Server > JAR Files`
        - Clique em `New`
        - Preencha os campos:
            - `Name`: `vault-servicenow-credential-resolver`
            - `Version`: `0.1.0`
            - `File`: Selecione o arquivo `JAR` obtido da etapa anterior

5. Configurando o projeto para rodar no seu ambiente:

6. Build das imagens do dockerfiles necessárias:
    - Mid Server:
        - Acesse a pasta do projeto `/mid-with-vault-container/app`
        - Execute o comando:
        ```bash
            docker build -t mid-vault:0.1.0 -f Dockerfile .
        ```
        - Verifique se a imagem foi criada com sucesso:
        ```bash
            docker images
        ```
        - No resultado da execução do comando acima, você deverá ver a imagem `mid-vault` com a tag `0.1.0`
    - Vault Server
        - Acesse a pasta do projeto `/mid-with-vault-container/vault-server`
        - Execute o comando:
        ```bash
            docker build -t vault-server:0.1.0 -f Dockerfile .
        ```
        - Verifique se a imagem foi criada com sucesso:
        ```bash
            docker images
        ```
        - No resultado da execução do comando acima, você deverá ver a imagem `vault-server` com a tag `0.1.0`

5. Iniciando o Docker Compose:
    - ***Este passo só poderá ocorrer se o passo anterior foi executado com sucesso.***
    - Na pasta do projeto localize o arquivo `/mid-with-vault-container/`
    - No arquivo `docker-compose.yml`:
        - Altere o valor da variável `MID_INSTANCE_URL` para a URL da sua ***PDI***.  Exemplo:
        ```yaml
            MID_INSTANCE_URL: "https://dev00000.service-now.com"
        ```
        - Altere o valor da variável `MID_INSTANCE_USER` para o usuário `mid_server` criado na etapa 2. Exemplo:
        ```yaml
            MID_INSTANCE_USER: "mid_server"
        ```
        - Altere o valor da variável `MID_INSTANCE_PASSWORD` para a senha do usuário `mid_server` criado na etapa 2. Exemplo:
        ```yaml
            MID_INSTANCE_PASSWORD: "#Da-jOd8M:A8w>y,o)3oE+iP*Pvk=7}:08"
        ```
        > ***DICA***: Estas variaveis se encontram dentro do serviço `mid_server_with_valt_agent` na linha 20, 21 e 22.
    - Na pasta do projeto execute o comando:
    ```bash
        docker-compose up
    ```
    - Este comando irá iniciar os containers e você poderá acompanhar o log de execução do `MID Server` e do `Credential Resolver`, porem seu terminal ficará preso a execução dos containers. Para executar os containers em modo `detached` (em segundo plano), execute o comando:
    ```bash
        docker-compose up -d
    ```
    - Para acompanhar o log de execução dos containers execute o comando:
    ```bash
        docker-compose logs -f
    ```
    - Para parar a execução dos containers execute o comando:
    ```bash
        docker-compose down
    ```

6. Validando o `MID Server`:
    - ***Este passo só poderá ocorrer se o passo anterior foi executado com sucesso.***
    - Acesse sua ***PDI*** e faça login com o usuário `admin`
    - Acesse o menu `MID Server > Servers`
    - Na lista de MID Servers, localize o MID Server com o nome `mid-vault` e acesse seu registro
        - Verifique se o campo `Status` está com o valor `Up`
        - Nas UI Actions Links, clique na Action `Validate`
        - Aguarde um momento e verifique se o campo `Validated` está com o valor `true`
        - Na releated list `Properties` clique em `New`
            - Preencha os campos:
                - `Name`: `mid.external_credentials.vault.address`
                - `Value`: `http://127.0.0.1:8200`
            - Clique em `Submit`

7. Validando o `Credential Resolver`:
    - ***Este passo só poderá ocorrer se o passo anterior foi executado com sucesso.***
    - Acesse sua ***PDI*** e faça login com o usuário `admin`
    - Acesse o menu `Flow Designer`
    - Na nova tela aberta, crie uma nova `Action`:
        - Na Tela de `Action Properties`:
            - Preencha os campos:
                - `Name`: `Test Credential Resolver`
                - `Description`: `Test Credential Resolver`
                - Os demais campos deixar com os valores padrões
            - Clique em `Submit`
        - Na Tela de `Action Designer`:
            - Adicione um step do tipo `Look Up Record`
                - Na tela de `Step Properties`:
                    - Preencha os campos:
                        - `Table`: `MID Server [ecc_agent]`
                        - `Filter`: `user_name` `is` `mid-vault`
                        - Os demais campos deixar com os valores padrões
                    - Clique em `Save`
            - Adicione um step do tipo `REST`:
                - Na tela de `Step Properties`:
                    - `Connection`: `Use Connection Alias`
                    - `Connection Alias`: 
                        - Clique no botão `+`. Você será direcionado para a tela de criação de uma `HTTP(s) Connection`:
                            - Preencha os campos:
                                - `Name`: `Get Sys User List`
                                - `Type`: `HTTP(s)`
                                - `Base URL`: `http://






### Comandos uteis:

- `docker-compose up -d` - Inicia os containers

- `docker run -d --name test mid-vault:0.1.0 /bin/bash -c "tail -f /dev/null"` - Inicia o container em modo de teste

- `docker build -t mid-vault:0.1.0 -f Dockerfile .` - Cria a imagem do container