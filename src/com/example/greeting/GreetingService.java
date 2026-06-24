package com.example.greeting;

/**
 * GreetingService interface defines the contract for the greeting service.
 * OSGi components will use this interface to interact with the service,
 * ensuring low coupling.
 */
public interface GreetingService {
    /**
     * Generates a greeting message.
     *
     * @param name the name of the person to greet
     * @return a formatted greeting string
     */
    String greet(String name);
}
