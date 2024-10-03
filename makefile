.PHONY: lint
lint:
	# noop

.PHONY: test
test:
	# noop

./mixtapestudy:
	git clone git@github.com:douglasryanadams/mixtapestudy.git

.PHONY: validate
validate: ./mixtapestudy
	@# This will take a few minutes the first time as it builds a few
	@# docker images, it may appear to hang at the tests
	cp fake.env mixtapestudy/.env
	cd mixtapestudy && git checkout main \
		&& git pull origin main \
		&& make check
