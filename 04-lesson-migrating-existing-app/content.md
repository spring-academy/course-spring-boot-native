Unlike the simple application you saw in the first lesson, most real-world Java applications require additional code to run as a native image. Some logical questions to ask are, "Why is that? What is it about a native image that differs from a Java program running in the JVM?" Great questions!

The answer, in brief, is that the native image compiler analyzes your application, tries to identify all code used, and removes any code which is not actually used by the application. This is sometimes referred to as “dead code detection and removal”. It doesn’t remove application code, but rather any unused methods from library dependencies. Removing unused code has many benefits, such as a smaller memory footprint when running the application, and a faster compilation time than would otherwise be possible.

## Native Runtime Hints

Java is a statically typed language, but some operations - like reflection, resources, proxies, and serialization - are dynamic (performed at runtime). GraalVM refers to the set of data that is required to perform these dynamic operations as **Reachability Metadata**. Like application code itself, GraalVM attempts to only include the necessary reachability metadata, in order to produce a small executable in a reasonable amount of time.

It’s not possible - or, it's very difficult - for the compiler to know which reachability metadata is required at runtime, and which is not. Therefore, the application programmer needs to provide some information in the application code so that all required elements are included in the compiled native image. The Spring API used to provide this information is called the **Runtime Hints API.** Why is the word “hints” used? Because the programmer is telling (hinting) to the compiler that additional information needs to be compiled into the runtime image.

Providing hints requires additional programming work, so the Spring Framework and GraalVM automatically provide some reachability metadata, so that you don’t have to! Which metadata are automatically provided? There are two main types:

1. Metadata exposed on Spring Beans API and requiring reflection or proxies in the application code is automatically included in the native image. For example, if a class is included in a Repository bean as a return value, then the reflection metadata for that class is included.
2. In addition to including entries based on your beans API, the Native Build Tools plugin is automatically configured to retrieve reachability metadata for supported Open Source libraries from [https://github.com/oracle/graalvm-reachability-metadata](https://github.com/oracle/graalvm-reachability-metadata). You can get a more approachable list of the supported libraries in [https://www.graalvm.org/native-image/libraries-and-frameworks/](https://www.graalvm.org/native-image/libraries-and-frameworks/). This is the mechanism by which anyone who develops a Java library can make it easy to use in applications deployed as a native image.

By inspecting your own application’s Beans API and combining that with the open source reachability metadata, the GraalVM generates much of the reachability metadata that the native image needs to run correctly. Thanks to that information, _most_ of your application can compile to a native executable without extra work on your part.

On the other hand, developers _do_ need to provide hints for any items (like classes, or resources) on which runtime operations are performed, including reflection, dynamic proxying, or serialization, and which aren't automatically detected by the native image build tools, or Spring Ahead-Of-Time (AOT) transformations.

## Ahead-of-Time Optimizations and Reachability Metadata

At this point, we’ll provide a little more detail on which parts of the GraalVM system come into play during the process of building and deploying a native image application.

First, recall from a previous lesson the process by which a native image application is compiled, deployed, and executed. Here’s the diagram that you’ve already seen from that lesson:

![Deploying a Spring Boot application as a native image](https://raw.githubusercontent.com/spring-academy/spring-academy-assets/main/courses/course-spring-boot-native/deployment-native.svg)

- The application source code contains hints which allow the **Spring** **Ahead-of-Time Optimizations** (AOT) phase to generate reachability metadata. These hints aren't separate from the application, they're actually an integral part of the application source code.

- During the **Compile (native image)** phase, this reachability metadata is used to add the necessary data to the compiled, standalone native image.

It’s worthwhile to understand the difference between the generation of the reachability metadata (during `javac` compilation), the actual inclusion of the required data in the native image (done by the native image build tools), and the benefit this separation provides:

- The metadata doesn’t affect a regular JVM deployment, but can be critical for a native image compilation and deployment.
- Incorporating the native hints in the application source code ensures that the application can be deployed both as a traditional JVM-deployed Java application, or as a native image application.

## The Cash Card Application: Preview

In the upcoming Lab, you’ll put the concepts we covered in this lesson into practice by migrating a real-world application to run as a native image. The application is called "Cash Card". It outputs a list of account balances for cash value cards, similar to debit cards, that people might use for purchases. Here’s what the application output looks like:

```
Your Account Balances

id: 99, amount: 123.45, owner:sarah1
id: 102, amount: 200.0, owner:kumar2
```

In order to produce the above output, the Cash Card application will require you to provide the necessary hints to include two types of reachability metadata:

The header (the “Your Account Balances” text) is stored as a **Java Resource** (a file on disk). You’ll need to hint to the compiler that the resource is required at runtime. Why doesn’t the compiler automatically include the resource? Because that would be potentially wasteful. Not all resources are required at runtime.

The template rendering of the list of accounts uses the **Java Reflection API** to retrieve the values of the id and account fields from the CashCard objects. You’ll see in the Lab that these CashCard objects aren't automatically included in the reachability metadata, because they're not referenced in any Bean class.

Now that you know the basics, let’s do some actual coding in the Lab!
