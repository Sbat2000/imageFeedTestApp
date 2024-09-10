//
//  SearchHistoryService.swift
//  ImageFeedTestApp
//
//  Created by Aleksandr Garipov on 10.09.2024.
//

import Foundation

protocol SearchHistoryServiceProtocol {
    func saveSearchQuery(_ query: String)
    func fetchSearchHistory() -> [String]
    func clearSearchHistory()
}

import Foundation

final class SearchHistoryService: SearchHistoryServiceProtocol {

    private let userDefaults = UserDefaults.standard
    private let historyKey = "searchHistory"
    private let maxHistoryCount = 5

    func saveSearchQuery(_ query: String) {
        var history = fetchSearchHistory()

        if let index = history.firstIndex(of: query) {
            history.remove(at: index)
        }

        history.insert(query, at: 0)

        if history.count > maxHistoryCount {
            history = Array(history.prefix(maxHistoryCount))
        }

        userDefaults.set(history, forKey: historyKey)
    }

    func fetchSearchHistory() -> [String] {
        return userDefaults.stringArray(forKey: historyKey) ?? []
    }

    func clearSearchHistory() {
        userDefaults.removeObject(forKey: historyKey)
    }
}
