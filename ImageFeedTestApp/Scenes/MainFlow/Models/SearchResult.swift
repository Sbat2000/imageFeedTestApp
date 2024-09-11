//
//  SearchResult.swift
//  ImageFeedTestApp
//
//  Created by Aleksandr Garipov on 09.09.2024.
//

import Foundation

struct SearchResult: Codable {
    let total: Int
    let totalPages: Int
    let results: [PhotoModel]
}

struct PhotoModel: Codable, Hashable, Identifiable {

    let id: String?
    let description: String?
    let altDescription: String?
    let createdAt: Date?
    let width: Int?
    let height: Int?
    let urls: Urls?
    let user: UserModel

    struct Urls: Codable, Hashable {
        let small: String?
        let full: String?
    }

    struct UserModel: Codable, Hashable {
        let username: String?
        let bio: String?
        let location: String?
    }
}
