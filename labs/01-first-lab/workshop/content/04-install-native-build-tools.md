Now that we've seen the non-native application work as expected, we'll use the Native Build Tools plugins in order to compile your Spring Boot application to a native executable.

But, we haven't installed any native build tools. Let's do so, using the [recommended installation method](https://docs.spring.io/spring-boot/docs/current/reference/html/native-image.html#native-image.developing-your-first-application.native-build-tools.prerequisites) for Linux and MacOS: Using [SDKMAN!](https://sdkman.io)

### Install SDKMAN!

The installation is simple and quick:

```console
[~/demo] $ curl -s "https://get.sdkman.io" | bash
```

Because of the way Linux shells work, in order for the installed `sdk` executable to be visible, you'll need to alter the shell environment to make it visible, or create a new shell. We'll follow the instructions from SDKMAN! to alter the shell environment:

```console
[~/demo] source "/home/eduk8s/.sdkman/bin/sdkman-init.sh"
```

### Install GraalVM

Now we'll use SDKMAN! to install a GraalVM distribution. Since those are Java distributions, we'll ask SDKMAN! what choices it has in the `java` application:
There are many, but we recommend either "GraalVM CE" (CE means Community Edition) or "Liberica NIK" (NIK means Native Image Kit).

```console
[~/demo] $ sdk list java
================================================================================
Available Java Versions for Linux 64bit
================================================================================
 Vendor        | Use | Version      | Dist    | Status     | Identifier
--------------------------------------------------------------------------------
 ...
 Liberica NIK  |     | 25.0.4.r25   | nik     |            | 25.0.4.r25-nik
               |     | 25.0.4.fx    | nik     |            | 25.0.4.fx-nik
```

Great! Let's use Liberica NIK, which is based on the same JDK as the regular Liberica distribution.
We'll choose this one and install the latest Java 25 version available:

```console
[~/demo] $ sdk install java 25.0.4.r25-nik
```

The install should take a couple of minutes after which you will be asked if you wish to set the newly installed JDK as the default. Select `y` and hit enter.

```console
...
Installing: java 25.0.4.r25-nik
Done installing!

Do you want java 25.0.4.r25-nik to be set as default? (Y/n): y

Setting java 25.0.4.r25-nik as default.
```

Let's verify that our `java` executable is the GraalVM we just installed. First, you'll need to start a new shell, so that the shell can "see" what was just installed by SDKMAN!:

```console
[~/demo] $ bash
```

Now that you've started a new shell, you should see that the version of Java is the newly-installed GraalVM:

```console
[~/demo] $ java --version
openjdk 25.0.4 2026-07-21 LTS
OpenJDK Runtime Environment Liberica-NIK-25.0.4-1 (build 25.0.4+10-LTS)
OpenJDK 64-Bit Server VM Liberica-NIK-25.0.4-1 (build 25.0.4+10-LTS, mixed mode, sharing)
```

Let's also check that the `native-image` tool is available as expected:

```console
[~/demo] $ native-image --version
native-image 25.0.4 2026-07-21
GraalVM Runtime Environment Liberica-NIK-25.0.4-1 (build 25.0.4+10-LTS)
Substrate VM Liberica-NIK-25.0.4-1 (build 25.0.4+10-LTS, serial gc)
```

Now that we have GraalVM installed, we're ready to use it to build and run our application as a native image.
