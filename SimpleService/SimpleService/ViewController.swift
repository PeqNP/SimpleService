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

    let productProvider: ProjectProvider = ProjectService(environment: .prod, requester: AlamofireServiceRequester())
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

