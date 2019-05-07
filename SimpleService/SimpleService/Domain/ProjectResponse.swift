/**
 Represents a project response from a server.
 
 This provides a way to track the offset of a product query as well.
 
 License: MIT
 
 Copyright © 2019 Upstart Illustration LLC. All rights reserved.
 */

import Foundation

struct ProjectResponse {
    let offset: Any?
    let projects: [Project]
}

/// Factory Initializers

extension ProjectResponse {
    init(from response: ProjectsEndpoint.ResponseType, offset: Int) {
        self.offset = offset
        self.projects = response.projects.map { (project) -> Project in
            // FIXME: This should be an image local to the project
            var imageURL: URL = URL(string: "http://placekitten.com/200/300")!
            if let thumbnailURL = URL(string: project.image.t) {
                imageURL = thumbnailURL
            }
            let goal = Int(project.goal) ?? 0
            let pledged = Int(project.pledged) ?? 0
            
            let source: ProjectSource
            switch project.site.lowercased() {
            case "kickstarter":
                source = .kickstarter
            case "indiegogo":
                source = .indiegogo
            default:
                source = .unknown
            }
            
            return Project(
                id: 1,
                source: source,
                url: URL(string: project.url),
                name: project.name,
                goal: goal,
                pledged: pledged,
                numBackers: Int(project.backerCount) ?? 0,
                imageURLs: [imageURL],
                videoPreviewURL: nil,
                videoURL: URL(string: project.url),
                hasEarlyBirdRewards: project.hasEarlyBirdRewards,
                funded: pledged > 0 && pledged >= goal
            )
        }
    }
}
