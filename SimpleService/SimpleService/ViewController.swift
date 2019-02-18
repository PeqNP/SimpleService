/**
 Provides definition of a request made to a service.
 
 License: MIT
 
 Copyright © 2018 Upstart Illustration LLC. All rights reserved.
 */

import BrightFutures
import UIKit

enum ProjectProviderError: Error {
    case failedToLoadProject
}

protocol ProjectProvider {
    func projects(offset: Any?, limit: Int) -> Future<ProjectResponse, ProjectProviderError>
}

class ViewController: UIViewController {

    var loginService: LoginService?
    var productProvider: ProjectProvider?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // This could be injected into the `ViewController` using `Swinject` or your favorite dependency injection library.
        let servicePluginProvider = ServicePluginProvider(plugins: [TraceContextServicePlugin()])
        let alamofireRequester = AlamofireServiceRequester()
        let informationalRequester = InformationalServiceRequester()
        
        // Services that we can interact with
        loginService = LoginService(environment: .prod, requester: informationalRequester, pluginProvider: servicePluginProvider)
        productProvider = ProjectService(environment: .prod, requester: alamofireRequester, pluginProvider: servicePluginProvider)
        
        // Attempt to login to the server. Please feel free to put a breakpoint in `Service`, or the `URLRequestFactory`, to see how this request is created. The `LoginService` illustrates how all key/value pairs are sent to the server.
        loginService?.login(username: "username", password: "password").onComplete { (result) in
            switch result {
            case .success(let user):
                print(user)
            case .failure(let error):
                print(error)
            }
        }
        
        return Void()
        productProvider?.projects(offset: nil, limit: 10).onComplete { (result) in
            switch result {
            case .success(let products):
                print(products)
            case .failure(let error):
                print(error)
            }
        }
    }
}

