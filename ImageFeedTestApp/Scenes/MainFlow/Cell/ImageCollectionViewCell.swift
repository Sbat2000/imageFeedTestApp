//
//  ImageCollectionViewCell.swift
//  ImageFeedTestApp
//
//  Created by Aleksandr Garipov on 08.09.2024.
//

import UIKit

final class ImageCollectionViewCell: UICollectionViewCell {

    // MARK: - Enum State

    enum CellState {
        case loading
        case content(UIImage)
        case error(String)
    }

    // MARK: - Properties

    private var currentState: CellState = .loading
    private var currentTask: Task<Void, Never>?
    private var currentImageURL: URL?

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

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .red
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
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

        guard let urlString = photoModel.urls?.small, let url = URL(string: urlString) else {
            updateState(.error("Invalid image URL"))
            return
        }

        if currentImageURL != url {
            currentTask?.cancel()
            currentImageURL = url
            imageView.image = nil
            updateState(.loading)
            setImage(for: imageView, url: url)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        currentTask?.cancel()
        currentTask = nil
        currentImageURL = nil
        imageView.image = nil
        updateState(.loading)
    }

    // MARK: - State Update

    private func updateState(_ state: CellState) {
        currentState = state
        switch state {
        case .loading:
            activityIndicator.startAnimating()
            imageView.isHidden = true
            errorLabel.isHidden = true
            descriptionLabel.isHidden = true

        case .content(let image):
            activityIndicator.stopAnimating()
            imageView.image = image
            imageView.isHidden = false
            errorLabel.isHidden = true
            descriptionLabel.isHidden = false

        case .error(let message):
            activityIndicator.stopAnimating()
            imageView.isHidden = true
            errorLabel.text = message
            errorLabel.isHidden = false
            descriptionLabel.isHidden = true
        }
    }
}

// MARK: - Private Methods

private extension ImageCollectionViewCell {

    func setupUI() {
        contentView.addSubview(polaroidView)
        polaroidView.addSubview(imageView)
        polaroidView.addSubview(descriptionLabel)
        polaroidView.addSubview(activityIndicator)
        polaroidView.addSubview(errorLabel)
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
            descriptionLabel.bottomAnchor.constraint(equalTo: polaroidView.bottomAnchor, constant: -Constants.Layout.imageCellPadding),

            activityIndicator.centerXAnchor.constraint(equalTo: polaroidView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: polaroidView.centerYAnchor),

            errorLabel.centerXAnchor.constraint(equalTo: polaroidView.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: polaroidView.centerYAnchor)
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
                updateState(.content(image))
            } catch {
                updateState(.error("Failed to load image"))
            }
        }
    }
}
