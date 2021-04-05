build-linux-kernel-src-image:
	docker build -t tiagonapoli/linux-kernel-src -f ./images/linux-kernel-src.dockerfile ./images

build-profiler-image: build-linux-kernel-src-image
	./scripts/build-profiling-image.sh $(KERNEL_VERSION)

publish-profiler-image: build-profiler-image
	./scripts/publish-profiling-image.sh $(KERNEL_VERSION)