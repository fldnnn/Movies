//
//  MovieDetail.swift
//  Movies
//
//  Created by fulden onan on 5.01.2025.
//

import Foundation

struct MovieDetail: Decodable {
    let id: Int?
    let title: String?
    let posterPath: String?
    let overview: String?
    let releaseDate: String?
    let runtime: Int?
    let voteCount: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case posterPath = "poster_path"
        case overview
        case releaseDate = "release_date"
        case runtime
        case voteCount = "vote_count"
    }
}
