//
//  ViewController.swift
//  ImageFeedTestApp
//
//  Created by Aleksandr Garipov on 08.09.2024.
//

import UIKit

class MainViewController: UIViewController {

    // MARK: - UI Elements

    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Type for search"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()

    // MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        setupUI()
        setupConstraints()
    }
}

// MARK: - Private methods

private extension MainViewController {
    
    func setupUI() {
        view.addSubview(searchBar)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
        ])
    }
}
