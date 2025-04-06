We’re ready to begin the process of compiling the Cash Card application to a native image and verify that it works as intended. Let's go!

## Configure Native Build Tools plugin

The first thing to do is add the native image plugin to the Gradle build file. Add the following line to the `plugins {}` block at the top of the `build.gradle` file:

```json
plugins {
   …
   id 'org.graalvm.buildtools.native' version '0.9.23'
}
```

## Compile and run as a native image

First, let’s try to compile and run the application in native image mode to get an idea of how much work we might need to do to complete the migration to native image.

```console
[~/exercises] $ ./gradlew nativeCompile
```

Note that this will take a couple minutes as the GraalVM analyzes and processes the application. You’ll see several steps as the application compiles:

```console
[1/8] Initializing…
[2/8] Performing analysis...  [******]
[3/8] Building universe...
[4/8] Parsing methods...      [**]
[5/8] Inlining methods...     [****]
[6/8] Compiling methods...    [****]
[7/8] Layouting methods...    [***]
[8/8] Creating image...       [***]
Finished generating 'cashcard' in 1m 17s.
[native-image-plugin] Native Image written to: /exercises/build/native/nativeCompile
```

Great, it compiles! Let’s see if it runs:

```console
[~/exercises] $ build/native/nativeCompile/cashcard
…
2023-08-01T23:38:23.673-06:00  INFO 89892 --- [nio-8080-exec-1] o.s.web.servlet.DispatcherServlet        : Completed initialization in 1 ms
```

So far so good! In your browser, manually test the `/banner` endpoint by navigating to <https://{{ session_namespace }}-cashcard.{{ ingress_domain }}/banner>. You’ll see the following output in the browser:

```console
There was an unexpected error (type=Internal Server Error, status=500).
```

**Surprise!** Instead of receiving the expected message, we get a runtime error! Looking at the Terminal output, we see the cause of the error:

```console
java.io.FileNotFoundException: class path resource [cashcard-banner.txt] cannot be opened because it does not exist
```

That’s disappointing. Let's put that in our list things to fix, and carry on investigating the other endpoint: `/list `.

Navigate to <https://{{ session_namespace }}-cashcard.{{ ingress_domain }}/list>. Again, you will get a 500 error. The terminal shows the cause:

```console
org.thymeleaf.exceptions.TemplateProcessingException: Exception evaluating SpringEL expression: "cashcard.id" (template: "list.html" - line 5, col 47)] with root cause

org.springframework.expression.spel.SpelEvaluationException: EL1008E: Property or field 'id' cannot be found on object of type 'example.cashcard.CashCardDto' - maybe not public or not valid?
```

### Learning Moment

An application which runs correctly as a traditional JVM program, and successfully compiles to a native image, might not necessarily run correctly as a native image!

The reason, as you learned in the previous lesson, is that some operations require you, the programmer, to provide hints in your application code. The compiler doesn’t catch these cases because they are _runtime_ operations involving dynamic aspects of the Java language (reflection, loading of a resource) that can't be analyzed by the native image compiler.

For this reason, it’s important to test your application thoroughly as a native image. It’s a good thing we have a good test suite for the Cash Card application!

## Run the Tests as a Native Image

Now that we've seen that our application isn't ready for native image compilation yet, let’s use our test suite to fix our errors, one by one. First, let’s run the entire test suite. Instead of the `test` Gradle target, we'll use the `nativeTest` target, which is part of the native build tools Gradle plugin.

```console
[~/exercises] $ ./gradlew nativeTest
…
[1/8] Initializing…
[2/8] Performing analysis...  [******]
[3/8] Building universe...
[4/8] Parsing methods...      [***]
[5/8] Inlining methods...     [****]
[6/8] Compiling methods...    [*******]
[7/8] Layouting methods...    [***]
[8/8] Creating image...       [***]
…

Failures (2):
  JUnit Jupiter:CashCardApplicationTests:cashCardHtmlList()
    MethodSource [className = 'example.cashcard.CashCardApplicationTests', methodName = 'cashCardHtmlList', methodParameterTypes = '']
    => java.lang.AssertionError:
expected: 200 OK
 but was: 500 INTERNAL_SERVER_ERROR
…
  JUnit Jupiter:CashCardApplicationTests:htmlBanner()
    MethodSource [className = 'example.cashcard.CashCardApplicationTests', methodName = 'htmlBanner', methodParameterTypes = '']
    => java.io.FileNotFoundException: class path resource [cashcard-banner.txt] cannot be opened because it does not exist


```

Take a moment to verify that both of our tests failed with the same error messages that you've already received a few moments ago, by testing the application manually through the browser.

Since we already know the reason for these failures is that we are missing reflection and resource runtime hints, we're ready to fix the errors!
