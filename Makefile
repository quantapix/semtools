REG = qbrn.reg
TAG = std

all: 
	docker build --pull -t $(REG)/ubu-run:$(TAG) - < Dockerfile
	docker push $(REG)/ubu-run:$(TAG)
	docker build --pull -t $(REG)/ubu-dev:$(TAG) - < Dockerfile.dev
	docker push $(REG)/ubu-dev:$(TAG)

clean:


REG = qbrn.reg

all: qold.std qnew.std qdev.src

qold.std: ../ubuntu/qrun.flag
	docker build --pull --build-arg VERSION=1.5.3 -t $(REG)/jul-old:std - < Dockerfile
	docker push $(REG)/jul-old:std
	touch qold.std

qnew.std: 
	docker build --pull --build-arg VERSION=1.6.0-beta1 -t $(REG)/jul-new:std - < Dockerfile
	docker push $(REG)/jul-new:std
	touch qnew.std

upstream: 
	git clone https://github.com/JuliaLang/julia.git upstream
	(cd upstream && git branch qold v1.5.3)
	(cd upstream && git branch qnew v1.6.0-beta1)
	(cd upstream && git branch --track qdev master)

qdev.src: upstream 
	(cd upstream && git checkout qdev)
	docker build --pull -t $(REG)/jul-dev:src -f Dockerfile.dev .
	docker push $(REG)/jul-dev:src
	touch qdev.src

clean:
