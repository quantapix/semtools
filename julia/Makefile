TAG = last
REG = qbrn.reg
IMG = dns-client

all: 
	docker build --pull --build-arg VERSION=1.5.3 -t $(REG)/jul-old:$(TAG) - < tar.Dockerfile
	docker push $(REG)/jul-old:$(TAG)
	docker build --pull --build-arg VERSION=1.6.0-beta1 -t $(REG)/jul-new:$(TAG) - < tar.Dockerfile
	docker push $(REG)/jul-new:$(TAG)
	# docker build --pull -t $(REG)/jul-dev:$(TAG) - < dev.Dockerfile
	# docker push $(REG)/jul-dev:$(TAG)

clean:
