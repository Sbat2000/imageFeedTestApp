//
//  AppCoordinatorProtocol.swift
//  ImageFeedTestApp
//
//  Created by Aleksandr Garipov on 11.09.2024.
//

import UIKit

final class AppCoordinator: BaseCoordinator {

    override func start() {
        showMainFlow()
    }

    override func finish() {
        print("AppCoordinator Finish")
    }
}

private extension AppCoordinator {

    func showMainFlow() {
        let mainCoordinator = MainCoordinator(
            type: .main,
            finishDelegate: self,
            navigationController: navigationController
        )
        addChild(mainCoordinator)
        mainCoordinator.start()
    }
}

extension AppCoordinator: CoordinatorFinishDelegate {
    func didFinish(_ coordinator: CoordinatorProtocol) {
        removeChild(coordinator)
        switch coordinator.type {
        case .main:
            return
        default:
            navigationController.popToRootViewController(animated: false)
        }
    }
}

