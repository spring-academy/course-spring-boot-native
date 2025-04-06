Remove the `@DisabledInNativeImage` annotation from the test that we just fixed (`htmlBanner`), so that now both tests will run when we execute the test suite:

```java
@Test
void htmlBanner() throws IOException {
...
```

## Problem: Cannot load a Resource file

We already know (because we ran the `htmlBanner` test previously) that this is the output from the test failure:

```console
JUnit Jupiter:CashCardApplicationTests:htmlBanner()
    MethodSource [className = 'example.cashcard.CashCardApplicationTests', methodName = 'htmlBanner', methodParameterTypes = '']
    => java.io.FileNotFoundException: class path resource [cashcard-banner.txt] cannot be opened because it does not exist
```

But, wait! The `cashcard-banner.txt` resource file _does_ exist where you would expect Java resources to be: `src/main/resources/cashcard-banner.txt`. Why isn't it available to the native image? The reason is, because the native compilation _does not automatically include_ all resources. Doing so would be wasteful (one reason for this is that not all resources are required at runtime). You need to provide a hint to specify which resources should be available at runtime.

## Solution: Specify fine-grained hints with RuntimeHintsRegistrar

We’ll add a bean which implements the `RuntimeHintsRegistrar` interface. This interface allows you to declare not only resource hints (which is what we’re about to do), but also reflection, JNI (Java Native Interface), proxy, and serialization hints. We're going to leverage this API to register the project specific `cashcard-banner.txt` resource file, which will result in it being included in the native image.

1. Add a nested class called `Hints` in `CashCardApplication` as in the following. **_Note_**: Be sure to add the three new import statements:

   ```java
   import org.springframework.aot.hint.RuntimeHints;
   import org.springframework.aot.hint.RuntimeHintsRegistrar;
   import org.springframework.lang.Nullable;

   public class CashCardApplication {
       …
       static class Hints implements RuntimeHintsRegistrar {
           @Override
           public void registerHints(RuntimeHints hints, @Nullable ClassLoader classLoader) {
               hints.resources().registerPattern("cashcard-banner.txt");
           }
       }
   }
   ```

   **_NOTE:_** We chose to use an inner (nested) class. We could just as easily do this using a regular top-level class. By using a nested class, we've kept all of the configuration “contained” in a single place. Depending on your own needs and preferences, you might wish to organize your own codebase differently!

2. Enable the `Hints` class by annotating the `CashCardApplication` class with the `@ImportRuntimeHints` annotation, as follows. **_Note_**: Be sure to add the new import statement:

   ```java
   import org.springframework.context.annotation.ImportRuntimeHints;
   …
   @SpringBootApplication
   @RegisterReflectionForBinding({ CashCardDto.class, UserDto.class })
   @ImportRuntimeHints(CashCardApplication.Hints.class)
   public class CashCardApplication {
       …
       static class Hints implements RuntimeHintsRegistrar {
           …
       }
   }
   ```

   The `@ImportRuntimeHints` annotation accepts a list of classes which implement the `RuntimeHintsRegistrar` interface, and is required.

   **_Note_** In this lab, we've chosen to put the annotation on our Application class, but it could be present on any class that's loaded into the Spring context, such as a `@Configuration` class.

   With those two additions, you should expect your test to pass. Try it!

3. Run the native test again:

   ```console
   [~/exercises] $ ./gradlew nativeTest
   ...
   BUILD SUCCESSFUL in 2m 44s
   ```

It worked! You've just successfully configured the application with the hints that the native build tools need in order to include the Java Resource required by the application at runtime. Awesome!
