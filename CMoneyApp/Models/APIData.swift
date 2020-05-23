//
//  APIData.swift
//  CMoneyApp
//
//  Created by Penny Huang on 2020/5/18.
//  Copyright © 2020 Penny Huang. All rights reserved.
//

import UIKit

struct APIData: Decodable {
    let id: Int
    let title: String
    let thumbnailUrl: String
}

enum NetworkError: Error {
    case invalidUrl
    case requestFailed(Error)
    case invalidResponse
    case invalidData
    case decodingError
}

struct APIController {
    static let shared = APIController()
    
    func fetchAPIData(completion: @escaping(Result<[APIData], NetworkError>) -> ()) {
        let urlStr = "https://jsonplaceholder.typicode.com/photos"
        guard let url = URL(string: urlStr) else {
            completion(.failure(.invalidUrl))
            return
        }
        
            URLSession.shared.dataTask(with: url) {data, response, error in
                if let error = error {
                    completion(.failure(.requestFailed(error)))
                }
                
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    completion(.failure(.invalidResponse))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(.invalidData))
                    return
                }
      
                do {
                    let apiData = try JSONDecoder().decode([APIData].self, from: data)
                    completion(.success(apiData))
                } catch {
                    completion(.failure(.decodingError))
                }

            }.resume()
        
    }
    
    func fetchImage(_ imageUrl: String, completion: @escaping(Result<UIImage, NetworkError>) -> () ) {
        let urlStr = imageUrl
        guard let url = URL(string: urlStr) else {
            completion(.failure(.invalidUrl))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let error = error {
                    completion(.failure(.requestFailed(error)))
            }
                
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(.invalidResponse))
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                completion(.failure(.invalidData))
                return
            }
            completion(.success(image))
                
        }.resume()
        
    }
    
    // MARK: - Test API data
    func testGetData(completion: ([APIData]?) -> ()) {
        guard let data = NSDataAsset(name: "response")?.data else {
           print("data not exist")
           return
        }
        do {
           let decoder = JSONDecoder()
           let result = try decoder.decode([APIData].self, from: data)
            completion(result)
           print(result)
        } catch  {
            completion(nil)
           print(error)
        }
    }
    
}
