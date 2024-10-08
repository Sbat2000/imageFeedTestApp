//
//  DetailViewController.swift
//  ImageFeedTestApp
//
//  Created by Aleksandr Garipov on 11.09.2024.
//

import UIKit
import Combine

class DetailViewController: UIViewController {

    // MARK: - Properties

    private var viewModel: DetailViewModelProtocol
    private var cancellables = Set<AnyCancellable>()

    // MARK: - UI Elements

    private lazy var polaroidView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 10
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.3
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 6
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var authorInfoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .systemGray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .red
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = LocalizableStrings.imageLoadFailed
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.isEnabled = false
        button.setTitleColor(.systemIndigo, for: .normal)
        button.setTitleColor(.lightGray, for: .disabled)
        button.setTitle(LocalizableStrings.saveImage, for: .normal)
        button.addTarget(self, action: #selector(saveImageTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.isEnabled = false
        button.setTitleColor(.systemIndigo, for: .normal)
        button.setTitleColor(.lightGray, for: .disabled)
        button.setTitle(LocalizableStrings.shareImage, for: .normal)
        button.addTarget(self, action: #selector(shareImageTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        bindViewModel()
        viewModel.loadContent()
    }

    init(viewModel: DetailViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private Methods
    private func setupUI() {
        navigationController?.navigationBar.tintColor = .systemGray
        view.backgroundColor = .systemBackground
        view.addSubview(polaroidView)
        polaroidView.addSubview(photoImageView)
        polaroidView.addSubview(descriptionLabel)
        polaroidView.addSubview(authorInfoLabel)
        polaroidView.addSubview(activityIndicator)
        polaroidView.addSubview(errorLabel)
        view.addSubview(saveButton)
        view.addSubview(shareButton)

        descriptionLabel.text = viewModel.descriptionText
        authorInfoLabel.text = viewModel.authorInfoText
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            polaroidView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.Layout.padding),
            polaroidView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.Layout.padding),
            polaroidView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.Layout.padding),
            polaroidView.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -Constants.Layout.DetailView.buttonBottomPadding),

            photoImageView.topAnchor.constraint(equalTo: polaroidView.topAnchor, constant: Constants.Layout.DetailView.polaroidPadding),
            photoImageView.leadingAnchor.constraint(equalTo: polaroidView.leadingAnchor, constant: Constants.Layout.DetailView.polaroidPadding),
            photoImageView.trailingAnchor.constraint(equalTo: polaroidView.trailingAnchor, constant: -Constants.Layout.DetailView.polaroidPadding),
            photoImageView.heightAnchor.constraint(equalTo: polaroidView.heightAnchor, multiplier: Constants.Layout.imageMultiplier),

            descriptionLabel.topAnchor.constraint(equalTo: photoImageView.bottomAnchor, constant: Constants.Layout.imageCellPadding),
            descriptionLabel.leadingAnchor.constraint(equalTo: polaroidView.leadingAnchor, constant: Constants.Layout.imageCellPadding),
            descriptionLabel.trailingAnchor.constraint(equalTo: polaroidView.trailingAnchor, constant: -Constants.Layout.imageCellPadding),

            authorInfoLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: Constants.Layout.imageCellPadding),
            authorInfoLabel.leadingAnchor.constraint(equalTo: polaroidView.leadingAnchor, constant: Constants.Layout.imageCellPadding),
            authorInfoLabel.trailingAnchor.constraint(equalTo: polaroidView.trailingAnchor, constant: -Constants.Layout.imageCellPadding),
            authorInfoLabel.bottomAnchor.constraint(equalTo: polaroidView.bottomAnchor, constant: -Constants.Layout.imageCellPadding),

            activityIndicator.centerXAnchor.constraint(equalTo: polaroidView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: polaroidView.centerYAnchor),

            errorLabel.centerXAnchor.constraint(equalTo: polaroidView.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: polaroidView.centerYAnchor),

            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.Layout.DetailView.buttonSidePadding),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.Layout.DetailView.buttonBottomPadding),

            shareButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.Layout.DetailView.buttonSidePadding),
            shareButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.Layout.DetailView.buttonBottomPadding)
        ])
    }
    private func bindViewModel() {
        viewModel.statePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.updateView(for: state)
            }
            .store(in: &cancellables)
    }

    private func updateView(for state: DetailViewState) {
        switch state {
        case .loading:
            activityIndicator.startAnimating()
            photoImageView.isHidden = true
            errorLabel.isHidden = true
            saveButton.isEnabled = false
            shareButton.isEnabled = false
        case .content(let image):
            activityIndicator.stopAnimating()
            photoImageView.image = image
            photoImageView.isHidden = false
            errorLabel.isHidden = true
            saveButton.isEnabled = true
            shareButton.isEnabled = true
        case .error(let errorMessage):
            activityIndicator.stopAnimating()
            photoImageView.isHidden = true
            errorLabel.isHidden = false
            errorLabel.text = errorMessage
            saveButton.isEnabled = false
            shareButton.isEnabled = false
        }
    }

    // MARK: - Actions

    @objc private func saveImageTapped() {
        guard let image = photoImageView.image else { return }
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        let alert = UIAlertController(title: nil, message: error == nil ? LocalizableStrings.imageSavedSuccessfully : LocalizableStrings.failedSaveImage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @objc private func shareImageTapped() {
        guard let image = photoImageView.image else { return }
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(activityVC, animated: true, completion: nil)
    }
}
