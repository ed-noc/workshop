SHELL:=/bin/bash

all: greet build

greet:
	$(info Hello Night of Chances 2023!)

clean:
	@bash scripts/stop-services.sh
	@rm -f .env .env*bak
	@find gitlab -type d -maxdepth 1 -mindepth 1 -exec rm -rf {} +

build: env-check
	@bash scripts/build.sh

extract-token:
	@docker exec noc-gitlab-ce gitlab-rails runner -e production "puts Gitlab::CurrentSettings.current_application_settings.runners_registration_token"

update-token-env:
	@sed -i .`date +%Y%m%d`.bak "s/REPLACE_ONCE_GENERATED/`docker exec noc-gitlab-ce gitlab-rails runner -e production "puts Gitlab::CurrentSettings.current_application_settings.runners_registration_token"`/g" .env

runner-register: update-token-env
	@bash scripts/register-runner.sh

personal-token:
	@docker exec noc-gitlab-ce gitlab-rails runner "token = User.find_by_username('root').personal_access_tokens.create(scopes: [:api], name: 'terraform'); token.set_token('my-tf-token-2022'); token.save"
	
build-ansible-image:
	$(info Building Ansible Image ...)
	docker build -t noc-ansible:1.0 -f ansible/Dockerfile .

build-ansible-image-no-cache:
	$(info Building Ansible Image --no-cache ...)
	docker build --no-cache --progress plain -t noc-ansible:1.0 -f ansible/Dockerfile .

env-check: 
	@if [ ! -f .env ]; then echo -e "Seems you are missing '.env' file.\nRun 'cp .env.default .env' to create one..."; exit 1; fi

vault-start:
	@docker compose -f vault/docker-compose.yml up -d

vault-configure: build-ansible-image
	@docker run --rm -it -v ${PWD}/vault:/vault --network=toolchain-network noc-ansible:1.0 ansible-playbook /vault/playbooks/main.yml

vault-clean: 
	@cd vault && docker compose down
	@rm -rf vault/.init_tokens vault/vault/data vault/vault/logs vault/vault/policies
