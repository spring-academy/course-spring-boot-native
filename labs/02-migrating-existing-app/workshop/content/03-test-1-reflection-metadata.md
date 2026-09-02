Let’s concentrate on one test at a time. We’ll start with the first failure, in `cashCardHtmlList`.

Let’s focus on this test by using an annotation provided by our testing framework on the other test: `@DisabledInNativeImage`. This is handy when you have certain tests that you don’t want to run while you're running the tests as a native image, instead of in the standard JVM.

Edit `src/test/java/example/cashcard/CashCardApplicationTests.java` and add `@DisabledInNativeImage` to the `htmlBanner()` test. Be sure to add the new `import` statement:

```java
import org.junit.jupiter.api.condition.DisabledInNativeImage;
...

@Test
@DisabledInNativeImage
void htmlBanner() throws IOException {
…
```

## Problem: Missing reflection metadata

We’ve already seen the output of the `cashCardHtmlList` test failure. Here it is:

```console
org.thymeleaf.exceptions.TemplateProcessingException: Exception evaluating SpringEL expression: "cashcard.id" (template: "list.html" - line 5, col 47)
…
JUnit Jupiter:CashCardApplicationTests:cashCardHtmlList()
    MethodSource [className = 'example.cashcard.CashCardApplicationTests', methodName = 'cashCardHtmlList', methodParameterTypes = '']
    => java.lang.AssertionError:
expected: 200 OK
 but was: 500 INTERNAL_SERVER_ERROR
```

We're going to fix this error in a moment, but first let’s analyze what the cause of the failure is, by doing an experiment. Let’s replace the current Controller code with an alternative implementation: We’ll try to render the output NOT using the `CashCardDto` classes, but rather the `CashCard` class (the one that is returned from the Repository).

Modify the `findAll` method in `src/main/java/example/cashcard/CashCardController.java` by commenting out the current implementation, and replacing it with a seemingly-equivalent one:

```java
public class CashCardController {
…
   @GetMapping("/list")
   public String findAll(Model model) {
//      List<CashCardDto> cashcards = cashCardRepository.findAll().stream()
//              .map(c -> new CashCardDto(c.id(), c.amount(),  new UserDto(c.owner()))).toList();
       List<CashCard> cashcards = cashCardRepository.findAll();
       model.addAttribute("cashcards", cashcards);
       return "list.html";
   }
}
```

To convince yourself that this should produce the same response, take another look at the `src/main/resources/templates/list.html` template. Notice that since the field names are the same in the `CashCard` class and `CashCardDto` class, the template should still render the same output HTML.

Now, let’s run the tests again:

```console
[~/exercises] $ ./gradlew nativeTest
… several minutes of processing …
BUILD SUCCESSFUL in 1m 27s
```

We changed one simple thing: Namely, using `CashCard` instead of `CashCardDto`, and the `cashCardHtmlList` test now passes. Why is this?

### Reachability Metadata

GraalVM doesn’t always know which parts of your codebase need to be processed for native image compilation! In this case, the problem is that the Java reflection metadata for the `CashCard` class is included in the native executable, but `CashCardDto` is not. Let’s use the output of the native image compilation to verify that.

View the content of the `build/generated/aotTestResources/META-INF/native-image/example/cashcard` directory. It contains 3 files: `proxy-config.json`, `reflect-config.json`, and `resource-config.json`. These files contain **reachability metadata,** which are generated during native compilation.

Open the `reflect-config.json` file. You’ll see an entry for the `CashCard` class:

```json
{
  "name": "example.cashcard.CashCard",
  "allDeclaredConstructors": true,
  "allDeclaredFields": true,
  "methods": [
    {
      "name": "id",
      "parameterTypes": []
    },
    {
      "name": "amount",
      "parameterTypes": []
    },
    {
      "name": "owner",
      "parameterTypes": []
    }
  ]
}
```

What you _won't_ find, however, is any reference to the `CashCardDto` or `UserDto` classes. This is the cause of our error.

Why is there an entry for the `CashCard` class but not the `*Dto` classes? Spring does its best to infer the reflection entries based on the types exposed in your beans API. In this case, the entry in the `reflect-config.json` file has been created for the `CashCard` class because `CashCard` is exposed in `CashCardRepository` API, which is a Spring Bean.

The cause of our current error is that the reachability data for our own application’s `CashCardDto` and `UserDto` classes are not part of any Spring Bean API. They're provided to the Thymeleaf templating engine using standard Java calls. It then tries to use Java reflection on the objects in order to render the template file, but it can't, because there is not reflection metadata for those classes in the native image.

> **_Note_** (Recapping some learnings from the previous lesson): In this specific case, the Spring Ahead-Of-Time (AOT) engine can’t infer this information, which is needed by the Thymeleaf templating library. Therefore, you'll need to specify it explicitly. Thymeleaf is not a special case. Any reflection-based serialization - for example, in HTTP handler methods (when using HTTP clients like `WebClient` or `RestTemplate`) - will also require you to provide hints in the same way. Thus, this solution applies to many real-world scenarios you'll encounter when preparing an application for deployment as a native image.

## Solution: Specify static reflection hints using the Runtime Hints API

Fortunately, you _don't_ need to manually edit the `reflect-config.json` file. There's a type-safe, less error-prone way: use the Runtime Hints API!

To recap: The Thymeleaf templating engine is missing information from record classes used in the template model like `CashCardDto` and `UserDto`. Because of this, we're going to specify them manually. It can be tricky to know exactly how much reflection should be configured. Fortunately, the Runtime Hints API provides the `@RegisterReflectionForBinding` annotation, which is designed to register exactly what's needed, in most cases, for such a binding or serialization use case. So, let’s use it.

1. Make sure that your Controller class is back in its original state, where it provides the `*Dto` classes to the Thymeleaf rendering engine (undo the experiment from the previous step):

   ```java
   public String findAll(Model model) {
       List<CashCardDto> cashcards = cashCardRepository.findAll().stream()
           .map(c -> new CashCardDto(c.id(), c.amount(),  new UserDto(c.owner()))).toList();
       model.addAttribute("cashcards", cashcards);
       return "list.html";
   }
   ```

1. Annotate the `CashCardApplication` class with the `@RegisterReflectionForBinding` annotation, so that the class definition looks like this. **_Note_**: Be sure to add the new `import` statement.

   In `src/main/java/example/cashcard/CashCardApplication.java`:

   ```java
   import org.springframework.aot.hint.annotation.RegisterReflectionForBinding;
   …
   @SpringBootApplication
   @RegisterReflectionForBinding({ CashCardDto.class, UserDto.class })
   public class CashCardApplication {
       …
   }
   ```

   The `@RegisterReflectionForBinding` annotation accepts a list of classes, and ensures that the necessary reflection metadata for these classes are available to the running native image. In our case, this is what Thymeleaf needs to read the field values from the `*Dto` objects, in order to render the web page.

1. Run the native tests again:

   ```console
   [~/exercises] $ ./gradlew nativeTest

   example.cashcard.CashCardApplicationTests > cashCardHtmlList() SUCCESSFUL
   example.cashcard.CashCardApplicationTests > htmlBanner() SUCCESSFUL

   Test run finished after 101 ms
   [         2 containers found      ]
   [         0 containers skipped    ]
   [         2 containers started    ]
   [         0 containers aborted    ]
   [         2 containers successful ]
   [         0 containers failed     ]
   [         2 tests found           ]
   [         0 tests skipped         ]
   [         2 tests started         ]
   [         0 tests aborted         ]
   [         2 tests successful      ]
   [         0 tests failed          ]
   BUILD SUCCESSFUL in 1m 13s
   ```

Hooray! This time our test passes.

Now, let’s move on to our other failing test.
