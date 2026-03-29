import WidgetKit
import SwiftUI

struct ChamCongWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), status: "none", checkIn: "--", checkOut: "--", total: "--", note: "")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), status: "none", checkIn: "--", checkOut: "--", total: "--", note: "")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Load data from UserDefaults (shared with app)
        let defaults = UserDefaults(suiteName: "group.com.yourname.chamcong")
        let status = defaults?.string(forKey: "widget_status") ?? "none"
        let checkIn = defaults?.string(forKey: "widget_check_in") ?? "--"
        let checkOut = defaults?.string(forKey: "widget_check_out") ?? "--"
        let total = defaults?.string(forKey: "widget_total") ?? "--"
        let note = defaults?.string(forKey: "widget_note") ?? ""

        let entry = SimpleEntry(date: Date(), status: status, checkIn: checkIn, checkOut: checkOut, total: total, note: note)
        entries.append(entry)

        // Refresh every 15 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let timeline = Timeline(entries: entries, policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let status: String
    let checkIn: String
    let checkOut: String
    let total: String
    let note: String
}

struct ChamCongWidgetEntryView: View {
    var entry: ChamCongWidgetProvider.Entry

    var statusColor: Color {
        switch entry.status {
        case "working":
            return Color.green
        case "done":
            return Color.blue
        default:
            return Color.gray
        }
    }

    var statusText: String {
        switch entry.status {
        case "working":
            return "Đang làm"
        case "done":
            return "Đã về"
        default:
            return "Chưa vào"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Chấm Công")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Text(entry.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            HStack(spacing: 8) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 12, height: 12)
                Text(statusText)
                    .font(.body)
                    .fontWeight(.semibold)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Vào:")
                        .foregroundColor(.secondary)
                    Text(entry.checkIn)
                        .fontWeight(.semibold)
                }
                if entry.status == "done" {
                    HStack {
                        Text("Ra:")
                            .foregroundColor(.secondary)
                        Text(entry.checkOut)
                            .fontWeight(.semibold)
                    }
                    HStack {
                        Text("Tổng:")
                            .foregroundColor(.secondary)
                        Text(entry.total)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                }
            }
            .font(.caption)

            if !entry.note.isEmpty {
                Text(entry.note)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

@main
struct ChamCongWidget: Widget {
    let kind: String = "ChamCongWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ChamCongWidgetProvider()) { entry in
            ChamCongWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Chấm Công")
        .description("Hiển thị trạng thái chấm công hôm nay")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview {
    ChamCongWidgetEntryView(entry: SimpleEntry(
        date: Date(),
        status: "working",
        checkIn: "08:30",
        checkOut: "--",
        total: "5h 15m",
        note: ""
    ))
    .previewContext(WidgetPreviewContext(family: .systemMedium))
}
