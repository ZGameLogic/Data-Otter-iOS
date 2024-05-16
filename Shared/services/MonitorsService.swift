//
//  MonitorsService.swift
//  Monitors
//
//  Created by Benjamin Shabowski on 5/12/24.
//

import Foundation

struct MonitorsService {
    private static let BASE_URL = "http://20.40.218.161:8080"
    
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
    
    public static func getMonitorGroups(completion: @escaping (Result<[MonitorGroup], Error>) -> Void) {
        let url = URL(string: "\(BASE_URL)/groups")!
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
                let decodedData = try JSONDecoder().decode([MonitorGroup].self, from: data)
                completion(.success(decodedData))
           } catch {
               completion(.failure(error))
               return
           }
        }.resume()
    }
    
    public static func getMonitorsWithStatusSyncronous() -> Result<[MonitorStatus], Error> {
        let semaphore = DispatchSemaphore(value: 0)
        var result: Result<[MonitorStatus], Error>!

        getMonitorsWithStatus { asyncResult in
            result = asyncResult
            semaphore.signal()
        }

        semaphore.wait()
        return result
    }

    
    public static func getMonitors(completion: @escaping (Result<[MonitorStatus], Error>) -> Void) {
        let url = URL(string: "\(BASE_URL)/monitors")!
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
    
    public static func getMonitorsSyncronous() -> Result<[MonitorStatus], Error> {
        let semaphore = DispatchSemaphore(value: 0)
        var result: Result<[MonitorStatus], Error>!

        getMonitors { asyncResult in
            result = asyncResult
            semaphore.signal()
        }

        semaphore.wait()
        return result
    }
    
    public static func getMonitorHistory(id: Int, start: Date, end: Date?, condensed: Bool, completion: @escaping (Result<[Status], Error>) -> Void) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
        let formattedStartDate = dateFormatter.string(from: start)
        
        var urlComponents = URLComponents(string: "\(BASE_URL)/monitors/\(id)/history")!
        urlComponents.queryItems = [
            URLQueryItem(name: "condensed", value: "\(condensed)"),
            URLQueryItem(name: "start", value: formattedStartDate),
        ]
        
        if let end = end {
            let formattedEndDate = dateFormatter.string(from: end)
            urlComponents.queryItems!.append(URLQueryItem(name: "end", value: formattedEndDate))
        }
        
        let url = urlComponents.url!
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
    
    public static func getMonitorHistorySyncronous(id: Int) -> Result<[Status], Error> {
        let semaphore = DispatchSemaphore(value: 0)
        var result: Result<[Status], Error>!

        getMonitorHistory(id: id, condensed: true) { asyncResult in
            result = asyncResult
            semaphore.signal()
        }

        semaphore.wait()
        return result
    }
    
    public static func getMonitorHistory(id: Int, condensed: Bool, completion: @escaping (Result<[Status], Error>) -> Void) {
        let currentDate = Date()
        let calendar = Calendar.current
        let twelveHoursAgo = calendar.date(byAdding: .hour, value: -12, to: currentDate)!
        return getMonitorHistory(id: id, start: twelveHoursAgo, end: nil, condensed: condensed, completion: completion)
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
                let decodedData = try JSONDecoder().decode(MonitorStatus.self, from: data)
                completion(.success(decodedData))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    public static func createMonitor(monitorData: MonitorData, completion: @escaping (Result<MonitorStatus, Error>) -> Void) {
        let url = URL(string: "\(BASE_URL)/monitors")!
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
                let decodedData = try JSONDecoder().decode(MonitorStatus.self, from: data)
                completion(.success(decodedData))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    public static func deleteMonitor(monitorId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        let url = URL(string: "\(BASE_URL)/monitors/\(monitorId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard data != nil else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            completion(.success(()))
        }.resume()
    }
}
