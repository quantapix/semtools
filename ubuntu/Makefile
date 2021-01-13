REG = qbrn.reg
TAG = std

all: 
	docker build --pull -t $(REG)/ubu-run:$(TAG) - < Dockerfile
	docker push $(REG)/ubu-run:$(TAG)
	docker build --pull -t $(REG)/ubu-dev:$(TAG) - < Dockerfile.dev
	docker push $(REG)/ubu-dev:$(TAG)

clean:
