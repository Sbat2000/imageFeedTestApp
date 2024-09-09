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
    func loadData(query: String)
}

// MARK: - ViewModel

final class MainScreenViewModel: MainScreenViewModelProtocol {


    // MARK: - Published Properties

    @Published private var photos: [PhotoModel] = []

    // MARK: - Properties

    private let searchService: SearchServiceProtocol

    // MARK: - Life Cycle

    init(searchService: SearchServiceProtocol = SearchService(networkClient: DefaultNetworkClient())) {
        self.searchService = searchService
    }

    // MARK: - Public Methods

    var photosPublisher: Published<[PhotoModel]>.Publisher {
        $photos
    }

    func loadData(query: String) {
        searchService.searchImages(query: query, page: 1) { [weak self] result in
            switch result {
            case .success(let searchResult):
                let photoModels = searchResult.results.map { $0 }
                DispatchQueue.main.async {
                    self?.photos = photoModels
                    print(self?.photos)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
