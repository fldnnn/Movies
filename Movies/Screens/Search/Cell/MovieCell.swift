//
//  MovieCell.swift
//  Movies
//
//  Created by fulden onan on 5.01.2025.
//

import UIKit

final class MovieCell: UICollectionViewCell {
    static let reuseIdentifier = "MovieCell"
    private let movieImageView = UIImageView()
    private let titleLabel = UILabel()
    private let favoriteIcon = UIImageView(image: UIImage(systemName: "star.fill"))

    private var currentIndexPath: IndexPath?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    required init?(coder: NSCoder) { fatalError() }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        movieImageView.image = nil
    }

    private func setupViews() {
        movieImageView.contentMode = .scaleAspectFill 
        movieImageView.clipsToBounds = true
        movieImageView.layer.masksToBounds = true
        movieImageView.layer.cornerRadius = 5

        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .center

        favoriteIcon.tintColor = .systemBlue
        favoriteIcon.contentMode = .scaleAspectFit
        favoriteIcon.isHidden = true

        contentView.addSubview(movieImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(favoriteIcon)
        movieImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        favoriteIcon.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            movieImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            movieImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            movieImageView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            movieImageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.8),

            titleLabel.topAnchor.constraint(equalTo: movieImageView.bottomAnchor, constant: 4),
            titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 4),
            titleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -4),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -4),

            favoriteIcon.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            favoriteIcon.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -8),
            favoriteIcon.widthAnchor.constraint(equalToConstant: 20),
            favoriteIcon.heightAnchor.constraint(equalToConstant: 20)
        ])
    }

    func configure(with movie: Movie, isFavorite: Bool, at indexPath: IndexPath) {
        titleLabel.text = movie.title
        favoriteIcon.isHidden = !isFavorite
        currentIndexPath = indexPath
        movieImageView.image = nil

        if let posterPath = movie.posterPath {
            ImageLoader.shared.loadImage(from: posterPath) { [weak self] image in
                guard let self = self else { return }
                if let visibleIndexPath = self.currentIndexPath,
                   visibleIndexPath == indexPath {
                    self.movieImageView.image = image
                }
            }
        } else {
            movieImageView.image = nil
        }
    }
}
