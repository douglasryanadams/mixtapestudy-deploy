.PHONY: lint
lint:
	./ansible/.venv/bin/yamllint ./ansible/playbook.yaml --strict
	# Using the venv to avoid warning from ansible-lint
	source ./ansible/.venv/bin/activate && ansible-lint ./ansible/playbook.yaml --strict

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
push: lint
	./ansible/.venv/bin/ansible-playbook -i .priv/inventory.ini ./ansible/playbook.yaml
