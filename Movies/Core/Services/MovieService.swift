//
//  MovieService.swift
//  Movies
//
//  Created by fulden onan on 5.01.2025.
//

import Foundation
import Combine

final class MovieService {
    private let session = URLSession.shared
    private let popularMovieUrl = Bundle.main.infoDictionary?["MOVIES_API_URL"] as? String
    
    func fetchPopularMovies(page: Int) -> AnyPublisher<MovieResults, Error> {
        guard let popularMovieUrl = popularMovieUrl, var urlComponents = URLComponents(string: popularMovieUrl), let token = KeychainManager.load(key: .token) else { return Fail(error: URLError(.badURL)).eraseToAnyPublisher() }
        
        urlComponents.queryItems = [ URLQueryItem(name: "page", value: "\(page)") ]
        
        guard let url = urlComponents.url else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        return session.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                if let httpResponse = response as? HTTPURLResponse,
                   !(200...299).contains(httpResponse.statusCode) {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: MovieResults.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
       
    func fetchMovieDetail(movieId: Int, completion: @escaping (Result<MovieDetail, Error>) -> Void) {
        guard let url = URL(string: "https://api.themoviedb.org/3/movie/\(movieId)"), let token = KeychainManager.load(key: .token) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                // create a custom error
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(MovieDetail.self, from: data)
                completion(.success(decoded))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    func uploadImage(titleName: String,
                     base64str: String,
                     completion: @escaping (Result<UploadResponse, Error>) -> Void) {
        
        let urlString = "https://www.nftcalculatorsapp.net/text_to_image_case_study"
        guard let url = URL(string: urlString) else {
            let error = NSError(domain: "MovieService",
                                code: 1,
                                userInfo: [NSLocalizedDescriptionKey: "Invalid upload URL"])
            completion(.failure(error))
            return
        }
        
        let requestBody: [String: Any] = [
            "prompt": titleName,
            "base64str": base64str,
            "inputImage": false
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            let error = NSError(domain: "MovieService",
                                code: 2,
                                userInfo: [NSLocalizedDescriptionKey: "Failed to encode JSON."])
            completion(.failure(error))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                let error = NSError(domain: "MovieService",
                                    code: 3,
                                    userInfo: [NSLocalizedDescriptionKey: "No data in response."])
                completion(.failure(error))
                return
            }
            do {
                let decoded = try JSONDecoder().decode(UploadResponse.self, from: data)
                completion(.success(decoded))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
