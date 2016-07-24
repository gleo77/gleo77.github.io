---
layout: post
title: "How to enable request logging while working with Jersey tests under Maven"
date: 2016-07-16
---

I've recently been working on developing a RESTful API using [Jersey](http://jersey.java.net) and one of my very first struggles was getting it to output the HTTP headers and request/response content during testing.

Bear in mind that I am not a professional developer so much of this may be obvious to a more experienced professional.

Jersey provides the [Jersey Test](https://jersey.java.net/documentation/latest/test-framework.html) framework to make writing Jersey tests simpler and even provides this small snippet to show how to enable logging of headers and content:

{% highlight java %}
public class SimpleTest extends JerseyTest {
    // ...
 
    @Override
    protected Application configure() {
        enable(TestProperties.LOG_TRAFFIC);
        enable(TestProperties.DUMP_ENTITY);
 
        // ...
 
    }
}
{% endhighlight %}

Unfortunately it turns out that setting these properties is not enough to get JerseyTest to output traffic, at least not while testing under Maven (via the Surefire plugin). The reason is that, by default, Jersey will only log additional content if logging (using [java.util.logging](https://docs.oracle.com/javase/7/docs/api/java/util/logging/package-summary.html)) is set to *FINE* or higher. In most scenarios, logging with be set to *INFO*.

That leaves us with two obvious solutions:

- Force Jersey to log even when logging is set to *INFO*
- Change the logging level during testing to *FINE* or higher

## Changing JerseyTest's Log Level

To change the logging level for a class that extends `JerseyTest` add the following code to your `configure()` method:

{% highlight java %}
ResourceConfig config = new ResourceConfig().property(LoggingFeature.LOGGING_FEATURE_LOGGER_LEVEL_SERVER, "WARNING");
return config;
{% endhighlight %}

This will cause `JerseyTest` to log everything at *WARNING* level which will display if your log level is currently set to *INFO*.

## Changing the Log Level of Maven Tests

To change the logging configuration while running Maven you will need to first create a `logging.properties` file and then tell Maven where to find it.

### Creating a logging.properties

Create a new file named `logging.properties` and save it under `src/main/resources` in your project's directory (create the `resources` folder if necessary)

{% highlight properties %}
handlers = java.util.logging.ConsoleHandler
java.util.logging.ConsoleHandler.level = FINE
java.util.logging.ConsoleHandler.formatter = java.util.logging.SimpleFormatter
org.glassfish.jersey.test.JerseyTest.level = FINE
{% endhighlight %}

### Modify your pom.xml to force Maven to read your new properties

In order to override the default logging values you will need to tell Maven where to find your new properties file. Do this by adding the following to the `plugins` section of your `pom.xml`:

{% highlight xml %}
<!-- ... -->
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-surefire-plugin</artifactId>
                <version>2.19.1</version>
                <configuration>
                    <argLine>-Djava.util.logging.config.file=target/classes/logging.properties</argLine>
                </configuration>
            </plugin>  
<!-- ... -->
{% endhighlight %}

**Note** if you already have the `plugin` section then you can simply add the `configuration` and `argLine` section as shown above.
