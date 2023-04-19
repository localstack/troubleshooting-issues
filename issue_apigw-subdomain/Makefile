export AWS_ACCESS_KEY_ID ?= test
export AWS_SECRET_ACCESS_KEY ?= test
export AWS_DEFAULT_REGION ?= us-east-1

STAGE ?= local

usage:       ## Show this help
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

install:     ## Install dependencies
	@npm install
	@which serverless || npm install -g serverless
	@which localstack || pip install localstack
	@which awslocal || pip install awscli-local

deploy_aws:
	SLS_DEBUG=1 serverless deploy --stage dev && make save_url STAGE=dev

deploy:         ## Deploy the app locally
		@echo "Deploying Serverless app to local environment"; \
		SLS_DEBUG=1 serverless deploy --stage local && make save_url STAGE=local

save_url:
	serverless info --stage $(STAGE) --verbose | grep HttpApiUrl | awk '{print $$2}' >url.txt

invoke:			## Invoke the app
	curl -v "$$(cat url.txt)/hello"

container_invoke:
	URL=$$(cat url.txt)/hello && docker run --rm -it --network ls nicolaka/netshoot /bin/bash -c "curl $${URL}"

container_shell:
	@echo "Invoke URL:"
	@echo "$$(cat url.txt)hello"
	docker run --rm -it --network ls nicolaka/netshoot /bin/bash

start:
	localstack start -d

stop:
	@echo
	localstack stop
ready:
	@echo Waiting on the LocalStack container...
	@localstack wait -t 30 && echo Localstack is ready to use! || (echo Gave up waiting on LocalStack, exiting. && exit 1)

logs:
	@localstack logs > logs.txt

test-ci:
	make start install ready run; return_code=`echo $$?`;\
	make logs; make stop; exit $$return_code;

clean:
	rm -rf .serverless
	rm -rf node_modules

.PHONY: usage install run invoke container_invoke container_shell deploy deploy_aws save_url ready stop logs test-ci clean
