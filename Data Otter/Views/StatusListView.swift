//
//  StatusListView.swift
//  Data Otter
//
//  Created by Benjamin Shabowski on 5/16/24.
//

import SwiftUI

struct StatusListView: View {
    let id: Int
    @State var history: [Status]

    var body: some View {
        List {
            if(history.isEmpty){
                Text("Fetching monitor full history...")
            } else {
                ForEach(history) { status in
                    HStack {
                        VStack(alignment: .leading){
                            Text(formatDateTime(status.dateRecorded))
                            Text(formatDateDay(status.dateRecorded)).font(.system(size: 10.0))
                        }
                        Spacer()
                        VStack(alignment: .trailing){
                            Text("SC: \(status.statusCode)").font(.footnote)
                            Text("\(status.milliseconds)ms").font(.footnote)
                            Text("\(status.attempts) attempt(s)").font(.footnote)
                        }
                        Text(status.status ? "🟢" : "🔴")
                    }
                }
            }
        }.onAppear {
            fetchMonitorsHistory()
        }
    }
    
    func formatDateTime(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mma"
        return dateFormatter.string(from: date)
    }
    
    func formatDateDay(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd"
        return dateFormatter.string(from: date)
    }
    
    func fetchMonitorsHistory() {
       print("Fetching monitor history")

       MonitorsService.getMonitorHistory(id: id, condensed: false) { result in
           DispatchQueue.main.async {
               switch result {
               case .success(let data):
                   history = data
               case .failure(let error):
                   print(error)
               }
           }
       }
   }
}

#Preview {
    StatusListView(id: 1, history: [
        Status(dateRecorded: Date(), milliseconds: 30, status: true, attempts: 1, statusCode: 200),
        Status(dateRecorded: Date(), milliseconds: 30, status: false, attempts: 3, statusCode: 404)
    ])
}
