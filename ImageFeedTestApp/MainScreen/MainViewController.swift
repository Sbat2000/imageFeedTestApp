//
//  ViewController.swift
//  ImageFeedTestApp
//
//  Created by Aleksandr Garipov on 08.09.2024.
//

import UIKit
import Combine

class MainViewController: UIViewController {

    // MARK: - Properties

    private var viewModel: MainScreenViewModelProtocol = MainScreenViewModel()
    private var cancellables = Set<AnyCancellable>()

    private var dataSource: UICollectionViewDiffableDataSource<Int, PhotoModel>!

    // MARK: - UI Elements

    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Type for search"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()

    private lazy var imageCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createListLayout())
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: "ImageCollectionViewCell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    // MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        subscribeToViewModel()
        configureDataSource()
        viewModel.loadData(query: "dog")
    }
}

// MARK: - Private methods

private extension MainViewController {
    
    func setupUI() {
        view.addSubview(searchBar)
        view.addSubview(imageCollectionView)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),

            imageCollectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            imageCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - Binding

    private func subscribeToViewModel() {
        viewModel.photosPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] photos in
                self?.updateSnapshot(with: photos)
            }
            .store(in: &cancellables)
    }

    // MARK: - Layout Configuration

    private func createListLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        let width = view.bounds.width - 20
        let height = width * 2 / 3
        layout.itemSize = CGSize(width: width, height: height)
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        return layout
    }
}

// MARK: - DiffableDataSource Extension

private extension MainViewController {

    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Int, PhotoModel>(collectionView: imageCollectionView) { (collectionView, indexPath, photoModel) -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as? ImageCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: photoModel)
            return cell
        }
    }

    func updateSnapshot(with photos: [PhotoModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, PhotoModel>()
        snapshot.appendSections([0])
        snapshot.appendItems(photos)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}
