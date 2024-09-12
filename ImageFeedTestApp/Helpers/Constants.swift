//
//  Constants.swift
//  ImageFeedTestApp
//
//  Created by Aleksandr Garipov on 11.09.2024.
//

import Foundation

enum Constants {

    enum Layout {
        static let padding: CGFloat = 10
        static let imageCellPadding: CGFloat = 8
        static let imageMultiplier = 0.75
        static let cornerRadius: CGFloat = 10
        static let rowHeight: CGFloat = 44
        static let maxSuggestionTableHeight: CGFloat = 220
        static let segmentedControlInset: CGFloat = 18

        enum DetailView {
            static let polaroidPadding: CGFloat = 16
            static let buttonBottomPadding: CGFloat = 20
            static let buttonSidePadding: CGFloat = 20
            static let activityIndicatorSize: CGFloat = 50
        }
    }

    enum ReuseIdentifier {
        static let imageCellIdentifier = "ImageCollectionViewCell"
        static let suggestionCellIdentifier = "SuggestionCell"
    }
}
