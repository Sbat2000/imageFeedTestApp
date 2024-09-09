//
//  NetworkTask.swift
//  ImageFeedTestApp
//
//  Created by Aleksandr Garipov on 09.09.2024.
//

import Foundation

protocol NetworkTask {
    func cancel()
}

struct DefaultNetworkTask: NetworkTask {
    let dataTask: URLSessionDataTask

    func cancel() {
        dataTask.cancel()
    }
}
