.PHONY: docker.% test.% default help yarn.% rails.% aws.%

SERVICE ?= web
APP_NAME ?= medarrive.web
GEM_LOCK_MD5 ?= `md5 -q Gemfile.lock | cut -c1-5`
GEM_MD5 ?= `md5 -q Gemfile | cut -c1-5`
YARN_MD5 ?= `md5 -q yarn.lock | cut -c1-5`
DOCKER_COMMAND ?= ./run_docker.sh
default: help

.ONESHELL:
aws.ecr.login: #: Login to AWS ECR
	aws ecr get-login-password --region us-east-1 | docker login \
		--username AWS --password-stdin 915162735042.dkr.ecr.us-east-1.amazonaws.com

.ONESHELL:
ci.build.web: #: Build CI and Prod images
	REPO_URL_API=variable \
	IMAGE_TAG=variable \
	SECRET_KEY_BASE=precompile \
	docker compose -f ./docker-compose.ci.yml build \
		--build-arg SECRET_KEY_BASE=$SECRET_KEY_BASE \
		--build-arg SENTRY_DSN=$SENTRY_DSN \
		--build-arg POSTMARK_API_KEY=$POSTMARK_API_KEY \
		--build-arg SECRET_KEY_BASE=$SECRET_KEY_BASE web

ci.brakeman.quiet: #: Run from inside of a container for Breakman security checks
	bundle exec brakeman --color -q --no-exit-on-warn

# rails.erd: docker.build #: Generate ERD Model Diagram for Rails
docker.routes:  docker.build docker.up.daemon #: Run rails route on Rails
	$(DOCKER_COMMAND) --command "exec $(SERVICE) bundle exec rails routes"

rails.bash: docker.bash #: Launch rails core container to a bash prompt Alias of docker.bash

rails.backgroundjob.start: docker.up.daemon #: Starts background Jobs
	$(DOCKER_COMMAND) --command "exec $(SERVICE) bin/delayed_job start"

rails.backgroundjob.stop: docker.up.daemon #: Stops background Jobs
	$(DOCKER_COMMAND) --command "exec $(SERVICE) bin/delayed_job stop"

rails.console: docker.build docker.up.daemon #: Interactive rails console
	$(DOCKER_COMMAND) --command "exec $(SERVICE) bundle exec rails c"

rails.migrate: docker.build docker.up.daemon #: Run rails db:migrate
	$(DOCKER_COMMAND) --command "exec $(SERVICE) bundle exec rails db:migrate"

rails.logs: docker.build docker.up.daemon #: Tail the docker compose logs
	$(DOCKER_COMMAND) --command "exec $(SERVICE) tail -fn0 log/*"

javascript.lint: docker.build docker.up.daemon #: Run ts lint
	$(DOCKER_COMMAND) --command "exec $(SERVICE) yarn lint-fix"
	$(DOCKER_COMMAND) --command "exec $(SERVICE) yarn tsc"

graph.gen: docker.build docker.up.daemon #: Run graph gen commands
	$(DOCKER_COMMAND) --command "exec -T $(SERVICE) yarn graphql-gen"

docker.logs: docker.build docker.up.daemon #: Tail the docker compose logs
	$(DOCKER_COMMAND) --command "logs -t -f --tail -n=30"

docker.log.web: docker.build docker.up.daemon #: Tail the web log
	$(DOCKER_COMMAND) --command "logs $(SERVICE) -t -f --tail=30"

docker.ps: #: Show running processes
	$(DOCKER_COMMAND) --command "ps"

docker.bash: docker.build docker.up.daemon #: Attach to running we container
	$(DOCKER_COMMAND) --command "exec $(SERVICE) /bin/bash"

rails.annotate: docker.build docker.up.daemon #: Annotate new routes for rails
	$(DOCKER_COMMAND) --command "exec $(SERVICE) bundle exec rails generate_ts_routes annotate_routes"

docker.restart: docker.build #: Restart the service container
	$(DOCKER_COMMAND) --command "restart $(SERVICE)"

rails.seed: docker.build docker.up.daemon #: Seed the DB
	$(DOCKER_COMMAND) --command "exec $(SERVICE) bundle exec rails db:seed"

rails.setup_db: docker.build docker.up.daemon #: Create the db table(s)
	$(DOCKER_COMMAND) --command "exec $(SERVICE) bundle exec rails db:drop db:create db:migrate"

yarn.install: docker.build docker.up.daemon #: Force reinstall of yarn packages
	$(DOCKER_COMMAND) --command "exec -T $(SERVICE) yarn install"

yarn.integrity: docker.build docker.up.daemon #: Check yarn packages
	$(DOCKER_COMMAND) --command "exec -T $(SERVICE) yarn check --integrity"

yarn.outdated: docker.build docker.up.daemon #: Check yarn packages for out of date packages
	$(DOCKER_COMMAND) --command "exec -T $(SERVICE) yarn outdated"

yarn.audit: docker.build docker.up.daemon #: Check yarn packages for high and critical updates
	$(DOCKER_COMMAND) --command "exec -T $(SERVICE) yarn audit --level high"

docker.stop: #: Stop running containers
	$(DOCKER_COMMAND) --command stop

docker.up.daemon: docker.build #: Start web containers
	$(DOCKER_COMMAND) --command "up -d"

docker.up: docker.build #: Start web containers
	$(DOCKER_COMMAND) --command up

docker.down: #: Bring down the service
	$(DOCKER_COMMAND) --command down

docker.ngrok: docker.build docker.up.daemon #: Start Ngrok
	$(DOCKER_COMMAND) --command "exec $(SERVICE) bin/ngrok"

docker.build: aws.ecr.login #: Build the containers base and full images if none are built. Fake versoin of v42
	./build_images.sh

docker.build.force: aws.ecr.login #: Force rebuild of docker images
	./build_images.sh FORCE

docker.purge: #: Completely clear docker backend including cached images
	./bin/docker_purge.sh

test.js: docker.build docker.up.daemon #: Run Yarn tests
	$(DOCKER_COMMAND) --command "exec $(SERVICE) yarn test $(ARGS)"

test.ruby.guard: docker.build docker.up.daemon #: Run rspec tests with Guard
	$(DOCKER_COMMAND) --command "exec $(SERVICE) bundle exec guard -g rails" --environment guard

test.ruby: docker.build docker.up.daemon #: run Rspec Tests
	$(DOCKER_COMMAND) --command "exec $(SERVICE) bundle exec rspec $(ARGS)"

test.coverage: #: Show Rspec Test results and code coverage
	open coverage/index.html

test.parallel: docker.build docker.up.daemon #: Run Rspec Tests in Parallel
	$(DOCKER_COMMAND) --command "exec $(SERVICE) bundle exec rails parallel:spec"

test.js.watch: docker.build docker.up.daemon #: Watch yarn files for test changes
	$(DOCKER_COMMAND) --command "exec $(SERVICE) yarn test:watch"

test.rescue: docker.build docker.up.daemon #: Rescue Rspec Ruby tests
	$(DOCKER_COMMAND) --command "exec $(SERVICE) bundle exec rescue rspec $(ARGS)"

rubocop.all: docker.build docker.up.daemon #: --command "execute rubocop on all working directories
	$(DOCKER_COMMAND) --command "exec $(SERVICE) bundle exec rubocop -A app/ spec/ bin/ bin/"

rubocop.modified: docker.build docker.up.daemon #: --command "execute rubocop on all changed files
	$(DOCKER_COMMAND) --command "exec $(SERVICE) bin/direnv/rubocop_changed"

githooks.precommit: docker.build docker.up.daemon #: Checks and auto corrects types where possible on changed files
	$(DOCKER_COMMAND) --command "exec $(SERVICE) bin/direnv/fast_thread.rb"

help: #: Show help topics
	@grep "#:" Makefile* | grep -v "@grep" | sort | sed "s/\([A-Za-z_ -]*\):.*#\(.*\)/$$(tput setaf 3)\1$$(tput sgr0)\2/g"
	
db.dump: docker.build docker.up.daemon # Create backup dump of only the database data
	docker-compose exec db sh -c "PGPASSWORD=password pg_dump -U postgres --column-inserts --data-only -F c -v -h db -d myapp_development > backup.sql"

db.restore: docker.build docker.up.daemon # Restores database data from backup
	docker-compose exec db sh -c "PGPASSWORD=password pg_restore -U postgres -d myapp_development backup.sql"

db.rebuild: db.dump rails.setup_db db.restore # Dumps, wipes, restores data from prior state