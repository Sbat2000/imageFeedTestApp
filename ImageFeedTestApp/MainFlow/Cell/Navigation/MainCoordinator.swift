//
//  MainCoordinator.swift
//  ImageFeedTestApp
//
//  Created by Aleksandr Garipov on 11.09.2024.
//

import Foundation

final class MainCoordinator: BaseCoordinator {
    override func start() {
        let mainViewController = MainSceneFactory.makeMainViewController(with: self)
        navigationController.setViewControllers([mainViewController], animated: false)
    }
}
