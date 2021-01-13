REG = qbrn.reg
TAG = std

all: 
	docker build --pull --build-arg VERSION=1.5.3 -t $(REG)/jul-old:$(TAG) - < Dockerfile
	docker push $(REG)/jul-old:$(TAG)
	docker build --pull --build-arg VERSION=1.6.0-beta1 -t $(REG)/jul-new:$(TAG) - < Dockerfile
	docker push $(REG)/jul-new:$(TAG)
	# docker build --pull --build-arg VERSION=master -t $(REG)/jul-dev:$(TAG) - < Dockerfile.dev
	# docker push $(REG)/jul-dev:$(TAG)

clean:
