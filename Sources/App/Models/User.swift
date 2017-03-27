import Foundation
import Vapor

struct User {
    let id: UInt
    let name: String
    let team: String

    init?(json: [String : Polymorphic]) {
        guard let id = json["id"]?.uint,
            let name = json["name"]?.string,
            let team = json["team"]?.string else {
                return nil
        }

        self.id   = id
        self.name = name
        self.team = team
    }
}
