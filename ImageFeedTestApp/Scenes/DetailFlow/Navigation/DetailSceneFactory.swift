//
//  DetailSceneFactory.swift
//  ImageFeedTestApp
//
//  Created by Aleksandr Garipov on 11.09.2024.
//

import Foundation

struct DetailSceneFactory {

    static func makeDetailViewController(for photo: PhotoModel) -> DetailViewController {
        let viewModel = DetailViewModel(photo: photo)
        let viewController = DetailViewController(viewModel: viewModel)
        return viewController
    }
}
