//
//  MainScreenViewModel.swift
//  ImageFeedTestApp
//
//  Created by Aleksandr Garipov on 08.09.2024.
//

import Foundation

// MARK: - MainViewModelProtocol

protocol MainScreenViewModelProtocol {
    var photosPublisher: Published<[PhotoModel]>.Publisher { get }
    func loadData()
}

// MARK: - ViewModel

final class MainScreenViewModel: MainScreenViewModelProtocol {

    // MARK: - Published Properties

    @Published private var photos: [PhotoModel] = []

    // MARK: - Public Methods

    var photosPublisher: Published<[PhotoModel]>.Publisher {
        $photos
    }

    func loadData() {
        photos = [
            PhotoModel(id: UUID(), description: "Mock Photo 1", image: "sun.max"),
            PhotoModel(id: UUID(), description: "Mock Photo 2", image: "sun.min"),
            PhotoModel(id: UUID(), description: "Mock Photo 3", image: "sun.max.circle.fill")
        ]
    }
}
