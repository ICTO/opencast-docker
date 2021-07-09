# Copyright 2016 The WWU eLectures Team All rights reserved.
#
# Licensed under the Educational Community License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License. You may obtain a copy of the License at
#
#     http://opensource.org/licenses/ECL-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

DOCKER_IMAGE_BASE=quay.io/mm-dict
DOCKER_TAG=$(shell cat VERSION)

REPO=$(shell sed -n -e 's/^ARG repo="\(.*\)"/\1/p' Dockerfiles/allinone/Dockerfile)
BRANCH=$(shell sed -n -e 's/^ARG branch="\(.*\)"/\1/p' Dockerfiles/allinone/Dockerfile)

CUSTOM_DOCKER_BUILD_ARGS=

export DOCKER_BUILDKIT=1

all: lint build test

build: build-allinone build-admin build-ingest build-presentation build-worker build-worker-nvidia
build-allinone:
	docker build \
		--pull \
		--build-arg repo=$(REPO) \
		--build-arg branch=$(BRANCH) \
		-t $(DOCKER_IMAGE_BASE)/opencast-allinone \
		-t $(DOCKER_IMAGE_BASE)/opencast-allinone:$(DOCKER_TAG) \
		$(CUSTOM_DOCKER_BUILD_ARGS) \
		-f Dockerfiles/allinone/Dockerfile \
		.
build-admin:
	docker build \
		--pull \
		--build-arg repo=$(REPO) \
		--build-arg branch=$(BRANCH) \
		-t $(DOCKER_IMAGE_BASE)/opencast-admin \
		-t $(DOCKER_IMAGE_BASE)/opencast-admin:$(DOCKER_TAG) \
		$(CUSTOM_DOCKER_BUILD_ARGS) \
		-f Dockerfiles/admin/Dockerfile \
		.
build-ingest:
	docker build \
		--pull \
		--build-arg repo=$(REPO) \
		--build-arg branch=$(BRANCH) \
		-t $(DOCKER_IMAGE_BASE)/opencast-ingest \
		-t $(DOCKER_IMAGE_BASE)/opencast-ingest:$(DOCKER_TAG) \
		$(CUSTOM_DOCKER_BUILD_ARGS) \
		-f Dockerfiles/ingest/Dockerfile \
		.
build-presentation:
	docker build \
		--pull \
		--build-arg repo=$(REPO) \
		--build-arg branch=$(BRANCH) \
		-t $(DOCKER_IMAGE_BASE)/opencast-presentation \
		-t $(DOCKER_IMAGE_BASE)/opencast-presentation:$(DOCKER_TAG) \
		$(CUSTOM_DOCKER_BUILD_ARGS) \
		-f Dockerfiles/presentation/Dockerfile \
		.
build-worker:
	docker build \
		--pull \
		--build-arg repo=$(REPO) \
		--build-arg branch=$(BRANCH) \
		-t $(DOCKER_IMAGE_BASE)/opencast-worker \
		-t $(DOCKER_IMAGE_BASE)/opencast-worker:$(DOCKER_TAG) \
		$(CUSTOM_DOCKER_BUILD_ARGS) \
		-f Dockerfiles/worker/Dockerfile \
		.
build-worker-nvidia:
	docker build \
		--pull \
		--build-arg repo=$(REPO) \
		--build-arg branch=$(BRANCH) \
		-t $(DOCKER_IMAGE_BASE)/opencast-worker-nvidia \
		-t $(DOCKER_IMAGE_BASE)/opencast-worker-nvidia:$(DOCKER_TAG) \
		$(CUSTOM_DOCKER_BUILD_ARGS) \
		-f Dockerfiles/worker-nvenc/Dockerfile \
		.
.PHONY: build build-allinone build-admin build-ingest build-presentation build-worker build-worker-nvidia

test:
	bats test
.PHONY: test

clean:
	-docker rmi $(DOCKER_IMAGE_BASE)/opencast-allinone
	-docker rmi $(DOCKER_IMAGE_BASE)/opencast-admin
	-docker rmi $(DOCKER_IMAGE_BASE)/opencast-ingest
	-docker rmi $(DOCKER_IMAGE_BASE)/opencast-presentation
	-docker rmi $(DOCKER_IMAGE_BASE)/opencast-worker
	-docker rmi $(DOCKER_IMAGE_BASE)/opencast-worker-nvidia
	-docker rmi $(DOCKER_IMAGE_BASE)/opencast-allinone:$(DOCKER_TAG)
	-docker rmi $(DOCKER_IMAGE_BASE)/opencast-admin:$(DOCKER_TAG)
	-docker rmi $(DOCKER_IMAGE_BASE)/opencast-ingest:$(DOCKER_TAG)
	-docker rmi $(DOCKER_IMAGE_BASE)/opencast-presentation:$(DOCKER_TAG)
	-docker rmi $(DOCKER_IMAGE_BASE)/opencast-worker:$(DOCKER_TAG)
	-docker rmi $(DOCKER_IMAGE_BASE)/opencast-worker-nvidia:$(DOCKER_TAG)
.PHONY: clean

lint:
	cd rootfs && shellcheck --external-sources *.sh ./opencast/docker/scripts/*.sh
	cd Dockerfiles/build/rootfs/usr/local/bin && shellcheck --external-sources *
.PHONY: lint
