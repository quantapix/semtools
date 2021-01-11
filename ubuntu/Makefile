TAG = last
REG = qbrn.reg
IMG = dns-client

all: 
	docker build --pull -t $(REG)/ubu-slim:$(TAG) - < ubu-slim.Dockerfile
	docker push $(REG)/ubu-slim:$(TAG)
	docker build --pull -t $(REG)/ubu-base:$(TAG) - < ubu-base.Dockerfile
	docker push $(REG)/ubu-base:$(TAG)

clean:
