# SimpleService

A simple service pattern written in Swift.

## Why?

- Service endpoint as configuration; to see, at a glance, all available properties and required dependencies
- Strongly-typed parameters
- Decouple service response from domain model
- Plugins which allow you to respond accordingly when service requests are made. For example, consider logging the user in before a request was made.
- Testing made easy!

The architecture of the library is designed for maximum testability, single responsibility, and re-usability. It doesn't make assumptions as to your app's architecture, and therefore, should be very easy to integrate into any app -- old or new.

## TODO

- Support raw data for request (images, binaries, files, etc.)
- Make sure that request body can send a `struct`, such as a `User`
- Illustrate how you can test a service by making its `ResponseType` as a `Data` and using `prettyPrint`
