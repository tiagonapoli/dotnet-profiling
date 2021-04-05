build-debian:
	docker build -t tiagonapoli/dotnet-profiling-webapi-example:debian -f ./Dockerfile.debian .

run-debian: build-debian
	docker run -it --rm --mount type=bind,source=/tmp,target=/tmp -p 5000:80 --name dotnet-profiling-webapi-example-debian tiagonapoli/dotnet-profiling-webapi-example:debian 
	# docker run -it --rm -p 5000:80 --name dotnet-profiling-webapi-example-debian tiagonapoli/dotnet-profiling-webapi-example:debian

exec-debian:
	docker exec -it dotnet-profiling-webapi-example-debian /bin/bash

publish-debian: build-debian
	docker push tiagonapoli/dotnet-profiling-webapi-example:debian

build-alpine:
	docker build -t dotnet-profiling-webapi-example:alpine -f ./Dockerfile.alpine .

run-alpine: build-alpine
	docker run -it --rm --mount type=bind,source=/tmp,target=/tmp -p 5000:80 --name dotnet-profiling-webapi-example-alpine dotnet-profiling-webapi-example:alpine 

exec-alpine:
	docker exec -it dotnet-profiling-webapi-example-alpine /bin/sh