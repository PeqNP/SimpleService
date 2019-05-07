/**
 Provides view into the queried data.
 
 For now this only prints the results of the service responses.
 
 License: MIT
 
 Copyright © 2018 Upstart Illustration LLC. All rights reserved.
 */

import BrightFutures
import UIKit

class ViewController: UIViewController {

    var loginService: LoginService?
    var productProvider: ProjectProvider?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // This could be injected into the `ViewController` using `Swinject` or your favorite dependency injection library.
        let servicePluginProvider = ServicePluginProvider()
        servicePluginProvider.registerPlugins( [TraceContextServicePlugin()])
        
        // To make live requests, toggle the `requester`.
//        let requester = AlamofireServiceRequester()
        let requester = InformationalServiceRequester()
        
        // Services that we can interact with
        let service = Service(environment: .prod, requester: requester)
        loginService = LoginService(service: service)
        productProvider = ProjectService(service: service)
        
        // Attempt to login to the server. Please feel free to put a breakpoint in `Service`, or the `URLRequestFactory`, to see how this request is created. The `LoginService` illustrates how all key/value pairs are sent to the server.
        loginService?.login(username: "username", password: "password").onComplete { (result) in
            switch result {
            case .success(let user):
                print(user)
            case .failure(let error):
                print("Failed to login because: \(error)")
            }
        }
        
        productProvider?.projects(offset: nil, limit: 10).onComplete { (result) in
            switch result {
            case .success(let products):
                print(products)
            case .failure(let error):
                print("Failed to load projects because: \(error)")
            }
        }
    }
}

