//
//  WidgetExtension.swift
//  WidgetExtension
//
//  Created by Andani Matoro on 2025/03/24.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    
    private func dataFromFlutter()-> SimpleEntry {
        let userDefaults = UserDefaults(suiteName:"group.homeScreenApp")
        let text = userDefaults?.string(forKey: "text_from_flutter_app") ?? "0"
        return SimpleEntry(date: Date(), text: text)
        
    }
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), text: "😀")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), text: "😀")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = dataFromFlutter()

        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }

//    func relevances() async -> WidgetRelevances<Void> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let text: String
}


struct WidgetExtensionEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text("Time:")
            Text(entry.date, style: .time)

            Text("Text:")
            Text(entry.text)
        }
    }
}

struct WidgetExtension: Widget {
    let kind: String = "WidgetExtension"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                WidgetExtensionEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                WidgetExtensionEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

#Preview(as: .systemSmall) {
    WidgetExtension()
} timeline: {
    SimpleEntry(date: .now, text: "😀")
    SimpleEntry(date: .now, text: "🤩")
}
