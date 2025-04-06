Congratulations! You’ve taken an existing application, and made modifications to it to its source code in order to allow it to run as a native image. Specifically:

- You learned how to reason about **GraalVM reachability metadata**, how it's produced, where to find it in the files generated during native image compilation, and how to diagnose failures that result from lack of reachability metadata. Specifically, you identified classes which were absent from the `reflect-config.json` file.

You learned how to use the **Spring Runtime Hints API** to configure different types of runtime information:

- To supply the missing **runtime reflection data**, you used the `@RegisterReflectionForBinding` annotation. This caused the native compiler to include reflection metadata for two missing classes (`CashCardDto` and `UserDto`).
- You caused the native compiler to include a specific Java **resource file** at runtime, by adding a class that implements `RuntimeHintsRegistrar` to the Spring context.
