//
//  MonitorsService.swift
//  Monitors
//
//  Created by Benjamin Shabowski on 5/12/24.
//

import Foundation

struct MonitorsService {
    private static let BASE_URL = "http://localhost:8080"
    
    public static func getMonitorsWithStatus(completion: @escaping (Result<[MonitorStatus], Error>) -> Void) {
        let url = URL(string: "\(BASE_URL)/monitors?include-status=true")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            do {
                let decodedData = try JSONDecoder().decode([MonitorStatus].self, from: data)
                completion(.success(decodedData))
           } catch {
               completion(.failure(error))
               return
           }
        }.resume()
    }
    
    public static func getMonitorHistory(id: Int, completion: @escaping (Result<[Status], Error>) -> Void) {
        let url = URL(string: "\(BASE_URL)/monitors/\(id)/history?condensed=true")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            do {
                let decodedData = try JSONDecoder().decode([Status].self, from: data)
                completion(.success(decodedData))
           } catch {
               completion(.failure(error))
               return
           }
        }.resume()
    }
    
    public static func testMonitor(monitorData: MonitorData, completion: @escaping (Result<MonitorCreationResult, Error>) -> Void) {
        let url = URL(string: "\(BASE_URL)/monitors/test")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(monitorData)
            request.httpBody = jsonData
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            do {
                print(data)
                let decodedData = try JSONDecoder().decode(MonitorCreationResult.self, from: data)
                completion(.success(decodedData))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    public static func updateMonitor(monitorData: MonitorStatus, completion: @escaping (Result<MonitorStatus, Error>) -> Void) {
        let url = URL(string: "\(BASE_URL)/monitors/\(monitorData.id)")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(monitorData)
            request.httpBody = jsonData
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            do {
                print(data)
                let decodedData = try JSONDecoder().decode(MonitorStatus.self, from: data)
                completion(.success(decodedData))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    public static func createMonitor(monitorData: MonitorStatus, completion: @escaping (Result<MonitorStatus, Error>) -> Void) {
        let url = URL(string: "\(BASE_URL)/monitors/\(monitorData.id)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(monitorData)
            request.httpBody = jsonData
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            do {
                print(data)
                let decodedData = try JSONDecoder().decode(MonitorStatus.self, from: data)
                completion(.success(decodedData))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
