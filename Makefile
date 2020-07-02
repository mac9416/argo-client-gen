GIT_ORG    := argoproj
GIT_BRANCH := $(shell git rev-parse --abbrev-ref=loose HEAD | sed 's/heads\///')
VERSION    := HEAD
LANGUAGE   := java

# VERSION as GIT_BRANCH must be different
ifneq ($(VERSION),$(GIT_BRANCH))

ifeq ($(LANGUAGE),scala)
	GENPLUGIN := scala-akka
else
	GENPLUGIN := $(LANGUAGE)
endif

SWAGGER    := https://raw.githubusercontent.com/$(GIT_ORG)/argo/$(VERSION)/api/openapi-spec/swagger.json

clients: java

.PHONY: clean
clean:
	rm -Rf dist

dist/swagger.json:
	curl -L -o dist/swagger.json $(SWAGGER)

dist/openapi-generator-cli.jar:
	mkdir -p dist
	curl -L -o dist/openapi-generator-cli.jar https://repo1.maven.org/maven2/org/openapitools/openapi-generator-cli/4.2.3/openapi-generator-cli-4.2.3.jar

# java client

ifeq ($(VERSION),HEAD)
JAVA_CLIENT_VERSION := 1-SNAPSHOT
else
JAVA_CLIENT_VERSION := $(VERSION)
endif
JAVA_CLIENT_JAR     := $(HOME)/.m2/repository/io/argoproj/workflow/argo-client-java/$(JAVA_CLIENT_VERSION)/argo-client-java-$(JAVA_CLIENT_VERSION).jar

dist/java.swagger.json: dist/swagger.json
	cat dist/swagger.json | sed 's/io.argoproj.workflow.v1alpha1.//' | sed 's/io.k8s.api.core.v1.//'> dist/java.swagger.json

.PHONY: java
java: $(JAVA_CLIENT_JAR)

$(JAVA_CLIENT_JAR): dist/openapi-generator-cli.jar dist/java.swagger.json
	git submodule update --remote --init $(LANGUAGE)
	cd $(LANGUAGE) && git checkout -b $(GIT_BRANCH) || git checkout $(GIT_BRANCH)
	rm -Rf $(LANGUAGE)/*
	java \
		-jar dist/openapi-generator-cli.jar \
		generate \
		-i dist/java.swagger.json \
		-g $(GENPLUGIN) \
		-o $(LANGUAGE) \
		--group-id io.argoproj.workflow \
		--artifact-id argo-client-$(LANGUAGE) \
		--artifact-version $(JAVA_CLIENT_VERSION) \
		--api-package io.argoproj.workflow.apis \
		--invoker-package io.argoproj.workflow \
		--model-package io.argoproj.workflow.models \
#		-p hideGenerationTimestamp=true \
#		-p dateLibrary=joda \
#		--import-mappings Any=ArgoAny
#		--import-mappings Time=org.joda.time.DateTime \
#		--import-mappings V1Affinity=io.kubernetes.client.models.V1Affinity \
#		--import-mappings V1ConfigMapKeySelector=io.kubernetes.client.models.V1ConfigMapKeySelector \
#		--import-mappings V1Container=io.kubernetes.client.models.V1Container \
#		--import-mappings V1ContainerPort=io.kubernetes.client.models.V1ContainerPort \
#		--import-mappings V1EnvFromSource=io.kubernetes.client.models.V1EnvFromSource \
#		--import-mappings V1EnvVar=io.kubernetes.client.models.V1EnvVar \
#		--import-mappings V1HostAlias=io.kubernetes.client.models.V1HostAlias \
#		--import-mappings V1Lifecycle=io.kubernetes.client.models.V1Lifecycle \
#		--import-mappings V1ListMeta=io.kubernetes.client.models.V1ListMeta \
#		--import-mappings V1LocalObjectReference=io.kubernetes.client.models.V1LocalObjectReference \
#		--import-mappings V1ObjectMeta=io.kubernetes.client.models.V1ObjectMeta \
#		--import-mappings V1ObjectReference=io.kubernetes.client.models.V1ObjectReference \
#		--import-mappings V1PersistentVolumeClaim=io.kubernetes.client.models.V1PersistentVolumeClaim \
#		--import-mappings V1PodDisruptionBudgetSpec=io.kubernetes.client.models.V1beta1PodDisruptionBudgetSpec \
#		--import-mappings V1PodDNSConfig=io.kubernetes.client.models.V1PodDNSConfig \
#		--import-mappings V1PodSecurityContext=io.kubernetes.client.models.V1PodSecurityContext \
#		--import-mappings V1Probe=io.kubernetes.client.models.V1Probe \
#		--import-mappings V1ResourceRequirements=io.kubernetes.client.models.V1ResourceRequirements \
#		--import-mappings V1SecretKeySelector=io.kubernetes.client.models.V1SecretKeySelector \
#		--import-mappings V1SecurityContext=io.kubernetes.client.models.V1SecurityContext \
#		--import-mappings V1Toleration=io.kubernetes.client.models.V1Toleration \
#		--import-mappings V1Volume=io.kubernetes.client.models.V1Volume \
#		--import-mappings V1VolumeDevice=io.kubernetes.client.models.V1VolumeDevice \
#		--import-mappings V1VolumeMount=io.kubernetes.client.models.V1VolumeMount \
#		--type-mappings Time=org.joda.time.DateTime \
#		--type-mappings Affinity=V1Affinity \
#		--type-mappings ConfigMapKeySelector=V1ConfigMapKeySelector \
#		--type-mappings Container=V1Container \
#		--type-mappings ContainerPort=V1ContainerPort \
#		--type-mappings EnvFromSource=V1EnvFromSource \
#		--type-mappings EnvVar=V1EnvVar \
#		--type-mappings HostAlias=V1HostAlias \
#		--type-mappings Lifecycle=V1Lifecycle \
#		--type-mappings ListMeta=V1ListMeta \
#		--type-mappings LocalObjectReference=V1LocalObjectReference \
#		--type-mappings ObjectMeta=V1ObjectMeta \
#		--type-mappings ObjectReference=V1ObjectReference \
#		--type-mappings PersistentVolumeClaim=V1PersistentVolumeClaim \
#		--type-mappings PodDisruptionBudgetSpec=V1beta1PodDisruptionBudgetSpec \
#		--type-mappings PodDNSConfig=V1PodDNSConfig \
#		--type-mappings PodSecurityContext=V1PodSecurityContext \
#		--type-mappings Probe=V1Probe \
#		--type-mappings ResourceRequirements=V1ResourceRequirements \
#		--type-mappings SecretKeySelector=V1SecretKeySelector \
#		--type-mappings SecurityContext=V1SecurityContext \
#		--type-mappings Toleration=V1Toleration \
#		--type-mappings Volume=V1Volume \
#		--type-mappings VolumeDevice=V1VolumeDevice \
#		--type-mappings VolumeMount=V1VolumeMount \
#		--generate-alias-as-model \
	# add the io.kubernetes:java-client to the deps
	cd $(LANGUAGE) && sed 's/<dependencies>/<dependencies><dependency><groupId>io.kubernetes<\/groupId><artifactId>client-java<\/artifactId><version>5.0.0<\/version><\/dependency>/g' pom.xml > tmp && mv tmp pom.xml


	cd $(LANGUAGE) && mvn package -Dmaven.javadoc.skip
	cd $(LANGUAGE) && git add .
	cd $(LANGUAGE) && git diff --exit-code || git commit -m 'Updated to $(JAVA_CLIENT_VERSION)'
ifneq ($(VERSION),HEAD)
	git tag -f $(VERSION)
endif
	cd $(LANGUAGE) && mvn install -DskipTests -Dmaven.javadoc.skip
	git add $(LANGUAGE)

.PHONY: test-java
test-java: java-test/target/ok

java-test/target/ok: $(JAVA_CLIENT_JAR)
	cd java-test && mvn versions:set -DnewVersion=$(JAVA_CLIENT_VERSION) verify
	touch java-test/target/ok

.PHONY: publish-java
publish-java: test-java
	# https://help.github.com/en/packages/using-github-packages-with-your-projects-ecosystem/configuring-apache-maven-for-use-with-github-packages
	cd java && mvn deploy -DskipTests -Dmaven.javadoc.skip -DaltDeploymentRepository=github::default::https://maven.pkg.github.com/argoproj-labs/argo-client-java
	cd java && git push origin $(GIT_BRANCH)
ifneq ($(VERSION),HEAD)
	cd java && git push origin $(VERSION)
endif

endif
