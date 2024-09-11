//
//  CoordinatorProtocol.swift
//  ImageFeedTestApp
//
//  Created by Aleksandr Garipov on 11.09.2024.
//

import UIKit

enum CoordinatorType {
    case app
    case main
    case detail
}

protocol CoordinatorFinishDelegate: AnyObject {
    func didFinish(_ coordinator: CoordinatorProtocol)
}

protocol CoordinatorProtocol: AnyObject {
    var type: CoordinatorType { get }
    var finishDelegate: CoordinatorFinishDelegate? { get set }
    var navigationController: UINavigationController { get set }
    var childCoordinators: [CoordinatorProtocol] { get set }

    func start()
    func finish()
}

extension CoordinatorProtocol {

    func addChild(_ coordinator: CoordinatorProtocol) {
        childCoordinators.append(coordinator)
    }

    func removeChild(_ coordinator: CoordinatorProtocol) {
        childCoordinators = childCoordinators.filter { $0 !== coordinator }
    }
}
