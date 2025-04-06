Let's build the native image:

```console
[~/demo] $ ./gradlew nativeCompile
...
Finished generating 'demo' in 1m 34s.
    [native-image-plugin] Native Image written to: demo/build/native/nativeCompile

BUILD SUCCESSFUL in 2m 4s
```

You'll notice that the native build takes _significantly more time_ than JVM build we did previously.

During the execution of this command, Spring Ahead-Of-Time (AOT) engine analyzes the application and infers the native configuration needed (for reflection, proxies, or resources, for example), and generates a programmatic application context, optimized for native image (less reflection needed, Spring Boot conditions precomputed, etc).
Then, the GraalVM native image compiler performs a static analysis of the application, compiles the JVM bytecode to a native executable, and includes the dependencies and JVM subsets used.

## Run the application with the native executable

In the upper terminal, execute this command:

```console
[~/demo] $ build/native/nativeCompile/demo
```

Check the application startup time again. Notice that this time, the native application started _significantly faster_:

```
Started DemoApplication in 0.054 seconds (process running for 0.096)
```

Once again, verify that the application is behaving correctly. In the lower terminal, request the web page and check that your application still says "hello":

```console
[~/demo] $ curl http://localhost:8080/
hello
```

In the upper terminal, stop the application by pressing _CTRL + C_.

## Celebrate!

Congratulations! You just built, ran, and tested a Spring Boot application as a native image.

You can learn more by reading the [Building a Native Image using Native Build Tools](https://docs.spring.io/spring-boot/docs/current/reference/html/native-image.html#native-image.developing-your-first-application.native-build-tools) section of Spring Boot reference documentation.
