.PHONY: clean
clean:
	rm -rf mixtapestudy

.PHONY: lint
lint:
	./ansible/.venv/bin/yamllint ./ansible/ec2-config.yaml --strict
	./ansible/.venv/bin/yamllint ./ansible/rds-config.yaml --strict
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

.priv/vault:
	@echo "Vault file requires:"
	@echo "  docker_domain"
	@echo "  docker_password"
	@echo "  database_domain"
	@echo "  database_admin_username"
	@echo "  database_admin_password"
	@echo "  database_user_username"
	@echo "  database_user_password"
	mkdir -p .priv
	./ansible/.venv/bin/ansible-vault create .priv/vault

.PHONY: push
push: lint .priv/vault
	./ansible/.venv/bin/ansible-playbook \
		--ask-vault-password \
		--inventory .priv/inventory.ini \
		./ansible/ec2-config.yaml

.PHONY: config_database
config_database: .priv/vault
	./ansible/.venv/bin/ansible-playbook \
		--ask-vault-password \
		--inventory .priv/inventory.ini \
		./ansible/rds-config.yaml

.PHONY: vault
vault: .priv/vault
	./ansible/.venv/bin/ansible-vault edit .priv/vault