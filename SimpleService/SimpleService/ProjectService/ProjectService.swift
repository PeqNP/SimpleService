/**
 Public service to consume projects from the Backit service.
 
License: MIT
 
 Copyright © 2019 Upstart Illustration LLC. All rights reserved.
 */

import BrightFutures
import Foundation

class ProjectService: Service, ProjectProvider {
    
    func projects(offset: Any?, limit: Int) -> Future<ProjectResponse, ProjectProviderError> {
        let nextOffset: Int
        if let offset = offset as? Int {
            nextOffset = offset + limit
        }
        else {
            nextOffset = 0
        }
        
        let request = ProjectsEndpoint(queryParameters: [
            .funding(true),
            .backerCountMin(100),
            .country("United States"),
            .sort("backerCount"),
            .sortDirection("desc"),
            .offset(nextOffset),
            .limit(limit)
        ])
        return self.request(request)
            .map { response -> ProjectResponse in
                return ProjectResponse(from: response, offset: nextOffset)
            }
            .mapError { error -> ProjectProviderError in
                return .failedToLoadProject
            }
    }
}
