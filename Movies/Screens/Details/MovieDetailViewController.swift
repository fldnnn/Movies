//
//  MovieDetailViewController.swift
//  Movies
//
//  Created by fulden onan on 5.01.2025.
//

import UIKit

class MovieDetailViewController: UIViewController {
    
    private let viewModel: MovieDetailViewModel
    
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let titleLabelName = UILabel()
    private let titleLabelVoteCount = UILabel()
    
    private let loadingView = LoadingView()
    
    private lazy var favoriteButton: UIBarButtonItem = {
        let barButton = UIBarButtonItem(image: nil,
                                        style: .plain,
                                        target: self,
                                        action: #selector(favoriteButtonTapped))
        return barButton
    }()
 
//    private let uploadIndicator = UIActivityIndicatorView(style: .large)
    
    init(viewModel: MovieDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        title = "Detail"
        navigationItem.rightBarButtonItem = favoriteButton
        updateStarButton()
        
        setupUI()
        //        configure()
        showLoading(true)
        setupCallbacks()
        viewModel.fetchMovieDetail()
    }
    
    private func setupUI() {
        imageView.contentMode = .scaleAspectFit //.scaleAspectFill
        imageView.clipsToBounds = true
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        
        titleLabelName.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabelName.numberOfLines = 0
        titleLabelName.textAlignment = .center
        
        titleLabelVoteCount.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabelVoteCount.numberOfLines = 0
        titleLabelVoteCount.textAlignment = .left
        
        view.addSubview(imageView)
        view.addSubview(titleLabel)
        view.addSubview(titleLabelName)
        view.addSubview(titleLabelVoteCount)
        view.addSubview(loadingView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabelName.translatesAutoresizingMaskIntoConstraints = false
        titleLabelVoteCount.translatesAutoresizingMaskIntoConstraints = false
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        
        loadingView.isHidden = true

        titleLabel.text = ""
        titleLabelName.text = ""
        titleLabelVoteCount.text = ""
        titleLabel.textColor = .black
        titleLabelName.textColor = .black
        titleLabelVoteCount.textColor = .black
        
        NSLayoutConstraint.activate([
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            loadingView.leftAnchor.constraint(equalTo: view.leftAnchor),
            loadingView.rightAnchor.constraint(equalTo: view.rightAnchor),
            
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            imageView.leftAnchor.constraint(equalTo: view.leftAnchor),
            imageView.rightAnchor.constraint(equalTo: view.rightAnchor),
            imageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4),
            
            titleLabelName.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            titleLabelName.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            titleLabelName.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            
            
            titleLabel.topAnchor.constraint(equalTo: titleLabelName.bottomAnchor, constant: 8),
            titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            titleLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            
            titleLabelVoteCount.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            titleLabelVoteCount.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            titleLabelVoteCount.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            titleLabelVoteCount.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
            
        ])
        
//        view.addSubview(uploadIndicator)
//        uploadIndicator.center = view.center
//        uploadIndicator.hidesWhenStopped = true
    }
    
    private func configure() {
        let movie = viewModel.movieDetail //.movie
        
        titleLabel.text = movie?.overview
        titleLabelName.text = movie?.title
        if let voteCount = movie?.voteCount {
            titleLabelVoteCount.text = "Voted: \(voteCount)"
        }
        if let posterPath = movie?.posterPath {
            ImageLoader.shared.loadImage(from: posterPath) { [weak self] image in
                guard let self = self else { return }
                self.imageView.image = image
            }
        }
    }
    
    private func setupCallbacks() {
        viewModel.onDetailUpdated = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.showLoading(false)
                self.configure()
            }
        }
        
        viewModel.onDetailError = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.showLoading(false)
            }
        }

        viewModel.onFavoriteStatusChanged = { [weak self] isFavorite in
            guard let self = self else { return }
            self.updateStarButton()
        }
        
        // Can be used for when upload is finished
//        viewModel.onImageUploadSuccess = { [weak self] in
//            guard let self = self else { return }
//            self.uploadIndicator.stopAnimating()
//            // Show success alert or toast
//            let alert = UIAlertController(title: "Upload Success",
//                                          message: "The poster was uploaded!",
//                                          preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .default))
//            self.present(alert, animated: true)
//        }
//        viewModel.onImageUploadFailure = { [weak self] error in
//            guard let self = self else { return }
//            self.uploadIndicator.stopAnimating()
//            // Show error
//            let alert = UIAlertController(title: "Upload Failed",
//                                          message: error.localizedDescription,
//                                          preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .default))
//            self.present(alert, animated: true)
//        }
    }
    
    private func updateStarButton() {
        let imageName = viewModel.isFavorite ? "star.fill" : "star"
        favoriteButton.image = UIImage(systemName: imageName)
    }
    
    @objc private func favoriteButtonTapped() {
        viewModel.toggleFavorite()
        
        guard let posterImg = imageView.image else { return }
        let titleName = viewModel.movieDetail?.title ?? "Unknown Title"
//        uploadIndicator.startAnimating()
        viewModel.uploadPosterImage(posterImg, titleName: titleName)
    }
    
    private func showLoading(_ show: Bool) {
        if show {
            loadingView.startAnimating()
        } else {
            loadingView.stopAnimating()
        }
    }
}
