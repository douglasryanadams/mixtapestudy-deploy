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

.PHONY: push
push:


.priv/vault:
	@echo "Vault file requires: ecr_domain and ecr_password"
	mkdir -p .priv
	./ansible/.venv/bin/ansible-vault create .priv/vault

.PHONY: config
config: lint .priv/vault
	./ansible/.venv/bin/ansible-playbook \
		--ask-vault-password \
		--inventory .priv/inventory.ini \
		./ansible/playbook.yaml

.PHONY: vault
vault: .priv/vault
	./ansible/.venv/bin/ansible-vault edit .priv/vault