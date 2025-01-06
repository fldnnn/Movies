//
//  MovieListViewController.swift
//  Movies
//
//  Created by fulden onan on 5.01.2025.
//

import UIKit

class MovieListViewController: UIViewController {
    private let viewModel: MovieListViewModel

    // Callback for coordinator
    var onMovieSelected: ((Movie) -> Void)?

    // UI
    private lazy var collectionView: UICollectionView = {
        let layout = makeLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.dataSource = self
        cv.delegate = self
//        cv.prefetchDataSource = self
        cv.backgroundColor = .white
        cv.register(MovieCell.self, forCellWithReuseIdentifier: MovieCell.reuseIdentifier)
        cv.register(ListMovieCell.self, forCellWithReuseIdentifier: ListMovieCell.reuseIdentifier)
        return cv
    }()

    private lazy var toggleLayoutButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: .Photos.grid, style: .plain, target: self, action: #selector(toggleLayout))

        return button
    }()

    private let searchController = UISearchController(searchResultsController: nil)

    // Layout mode
    private var isGrid = false

    // MARK: - Init
    init(viewModel: MovieListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // If you prefer to fully reload:
        let ids = FavoritesManager.shared.fetchAllFavoriteMovieIds()
        viewModel.updateFavoriteIds(ids)
        collectionView.reloadData()
    }

    private func setupUI() {
        title = "Movies"
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = toggleLayoutButton

        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        definesPresentationContext = true

        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupBindings() {
        viewModel.onDataUpdated = { [weak self] in
            guard let self = self else { return }
            self.collectionView.reloadData()
        }
    }

    // MARK: - Actions
    @objc private func toggleLayout() {
        isGrid.toggle()
        toggleLayoutButton.image = isGrid ? .Photos.list : .Photos.grid

        collectionView.reloadData()
        collectionView.setCollectionViewLayout(makeLayout(), animated: true)   
    }

    private func makeLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        let spacing: CGFloat = 8

        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)

        let width = UIScreen.main.bounds.width
        if isGrid {
            let itemWidth = (width - (3 * spacing)) / 2
            layout.itemSize = CGSize(width: itemWidth, height: itemWidth * 1.4)
        } else {
            let itemWidth = width - (2 * spacing)
            layout.itemSize = CGSize(width: itemWidth, height: itemWidth * 0.4)
//            let itemWidth = width - (2 * spacing)
//            let itemHeight: CGFloat = 100  // or something for horizontal layout
//            layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        }

        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        return layout
    }
}

// MARK: - UICollectionViewDataSource
extension MovieListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.filteredMovies.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let movie = viewModel.filteredMovies[indexPath.row]
        guard let id = movie.id else { return UICollectionViewCell() }
        let isFav = viewModel.isFavorite(movieId: id)
        if isGrid {
            // Dequeue Grid style cell
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: MovieCell.reuseIdentifier,
                for: indexPath
            ) as? MovieCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: movie, isFavorite: isFav, at: indexPath)
            return cell
        } else {
            // Dequeue List style cell
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ListMovieCell.reuseIdentifier,
                for: indexPath
            ) as? ListMovieCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: movie, isFavorite: isFav, at: indexPath)
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegate
extension MovieListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movie = viewModel.filteredMovies[indexPath.row]
        onMovieSelected?(movie)
    }

    // Load more if near bottom
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height

        if offsetY > contentHeight - frameHeight * 2 {
            viewModel.loadMoreIfNeeded()
        }
    }
}

// MARK: - UISearchResultsUpdating
extension MovieListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        viewModel.searchMovies(with: searchText)
    }
}
