We'll continue by simply building and testing the application as a non-native, i.e. regular JVM application. We'll turn it into a native image in subsequent steps. Why?

- A Spring Boot native application is mostly a regular Spring Boot application where you'll use the JVM as usual, to develop, debug and test your application.
- Compiling to a native image executable can be seen as a deployment optimization that needs to be tested locally, but that doesn't change the developer experience, which remains mostly the same as a regular Spring Boot JVM application.

In the upper Terminal, run the following command, which tells Gradle to build and run the Spring Boot application. Be sure to change to the `demo` directory first:

```console
[~] $ cd demo
[~/demo] $ ./gradlew bootRun
```

Within a minute, you should see that the application has started. You'll know the application has started when you see the text containing the startup time. In the below example, it took about 0.7 seconds for the application to startup. This does _not_ include the compile and download times - just the application startup time:

```console
2023-06-29T00:59:24.760Z  INFO 1561 --- [           main] com.example.demo.DemoApplication         : Started DemoApplication in 0.734 seconds (process running for 0.881)
```

Make a note of how long it took the application to start. We'll use this information in a couple of minutes.

Your application is running in the _upper_ terminal, so we'll let it continue running. Using the _lower_ terminal, make a GET request for the web page, and check that your application serves the HTTP request as expected. You can use the `curl` command line tool to do this:

```console
[~] $ curl http://localhost:8080/
hello
```

In the lower terminal, you'll see that the application answers back by saying `hello`. Success!

Now, in the upper terminal, stop the application by pressing _CTRL + C_.
