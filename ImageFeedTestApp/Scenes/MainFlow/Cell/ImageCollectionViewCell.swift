//
//  ImageCollectionViewCell.swift
//  ImageFeedTestApp
//
//  Created by Aleksandr Garipov on 08.09.2024.
//

import UIKit

final class ImageCollectionViewCell: UICollectionViewCell {

    // MARK: - UI Elements

    private lazy var polaroidView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 8
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.3
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 6
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .systemGray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public methods

    func configure(with photoModel: PhotoModel) {
        descriptionLabel.text = photoModel.description ?? LocalizableStrings.noDescription
        guard let urlString = photoModel.urls?.small else { return }
        guard let urlImage = URL(string: urlString) else { return }
        setImage(for: imageView, url: urlImage)
    }
}

// MARK: - Private Methods

private extension ImageCollectionViewCell {

    func setupUI() {
        contentView.addSubview(polaroidView)
        polaroidView.addSubview(imageView)
        polaroidView.addSubview(descriptionLabel)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            polaroidView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.Layout.imageCellPadding),
            polaroidView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Layout.imageCellPadding),
            polaroidView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Layout.imageCellPadding),
            polaroidView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.Layout.imageCellPadding),

            imageView.topAnchor.constraint(equalTo: polaroidView.topAnchor, constant: Constants.Layout.imageCellPadding),
            imageView.leadingAnchor.constraint(equalTo: polaroidView.leadingAnchor, constant: Constants.Layout.imageCellPadding),
            imageView.trailingAnchor.constraint(equalTo: polaroidView.trailingAnchor, constant: -Constants.Layout.imageCellPadding),
            imageView.heightAnchor.constraint(equalTo: polaroidView.heightAnchor, multiplier: Constants.Layout.imageMultiplier),

            descriptionLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: Constants.Layout.imageCellPadding),
            descriptionLabel.leadingAnchor.constraint(equalTo: polaroidView.leadingAnchor, constant: Constants.Layout.imageCellPadding),
            descriptionLabel.trailingAnchor.constraint(equalTo: polaroidView.trailingAnchor, constant: -Constants.Layout.imageCellPadding),
            descriptionLabel.bottomAnchor.constraint(equalTo: polaroidView.bottomAnchor, constant: -Constants.Layout.imageCellPadding)
        ])
    }
}

// MARK: load image

private extension ImageCollectionViewCell {

    func loadImage(for url: URL) async throws -> UIImage {
        let urlRequest = URLRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        guard let response = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard response.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        guard let image = UIImage(data: data) else {
            throw URLError(.cannotDecodeContentData)
        }

        return image
    }


    func setImage(for imageView: UIImageView, url: URL) {
        Task {
            do {
                let image = try await loadImage(for: url)
                imageView.image = image
            } catch {
                print(error.localizedDescription)
                imageView.image = nil
            }
        }
    }
}
