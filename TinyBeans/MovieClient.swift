//
//  MovieClient.swift
//  TinyBeans
//
//  Created by Jian Ma on 3/15/24.
//

import Foundation

let apiKey = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJiYTk4ZTZkMmVkOTA5M2VkMTdmOTAxZDRjYjZlY2QwYiIsInN1YiI6IjY1ZjM5NGU0MjkzODM1MDE4NzI3ZTViNCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.zq0byEknt46vrxrtNZUn5roszXRXIBTeglKp5rBGkTY"

let imageURLPrefix = "https://image.tmdb.org/t/p/original"

struct MovieClient {


    let fetchPopluarList: (_ page: Int) async throws -> RemoteMovieRoot
    let fetchDetailByMovieID: (Int) async throws -> RemoteMovieDetail

    
    static let mock: MovieClient = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        return .init(
            fetchPopluarList: { _ in
                try tryLoadJson(fileName: "RemoteMovies+Mock", decoder: decoder)

//                let root: RemoteMovieRoot? = loadJson(fileName: "RemoteMovies+Mock", decoder: decoder)
//                return root?.results ?? []
            },
            fetchDetailByMovieID: { _ in
                try tryLoadJson(fileName: "RemoteMovieDetail+Mock", decoder: decoder)
            }
        )

    }()
    
    
    static func live(apiKey: String) -> MovieClient {
        let session = URLSession.shared
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return .init(
            fetchPopluarList: { page in
//                throw NSError(domain: "Network failure", code: -1)
//                try await Task.sleep(for: .seconds(2))
//                throw URLError(.badURL)
                print("-=- fetchPopluarList \(page)")
                guard let url = URL(string: "https://api.themoviedb.org/3/movie/popular?language=en-US&page=\(page)") else {
                    throw URLError(.badURL)
                }
                
                var request = URLRequest(url: url)
                request.allHTTPHeaderFields = [
                    "Authorization": "Bearer \(apiKey)",
                    "accept": "application/json"
                ]
                
                let (data, _) = try await session.data(for: request)
                
                return try decoder.decode(RemoteMovieRoot.self, from: data)
            },
            fetchDetailByMovieID: { movieID in
                guard let url = URL(string: "https://api.themoviedb.org/3/movie/\(movieID)?language=en-US") else {
                    throw URLError(.badURL)

                }
                var request = URLRequest(url: url)
                request.allHTTPHeaderFields = [
                    "Authorization": "Bearer \(apiKey)",
                    "accept": "application/json"
                ]
                
                let (data, _) = try await session.data(for: request)

                return try decoder.decode(RemoteMovieDetail.self, from: data)
            }
        )
    }
}


// 94623605
extension Data {
    var prettyPrintedJSONString: NSString? {
        guard let jsonObject = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: jsonObject,
                                                       options: [.prettyPrinted]),
              let prettyJSON = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else {
                  return nil
               }

        return prettyJSON
    }
}
