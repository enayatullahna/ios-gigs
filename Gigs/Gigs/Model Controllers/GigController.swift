//
//  GigController.swift
//  Gigs
//
//  Created by Enayatullah Naseri on 6/13/19.
//  Copyright © 2019 Enayatullah Naseri. All rights reserved.
//

import Foundation
import UIKit

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

// error tracking
enum NetworkError: Error {
    case noAuth
    case badAuth
    case otherError
    case badData
    case noDecode
}

class GigController {
    
    private var gigs: [Gig] = []
    var bearer: Bearer?
    let baseURL = URL(string: "https://lambdagigs.vapor.cloud/api")! // forced unrap
    
    
    // Sign up
    func signUp(with user: User, completion: @escaping (Error?) -> ()) {
        // create Endpont URL - endpoint is the location after link
        let singUpURL = self.baseURL.appendingPathComponent("users/signup")
        
        // set up Request
        
        var request = URLRequest(url: singUpURL)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // initialize JSON Encoder
        
        let jsonEncoder = JSONEncoder()
        
        // Encode the data, catch errors
        
        do {
            let jasonData = try jsonEncoder.encode(user)
            request.httpBody = jasonData
        } catch {
            
            NSLog("Error endoder user object: \(error)")
            completion(error)
            return
            
        }
        
        URLSession.shared.dataTask(with: request) { (_, responce, error) in
            if let responce = responce as? HTTPURLResponse,
                responce.statusCode != 200 {
                completion(NSError(domain: "", code: responce.statusCode, userInfo: nil))
                return
            }
            
            if let error = error {
                completion(error)
                return
            }
            
            completion(nil)
            
            }.resume()
    }
    
    // signIn
    func signIn(with user: User, completion: @escaping (Error?) -> ()) {
        
        let loginURL = baseURL.appendingPathComponent("users/login")
        
        var request = URLRequest(url: loginURL)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonEncoder = JSONEncoder()
        do {
            let jasonData = try jsonEncoder.encode(user)
            request.httpBody = jasonData
        } catch {
            
            NSLog("Error endoder user object: \(error)")
            completion(error)
            return
            
        }
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                completion(NSError(domain: "", code: response.statusCode, userInfo: nil))
                return
            }
            
            if let error = error {
                completion(error)
                return
            }
            guard let data = data else {
                completion(nil)
                return
                
            }
            
            let decoder = JSONDecoder()
            
            do {
                self.bearer = try decoder.decode(Bearer.self, from: data)
            } catch {
                NSLog("Error decoding bearer object: \(error)")
            }
            
            completion(nil)
            }.resume()
        
    }
    
    // fetch all gigs
    func fetchAllGigs(completion: @escaping (Result<[String], NetworkError>) -> Void) {
        guard let bearer = self.bearer else {
            completion(.failure(.noAuth))
            return
        }
        
        let allAnimalURL = self.baseURL.appendingPathComponent("gigs")
        
        var request = URLRequest(url: allAnimalURL)
        
        request.httpMethod = HTTPMethod.get.rawValue
        request.addValue("Bearer \(bearer.token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let response = response as? HTTPURLResponse,
                response.statusCode == 401 {
                completion(.failure(.badAuth))
                return
            }
            
            if let _ = error {
                completion(.failure(.otherError))
                return
            }
            guard let data = data else {
                completion(.failure(.badData))
                return
            }
            let decoder = JSONDecoder()
            
            do {
                let anumalNames = try decoder.decode([String].self, from: data)
                completion(.success(anumalNames))
            } catch {
                NSLog("Error decoding animal object: \(error)")
                completion(.failure(.noDecode))
                return
            }
            }.resume()
    }
    
    //Create a gig
    func createAGig(gig: Gig, completion: @escaping (Error?)->Void) {
        
        
        // add .resume()
    }
    
    
    
}
