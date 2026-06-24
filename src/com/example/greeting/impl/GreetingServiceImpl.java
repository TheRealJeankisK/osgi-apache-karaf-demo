package com.example.greeting.impl;

import com.example.greeting.GreetingService;

/**
 * GreetingServiceImpl is the concrete implementation of the GreetingService.
 * This class is kept in an internal package (impl) so that consuming bundles
 * do not depend directly on it, only on the interface.
 */
public class GreetingServiceImpl implements GreetingService {

    @Override
    public String greet(String name) {
        if (name == null || name.trim().isEmpty()) {
            name = "Guest";
        }
        return "Hello, " + name + "! Welcome to the OSGi dynamic architecture demo.";
    }
}
