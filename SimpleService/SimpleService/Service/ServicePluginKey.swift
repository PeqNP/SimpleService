/**
 Provides a key to map to a `ServicePlugin`s.
 
 This file should be updated to reflect your app's respective plugins. Every app will have their own unique plugins. To install a plugin for an endpoint, you must register your plugin(s) with either `Service.registerPlugin()` or `Service.registerPlugins()`.
 
 The idea of decoupling the `ServicePluginKey` from referencing its concrete class as it allows the client app to define who provides the behavior. It's similar to a protocol where the service says, "I need a plugin that performs X behavior." The client will provide a class which implements X behavior. In this way the service and the layer that implements the plugin are decoupled making the lower-level service layer as lean as possible w/o dictating how the client implements the behavior.
 
 Let's take a look at the single plugin in this example. The case `traceContext` is stating (admittedly a bit ambiguously), "I have a service which can accept a trace context and needs it in order to operate." The client could then use any library or method to generate a trace context and modify the `URLRequest` before it is sent to the service.
 
 Please refer to the client implementation `TraceContextServicePlugin` which states that it provides this behavior and illustrates how a `URLRequest` can be modified before it is sent to the server.
 
 License: MIT
 
 Copyright © 2018 Upstart Illustration LLC. All rights reserved.
 */

import Foundation

enum ServicePluginKey: Equatable {
    /// Inject a trace context from metrics provider
    case traceContext
}
