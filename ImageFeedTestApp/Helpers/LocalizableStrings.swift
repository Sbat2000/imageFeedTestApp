//
//  LocalizableStrings.swift
//  ImageFeedTestApp
//
//  Created by Aleksandr Garipov on 11.09.2024.
//

import Foundation

struct LocalizableStrings {
    static let searchPlaceholder        = NSLocalizedString("searchPlaceholder", comment: "SearchBar Placeholder")
    static let list                     = NSLocalizedString("list", comment: "Layout segment control switcher")
    static let grid                     = NSLocalizedString("grid", comment: "Layout segment control switcher")
    static let noDescription            = NSLocalizedString("noDescription", comment: "Layout segment control switcher")
    static let imageLoadFailed          = NSLocalizedString("imageLoadFailed", comment: "Load image failed error text")
    static let saveImage                = NSLocalizedString("saveImage", comment: "Save image text")
    static let shareImage               = NSLocalizedString("shareImage", comment: "Share image text")
    static let imageSavedSuccessfully   = NSLocalizedString("imageSavedSuccessfully", comment: "Image save success message")
    static let failedSaveImage          = NSLocalizedString("failedSaveImage", comment: "Image save error message")
    static let unknownAuthor            = NSLocalizedString("unknown", comment: "Unknown author")
    static let unknownLocation          = NSLocalizedString("unknownLocation", comment: "Unknown location")
    static let photoBy                  = NSLocalizedString("photoBy", comment: "Author name")
    static let from                     = NSLocalizedString("from", comment: "From")
}
