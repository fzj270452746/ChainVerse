import Foundation
import UserNotifications

// Daily nudges to forge a chain. Thin wrapper over UNUserNotificationCenter:
// each chain owns one repeating notification keyed by its id.
enum Reminders {
    private static var center: UNUserNotificationCenter { .current() }

    // Ask once; the closure reports whether nudges are allowed.
    static func request(_ done: @escaping (Bool) -> Void) {
        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            DispatchQueue.main.async { done(granted) }
        }
    }

    static func status(_ done: @escaping (Bool) -> Void) {
        center.getNotificationSettings { s in
            DispatchQueue.main.async { done(s.authorizationStatus == .authorized) }
        }
    }

    // Bring the chain's scheduled notification in line with its reminder field.
    static func sync(_ chain: ChainCore) {
        cancel(chain.id)
        guard let at = chain.reminder else { return }

        let comps = Calendar.current.dateComponents([.hour, .minute], from: at)
        let content = UNMutableNotificationContent()
        content.title = chain.title
        content.body = "Keep the chain alive — forge it today."
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        let request = UNNotificationRequest(identifier: key(chain.id), content: content, trigger: trigger)
        center.add(request, withCompletionHandler: nil)
    }

    static func cancel(_ id: UUID) {
        center.removePendingNotificationRequests(withIdentifiers: [key(id)])
    }

    static func clearAll() {
        center.removeAllPendingNotificationRequests()
    }

    private static func key(_ id: UUID) -> String { "chain.\(id.uuidString)" }
}
