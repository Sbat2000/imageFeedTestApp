//
//  DetailViewModel.swift
//  ImageFeedTestApp
//
//  Created by Aleksandr Garipov on 11.09.2024.
//

import UIKit
import Combine

enum DetailViewState {
    case loading
    case content(UIImage)
    case error(String)
}

protocol DetailViewModelProtocol {
    var statePublisher: Published<DetailViewState>.Publisher { get }
    var descriptionText: String { get }
    var authorInfoText: String { get }
    func loadContent()
}

final class DetailViewModel: DetailViewModelProtocol {
    private let photo: PhotoModel

    @Published private(set) var state: DetailViewState = .loading

    var statePublisher: Published<DetailViewState>.Publisher { $state }

    init(photo: PhotoModel) {
        self.photo = photo
    }

    var descriptionText: String {
        return photo.description ?? LocalizableStrings.noDescription
    }

    var authorInfoText: String {
        let username = photo.user.username ?? LocalizableStrings.unknownAuthor
        let location = photo.user.location ?? LocalizableStrings.unknownLocation
        return "\(LocalizableStrings.photoBy) \(username) \(LocalizableStrings.from)  \(location)"
    }

    func loadContent() {
        guard let urlString = photo.urls?.full, let url = URL(string: urlString) else {
            state = .error("Invalid URL")
            return
        }

        Task {
            do {
                let image = try await ImageLoaderService.shared.loadImage(from: url)
                state = .content(image)
            } catch {
                state = .error("Failed to load image")
            }
        }
    }
}
