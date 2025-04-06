In this lab you'll learn about Spring Boot and GraalVM native images. This is what we'll do:

- Use Spring Initializr to generate a starter Spring Boot web application that is ready to be built as a native image.
- Add a small amount of code so that we can easily test the application from the command line or a browser.
- Build and test the application in three different ways:
  - As a standard, non-native JVM application
  - As a native image application
  - As an OCI container containing a native image
