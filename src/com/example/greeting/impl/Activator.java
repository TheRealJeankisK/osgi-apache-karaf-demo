package com.example.greeting.impl;

import com.example.greeting.GreetingService;
import org.osgi.framework.BundleActivator;
import org.osgi.framework.BundleContext;
import org.osgi.framework.ServiceRegistration;

/**
 * Activator controls the lifecycle of the greeting-service bundle.
 * It registers the GreetingService implementation in the OSGi Service Registry
 * upon bundle startup, making it available to other bundles.
 */
public class Activator implements BundleActivator {

    private ServiceRegistration<?> registration;

    @Override
    public void start(BundleContext context) throws Exception {
        System.out.println("[Greeting Provider] Bundle starting...");
        
        // Instantiate the service implementation
        GreetingService service = new GreetingServiceImpl();
        
        // Register the service under its interface name in the OSGi Service Registry
        registration = context.registerService(GreetingService.class.getName(), service, null);
        
        System.out.println("[Greeting Provider] GreetingService registered successfully!");
    }

    @Override
    public void stop(BundleContext context) throws Exception {
        System.out.println("[Greeting Provider] Bundle stopping...");
        
        // Unregister the service
        if (registration != null) {
            registration.unregister();
            System.out.println("[Greeting Provider] GreetingService unregistered.");
        }
        
        System.out.println("[Greeting Provider] Bundle stopped.");
    }
}
