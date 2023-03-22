# Vault

Welcome to this part of the workshop. Here we will do a little intro to a tool called **Vault**. It is an open-source secret management tool, encryption as a service and privileged access management tool.

GitLab can consume external secrets. There are Premium-Tier options on how to do so, however we are on a budget, right? So, lets try to make this happen without paying a dime.

## Getting Started

We prepared a few things in this folder (vault) for you to make your life easier, or more complicated. We will see :)

Again we will use **GitLab Runner** to obtain the secrets from Vault, but no additional configuration should be done to GitLab Runner at this time.

## Vault Start

Starting Vault should be straightforward. Just run it using docker compose in this directory. It will boot quite quickly and should be reachable at [http://localhost:8200](http://localhost:8200)

```bash
docker-compose -p vault up -d
```

## Vault Initialization & Configuration

To initialize Vault, yet to configure it in a basic way there are a few steps ahead. But no worries, if you are persistent enough you may very well automate the effort away.

### Prerequisites

There are some prerequisites to this. As part of Vault configuration we will set JWT auth method role. In order to do this GitLab needs to be already running and reachable from our containers (take a look at the parent [README.md](../terraform/README.md) for further instructions regarding GitLab).

A few curls that you can use to check it out:

```bash
curl -s -k -X GET http://localhost/-/jwks | jq
curl -s -k -X GET http://localhost/.well-known/openid-configuration | jq
```

### Initialize & Configure

#### TL;DR

There are a few lines of ansible code prepared for you to initialize and configure Vault. 

First build locally an Ansible image you can use to run the playbook.

```
docker build -t noc-ansible:alpine -f ../ansible/Dockerfile .
```

Once your build is done try to run the playbook inside your newly build container to configure initialize and configure Vault for you.

```
docker run --rm -it -v ${PWD}:/vault --network=toolchain-network noc-ansible:alpine ansible-playbook /vault/playbooks/main.yml
```

#### Details

Once Vault is up, you can use your console to interact with vault, given you have installed it.
If thats not the case, we can click around UI for most of actions.

To provide an address to vault utility should export its address.

```bash
export VAULT_ADDR=http://localhost:8200
```

Use the root token to log in. You can get it from `.init_tokens` file.
```
vault login
```

Check the status of Vault.
```
vault status
```

Enable JWT auth method and configure its details.
```
vault auth enable jwt
vault write auth/jwt/config jwks_url="http://noc-gitlab-ce/-/jwks" bound_issuer="http://localhost"
vault read auth/jwt/config
```

Create a key-value secret engine and provide it with some secret on a specific path.
```
vault secrets enable -version=2 -path=secrets kv
vault kv put secrets/gitlab/project_1 event=noc
vault kv get secrets/gitlab/project_1
vault kv get -field=event secrets/gitlab/project_1
```

Create a specific Vault policy, so Vault knows that GitLab needs to read the secrets.

```bash
vault policy write gitlab-vault-readonly playbooks/files/gitlab-vault-policy.hcl
vault policy read gitlab-vault-readonly
```

Create an auth role for GitLab.

```bash
cat playbooks/files/gitlab-jwt-role.json | vault write auth/jwt/role/gitlab-vault-readonly -
vault list auth/jwt/role
vault read auth/jwt/role/gitlab-vault-readonly
```

## Getting Secret in a Pipeline

Next, you need to create a **New project** within GitLab. Choose the **Create blank project** option, choose a name for you project (e.g. Vault), and set the repository to **Public**. Also uncheck the **Initialize repository with a README** option, so our project is initialized completely empty.

Open the project in WEB IDE and create a new `.gitlab-ci.yml` file with following content:

```bash
variables:
  VAULT_ADDR: http://vault:8200
  VAULT_SECRET_PATH: gitlab/project_1
  VAULT_ROLE: gitlab-vault-readonly

stages:
  - get_secrets

vault secrets:
  stage: get_secrets
  image: alpine:latest
  script:
    ##### Print attributes about job #####
    - echo $CI_COMMIT_REF_NAME
    - echo $CI_COMMIT_REF_PROTECTED
    ##### Install CURL #####
    - sed -i 's/https/http/g' /etc/apk/repositories
    - apk add --allow-untrusted -q curl jq vault
    ##### Obtain Vault token #####
    - export VAULT_TOKEN="$(vault write -field=token auth/jwt/login role=${VAULT_ROLE} jwt=$CI_JOB_JWT_V2)"
    - echo $VAULT_TOKEN
    ##### Obtain Vault secret #####
    - export EVENT="$(vault kv get -field=event secrets/gitlab/project_1)"
    - echo $EVENT
```

This yml configuration file is also available next to this README.md.

Once you commit, hopefully the magic will happen and you will be able to obtain your secret stored in Vault.
