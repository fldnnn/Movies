//
//  Movie.swift
//  Movies
//
//  Created by fulden onan on 5.01.2025.
//

import Foundation

struct Movie: Decodable {
    let id: Int?
    let title: String?
    let posterPath: String?

    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case posterPath = "poster_path"
    }
}
struct MovieResults: Decodable {
    let page: Int?
    let results: [Movie]?
    let totalPages: Int?

    private enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
    }
}
