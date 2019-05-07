/**
 Manages and provides `ServicePlugin`s for `ServiceEndpoint`s.
 
 License: MIT
 
 Copyright © 2018 Upstart Illustration LLC. All rights reserved.
 */

import Foundation

class ServicePluginProvider {
    private var plugins: [ServicePlugin] = []
    
    /**
     Register a plugin.
     
     - parameter plugin: A plugin to register.
     */
    func registerPlugin(_ plugin: ServicePlugin) {
        self.plugins.append(plugin)
    }
    
    /**
     Register a list of plugins.
     
     - parameter plugins: A list of plugins to register
     */
    func registerPlugins(_ plugins: [ServicePlugin]) {
        self.plugins.append(contentsOf: plugins)
    }
    
    /**
     Returns a list of plugins for a given `Endpoint`.
     
     - parameter endpoint: The `Endpoint` to return plugins for
     - returns: A list of `ServicePlugin`s required by the `Endpoint`
     */
    func pluginsFor<T: ServiceEndpoint>(_ endpoint: T) throws -> [ServicePlugin] {
        guard let endpointPlugins = endpoint.plugins else {
            return []
        }
        
        let returnPlugins: [ServicePlugin] = plugins.filter { (plugin) -> Bool in
            return endpointPlugins.contains(plugin.key)
        }
        if endpointPlugins.count != returnPlugins.count {
            throw ServiceError.requiredPluginsNotFound(endpointPlugins)
        }
        return returnPlugins
    }
}
