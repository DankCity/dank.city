APP := dankcity/dank.city

docker-login:
	echo $(DOCKER_PASS) | docker login -u $(DOCKER_USER) --password-stdin

build:
	docker build -t $(APP):local .

tag-latest:
	docker tag $(APP):local $(APP):latest

push-latest:
	docker push $(APP):latest
