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
    private var suggestionsDataSource: UITableViewDiffableDataSource<Int, String>!
    private var suggestionsTableHeightConstraint: NSLayoutConstraint?

    // MARK: - UI Elements

    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.backgroundImage = UIImage()
        searchBar.delegate = self
        searchBar.placeholder = "Type for search"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()

    private lazy var imageCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createTwoColumnsCompositionalLayout())
        collectionView.register(
            ImageCollectionViewCell.self,
            forCellWithReuseIdentifier: Constants.ReuseIdentifier.imageCellIdentifier
        )
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    private lazy var layoutSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["1 Column", "2 Columns"])
        segmentedControl.selectedSegmentIndex = 1
        segmentedControl.addTarget(self, action: #selector(layoutChanged), for: .valueChanged)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        return segmentedControl
    }()

    private lazy var suggestionsTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SuggestionCell")
        tableView.backgroundColor = .systemBackground
        tableView.delegate = self
        tableView.layer.masksToBounds = true
        tableView.layer.cornerRadius = 10
        tableView.isHidden = true
        return tableView
    }()

    // MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        subscribeToViewModel()
        configureImageCollectionViewDataSource()
        configureSuggestionsDataSource()
    }
}

// MARK: - Private methods

private extension MainViewController {

    func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(searchBar)
        view.addSubview(layoutSegmentedControl)
        view.addSubview(imageCollectionView)
        view.addSubview(suggestionsTableView)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.Layout.padding),
            searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.Layout.padding),
            searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.Layout.padding),

            layoutSegmentedControl.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: Constants.Layout.padding),
            layoutSegmentedControl.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.Layout.segmentedControlInset),
            layoutSegmentedControl.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.Layout.segmentedControlInset),

            imageCollectionView.topAnchor.constraint(equalTo: layoutSegmentedControl.bottomAnchor, constant: Constants.Layout.padding),
            imageCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            suggestionsTableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 5),
            suggestionsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.Layout.segmentedControlInset),
            suggestionsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.Layout.segmentedControlInset),
            suggestionsTableView.heightAnchor.constraint(lessThanOrEqualToConstant: Constants.Layout.maxSuggestionTableHeight)
        ])
        suggestionsTableHeightConstraint = suggestionsTableView.heightAnchor.constraint(equalToConstant: 0)
        suggestionsTableHeightConstraint?.isActive = true
    }

    // MARK: - Binding

    func subscribeToViewModel() {
        viewModel.sectionsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sections in
                self?.updateImageCollectionViewSnapshot(with: sections)
            }
            .store(in: &cancellables)
    }

    // MARK: - Layout Configuration

    func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { [weak self] (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            guard let self = self else { return nil }
            guard let sectionModel = self.viewModel.section(at: sectionIndex) else { return nil }

            let itemHeights = sectionModel.itemHeights

            let items: [NSCollectionLayoutItem] = itemHeights.map { height in
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(height)
                )
                return NSCollectionLayoutItem(layoutSize: itemSize)
            }

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(itemHeights.reduce(0, +))
            )
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: items)

            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = Constants.Layout.padding

            return section
        }
    }

    func createTwoColumnsCompositionalLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in

            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.5),
                heightDimension: .absolute(250)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(250)
            )
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitem: item,
                count: 2
            )

            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = Constants.Layout.padding
            section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)

            return section
        }
    }

    @objc private func layoutChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            imageCollectionView.setCollectionViewLayout(createCompositionalLayout(), animated: true)
        case 1:
            imageCollectionView.setCollectionViewLayout(createTwoColumnsCompositionalLayout(), animated: true)
        default:
            break
        }
    }
}

// MARK: - CollectionViewDiffableDataSource Extension

private extension MainViewController {

    func configureImageCollectionViewDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Int, PhotoModel>(collectionView: imageCollectionView) { (collectionView, indexPath, photoModel) -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: Constants.ReuseIdentifier.imageCellIdentifier,
                for: indexPath
            ) as? ImageCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: photoModel)
            return cell
        }
    }

    func updateImageCollectionViewSnapshot(with sections: [SectionModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, PhotoModel>()
        for (sectionIndex, section) in sections.enumerated() {
            snapshot.appendSections([sectionIndex])
            snapshot.appendItems(section.items)
        }
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - SearchBarDelegate

extension MainViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.searchText = searchText

        let filteredHistory: [String]
        if searchText.isEmpty {
            filteredHistory = viewModel.searchHistory
        } else {
            filteredHistory = viewModel.searchHistory.filter { $0.lowercased().contains(searchText.lowercased()) }
        }

        updateSuggestionsSnapshot(with: filteredHistory)

        suggestionsTableView.isHidden = filteredHistory.isEmpty
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        let history = viewModel.searchHistory
        updateSuggestionsSnapshot(with: history)

        suggestionsTableView.isHidden = history.isEmpty
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text, !query.isEmpty else {
            searchBar.resignFirstResponder()
            return
        }
        viewModel.searchButtonTapped()
        searchBar.resignFirstResponder()
    }
}

// MARK: - TableViewDiffableDataSource Extension

private extension MainViewController {

    func configureSuggestionsDataSource() {
        suggestionsDataSource = UITableViewDiffableDataSource<Int, String>(tableView: suggestionsTableView) { (tableView, indexPath, suggestion) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(
                withIdentifier: Constants.ReuseIdentifier.suggestionCellIdentifier,
                for: indexPath
            )
            cell.textLabel?.text = suggestion
            return cell
        }
    }

    func updateSuggestionsSnapshot(with suggestions: [String]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, String>()
        snapshot.appendSections([0])
        snapshot.appendItems(suggestions)

        suggestionsDataSource.apply(snapshot, animatingDifferences: true)

        let rowHeight: CGFloat = Constants.Layout.rowHeight
        let maxHeight: CGFloat = Constants.Layout.maxSuggestionTableHeight
        let totalHeight = min(CGFloat(suggestions.count) * rowHeight, maxHeight)

        suggestionsTableHeightConstraint?.constant = totalHeight

        suggestionsTableView.isHidden = suggestions.isEmpty
    }
}


extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let suggestion = suggestionsDataSource.itemIdentifier(for: indexPath) else { return }

        searchBar.text = suggestion

        suggestionsTableView.isHidden = true

        viewModel.searchText = suggestion
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
