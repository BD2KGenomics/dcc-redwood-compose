NAME=ucsc-storage-client

docker: archive
	docker build -t ucsc-storage-client .

archive: build
	cd artifacts && tar czf ${NAME}-dist.tar.gz ${NAME}

build: artifacts
	- mkdir -p artifacts/${NAME}/conf
	cp ../ssl/artifacts/cacerts artifacts/${NAME}/conf/cacerts
	cp -r bin artifacts/${NAME}/bin
	cp -r lib artifacts/${NAME}/lib

artifacts:
	- mkdir artifacts

clean:
	- rm -r artifacts
