//
//  ImageCollectionViewCell.swift
//  ImageFeedTestApp
//
//  Created by Aleksandr Garipov on 08.09.2024.
//

import UIKit

final class ImageCollectionViewCell: UICollectionViewCell {

    // MARK: - UI Elements

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .darkGray
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
        descriptionLabel.text = photoModel.description ?? "No description"
        guard let urlString = photoModel.urls?.small else { return }
        guard let urlImage = URL(string: urlString) else { return }
        setImage(for: imageView, url: urlImage)
    }
}

// MARK: - Private Methods

private extension ImageCollectionViewCell {

    func setupUI() {
        contentView.addSubview(imageView)
        contentView.addSubview(descriptionLabel)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            descriptionLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
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
