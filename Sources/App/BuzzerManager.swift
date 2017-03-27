import Foundation
import Vapor

public final class BuzzerManager {
    var users: Set<String> = []
    var buzzes: Set<String> = []
    var sockets: [String:WebSocket] = [:]

    func addIfNeeded(id: String, socket: WebSocket) {
        if let _ = sockets[id] {
            return
        }

        sockets[id] = socket
        print("Socket added with ID: \(id)")
    }

    func sendAll(event: WebSocket.CustomEvent, text: String, ignoreId: String) throws {
        for (id, socket) in sockets where id != ignoreId {
            print("Sending event \(event.rawValue) to \(id)")
            try socket.send(event: event, text: text)
        }
    }
}

extension WebSocket {
    public enum CustomEvent: String {
        case join, buzz, buzzes, clear, active
    }

    public func send(event: CustomEvent, text: String) throws {
        let json = try JSON(node: [
            "event": event.rawValue,
            "payload": text
            ]
        )

        try send(opCode: .text, with: json.makeBytes())
    }
}

extension Sequence where Iterator.Element == String {

    /// Returns a CSV representation of the array.
    ///
    /// - parameter data: Collection to be concatanted.
    ///
    /// - returns: CSV list as a string
    ///
    /// - SeeAlso: `joined(separator:)`
    ///
    func toCSV() -> String {
        return joined(separator: ",")
    }
}
