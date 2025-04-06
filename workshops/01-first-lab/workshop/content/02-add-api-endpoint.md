Now let's add a REST GET endpoint so that it's easy to test that our application works.

Select the **_Editor_** tab, to the right. This tab is running Visual Studio Code, an IDE that we'll use to interactively edit and test the application.
Add the following Controller class by creating the file `demo/src/main/java/com/example/demo/HelloController.java` with the following content:

```copy java
package com.example.demo;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
class HelloController {

	@GetMapping("/")
	String hello() {
		return "hello";
	}
}
```

This gives the application the ability to respond with the text "hello" when you execute an HTTP GET request to the root path. You'll do exactly this, in just a minute or two.
