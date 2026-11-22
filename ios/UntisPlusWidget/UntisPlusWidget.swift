import SwiftUI
import WidgetKit

/// One step of the timeline the app writes (see lib/features/widgets/widget_timeline.dart).
struct LessonEntry: TimelineEntry {
  let date: Date
  let label: String
  let title: String
  let time: String
  let place: String
  let status: String
  let later: [String]
}

private let german = Locale.current.language.languageCode?.identifier == "de"

enum AppGroup {
  /// SideStore may rename the app group when it signs the app and lists the real one in
  /// ALTAppGroups: look in this extension's Info.plist, then in the app's.
  static var id: String {
    let app = Bundle(url: Bundle.main.bundleURL.deletingLastPathComponent().deletingLastPathComponent())
    for bundle in [Bundle.main, app].compactMap({ $0 }) {
      if let groups = bundle.object(forInfoDictionaryKey: "ALTAppGroups") as? [String], let first = groups.first {
        return first
      }
    }
    return "group.at.anelkoo.untisPlus"
  }
}

struct Provider: TimelineProvider {
  private var openApp: LessonEntry {
    LessonEntry(date: Date(), label: "", title: german ? "Öffne Untis+ einmal" : "Open Untis+ once",
                time: "", place: "", status: "", later: [])
  }

  private var sample: LessonEntry {
    LessonEntry(date: Date(), label: german ? "Jetzt" : "Now", title: "AM", time: "08:00–08:50",
                place: "E12 · MUE", status: "", later: ["08:50 · D · E12", "09:45 · E · E14"])
  }

  func placeholder(in context: Context) -> LessonEntry { sample }

  func getSnapshot(in context: Context, completion: @escaping (LessonEntry) -> Void) {
    completion(context.isPreview ? sample : (current(load()).first ?? openApp))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<LessonEntry>) -> Void) {
    let entries = current(load())
    completion(Timeline(entries: entries.isEmpty ? [openApp] : entries, policy: .atEnd))
  }

  /// Drops entries that a later, already started entry replaces.
  private func current(_ entries: [LessonEntry]) -> [LessonEntry] {
    guard let i = entries.lastIndex(where: { $0.date <= Date() }) else { return entries }
    return Array(entries[i...])
  }

  private func load() -> [LessonEntry] {
    guard let json = UserDefaults(suiteName: AppGroup.id)?.string(forKey: "timeline"),
          let items = try? JSONSerialization.jsonObject(with: Data(json.utf8)) as? [[String: Any]]
    else { return [] }
    return items.map { item in
      LessonEntry(
        date: Date(timeIntervalSince1970: ((item["from"] as? NSNumber)?.doubleValue ?? 0) / 1000),
        label: item["label"] as? String ?? "",
        title: item["title"] as? String ?? "",
        time: item["time"] as? String ?? "",
        place: item["place"] as? String ?? "",
        status: item["status"] as? String ?? "",
        later: item["later"] as? [String] ?? []
      )
    }
  }
}

struct LessonWidgetView: View {
  @Environment(\.widgetFamily) private var family
  let entry: LessonEntry

  var body: some View {
    VStack(alignment: .leading, spacing: 2) {
      if !entry.label.isEmpty {
        Text(entry.label).font(.caption.bold()).foregroundStyle(.tint)
      }
      Text(entry.title).font(.title3.bold()).lineLimit(2)
      if !entry.time.isEmpty { Text(entry.time).font(.subheadline) }
      if !entry.place.isEmpty {
        Text(entry.place).font(.subheadline).foregroundStyle(.secondary).lineLimit(1)
      }
      if !entry.status.isEmpty {
        Text(entry.status).font(.caption.bold()).foregroundStyle(.red)
      }
      if family == .systemMedium {
        ForEach(Array(entry.later.enumerated()), id: \.offset) { _, line in
          Text(line).font(.caption).foregroundStyle(.secondary).lineLimit(1)
        }
      }
      Spacer(minLength: 0)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .widgetBackground()
  }
}

private extension View {
  /// iOS 17 shows a placeholder instead of widgets that don't declare a container background.
  @ViewBuilder func widgetBackground() -> some View {
    if #available(iOS 17.0, *) {
      containerBackground(.fill.tertiary, for: .widget)
    } else {
      padding().background(Color(.systemBackground))
    }
  }
}

@main
struct UntisPlusWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: "UntisPlusWidget", provider: Provider()) { entry in
      LessonWidgetView(entry: entry)
    }
    .configurationDisplayName(german ? "Stundenplan" : "Timetable")
    .description(german ? "Die aktuelle oder nächste Stunde." : "The current or next lesson.")
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}
