/**
 *
 * Copyright © 2018 Backit. All rights reserved.
 */

import Foundation

struct ProjectResponse {
    let offset: Any?
    let projects: [Project]
}

struct Project {
    let id: Any
    let source: ProjectSource
    let url: URL? // Internal Backit URL
    let name: String
    let goal: Int
    let pledged: Int
    let numBackers: Int
    let imageURLs: [URL]
    let videoPreviewURL: URL?
    let videoURL: URL?
    let hasEarlyBirdRewards: Bool
    let funded: Bool
}
