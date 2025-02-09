//
//  Table View.swift
//  Monitors
//
//  Created by Benjamin Shabowski on 1/28/25.
//

import SwiftUI

struct TableView: View {
    let headers: [String]
    let data: [[String]]
    
    var body: some View {
        ScrollView([.horizontal, .vertical], showsIndicators: true) {
            Grid {
                GridRow {
                    ForEach(headers, id: \.self) { header in
                        Text(header)
                            .font(.headline)
                            .frame(maxWidth: .infinity, minHeight: 10)
                            .padding()
                            .background(Color.gray.opacity(0.3))
                            .border(Color.gray, width: 0.5)
                    }
                }
                
                ForEach(data.indices, id: \.self) { rowIndex in
                    GridRow {
                        ForEach(data[rowIndex], id: \.self) { cell in
                            Text(cell)
                                .frame(maxWidth: .infinity, minHeight: 10, alignment: .leading)
                                .padding()
                                .border(Color.gray, width: 0.5)
                        }
                    }
                }
            }
            .padding()
        }
    }
}

#Preview {
    TableView(headers: ["firstname", "lastname", "age", "misc", "misc 2"], data: [
        ["Ben", "Shabowski", "26", "Cool"],
        ["Reba", "Shabowski", "27", "Cute"],
        ["Emily", "Shabowski", "26", "Single"],
        ["Ben", "Shabowski", "26", "Cool"],
        ["Reba", "Shabowski", "27", "Cute"],
        ["Emily", "Shabowski", "26", "Single"],
        ["Ben", "Shabowski", "26", "Cool"],
        ["Reba", "Shabowski", "27", "Cute"],
        ["Emily", "Shabowski", "26", "Single"],
        ["Ben", "Shabowski", "26", "Cool"],
        ["Reba", "Shabowski", "27", "Cute"],
        ["Emily", "Shabowski", "26", "Single"],
        ["Ben", "Shabowski", "26", "Cool"],
        ["Reba", "Shabowski", "27", "Cute"],
        ["Emily", "Shabowski", "26", "Single"],
        ["Ben", "Shabowski", "26", "Cool"],
        ["Reba", "Shabowski", "27", "Cute"],
        ["Emily", "Shabowski", "26", "Single"]
    ])
}
