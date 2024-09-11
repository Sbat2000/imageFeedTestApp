//
//  MainCoordinator.swift
//  ImageFeedTestApp
//
//  Created by Aleksandr Garipov on 11.09.2024.
//

import Foundation

protocol MainCoordinatorProtocol: BaseCoordinator {
    func showDetailView(for photo: PhotoModel)
}

final class MainCoordinator: BaseCoordinator, MainCoordinatorProtocol {

    func showDetailView(for photo: PhotoModel) {
        let detailViewController = DetailSceneFactory.makeDetailViewController(for: photo)
        navigationController.pushViewController(detailViewController, animated: true)
    }
    
    override func start() {
        let mainViewController = MainSceneFactory.makeMainViewController(with: self)
        navigationController.setViewControllers([mainViewController], animated: false)
    }

    override func finish() {
        finishDelegate?.didFinish(self)
    }
}
