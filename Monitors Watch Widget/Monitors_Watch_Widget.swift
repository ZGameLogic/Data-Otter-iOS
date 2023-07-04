//
//  Monitors_Watch_Widget.swift
//  Monitors Watch Widget
//
//  Created by Benjamin Shabowski on 7/4/23.
//

import WidgetKit
import SwiftUI
import Intents

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

    func recommendations() -> [IntentRecommendation<ConfigurationIntent>] {
        return [
            IntentRecommendation(intent: ConfigurationIntent(), description: "ZGameLogic monitors")
        ]
    }
}

struct Monitors_Watch_WidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        GuageView(entry: entry)
    }
}

@main
struct Monitors_Watch_Widget: Widget {
    let kind: String = "Monitors_Watch_Widget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            Monitors_Watch_WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Data Otter")
        .description("Gets the status of the ZGameLogic monitors.")
        .supportedFamilies([.accessoryCircular])
    }
}

struct Monitors_Watch_Widget_Previews: PreviewProvider {
    static var previews: some View {
        Monitors_Watch_WidgetEntryView(entry: MonitorStatusEntry(date: Date(), monitors: Monitor.previewArray()))
            .previewContext(WidgetPreviewContext(family: .accessoryCircular))
    }
}
