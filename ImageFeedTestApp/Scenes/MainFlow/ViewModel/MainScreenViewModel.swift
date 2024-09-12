//
//  MainScreenViewModel.swift
//  ImageFeedTestApp
//
//  Created by Aleksandr Garipov on 08.09.2024.
//

import UIKit

struct SectionModel {
    var items: [PhotoModel]
    var itemHeights: [CGFloat]
}

enum MainViewState {
    case idle
    case loading
    case loadingMore
    case content([SectionModel])
    case error(String)
}

// MARK: - MainViewModelProtocol

protocol MainScreenViewModelProtocol {
    var statePublisher: Published<MainViewState>.Publisher { get }
    var searchHistory: [String] { get }
    var searchText: String { get set }
    func searchButtonTapped()
    func didSelectPhoto(_ photo: PhotoModel)
    func loadNextPageIfNeeded(currentItemIndex: Int)
    func section(at index: Int) -> SectionModel?
}

final class MainScreenViewModel: MainScreenViewModelProtocol {

    // MARK: - Published Properties

    @Published private(set) var state: MainViewState = .idle
    var statePublisher: Published<MainViewState>.Publisher { $state }

    // MARK: - Public Properties

    var searchText: String = ""
    var searchHistory: [String] = []

    // MARK: - Private Properties

    private let searchService: SearchServiceProtocol
    private let searchHistoryService: SearchHistoryServiceProtocol
    private weak var coordinator: MainCoordinatorProtocol?

    private var currentPage: Int = 1
    private var totalPages: Int = 1
    private var isLoading: Bool = false
    private var sections: [SectionModel] = []

    // MARK: - Life Cycle

    init(
        searchService: SearchServiceProtocol,
        searchHistoryService: SearchHistoryServiceProtocol,
        coordinator: MainCoordinatorProtocol?
    ) {
        self.searchService = searchService
        self.searchHistoryService = searchHistoryService
        self.coordinator = coordinator
        loadSearchHistory()
    }

    // MARK: - Public Methods

    func searchButtonTapped() {
        guard !searchText.isEmpty else { return }

        searchHistoryService.saveSearchQuery(searchText)
        loadSearchHistory()

        currentPage = 1
        sections = []
        state = .loading
        loadData(query: searchText, page: currentPage)
    }

    func section(at index: Int) -> SectionModel? {
        guard index < sections.count else { return nil }
        return sections[index]
    }

    func didSelectPhoto(_ photo: PhotoModel) {
        coordinator?.showDetailView(for: photo)
    }

    func loadNextPageIfNeeded(currentItemIndex: Int) {
        guard !isLoading,
              currentPage < totalPages,
              let section = sections.first else { return }

        let thresholdIndex = section.items.count - 5
        if currentItemIndex >= max(0, thresholdIndex) {
            currentPage += 1
            state = .loadingMore
            loadData(query: searchText, page: currentPage)
        }
    }

    // MARK: - Calculate Cell Height

    private func calculateCellHeight(for photo: PhotoModel) -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width - 20
        guard let imageWidth = photo.width, let imageHeight = photo.height else {
            return screenWidth * 0.75
        }

        let aspectRatio = CGFloat(imageHeight) / CGFloat(imageWidth)
        let descriptionHeight = calculateDescriptionHeight(for: photo.description ?? "", width: screenWidth - 20)

        return screenWidth * aspectRatio + descriptionHeight + 15
    }

    private func calculateDescriptionHeight(for text: String, width: CGFloat) -> CGFloat {
        let font = UIFont.systemFont(ofSize: 14)
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = text.boundingRect(
            with: constraintRect,
            options: .usesLineFragmentOrigin,
            attributes: [.font: font],
            context: nil
        )
        return ceil(boundingBox.height)
    }

    //MARK: - Private Methods

    private func loadData(query: String, page: Int) {
        isLoading = true
        state = .loading

        searchService.searchImages(query: query, page: page) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false

            switch result {
            case .success(let searchResult):
                let photoModels = searchResult.results
                
                if searchResult.total == 0 {
                    DispatchQueue.main.async {
                        self.state = .error("\(LocalizableStrings.notFound) \"\(query)\".")
                    }
                    return
                }

                let itemHeights = photoModels.map { self.calculateCellHeight(for: $0) }
                let section = SectionModel(items: photoModels, itemHeights: itemHeights)
                self.totalPages = searchResult.totalPages

                if self.sections.isEmpty {
                    self.sections.append(section)
                } else {
                    self.sections[0].items.append(contentsOf: photoModels)
                    self.sections[0].itemHeights.append(contentsOf: itemHeights)
                }

                DispatchQueue.main.async {
                    self.state = .content(self.sections)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.state = .error(error.localizedDescription)
                }
            }
        }
    }

    private func loadSearchHistory() {
        searchHistory = searchHistoryService.fetchSearchHistory()
    }
}
