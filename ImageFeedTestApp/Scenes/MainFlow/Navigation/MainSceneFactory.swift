//
//  MainSceneFactory.swift
//  ImageFeedTestApp
//
//  Created by Aleksandr Garipov on 11.09.2024.
//

import Foundation

struct MainSceneFactory {
    static func makeMainViewController(with coordinator: MainCoordinator) -> MainViewController {
        let searchService = SearchService(networkClient: DefaultNetworkClient())
        let searchHistoryService = SearchHistoryService()

        let viewModel = MainScreenViewModel(
            searchService: searchService,
            searchHistoryService: searchHistoryService,
            coordinator: coordinator
        )

        let viewController = MainViewController(viewModel: viewModel)
        return viewController
    }
}
