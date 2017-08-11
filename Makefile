
VERSION=0.07
SPARQL_VERSION=a5cc69b92abdee0f5fb2a1eed8a6895a5e23b3d6
CASSANDRARDF_VERSION=95a2ccb16771eaf3967e7778ecd124a8bb953572

FEDORA_FILES =  /usr/local/src/cassandra-rdf/librdf_storage_cassandra.so
FEDORA_FILES += /usr/local/src/sparql/sparql

SUDO=

all: product fedora container

product:
	mkdir product

fedora: product
	${SUDO} docker build ${BUILD_ARGS} -t sparql-fedora-dev \
		-f Dockerfile.fedora.dev .
	${SUDO} docker build ${BUILD_ARGS} -t sparql-fedora-build \
		--build-arg SPARQL_VERSION=${SPARQL_VERSION} \
		--build-arg CASSANDRARDF_VERSION=${CASSANDRARDF_VERSION} \
		-f Dockerfile.fedora.build .
	id=$$(${SUDO} docker run -d sparql-fedora-build sleep 180); \
	for file in ${FEDORA_FILES}; do \
		bn=$$(basename $$file); \
		${SUDO} docker cp $${id}:$${file} product/$${bn}; \
	done; \
	${SUDO} docker rm -f $${id}

container:
	${SUDO} docker build ${BUILD_ARGS} -t sparql \
		--build-arg VERSION=${VERSION} \
		-f Dockerfile.deploy .
	${SUDO} docker tag sparql docker.io/cybermaggedon/sparql-cassandra:${VERSION}
	${SUDO} docker tag sparql docker.io/cybermaggedon/sparql-cassandra:latest

push:
	${SUDO} docker push docker.io/cybermaggedon/sparql-cassandra:${VERSION}
	${SUDO} docker push docker.io/cybermaggedon/sparql-cassandra:latest
