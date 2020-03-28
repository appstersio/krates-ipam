# README: http://makefiletutorial.com

# Courtesy of: https://stackoverflow.com/a/49524393/3072002
# Common env variables (https://www.gnu.org/software/make/manual/make.html#index-_002eEXPORT_005fALL_005fVARIABLES)
.EXPORT_ALL_VARIABLES:
VERSION=$(shell cat VERSION)

.PHONY: test build run login push

build:
	@docker build --no-cache --pull -t krates/ipam-plugin:${VERSION} .

test:
	@docker run -ti --rm -v "$$(pwd):/app" krates/ipam-plugin:${VERSION} bundle exec rspec spec/

run:
	@docker-compose up

login:
	@docker login -u "${DOCKER_USERNAME}" -p "${DOCKER_PASSWORD}"

push:
	@docker push krates/ipam-plugin:${VERSION}