/**
 
 License: MIT
 
 Copyright © 2019 Upstart Illustration LLC. All rights reserved.
 */

import BrightFutures
import Foundation

enum ProjectProviderError: Error {
    case failedToLoadProject
}

protocol ProjectProvider {
    func projects(offset: Any?, limit: Int) -> Future<ProjectResponse, ProjectProviderError>
}
