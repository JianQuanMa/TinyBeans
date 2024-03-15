//
//  RemoteMovies.swift
//  TinyBeans
//
//  Created by Jian Ma on 3/15/24.
//

import Foundation

import Foundation

struct RemoteMovieRoot: Decodable {
    let page: Int
    let results: [RemoteMovie]
    let totalPages, totalResults: Int

}

struct RemoteMovie: Decodable {
    let adult: Bool
    let backdropPath: String?
    let genreIDS: [Int]?
    let id: Int
    let originalLanguage, originalTitle, overview: String
    let posterPath, releaseDate, title: String
    let voteCount: Int
    
    static let mockFromBundle: RemoteMovie = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let root: RemoteMovieRoot? = loadJson(fileName: "RemoteMovies+Mock", decoder: decoder)
        
        return root!.results.randomElement()!
    }()
}
