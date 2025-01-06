//
//  FavoritesCoordinator.swift
//  Movies
//
//  Created by fulden onan on 5.01.2025.
//

import UIKit

class FavoritesCoordinator {
    private let navigationController: UINavigationController
    private let favoritesViewModel = FavoritesViewModel()

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let favoritesVC = FavoritesViewController(viewModel: favoritesViewModel)
        favoritesVC.onFavoriteSelected = { [weak self] movie in
            guard let self = self else { return }
            self.showDetail(for: movie)
        }
        navigationController.pushViewController(favoritesVC, animated: false)
    }

    private func showDetail(for movie: Movie) {
        let detailVM = MovieDetailViewModel(movie: movie)

        detailVM.onFavoriteStatusChanged = { [weak self] isFav in
            guard let self = self else { return }
            self.favoritesViewModel.updateFavoriteStatus(for: movie, isFavorite: isFav)
        }

        let detailVC = MovieDetailViewController(viewModel: detailVM)
        navigationController.pushViewController(detailVC, animated: true)
    }
}
