//
//  zgamemonitors.swift
//  zgamemonitors
//
//  Created by Benjamin Shabowski on 6/20/23.
//

import WidgetKit
import SwiftUI
import Intents
import Charts

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> MonitorStatusEntry {
        MonitorStatusEntry(date: Date(), monitors: Monitor.previewArray())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (MonitorStatusEntry) -> ()) {
        let entry = MonitorStatusEntry(date: Date(), monitors: Monitor.previewArray())
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let newDate = Calendar.current.date(byAdding: .minute, value: 1, to: Date())!
        Task{
            do {
                var entries: [MonitorStatusEntry] = []
                let entry = try await MonitorStatusEntry(date: newDate, monitors: fetchHistory(), minecraftOnly: (configuration.minecraft ?? false) as! Bool)
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

struct zgamemonitorsEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        ZStack {
            ContainerRelativeShape().fill(Color(red:50/250.0, green:20/250.0, blue:79/250.0).gradient)
            switch family {
            case .accessoryCircular:
                Group {
                    GuageView(entry: entry)
                }
            case .systemSmall:
                Group {
                    GuageView(entry: entry).scaleEffect(2)
                }
            case .systemMedium:
                HStack {
                    GuageView(entry: entry).scaleEffect(2)
                .padding([.leading], 65)
                .padding([.trailing], 50)
                    VStack {
                        if(entry.downMonitors.count != 0){
                            Text("Alerting").padding([.top], 5)
                            ForEach(entry.downMonitors.sorted()){ monitor in
                                HStack {
                                    Text("🔴 \(monitor.name)")
                                    Spacer()
                                }.padding([.leading], 5)
                            }
                        } else {
                            if(entry.hasOnlinePlayers()){
                                Text("Online players").padding([.top], 5)
                                ForEach(entry.getOnlinePlayerNames(), id:\.self){name in
                                    Text(name)
                                }
                            } else {
                                Text("All good").padding([.top], 5)
                                ForEach(entry.upMonitors.sorted()){monitor in
                                    HStack {
                                        Text("🟢 \(monitor.name)")
                                        Spacer()
                                    }.padding([.leading], 5)
                                }
                            }
                        }
                        Spacer()
                    }
                        .frame(width:180)
                        .minimumScaleFactor(0.6)
                        .background(.white.opacity(0.25))
                    Spacer()
                }
            case .systemLarge:
                Group {
                    if(!entry.minecraftOnly){
                        HistoryGraphView(history: Monitor.convertToGraph(monitors: entry.monitors).sorted(by: < ))
                    } else {
                        PlayerHistoryGraphView(history: Monitor.convertToGraph(monitors: entry.monitors.filter{$0.type == "minecraft"}))
                    }
                }
                    .padding()
                    .background(.black.opacity(0.70))
                
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
        .configurationDisplayName("Data Otter")
        .description("Gets the status of the ZGameLogic monitors.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .accessoryCircular])
    }
}

struct zgamemonitors_Previews: PreviewProvider {
    static var previews: some View {
        zgamemonitorsEntryView(entry: MonitorStatusEntry(date: Date(), monitors: Monitor.previewArrayAllGood()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
