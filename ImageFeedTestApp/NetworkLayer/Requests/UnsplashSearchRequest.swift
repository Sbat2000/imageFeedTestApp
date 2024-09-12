//
//  UnsplashSearchRequest.swift
//  ImageFeedTestApp
//
//  Created by Aleksandr Garipov on 09.09.2024.
//

import Foundation

struct UnsplashSearchRequest: NetworkRequest {
    let endpoint: URL?
    // TODO: Вставьте сюда ваш API ключ
    let headers: [String: String]? = ["Authorization": "Client-ID Your apikey"]

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
