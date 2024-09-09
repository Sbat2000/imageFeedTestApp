//
//  URLRequest + Ext.swift
//  ImageFeedTestApp
//
//  Created by Aleksandr Garipov on 09.09.2024.
//

import Foundation

enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

protocol NetworkRequest {
    var endpoint: URL? { get }
    var httpMethod: HttpMethod { get }
    var dto: Encodable? { get }
    var headers: [String: String]? { get }
}

// MARK: - default

extension NetworkRequest {
    var httpMethod: HttpMethod { .get }
    var dto: Encodable? { nil }
    var headers: [String: String]? { nil }
}
