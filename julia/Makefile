REG = qbrn.reg
TAG = std

all: old new dev

old: 
	docker build --pull --build-arg VERSION=1.5.3 -t $(REG)/jul-old:std - < Dockerfile
	docker push $(REG)/jul-old:std

new: 
	docker build --pull --build-arg VERSION=1.6.0-beta1 -t $(REG)/jul-new:std - < Dockerfile
	docker push $(REG)/jul-new:std

# git clone https://github.com/JuliaLang/julia.git upstream
# (cd upstream && git checkout -B qold v1.5.3)
# (cd upstream && git checkout -B qnew v1.6.0-beta1)
# (cd upstream && git checkout -B qdev --track master)

dev:
	(cd upstream && git checkout qdev)
	docker build --pull -t $(REG)/jul-dev:src -f Dockerfile.dev .
	docker push $(REG)/jul-dev:src

clean:
