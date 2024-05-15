//
//  DataOtterGuageWidgetView.swift
//  Data Otter iOS WidgetExtension
//
//  Created by Benjamin Shabowski on 5/15/24.
//

import SwiftUI
import WidgetKit

struct DataOtterGuageWidgetView: View {
    @Environment(\.widgetFamily) var family
    var entry: Provider.Entry
    
    var body: some View {
        ZStack {
            switch family {
            case .accessoryCircular:
                AccessoryGuageWidgetView(entry: entry)
            case .systemSmall:
                SmallGuageWidgetView(entry: entry)
            case .systemMedium:
                MediumGuageWidgetView(entry: entry)
            default:
                Text("No size for this one :(")
            }
        }.containerBackground(Color(hex: "#481785").gradient, for: .widget)
    }
}

struct MediumGuageWidgetView: View {
    var entry: Provider.Entry
    
    var body: some View {
        HStack {
            gauge(entry).scaleEffect(2).padding([.leading], 50)
            Spacer()
            VStack {
                if(entry.downMonitors.count != 0){
                    Text("Alerting").padding([.top], 5)
                    ForEach(entry.downMonitors, id: \.self){ monitor in
                        HStack {
                            Text("🔴 \(monitor)")
                            Spacer()
                        }.padding([.leading], 5)
                    }
                } else {
                    Text("All good").padding([.top], 5)
                    ForEach(entry.upMonitors, id: \.self){ monitor in
                        HStack {
                            Text("🟢 \(monitor)")
                            Spacer()
                        }.padding([.leading], 5)
                    }
                }
                Spacer()
            }
            .frame(width:180)
            .minimumScaleFactor(0.6)
            .background(.white.opacity(0.25))
        }
    }
}

struct SmallGuageWidgetView: View {
    var entry: Provider.Entry
    
    var body: some View {
        gauge(entry).scaleEffect(2)
    }
}

struct AccessoryGuageWidgetView: View {
    var entry: Provider.Entry
    
    var body: some View {
        gauge(entry)
    }
}

func gauge(_ entry: Provider.Entry) -> some View {
    Gauge(value: Double(entry.up), in: 0...Double(entry.total)){}
    currentValueLabel: {
        Text(entry.up, format: .number).foregroundColor(entry.down == 0 ? .green : .red)
    } minimumValueLabel: {
        Text("0").foregroundColor(.red)
    } maximumValueLabel: {
        Text(entry.total, format: .number).foregroundColor(.green)
    }
    .gaugeStyle(.accessoryCircular)
    .tint(entry.down == 0 ? .green : .red)
}

#Preview(as: .systemSmall) {
    zgamemonitors()
} timeline: {
    MonitorStatusEntry(date: Date(), monitors: [
        MonitorStatus(id: 1, name: "Test Monitor 1", type: "API", url: "https://zgamelogic.com", regex: "Healthy", status: Status(dateRecorded: Date(), milliseconds: 3, status: true, attempts: 1, statusCode: 200)),
        MonitorStatus(id: 2, name: "Test Monitor 2", type: "API", url: "https://zgamelogic.com", regex: "Healthy", status: Status(dateRecorded: Date(), milliseconds: 3, status: true, attempts: 3, statusCode: 200)),
        MonitorStatus(id: 3, name: "Test Monitor 3", type: "WEB", url: "https://zgamelogic.com", regex: "Healthy", status: Status(dateRecorded: Date(), milliseconds: 3, status: true, attempts: 3, statusCode: 200))
    ])
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
