.PHONY: clean
clean:
	rm -rf mixtapestudy

.PHONY: lint
lint:
	./ansible/.venv/bin/yamllint ./ansible/playbook.yaml --strict
	@# Ansible lint was more trouble than it was worth, may revisit in the future

.PHONY: test
test:
	# noop

./ansible/.venv:
	python -m venv ./ansible/.venv

./mixtapestudy:
	git clone git@github.com:douglasryanadams/mixtapestudy.git

.PHONY: init
init: ./ansible/.venv ./mixtapestudy
	./ansible/.venv/bin/python -m pip install ansible yamllint ansible-lint
	./ansible/.venv/bin/ansible-galaxy collection install community.docker
	./ansible/.venv/bin/ansible-galaxy collection install ansible.posix

.PHONY: validate
validate: ./mixtapestudy
	@# This will take a few minutes the first time as it builds a few
	@# docker images, it may appear to hang at the tests
	cp fake.env mixtapestudy/.env
	cd mixtapestudy \
		&& git checkout main \
		&& git pull origin main \
		&& PYTHONDONTWRITEBYTECODE=x make check \
		&& make clean
	rm mixtapestudy/.env

.PHONY: healthcheck
healthcheck:
	# TODO: Write healthcheck playbook
	./ansible/.venv/bin/ansible mixtapehosts -m ping -i .priv/inventory.ini

#.PHONY: push
#push: env_check validate
#	aws ecr get-login-password --region "${AWS_REGION}" \
#		| docker login --username AWS --password-stdin "${DOCKER_DOMAIN}"
#	docker build \
#		--tag "${DOCKER_DOMAIN}/mixtapestudy/nginx:${MIXTAPE_VERSION}" \
#		--tag "${DOCKER_DOMAIN}/mixtapestudy/nginx:latest" \
#		mixtapestudy/nginx
#	docker build \
#		--tag "${DOCKER_DOMAIN}/mixtapestudy/mixtapestudy:${MIXTAPE_VERSION}" \
#		--tag "${DOCKER_DOMAIN}/mixtapestudy/mixtapestudy:latest" \
#		mixtapestudy
#	docker push "${DOCKER_DOMAIN}/mixtapestudy/nginx:${MIXTAPE_VERSION}"
#	docker push "${DOCKER_DOMAIN}/mixtapestudy/nginx:latest"
#	docker push "${DOCKER_DOMAIN}/mixtapestudy/mixtapestudy:${MIXTAPE_VERSION}"
#	docker push "${DOCKER_DOMAIN}/mixtapestudy/mixtapestudy:latest"

.priv/vault:
	@echo "Vault file requires: ecr_domain and ecr_password"
	mkdir -p .priv
	./ansible/.venv/bin/ansible-vault create .priv/vault

.PHONY: push
push: lint .priv/vault
	./ansible/.venv/bin/ansible-playbook \
		--ask-vault-password \
		--inventory .priv/inventory.ini \
		./ansible/playbook.yaml

.PHONY: vault
vault: .priv/vault
	./ansible/.venv/bin/ansible-vault edit .priv/vault