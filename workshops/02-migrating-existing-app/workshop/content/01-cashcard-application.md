In the **Terminal** and **Editor** panes to the right, you will find a codebase for a small application called Cash Card. This is a simple web application that has one function: To display a list of Cash Cards. You can think of a Cash Card as a debit card with a balance that can be used to make purchases. A Cash Card has an ID, an amount (cash balance), and an owner.

## Understanding the Application

Take a couple minutes to acquaint yourself with the codebase. You can navigate the codebase and run the application from either the **Terminal** or the **Editor**.

If you’re familiar with Spring Web and Spring Data, you will recognize the Controller and Repository classes. In addition, the application uses Thymeleaf, a templating engine for rendering web pages. If you’re not familiar with all of these libraries, don’t worry - you’ll still be able to complete this Lab! It’s the concepts which are important.

Take a look at the `CashCardController` class, which has two GET endpoints: `/list`, and `/banner`:

```java
@GetMapping("/list")
public String findAll(Model model) {
    List<CashCardDto> cashcards = cashCardRepository.findAll().stream()
        .map(c -> new CashCardDto(c.id(), c.amount(),  new UserDto(c.owner()))).toList();
    model.addAttribute("cashcards", cashcards);
    return "list.html";
}

@GetMapping("/banner")
public String banner(Model model)  throws IOException {
    ClassPathResource resource = new ClassPathResource("cashcard-banner.txt");
    String banner = new String(resource.getInputStream().readAllBytes(), StandardCharsets.UTF_8);
    model.addAttribute("banner", banner);
    return "banner.html";
}
```

- The `/banner` endpoint responds with the contents of the `cashcard-banner.txt` resource file.
- The `/list` endpoint is a little more complex: It retrieves all `Cashcard` objects from the database by calling the Repository, then provides the list to the Thymeleaf templating engine. Finally, Thymeleaf uses the `list.html` template file to generate the HTML response, containing a (very sparingly!) formatted list of the Cash Cards. In a moment we'll view the actual output in a browser.

The database for the tests is seeded to contain the entries in the `src/main/resources/data.sql` file, so the resulting output list should contain 4 Cash Cards.

Please also take note of the fact that there are two sets of data classes:

- `CashCard` - This class is used by the Repository.
- `CashCardDto` and `UserDto` - these two classes are used by the templating engine.

This is a common pattern in real-world applications: Having separate data classes for different application “layers”. In a few minutes, we’ll refer back to these two class layers, and cover why they’re important for this lab.

## Understanding the Tests

The codebase contains two tests: one for each GET endpoint (`/list` and `/banner`). The `/list` test expects to receive a subset of the data from the seed file (`data.sql`) to be present:

```java
@Test
void cashCardHtmlList() {
    ResponseEntity<String> result = restTemplate.exchange(RequestEntity.get("/list").build(), String.class);
    assertThat(result.getStatusCode()).isEqualTo(HttpStatus.OK);
    assertThat(result.getBody()).contains("sarah1", "kumar2", "101", "150.0");
}
```

The second test performs the same GET request, but instead of expecting values from the database, it expects the contents of the `src/main/resources/banner.txt` resource file to be present in the output.

```java
@Test
void htmlBanner() throws IOException {
    ClassPathResource resource = new ClassPathResource("cashcard-banner.txt");
    String banner = new String(resource.getInputStream().readAllBytes(), StandardCharsets.UTF_8);

    ResponseEntity<String> result = restTemplate.exchange(RequestEntity.get("/").build(), String.class);
    assertThat(result.getStatusCode()).isEqualTo(HttpStatus.OK);
    assertThat(result.getBody()).contains(banner);
}
```

Before trying to run the application as a native image, let’s make sure the tests pass as a standard JVM application:

```console
[~/exercises] $ ./gradlew test
> Task :test
…
BUILD SUCCESSFUL in 4s
```

## Running the application

As we expected of an application that's already complete, the tests pass! Let’s also look at the actual output web page, by running the application and navigating to the `/list` endpoint.

```console
[~/exercises] $ ./gradlew bootRun
```

The interactive lab environment you’re using exposes the running application on the public Internet, at this URL (which is specific to your current Lab session): <https://{{ session_namespace }}-cashcard.{{ ingress_domain }}/list>. Go ahead and navigate to that URL in a separate window (or tab) in your web browser.

Voilà! The output contains the list of all Cash Cards:

```text
id: 99, amount: 123.45, owner:UserDto[id=sarah1]
id: 100, amount: 1.0, owner:UserDto[id=sarah1]
id: 101, amount: 150.0, owner:UserDto[id=sarah1]
id: 102, amount: 200.0, owner:UserDto[id=kumar2]
```

Likewise, if you navigate to <https://{{ session_namespace }}-cashcard.{{ ingress_domain }}/banner> you’ll see the banner text:

```text
Welcome to your CashCard website!
```

You can imagine that another part of the application, maybe written in JavaScript, would assemble the banner and list together to produce the final output in a more user-friendly format. For this lab, we're not interested in user-friendly output.

Now that you have seen the application in action, go ahead and terminate it by going to the Terminal, and typing `CTRL - C`.
