//
//  MovieListCoordinator.swift
//  Movies
//
//  Created by fulden onan on 5.01.2025.
//

import UIKit

class MovieListCoordinator {
    private let navigationController: UINavigationController
    
    private var listViewModel: MovieListViewModel?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let viewModel = MovieListViewModel()
            self.listViewModel = viewModel

            let listVC = MovieListViewController(viewModel: viewModel)
            listVC.onMovieSelected = { [weak self] movie in
                guard let self = self else { return }
                self.showDetail(for: movie)
            }
            navigationController.pushViewController(listVC, animated: false)
    }

    private func showDetail(for movie: Movie) {
        let detailVM = MovieDetailViewModel(movie: movie)

        detailVM.onFavoriteStatusChanged = { [weak self] isFavorite in
            guard let self = self else { return }
            self.listViewModel?.updateFavoriteStatus(for: movie, isFavorite: isFavorite)
        }

        let detailVC = MovieDetailViewController(viewModel: detailVM)
        navigationController.pushViewController(detailVC, animated: true)
    }
}
