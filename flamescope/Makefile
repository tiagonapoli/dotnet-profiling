flamescope-build-image:
	docker build -t flamescope -f ./images/flamescope.dockerfile ./images

flamescope-run: flamescope-build-image
	./images/run-flamescope.sh

