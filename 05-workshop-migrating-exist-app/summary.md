In this interactive Lab, you’ll learn more about how to run a more complex application as a native image, by migrating an existing one.

This lab assumes you’re familiar with the material in the previous lesson.

- You’ll start with a small “Cash Card” Spring Boot web application
- You'll Build and run it successfully as a standard JVM application
- You'll then build it successfully, but encounter runtime failures, as a native image application
- Using the Runtime Hints API, you'll supply two types of metadata that the application requires in order to be native image compatible:
  - Reflection metadata
  - Runtime Java resources
