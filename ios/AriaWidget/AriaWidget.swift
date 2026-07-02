// ============================================================
//  Aria — Widget d'écran d'accueil iOS (WidgetKit / SwiftUI)
//
//  ⚠️ Ce fichier doit être ajouté à une EXTENSION Widget créée
//  dans Xcode (voir les étapes dans la réponse de l'assistant).
//  Il ne se compile pas tant que l'extension n'existe pas.
//
//  App Group requis (app + extension) : group.com.ibrahimadiallo.aria
// ============================================================
import WidgetKit
import SwiftUI

private let appGroupId = "group.com.ibrahimadiallo.aria"

struct AriaEntry: TimelineEntry {
    let date: Date
    let pct: Int
    let equilibre: String
    let projets: String
}

struct AriaProvider: TimelineProvider {
    func placeholder(in context: Context) -> AriaEntry {
        AriaEntry(date: Date(), pct: 0, equilibre: "", projets: "")
    }

    func getSnapshot(in context: Context, completion: @escaping (AriaEntry) -> Void) {
        completion(readEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<AriaEntry>) -> Void) {
        // Rafraîchit d'ici ~1h ; l'app pousse aussi des mises à jour immédiates.
        let next = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        completion(Timeline(entries: [readEntry()], policy: .after(next)))
    }

    private func readEntry() -> AriaEntry {
        let defaults = UserDefaults(suiteName: appGroupId)
        return AriaEntry(
            date: Date(),
            pct: defaults?.integer(forKey: "pct") ?? 0,
            equilibre: defaults?.string(forKey: "equilibre") ?? "",
            projets: defaults?.string(forKey: "projets") ?? ""
        )
    }
}

struct AriaWidgetEntryView: View {
    var entry: AriaProvider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("Aria")
                .font(.caption).bold()
                .foregroundColor(Color(red: 0.90, green: 0.75, blue: 0.39)) // or clair
            Text("\(entry.pct)%")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(Color(red: 0.96, green: 0.94, blue: 0.89)) // crème
            Text(entry.equilibre)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.85))
            Text(entry.projets)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.85))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding()
        .background(
            LinearGradient(
                colors: [Color(red: 0.082, green: 0.106, blue: 0.173),  // #151B2C
                         Color(red: 0.043, green: 0.059, blue: 0.102)], // #0B0F1A
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        )
    }
}

@main
struct AriaWidget: Widget {
    let kind: String = "AriaWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: AriaProvider()) { entry in
            if #available(iOS 17.0, *) {
                AriaWidgetEntryView(entry: entry)
                    .containerBackground(.clear, for: .widget)
            } else {
                AriaWidgetEntryView(entry: entry)
            }
        }
        .configurationDisplayName("Aria")
        .description("Ton équilibre du jour.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
