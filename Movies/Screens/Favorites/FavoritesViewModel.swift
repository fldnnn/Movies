//
//  FavoritesViewModel.swift
//  Movies
//
//  Created by fulden onan on 5.01.2025.
//

import Foundation

final class FavoritesViewModel {
    private let service = MovieService()

    var favorites: [Movie] = [] {
        didSet {
            onDataUpdated?()
        }
    }
    
    // A callback to notify the VC
    var onDataUpdated: (() -> Void)?
    
    init() {
        loadFavorites()
    }
    
    func loadFavorites() {
        let ids = FavoritesManager.shared.fetchAllFavoriteMovieIds()
        var temp: [Movie] = []
        let group = DispatchGroup()
        
        for id in ids {
            group.enter()
            service.fetchMovieDetail(movieId: id) { result in
                switch result {
                case .success(let movieDetail):
                    let movie = Movie(id: movieDetail.id!,
                                      title: movieDetail.title!,
                                      posterPath: movieDetail.posterPath)
                    temp.append(movie)
                case .failure(let error):
                    print("Failed to fetch detail for \(id): \(error)")
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            self.favorites = temp
        }
    }
    
    func updateFavoriteStatus(for movie: Movie, isFavorite: Bool) {
        if !isFavorite {
            // remove from local array
            favorites.removeAll { $0.id == movie.id }
        } else {
            favorites.append(movie)
        }
    }
}
