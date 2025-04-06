Now that you've successfully run the native image in your development environment, let's consider additional concerns that apply when deploying the application to the Cloud. Note that we won't _actually_ deploy the application, but we _will_ build it in a different way that is more suitable for Cloud deployment.

### Cloud Native Buildpacks - What and Why?

Spring Boot provides first class support for building container images thanks to [Cloud Native Buildpacks](https://docs.spring.io/spring-boot/docs/current/reference/html/container-images.html#container-images.buildpacks).

When you build the application using a Cloud Native Buildpack, you produce not only the native executable application, but also a wrapper (a Docker container, or more precisely an OCI container), which is a completely self-contained image, suitable for running in pretty much all modern Cloud infrastructure, including but not limited to AWS, Azure, GCP, or Tanzu.

### Requirements for building with a Cloud Native Buildpack

Building your application using a Buildpack does _not_ require the GraalVM native image compiler to be installed locally, but it _does_ require Docker to be installed and usable as the current (non-root) user. Not to worry! This interactive Lab environment already has Docker installed and ready for use.

**_Note_**: Regarding CPU architecture support: Cloud Native Buildpack support allows you to create **Linux x86/AMD** container images independently of the host Operating System, but **ARM** CPU architecture (e.g. the Mac M1 CPU) is not yet supported.

## Build the application with Cloud Native Buildpack

You can now build the application as an OCI container using the native Buildpack:

```console
[~/demo] $ ./gradlew bootBuildImage
```

This will take some time to complete, as this command triggers the native compilation of the application, as well the creation of an OCI image which contains a (virtualized) operating system.

You'll know the build is complete when you see output similar to the following:

```console
...
   [creator]     [7/7] Creating image...                                         (32.5s @ 2.31GB)
...
Successfully built image 'docker.io/library/demo:0.0.1-SNAPSHOT'
BUILD SUCCESSFUL in 2m 23s
```

Once the build is complete, running the resulting OCI image is quite easy and the startup time is very fast, as you can see by the output:

```console
[~/demo] $ docker run --rm -p 8080:8080 docker.io/library/demo:0.0.1-SNAPSHOT

Started DemoApplication in 0.045 seconds (process running for 0.048)
```

> What does the above command do?
>
> - `docker run` directs the Docker application to run the image that you just built.
> - `--rm` means "When the container exits, clean-up after yourself please Docker, thank you."
> - `-p 8080:8080` allows you to make HTTP requests to the running application from outside the Docker container (but still on your local machine).
> - `docker.io/library/demo:0.0.1-SNAPSHOT` is the name of the image that was registered in your local Docker registry from the previous step.

To be sure that nothing has gone awry, go ahead and request the web page in the same way that you've already verified in earlier builds:

```console
[~/demo] $ curl http://localhost:8080/
hello
```

Congratulations! You have created an OCI container image that contains your application and the entire supporting Operating System. The image contains only native code: there is no JVM involved, which means that much less hardware resources, in particular RAM, are required when running a native image.

You can learn more by reading the [Building a Native Image Using Buildpacks](https://docs.spring.io/spring-boot/docs/current/reference/html/native-image.html#native-image.developing-your-first-application.buildpacks) section of Spring Boot reference documentation.
