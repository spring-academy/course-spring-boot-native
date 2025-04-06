Let's talk about Spring Boot native images. What are they? What are the tradeoffs between running Spring Boot applications on the standard JVM, versus as a native image?

## Why?

In a nutshell, Spring support for compiling native applications allows cheaper and more sustainable deployment.
Specifically, compiling your application to native has several advantages:

- **Instant startup**: With typical startup time measured in milliseconds instead of seconds for the JVM.
- **No warmup**: Peak performance is available immediately.
- **Low resource usage**: You can run your workload on cheap instances with small CPU and low memory.
- **Reduced surface attack**: One drawback of native images is that you have to explicitly declare at build time which reflection and serialization operations will be performed at runtime. However, this becomes an advantage in terms of security, for two reasons:
  - The application contains only the necessary reachability metadata (which is also mentioned in the **tradeoffs** section, below), reducing the data available to attackers.
  - The application is in a "closed world", with no capabilities to load new code.
- **Compact packaging**: Smaller containers are easier to deploy and store.

## Different Tradeoffs

The JVM and native images make different tradeoffs, so it is important to understand that the advantages on native images come at the cost of some drawbacks:

- Native image **build time** is significantly slower and more resource consuming than a typical JVM build, and is performed in addition to the JVM build, not instead-of.
- Native images require additional **reachability metadata** that introduce additional compatibility requirements. Spring does its best to infer most of it, but for real-world applications, you'll likely have to provide additional hints.
- There's no dynamic optimization done at runtime, as is done with the JVM JIT compiler. Additionally, the level of performance of native images depends on the distribution of GraalVM used. The bottom line is: With enough resources, the JVM usually provides somewhat higher **throughput** than native images.

## How?

Spring Boot 3 introduces official support for compiling applications to native executable with [GraalVM](https://www.graalvm.org/).

Before talking about the native compilation, let’s start with a quick overview of a typical deployment of a Spring Boot JVM application.

The Java source code is compiled to Java bytecode, and can be packaged easily by Buildpacks as a container image that contains 3 main layers: the operating system, the JVM, and the application itself.

![Deploying a Spring Boot application to run on the JVM](https://raw.githubusercontent.com/spring-academy/spring-academy-assets/main/courses/course-spring-boot-native/deployment-jvm.svg)

Spring Boot 3 introduces additional capabilities, building a smaller, more efficient container image, thanks to two additional steps.

![Deploying a Spring Boot application as a native image](https://raw.githubusercontent.com/spring-academy/spring-academy-assets/main/courses/course-spring-boot-native/deployment-native.svg)

1. Spring Framework 6 now allows you to perform Ahead-Of-Time (AOT) optimizations to precompute at build-time which beans need to be injected, reducing the amount of reflection needed at runtime, making your Spring Boot application easier to analyze by the GraalVM native image compiler.

2. After the generation of the Java bytecode, the GraalVM native image compiler performs a static analysis of the application, generates an optimized, standalone native executable that can be statically linked and run on top of a minimal operating system, and deploys as a small and efficient container image, without the need for a JVM installation.

   ![Your Application Running Natively in the Cloud, without a JVM](https://raw.githubusercontent.com/spring-academy/spring-academy-assets/main/courses/course-spring-boot-native/scale-down-scale-up.svg)

Such containers can process incoming requests a few milliseconds after startup, and consume less memory than their JVM counterparts. They're a good fit for deploying Spring Boot applications on premises, or in the Cloud with Kubernetes platforms, especially when they provide scale to zero capabilities, like KNative.
