# SimpleService

A simple service pattern written in Swift.

## Why?

- To isolate service endpoint information to a single configuration object.
- Make it easy to see, at a glance, all dependencies required for a service endpoint.
- A strongly-typed interface when interacting with a service endpoint.

The architecture of the library is designed for maximum testability, single responsibility, and re-usability. It doesn't make assumptions as to your app's architecture, and therefore, should be very easy to integrate into any app -- old or new.
