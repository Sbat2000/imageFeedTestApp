//
//  UnsplashSearchRequest.swift
//  ImageFeedTestApp
//
//  Created by Aleksandr Garipov on 09.09.2024.
//

import Foundation

struct UnsplashSearchRequest: NetworkRequest {
    let endpoint: URL?
    let headers: [String: String]? = ["Authorization": "Client-ID sNAiwNG8bsDXRSdLn-0QTHy4zA3H3qemE4GOjrJb-Yc"]

    init(query: String, page: Int) {
        var components = URLComponents(string: "https://api.unsplash.com/search/photos")
        components?.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "30"),
        ]
        self.endpoint = components?.url
    }
}
