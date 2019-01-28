# SimpleService

A simple service pattern written in Swift.

## Why?

- To isolate service endpoint information to a single configuration object.
- Make it easy to see, at a glance, all dependencies required for a service endpoint.
- A strongly-typed interface when interacting with a service endpoint.

The architecture of the library is designed for maximum testability, single responsibility, and re-usability. It doesn't make assumptions as to your app's architecture, and therefore, should be very easy to integrate into any app -- old or new.

This simple app also shows you how to use dependency inversion. The `ViewController` defines a few `protocol`s which a provider must implement.

## TODO

- I didn't finish the `Header`, `PathParameter`, `PostParameter` mapping logic.
- Add an example which uses all `ServiceEndpoint` `associatedtype`s to illustrate.
- Add an example that shows how a `ServicePlugin` works. Including:
-- modify an a request before it is sent to the server
-- modify a response before it is consumed
-- respond to requests that were sent
