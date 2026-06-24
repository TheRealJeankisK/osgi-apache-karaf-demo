package com.example.client;

import com.example.greeting.GreetingService;
import org.osgi.framework.BundleActivator;
import org.osgi.framework.BundleContext;
import org.osgi.util.tracker.ServiceTracker;

/**
 * Activator for the greeting-client bundle.
 * It tracks the GreetingService dynamically using a ServiceTracker.
 * A background thread periodically checks for the service presence,
 * demonstrating how OSGi handles dynamic services coming and going.
 */
public class Activator implements BundleActivator {

    private ServiceTracker<GreetingService, GreetingService> tracker;
    private Thread workerThread;
    private volatile boolean running = true;

    @Override
    public void start(final BundleContext context) throws Exception {
        System.out.println("[Greeting Client] Bundle starting...");

        // Initialize the ServiceTracker for GreetingService
        tracker = new ServiceTracker<>(context, GreetingService.class.getName(), null);
        tracker.open();

        // Spawn a background thread to demonstrate dynamic tracking in real-time
        running = true;
        workerThread = new Thread(new Runnable() {
            @Override
            public void run() {
                System.out.println("[Greeting Client] Background worker thread started.");
                while (running) {
                    try {
                        // Attempt to obtain the service from the tracker
                        GreetingService service = tracker.getService();
                        
                        if (service != null) {
                            // Service is available, invoke it
                            String greeting = service.greet("Jean Gomez");
                            System.out.println("[Greeting Client] SUCCESS: " + greeting);
                        } else {
                            // Service is not available (either stopped or not installed)
                            System.out.println("[Greeting Client] WARNING: GreetingService is currently UNAVAILABLE.");
                        }

                        // Check every 3 seconds
                        Thread.sleep(3000);
                    } catch (InterruptedException e) {
                        // Thread interrupted when stopping the bundle
                        break;
                    } catch (Exception e) {
                        System.err.println("[Greeting Client] Error: " + e.getMessage());
                    }
                }
                System.out.println("[Greeting Client] Background worker thread stopped.");
            }
        });

        workerThread.start();
        System.out.println("[Greeting Client] Bundle started successfully.");
    }

    @Override
    public void stop(BundleContext context) throws Exception {
        System.out.println("[Greeting Client] Bundle stopping...");

        // Signal thread to stop and interrupt it
        running = false;
        if (workerThread != null) {
            workerThread.interrupt();
            workerThread.join(1000); // Wait up to 1 second for thread to terminate
        }

        // Close the ServiceTracker
        if (tracker != null) {
            tracker.close();
        }

        System.out.println("[Greeting Client] Bundle stopped.");
    }
}
