//
//  UploadResponse.swift
//  Movies
//
//  Created by fulden onan on 5.01.2025.
//

import Foundation

struct UploadResponse: Decodable {
    let result: Bool?
    let responseMessage: String?
    let data: UploadData?
}

struct UploadData: Decodable {
    let base64str: String?
    let title: String?
}
