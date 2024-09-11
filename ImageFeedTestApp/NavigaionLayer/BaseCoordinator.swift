//
//  BaseCoordinator.swift
//  ImageFeedTestApp
//
//  Created by Aleksandr Garipov on 11.09.2024.
//

import UIKit

class BaseCoordinator: CoordinatorProtocol {
    var type: CoordinatorType
    var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    var childCoordinators: [CoordinatorProtocol]

    init(
        type: CoordinatorType,
        finishDelegate: CoordinatorFinishDelegate? = nil,
        navigationController: UINavigationController,
        childCoordinators: [CoordinatorProtocol] = [CoordinatorProtocol]()
    ) {
        self.type = type
        self.finishDelegate = finishDelegate
        self.navigationController = navigationController
        self.childCoordinators = childCoordinators
    }

    deinit {
        childCoordinators.forEach { $0.finishDelegate = nil }
        childCoordinators.removeAll()
    }

    func start() {
        print("Coordinator start")
    }

    func finish() {
        print("Coordinator finish")
    }
}
