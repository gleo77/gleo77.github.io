---
layout: post
title: "Roll your own Auto Discovery with Jersey and HK2"
date: 2016-07-25
---

I recently read a great post by Justin Grant about [Dependency Injection in Jersey](http://www.justinleegrant.com/?p=516) and I wanted to update it with
a slight improvement I uncovered while working with Jersey 2.23.1.

First off, if you haven't read Justin's post and aren't familiar with HK2 and its use within Jersey, I would encourage you to read it first (link above).

Secondly, while I have had luck getting this approach to work, it may rely on some APIs that are open to change in the future so I cannot comment on 
whether this approach is in line with the future direction of Jersey.

My particular improvement applies to this specific note in Justin's blog:

> However, with Jersey, the ServiceLocator has been created and populated already, which means that it gets a little complicated.

It turns out there's actually an easier way to tie into Jersey's *ServiceLocator* than the one described in Justin's blog. This is done by utilizing a JAX-RS 
[Feature](https://jersey.java.net/apidocs/2.9/jersey/javax/ws/rs/core/Feature.html) and Jersey's [ServiceLocatorProvider](https://jersey.java.net/apidocs/2.9/jersey/org/glassfish/jersey/ServiceLocatorProvider.html)

{% highlight java %}
package com.example.di;

import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.ws.rs.core.Feature;
import javax.ws.rs.core.FeatureContext;
import org.glassfish.hk2.api.DynamicConfigurationService;
import org.glassfish.hk2.api.MultiException;
import org.glassfish.hk2.api.Populator;
import org.glassfish.hk2.api.ServiceLocator;
import org.glassfish.hk2.utilities.ClasspathDescriptorFileFinder;
import org.glassfish.hk2.utilities.DuplicatePostProcessor;
import org.glassfish.jersey.ServiceLocatorProvider;

public class MyDiscoverableFeature implements Feature {

    @Override
    public boolean configure(FeatureContext context) {
        ServiceLocator locator = ServiceLocatorProvider.getServiceLocator(context);
        DynamicConfigurationService dcs = locator.getService(DynamicConfigurationService.class);
        Populator populator = dcs.getPopulator();
        try {
            populator.populate(new ClasspathDescriptorFileFinder(this.getClass().getClassLoader()),
                    new DuplicatePostProcessor());
        } catch (IOException | MultiException ex) {
            Logger.getLogger(MyDiscoverableFeature.class.getName()).log(Level.SEVERE, null, ex);
        }
        return true;
    }
    
}
{% endhighlight %}

This class will cause the HK2 framework to scan your classpath for inhabitants files that are created using the `hk2-inhabitant-generator`. If you haven't
set that up as part of your build you can do so by adding the following line to the `plugins` section of your `pom.xml`:

{% highlight xml %}
<!-- ... -->
            <plugin>
                <groupId>org.glassfish.hk2</groupId>
                <artifactId>hk2-inhabitant-generator</artifactId>
                <version>2.4.0-b34</version>
                <executions>
                    <execution>
                        <goals>
                            <goal>generate-inhabitants</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
<!-- ... -->
{% endhighlight %}

To activate the class you will need to register your new feature as you would any other Jersey feature:

{% highlight java %}
    @Override
    protected Application configure() {
        // ...

        ResourceConfig config = new ResourceConfig();
        config.register(MyDiscoverableFeature.class);

        // ...
    }
{% endhighlight %}

From now on Jersey should automatically find all of your `@Contract` and `@Service` classes.
