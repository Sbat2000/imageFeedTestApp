//
//  SearchImageService.swift
//  ImageFeedTestApp
//
//  Created by Aleksandr Garipov on 09.09.2024.
//

import Foundation

protocol SearchServiceProtocol {
    func searchImages(query: String, page: Int, completion: @escaping (Result<SearchResult, Error>) -> Void)
}

struct SearchService: SearchServiceProtocol {
    private let networkClient: NetworkClientProtocol

    init(networkClient: NetworkClientProtocol) {
        self.networkClient = networkClient
    }

    func searchImages(query: String, page: Int, completion: @escaping (Result<SearchResult, Error>) -> Void) {
        let request = UnsplashSearchRequest(query: query, page: page)

        networkClient.send(request: request, type: SearchResult.self) { result in
            completion(result)
        }
    }
}
