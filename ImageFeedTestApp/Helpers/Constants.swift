//
//  Constants.swift
//  ImageFeedTestApp
//
//  Created by Aleksandr Garipov on 11.09.2024.
//

import Foundation

struct Constants {

    struct Layout {
        static let padding: CGFloat = 10
        static let imageCellPadding: CGFloat = 8
        static let imageMultiplier = 0.75
        static let cornerRadius: CGFloat = 10
        static let rowHeight: CGFloat = 44
        static let maxSuggestionTableHeight: CGFloat = 220
        static let segmentedControlInset: CGFloat = 18
    }

        // MARK: - Cells reuseIdentifier

    struct ReuseIdentifier {
        static let imageCellIdentifier = "ImageCollectionViewCell"
        static let suggestionCellIdentifier = "SuggestionCell"
    }
}
