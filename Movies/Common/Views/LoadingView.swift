//
//  LoadingView.swift
//  Movies
//
//  Created by fulden onan on 5.01.2025.
//

import UIKit

class LoadingView: UIView {
    private let spinner: UIActivityIndicatorView = {
        let activity = UIActivityIndicatorView(style: .large)
        activity.color = .white
        activity.hidesWhenStopped = true
        return activity
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        backgroundColor = UIColor.black.withAlphaComponent(0.4)

        addSubview(spinner)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    func startAnimating() {
        spinner.startAnimating()
        isHidden = false
    }

    func stopAnimating() {
        spinner.stopAnimating()
        isHidden = true
    }
}
