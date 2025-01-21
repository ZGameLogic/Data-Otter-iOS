//
//  MonitorsService.swift
//  Monitors
//
//  Created by Benjamin Shabowski on 5/12/24.
//

import Foundation

struct MonitorsService {
    #if targetEnvironment(simulator)
    static let BASE_URL = "http://localhost:8080"
    #else
    static let BASE_URL = "http://monitoring.zgamelogic.com:8080"
    #endif
    
    private static func getData<T: Decodable>(
        from url: String,
        query: [URLQueryItem]? = nil,
        _ completion: @escaping (Result<T, Error>) -> Void
    ) {
        var urlComponents = URLComponents(string: url)!
        urlComponents.queryItems = query
        
        guard let url = urlComponents.url else {
            completion(.failure(URLError(.badURL)))
            return
        }
        if(url.absoluteString.contains("/applications")) {
            print("started")
        }
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
                if(url.absoluteString.contains("/applications")) {
                    print("completed")
                }
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedData))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    private static func getDataSynchronously<T: Decodable>(from urlString: String, query: [URLQueryItem]? = nil) -> Result<T, Error> {
        let semaphore = DispatchSemaphore(value: 0)
        var result: Result<T, Error>!
        
        getData(from: urlString, query: query) { asyncResult in
            result = asyncResult
            semaphore.signal()
        }
        
        semaphore.wait()
        return result
    }
    
    public static func deleteData(from urlString: String, _ completion: @escaping (Result<Void, Error>) -> Void) {
        let url = URL(string: urlString)!
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
    
    private static func createData<T: Encodable, D: Decodable>(
        from urlString: String,
        data dataObject: T,
        _ completion: @escaping (Result<D, Error>) -> Void
    ) {
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(dataObject)
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
                let decodedData = try JSONDecoder().decode(D.self, from: data)
                completion(.success(decodedData))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    public static func getMonitorsWithStatus(completion: @escaping (Result<[Monitor], Error>) -> Void) {
        getData(from: "\(BASE_URL)/monitors", query: [URLQueryItem(name: "include-status", value: "true")], completion)
    }
    
    public static func getApplicationsWithStatus(completion: @escaping (Result<[Application], Error>) -> Void) {
        getData(from: "\(BASE_URL)/applications", query: [URLQueryItem(name: "include-status", value: "true")], completion)
    }
    
    public static func getAgentsWithStatus(completion: @escaping (Result<[Agent], Error>) -> Void){
        getData(from: "\(BASE_URL)/agents", query: [URLQueryItem(name: "include-status", value: "true")], completion)
    }
    
    public static func getRockStats(completion: @escaping(Result<[String: Int64], Error>) -> Void){
        getData(from: "\(BASE_URL)/rocks/stats", completion)
    }
    
    public static func getMonitorsWithStatusSyncronous() -> Result<[Monitor], Error> {
        getDataSynchronously(from: "\(BASE_URL)/monitors", query: [URLQueryItem(name: "include-status", value: "true")])
    }

    public static func getTags(completion: @escaping (Result<[Tag], Error>) -> Void) {
        getData(from: "\(BASE_URL)/tags", completion)
    }
    
    public static func getMonitors(completion: @escaping (Result<[Monitor], Error>) -> Void) {
        getData(from: "\(BASE_URL)/monitors", completion)
    }
    
    public static func getTagsSynchronous() -> Result<[Tag], Error> {
        getDataSynchronously(from: "\(BASE_URL)/tags")
    }
    
    public static func getMonitorsSyncronous() -> Result<[Monitor], Error> {
        getDataSynchronously(from: "\(BASE_URL)/monitors")
    }
    
    public static func getAgentHistory(agentId: Int64, start: Date, end: Date?, completion: @escaping (Result<[AgentStatus], Error>) -> Void) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
        let formattedStartDate = dateFormatter.string(from: start)
        
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "start", value: formattedStartDate)
        ]
        
        if let end = end {
            let formattedEndDate = dateFormatter.string(from: end)
            queryItems.append(URLQueryItem(name: "end", value: formattedEndDate))
        }
        
        queryItems.append(URLQueryItem(name: "fill", value: "true"))
        
        getData(from: "\(BASE_URL)/agent/\(agentId)/status/history", query: queryItems, completion)
    }
    
    public static func getMonitorHistory(applicationId: Int, id: Int, start: Date, end: Date?, condensed: Bool, completion: @escaping (Result<[Status], Error>) -> Void) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
        let formattedStartDate = dateFormatter.string(from: start)
        
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "condensed", value: "\(condensed)"),
            URLQueryItem(name: "start", value: formattedStartDate),
        ]
        
        if let end = end {
            let formattedEndDate = dateFormatter.string(from: end)
            queryItems.append(URLQueryItem(name: "end", value: formattedEndDate))
        }
        
        getData(from: "\(BASE_URL)/monitors/\(applicationId)/\(id)/history", query: queryItems, completion)
    }
    
    public static func getMonitorHistorySyncronous(applicationId: Int, id: Int, condensed: Bool) -> Result<[Status], Error> {
        let currentDate = Date()
        let calendar = Calendar.current
        let twelveHoursAgo = calendar.date(byAdding: .hour, value: -12, to: currentDate)!
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
        let formattedStartDate = dateFormatter.string(from: twelveHoursAgo)
        
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "condensed", value: "\(condensed)"),
            URLQueryItem(name: "start", value: formattedStartDate),
        ]
        
        return getDataSynchronously(from: "\(BASE_URL)/monitors/\(applicationId)/\(id)/history", query: queryItems)
    }
    
    public static func getMonitorHistory(applicationId: Int, id: Int, condensed: Bool, completion: @escaping (Result<[Status], Error>) -> Void) {
        let currentDate = Date()
        let calendar = Calendar.current
        let twelveHoursAgo = calendar.date(byAdding: .hour, value: -12, to: currentDate)!
        return getMonitorHistory(applicationId: applicationId, id: id, start: twelveHoursAgo, end: nil, condensed: condensed, completion: completion)
    }
    
    public static func getRockPageable(applicationId: Int, page: Int, size: Int, completion: @escaping (Result<PageableData<Rock>, Error>) -> Void) {
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "size", value: "\(size)"),
        ]
        
        return getData(from: "\(BASE_URL)/rocks/\(applicationId)", query: queryItems, completion)
    }
    
    public static func getAgentHistory(agentId: Int64, completion: @escaping (Result<[AgentStatus], Error>) -> Void){
        let currentDate = Date()
        let calendar = Calendar.current
        let twelveHoursAgo = calendar.date(byAdding: .hour, value: -12, to: currentDate)!
        return getAgentHistory(agentId: agentId, start: twelveHoursAgo, end: nil, completion: completion)
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

    public static func updateMonitor(monitorData: Monitor, completion: @escaping (Result<Monitor, Error>) -> Void) {
        let url = URL(string: "\(BASE_URL)/monitors/\(monitorData.applicationId)/\(monitorData.id)")!
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
                let decodedData = try JSONDecoder().decode(Monitor.self, from: data)
                completion(.success(decodedData))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    public static func createMonitor(monitorData: MonitorData, applicationId: Int64, completion: @escaping (Result<Monitor, Error>) -> Void) {
        createData(from: "\(BASE_URL)/monitors/\(applicationId)", data: monitorData, completion)
    }
    
    public static func createApplication(applicationData: ApplicationCreateData, completion: @escaping (Result<Application, Error>) -> Void){
        createData(from: "\(BASE_URL)/applications", data: applicationData, completion)
    }
    
    public static func deleteMonitor(monitorId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        deleteData(from: "\(BASE_URL)/monitors/\(monitorId)", completion)
    }
    
    public static func registrationEndpoint(add: Bool, token: String) async throws {
        guard let url = URL(string: BASE_URL + "/devices/\(add ? "register" : "unregister")/\(token)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )
        _ = try await URLSession.shared.data(for: request)
    }
}
