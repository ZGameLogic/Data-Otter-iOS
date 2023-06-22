//
//  zgamemonitors.swift
//  zgamemonitors
//
//  Created by Benjamin Shabowski on 6/20/23.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> MonitorStatusEntry {
        MonitorStatusEntry(date: Date(), monitors: [
            Monitor(name: "Test", status: true, type: "minecraft", online: 0, onlinePlayers: []),
            Monitor(name: "Test 2", status: false, type: "api", online: nil, onlinePlayers: nil)
        ])
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (MonitorStatusEntry) -> ()) {
        let entry = MonitorStatusEntry(date: Date(), monitors: [
            Monitor(name: "Test", status: true, type: "minecraft", online: 0, onlinePlayers: []),
            Monitor(name: "Test 2", status: false, type: "api", online: nil, onlinePlayers: nil)
        ])
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let newDate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        Task{
            do {
                var entries: [MonitorStatusEntry] = []
                let entry = try await MonitorStatusEntry(date: newDate, monitors: fetch())
                entries.append(entry)
                let timeline = Timeline(entries: entries, policy: .atEnd)
                completion(timeline)
            } catch networkError.inavlidURL {
                print("u")
            } catch networkError.invalidData {
                print("d")
            } catch networkError.inavlidResponse {
                print("r")
            } catch {
                print("huh")
            }
        }
    }
}

struct MonitorStatusEntry: TimelineEntry {
    let date: Date
    var up: Int
    var down: Int
    let total: Int
    var downMonitors: [String]
    var upMonitors: [String]
    
    init(date: Date, monitors: [Monitor]) {
        self.date = date
        downMonitors = []
        upMonitors = []
        for monitor in monitors {
            if(monitor.status){ // up
                upMonitors.append(monitor.name)
            } else { // down
                downMonitors.append(monitor.name)
            }
        }
        up = upMonitors.count
        down = downMonitors.count
        total = down + up
    }
}

struct zgamemonitorsEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        ZStack {
            ContainerRelativeShape().fill(Color(red:50/250.0, green:20/250.0, blue:79/250.0).gradient)
            switch family {
            case .systemSmall:
                Group {
                    Gauge(value: Double(entry.up), in: 0...Double(entry.total)) {}
                currentValueLabel: {
                    Text(entry.up, format: .number).foregroundColor(entry.down == 0 ? .green : .red)
                } minimumValueLabel: {
                    Text("0").foregroundColor(.red)
                } maximumValueLabel: {
                    Text(entry.total, format: .number).foregroundColor(.green)
                }
                .gaugeStyle(.accessoryCircular)
                .tint(entry.down == 0 ? .green : .red)
                .scaleEffect(2)
                }
            case .systemMedium:
                HStack {
                    Gauge(value: Double(entry.up), in: 0...Double(entry.total)) {}
                currentValueLabel: {
                    Text(entry.up, format: .number).foregroundColor(entry.down == 0 ? .green : .red)
                } minimumValueLabel: {
                    Text("0").foregroundColor(.red)
                } maximumValueLabel: {
                    Text(entry.total, format: .number).foregroundColor(.green)
                }
                .gaugeStyle(.accessoryCircular)
                .tint(entry.down == 0 ? .green : .red)
                .scaleEffect(2)
                .padding([.leading], 65)
                .padding([.trailing], 50)
                    VStack {
                        if(entry.downMonitors.count != 0){
                            Text("Alerting").padding([.top], 5)
                            ForEach(entry.downMonitors, id:\.self){ monitor in
                                HStack {
                                    Text("🔴 \(monitor)")
                                    Spacer()
                                }.padding([.leading], 5)
                            }
                        } else {
                            Text("All good").padding([.top], 5)
                            ForEach(entry.upMonitors, id:\.self){monitor in
                                HStack {
                                    Text("🟢 \(monitor)")
                                    Spacer()
                                }.padding([.leading], 5)
                            }
                        }
                        Spacer()
                    }.frame(width:180)
                        .minimumScaleFactor(0.6)
                    .background(.white.opacity(0.25))
                    Spacer()
                }
            case .systemLarge:
                Text("Large")
            default:
                Text("Some other WidgetFamily in the future.")
            }
        }
    }
}

struct zgamemonitors: Widget {
    let kind: String = "zgamemonitors"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            zgamemonitorsEntryView(entry: entry)
        }
        .configurationDisplayName("ZGameMonitors")
        .description("Gets the status of the ZGameLogic monitors.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct zgamemonitors_Previews: PreviewProvider {
    static var previews: some View {
        zgamemonitorsEntryView(entry: MonitorStatusEntry(date: Date(), monitors: [
            Monitor(name: "Test", status: true, type: "minecraft", online: 0, onlinePlayers: []),
            Monitor(name: "Test 2", status: false, type: "api", online: nil, onlinePlayers: nil)
        ]))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
