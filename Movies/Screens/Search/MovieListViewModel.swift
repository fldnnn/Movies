//
//  MovieListViewModel.swift
//  Movies
//
//  Created by fulden onan on 5.01.2025.
//

import Foundation

final class MovieListViewModel {
    // Output
    var movies: [Movie] = []
    var filteredMovies: [Movie] = [] // for search filter
    private var favoriteIds: Set<Int> = []
    
    // Pagination
    private var currentPage: Int = 1
    private var totalPages: Int = 1
    private var isLoading: Bool = false
    
    // Dependencies
    private let service = MovieService()
    
    // A callback property to notify the ViewController when data changes
    var onDataUpdated: (() -> Void)?
    
    init() {
        let ids = FavoritesManager.shared.fetchAllFavoriteMovieIds()
        favoriteIds = Set(ids)
        fetchMovies(page: currentPage)
    }
    
    func updateFavoriteIds(_ newIds: [Int]) {
        self.favoriteIds = Set(newIds)
        onDataUpdated?()
    }
    
    func fetchMovies(page: Int) {
        guard !isLoading else { return }
        isLoading = true
        
        service.fetchPopularMovies(page: page) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            
            switch result {
            case .success(let movieResults):
                if let page = movieResults.page, let totalPages = movieResults.totalPages, let results = movieResults.results {
                    self.currentPage = page
                    self.totalPages = totalPages
                    self.movies.append(contentsOf: results)
                    self.filteredMovies = self.movies
                    DispatchQueue.main.async {
                        self.onDataUpdated?()
                    }
                }
            case .failure(let error):
                print("Error fetching movies: \(error)")
            }
        }
    }
    
    // If user toggles from the detail screen or list screen, update here:
    func updateFavoriteStatus(for movie: Movie, isFavorite: Bool) {
        guard let id = movie.id else { return }
        if isFavorite {
            favoriteIds.insert(id)
        } else {
            favoriteIds.remove(id)
        }
        onDataUpdated?()
    }
    
    // If a movie is favorite
    func isFavorite(movieId: Int) -> Bool {
        return favoriteIds.contains(movieId)
    }
    
    func loadMoreIfNeeded() {
        guard currentPage < totalPages else { return }
        fetchMovies(page: currentPage + 1)
    }
    
    // MARK: - Search
    func searchMovies(with text: String) {
        if text.isEmpty {
            filteredMovies = movies
        } else {
            filteredMovies = movies.filter { movie in
                guard let title = movie.title?.lowercased() else {
                    return false
                }
                return title.contains(text.lowercased())
            }
//            filteredMovies = movies.filter { $0.title!.lowercased().contains(text.lowercased()) }
        }
        onDataUpdated?()
    }
}
