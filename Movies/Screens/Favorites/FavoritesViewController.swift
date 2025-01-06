//
//  FavoritesViewController.swift
//  Movies
//
//  Created by fulden onan on 5.01.2025.
//

import UIKit

class FavoritesViewController: UIViewController {
    private let viewModel: FavoritesViewModel
    
    // Callback for coordinator
    var onFavoriteSelected: ((Movie) -> Void)?
    
    private lazy var collectionView: UICollectionView = {
        let layout = makeTwoColumnLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(MovieCell.self, forCellWithReuseIdentifier: MovieCell.reuseIdentifier)
        
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    init(viewModel: FavoritesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.loadFavorites()
    }
    
    private func makeTwoColumnLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        let spacing: CGFloat = 8

        let screenWidth = UIScreen.main.bounds.width
        let itemWidth = (screenWidth - (3 * spacing)) / 2  // 2 columns => 3 spacings
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth * 1.4)
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        
        return layout
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Favorites"
        view.backgroundColor = .systemBackground
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        viewModel.onDataUpdated = { [weak self] in
            guard let self = self else { return }
            self.collectionView.reloadData()
        }
    }
}

extension FavoritesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.favorites.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MovieCell.reuseIdentifier,
            for: indexPath
        ) as? MovieCell else {
            return UICollectionViewCell()
        }
        
        let movie = viewModel.favorites[indexPath.row]
        cell.configure(with: movie, isFavorite: true, at: indexPath)
        return cell
    }
}

extension FavoritesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movie = viewModel.favorites[indexPath.row]
        onFavoriteSelected?(movie)
    }
}
