import Vapor
import struct Foundation.UUID

let drop = Droplet()
let buzzerManager = BuzzerManager()

drop.get { req in
    return try drop.view.make("join")
}

/// See everyone that buzzes in
drop.get("hosts") { req in
    return try drop.view.make("hosts", [
        "users" : (try? buzzerManager.users.makeNode()) ?? [].makeNode(),
        "buzzes": (try? buzzerManager.buzzes.makeNode()) ?? [].makeNode(),
    ])
}

drop.socket("ws") { req, ws in

    let id = UUID().uuidString
    buzzerManager.addIfNeeded(id: id, socket: ws)

    // ping the socket to keep it open
    try background {
        while ws.state == .open {
            try? ws.ping()
            drop.console.wait(seconds: 10) // every 10 seconds
        }
    }

    ws.onText = { ws, text in
        print("Text received: \(text)")

        let json = try JSON(bytes: Array(text.utf8))
        guard let eventString = json.object?["event"]?.string,
            let event = WebSocket.CustomEvent(rawValue: eventString),
            let payload = json.object?["payload"]?.object else {
                throw Abort.custom(status: .badRequest, message: "Invalid JSON data")
        }
        print("--> Parsed as valid JSON")

        buzzerManager.addIfNeeded(id: id, socket: ws)

        switch event {
        case WebSocket.CustomEvent.join:
            guard let user = User(json: payload) else {
                print("No user data found in JSON")
                throw Abort.custom(status: .badRequest, message: "No user data found on join event")
            }
            buzzerManager.users.insert(user.name)
            try buzzerManager.sendAll(event: .active, text: "\(buzzerManager.users.count)", ignoreId: id)
            print("\(user.name) joined!")
        case WebSocket.CustomEvent.buzz:
            guard let user = User(json: payload) else {
                throw Abort.custom(status: .badRequest, message: "No user data found on buzz event")
            }
            buzzerManager.buzzes.insert("\(user.name)-\(user.team)")
            try buzzerManager.sendAll(event: .buzzes, text: buzzerManager.buzzes.toCSV(), ignoreId: id)
            print("\(user.name) buzzed in!")
        case WebSocket.CustomEvent.clear:
            buzzerManager.buzzes = []
            try buzzerManager.sendAll(event: .buzzes, text: buzzerManager.buzzes.toCSV(), ignoreId: id)
            print("Cleared buzzes")
        default:
            throw Abort.custom(status: .badRequest, message: "No valid event found")
        }
    }

    ws.onClose = { ws, _, _, _ in
        buzzerManager.sockets.removeValue(forKey: id)
        try buzzerManager.sendAll(event: .active, text: "\(buzzerManager.users.count)", ignoreId: id)
        print("Socket closed")
    }
}

drop.run()
