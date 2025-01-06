//
//  AppCoordinator.swift
//  Movies
//
//  Created by fulden onan on 5.01.2025.
//

import UIKit

class AppCoordinator {
    private var window: UIWindow?
    private let tabBarController = UITabBarController()
    
    private var movieListCoordinator: MovieListCoordinator?
    private var favoritesCoordinator: FavoritesCoordinator?
    
    init(window: UIWindow? = nil) {
        self.window = window
    }
    
    func start() {
        guard let window = window else { return }
        
        let movieListNav = UINavigationController()
        movieListCoordinator = MovieListCoordinator(navigationController: movieListNav)
        guard let movieListCoordinator = movieListCoordinator else { return }
        movieListCoordinator.start()

        movieListNav.tabBarItem = UITabBarItem(title: "Movies",
                                               image: .Photos.house,
                                               selectedImage: nil)

        let favoritesNav = UINavigationController()
        favoritesCoordinator = FavoritesCoordinator(navigationController: favoritesNav)
        guard let favoritesCoordinator = favoritesCoordinator else { return }
        favoritesCoordinator.start()

        favoritesNav.tabBarItem = UITabBarItem(title: "Favorites",
                                               image: .Photos.starFill,
                                               selectedImage: nil)

        tabBarController.viewControllers = [movieListNav, favoritesNav]

        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
}
