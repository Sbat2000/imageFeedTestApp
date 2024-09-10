//
//  MainScreenViewModel.swift
//  ImageFeedTestApp
//
//  Created by Aleksandr Garipov on 08.09.2024.
//

import UIKit

// MARK: - MainViewModelProtocol

protocol MainScreenViewModelProtocol {
    var sectionsPublisher: Published<[SectionModel]>.Publisher { get }
    var searchText: String { get set }
    func searchButtonTapped()
    func section(at index: Int) -> SectionModel?
}

struct SectionModel {
    let items: [PhotoModel]
    let itemHeights: [CGFloat]
}

// MARK: - ViewModel

final class MainScreenViewModel: MainScreenViewModelProtocol {

    // MARK: - Published Properties

    @Published private var sections: [SectionModel] = []
    var searchText: String = ""

    // MARK: - Properties

    private let searchService: SearchServiceProtocol

    // MARK: - Life Cycle

    init(searchService: SearchServiceProtocol = SearchService(networkClient: DefaultNetworkClient())) {
        self.searchService = searchService
    }

    // MARK: - Public Methods

    var sectionsPublisher: Published<[SectionModel]>.Publisher {
        $sections
    }

    func searchButtonTapped() {
        guard !searchText.isEmpty else { return }
        loadData(query: searchText)
    }

    func section(at index: Int) -> SectionModel? {
        guard index < sections.count else { return nil }
        return sections[index]
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

    //MARK: - private methods

    private func loadData(query: String) {
        searchService.searchImages(query: query, page: 1) { [weak self] result in
            switch result {
            case .success(let searchResult):
                let photoModels = searchResult.results
                let itemHeights = photoModels.map { self?.calculateCellHeight(for: $0) ?? 0 }
                let section = SectionModel(items: photoModels, itemHeights: itemHeights)

                DispatchQueue.main.async {
                    self?.sections = [section]
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
