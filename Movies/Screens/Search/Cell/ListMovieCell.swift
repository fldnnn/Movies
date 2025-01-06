//
//  ListMovieCell.swift
//  Movies
//
//  Created by fulden onan on 5.01.2025.
//

import UIKit

final class ListMovieCell: UICollectionViewCell {
    static let reuseIdentifier = "ListMovieCell"
    private let favoriteIcon = UIImageView(image: UIImage(systemName: "star.fill"))
    private let posterImageView = UIImageView()
    private let titleLabel = UILabel()
    private let separator: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var currentIndexPath: IndexPath?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    required init?(coder: NSCoder) { fatalError() }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        posterImageView.image = nil
    }

    private func setupViews() {
        posterImageView.contentMode = .scaleAspectFill
        posterImageView.layer.cornerRadius = 5.0
        posterImageView.clipsToBounds = true
        posterImageView.layer.masksToBounds = true
        
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.numberOfLines = 2
        
        favoriteIcon.tintColor = .systemBlue
        favoriteIcon.contentMode = .scaleAspectFit
        favoriteIcon.isHidden = true
        
        contentView.addSubview(posterImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(favoriteIcon)
        contentView.addSubview(separator)
        
        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        favoriteIcon.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 4),
            separator.heightAnchor.constraint(equalToConstant: 1),

            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            posterImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            posterImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            posterImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.3),
            
            titleLabel.leftAnchor.constraint(equalTo: posterImageView.rightAnchor, constant: 8),
            titleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -8),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            favoriteIcon.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            favoriteIcon.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -8),
            favoriteIcon.widthAnchor.constraint(equalToConstant: 20),
            favoriteIcon.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    func configure(with movie: Movie, isFavorite: Bool, at indexPath: IndexPath) {
        titleLabel.text = movie.title
        favoriteIcon.tintColor = .systemBlue
        favoriteIcon.isHidden = !isFavorite
        currentIndexPath = indexPath
        posterImageView.image = nil
        
        if let posterPath = movie.posterPath {
            ImageLoader.shared.loadImage(from: posterPath) { [weak self] image in
                guard let self = self else { return }
                if let visibleIndexPath = self.currentIndexPath,
                   visibleIndexPath == indexPath {
                    self.posterImageView.image = image
                }
            }
        } else {
            posterImageView.image = nil
        }
    }
}
