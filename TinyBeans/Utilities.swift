//
//  Utilities.swift
//  TinyBeans
//
//  Created by Jian Ma on 3/15/24.
//

import Foundation

/*
 
 https://image.tmdb.org/t/p/original

 https://image.tmdb.org/t/p/original/xvk5AhfhgQcTuaCQyq3XqAnhEma.jpg
 xvk5AhfhgQcTuaCQyq3XqAnhEma.jpg
 */
func loadJson<T: Decodable>(
    fileName: String,
    decoder: JSONDecoder
) -> T? {
    guard
        let url = Bundle.main.url(forResource: fileName, withExtension: "json"),
        let data = try? Data(contentsOf: url),
        let person = try? decoder.decode(T.self, from: data)
    else {
        return nil
    }
    
    return person
}


func tryLoadJson<T: Decodable>(
    fileName: String,
    decoder: JSONDecoder
) throws -> T {
    guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
        throw URLError(.badURL)
    }

    return try decoder.decode(
        T.self,
        from: Data(contentsOf: url)
    )
}
