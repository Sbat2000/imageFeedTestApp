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
    let urls: Urls?

    struct Urls: Codable, Hashable {
        let small: String?
        let full: String?
    }
}
