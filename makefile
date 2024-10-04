.PHONY: lint
lint:
	# noop

.PHONY: test
test:
	# noop

./ansible/.venv:
	python -m venv ./ansible/.venv

./mixtapestudy:
	git clone git@github.com:douglasryanadams/mixtapestudy.git

.PHONY: init
init: ./ansible/.venv ./mixtapestudy
	./ansible/.venv/bin/python -m pip install ansible

.PHONY: validate
validate: ./mixtapestudy
	@# This will take a few minutes the first time as it builds a few
	@# docker images, it may appear to hang at the tests
	cp fake.env mixtapestudy/.env
	cd mixtapestudy && git checkout main \
		&& git pull origin main \
		&& make check

.PHONY: healthcheck
healthcheck:
	./ansible/.venv/bin/ansible mixtapehosts -m ping -i .priv/inventory.ini

