Let's build the native image. In the lab environment we will make use of the ``--quick-build-native`` flag. This flag allows for a slightly quicker compile time at the expense of a slightly larger binary:

```console
[~/demo] $ ./gradlew nativeCompile --quick-build-native
...
Finished generating 'demo' in 1m 34s.
    [native-image-plugin] Native Image written to: demo/build/native/nativeCompile

BUILD SUCCESSFUL in 2m 4s
```

You'll notice that the native build takes _significantly more time_ than JVM build we did previously.

During the execution of this command, Spring Ahead-Of-Time (AOT) engine analyzes the application and infers the native configuration needed (for reflection, proxies, or resources, for example), and generates a programmatic application context, optimized for native image (less reflection needed, Spring Boot conditions precomputed, etc).
Then, the GraalVM native image compiler performs a static analysis of the application, compiles the JVM bytecode to a native executable, and includes the dependencies and JVM subsets used.

**_Note_**: The lab environment has been configured with limited resources so you may need to be patient while the native compilation completes. You can follow the completion status in the console.

```
...
Build resources:
 - 6.49GB of memory (75.6% of system memory, in container)
 - 4 thread(s) (100.0% of 4 available processor(s), determined at start)
SLF4J(W): No SLF4J providers were found.
SLF4J(W): Defaulting to no-operation (NOP) logger implementation
SLF4J(W): See https://www.slf4j.org/codes.html#noProviders for further details.
[2/8] Performing analysis...  [******]                                                                 (288.0s @ 1.91GB)
   19,162 types,  28,835 fields, and  88,980 methods found reachable
    7,183 types,   3,727 fields, and  15,184 methods registered for reflection
      136 types,     229 fields, and     122 methods registered for JNI access
        0 downcalls and 0 upcalls registered for foreign access
        4 native libraries: dl, pthread, rt, z
[3/8] Building universe...                                                                              (38.2s @ 2.22GB)
[4/8] Parsing methods...      [*****]                                                                   (26.1s @ 2.40GB)
[5/8] Inlining methods...     [***]                                                                     (20.0s @ 2.66GB)
[6/8] Compiling methods...    [*****************]                                                      (303.1s @ 2.22GB)
[7/8] Laying out methods...   [*****]                                                                   (29.1s @ 2.97GB)
[8/8] Creating image...       [*****]                                                                   (25.4s @ 3.32GB)
...
Finished generating 'demo' in 12m 49s.
[native-image-plugin] Native Image written to: /home/eduk8s/demo/build/native/nativeCompile

BUILD SUCCESSFUL in 13m 26s
...
```

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
