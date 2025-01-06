//
//  MovieDetailViewModel.swift
//  Movies
//
//  Created by fulden onan on 5.01.2025.
//

import UIKit

final class MovieDetailViewModel {
    let movie: Movie?
    private let service: MovieService

    private(set) var isFavorite: Bool {
        didSet {
            onFavoriteStatusChanged?(isFavorite)
        }
    }
    
    private(set) var movieDetail: MovieDetail? {
        didSet {
            print("movieDetail changed to \(String(describing: movieDetail))")
            onDetailUpdated?()
        }
    }
    var onDetailUpdated: (() -> Void)?
    var onDetailError: (() -> Void)?
    
    var onImageUploadSuccess: (() -> Void)?
    var onImageUploadFailure: ((Error) -> Void)?
    
    // A callback to notify the outside
    var onFavoriteStatusChanged: ((Bool) -> Void)?
    
    init(movie: Movie, service: MovieService = MovieService()) {
        self.movie = movie
        self.isFavorite = movie.id.flatMap {
            FavoritesManager.shared.isFavorite(movieId: $0)
        } ?? false
        self.service = service
    }
    
    func fetchMovieDetail() {
        guard let movie = movie, let id = movie.id else { return }
        service.fetchMovieDetail(movieId: id) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let detail):
                DispatchQueue.main.async {
                    self.movieDetail = detail
                }
            case .failure(let error):
                print("Error fetching detail: \(error)")
                DispatchQueue.main.async {
                    self.onDetailError?()
                }
            }
        }
    }
    
    // Toggle favorite
    func toggleFavorite() {
        guard let movie = movie, let id = movie.id else { return }
        if isFavorite {
            // Remove from core data
            FavoritesManager.shared.removeFavorite(movieId: id)
            isFavorite = false
        } else {
            // Add to core data
            FavoritesManager.shared.addFavorite(movieId: id)
            isFavorite = true
        }
    }
    
    func uploadPosterImage(_ image: UIImage, titleName: String) {
        guard let resized = image.resizedToMinDimension(600) else {
            let error = NSError(domain: "MovieDetailViewModel",
                                code: 0,
                                userInfo: [NSLocalizedDescriptionKey: "Failed to resize image"])
            onImageUploadFailure?(error)
            return
        }
        
        guard let base64Str = resized.toBase64String() else {
            let error = NSError(domain: "MovieDetailViewModel",
                                code: 1,
                                userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to Base64"])
            onImageUploadFailure?(error)
            return
        }
        
        service.uploadImage(titleName: titleName, base64str: base64Str) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let uploadResponse):
                    if let result = uploadResponse.result, result {
                        self.onImageUploadSuccess?()
                    } else {
                        let error = NSError(domain: "MovieDetailViewModel",
                                            code: 2,
                                            userInfo: [NSLocalizedDescriptionKey: uploadResponse.responseMessage ?? "invalid response"])
                        self.onImageUploadFailure?(error)
                    }
                case .failure(let error):
                    self.onImageUploadFailure?(error)
                }
            }
        }
    }
}
