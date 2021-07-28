//
//  buildJson.swift
//  busAlarmWithCoreData
//
//  Created by 羅珮珊 on 2021/7/28.
//

import Foundation

struct busDirections: Codable {
    var DepartureStopNameZh: String
    var DestinationStopNameZh: String

    enum CodingKeys: String, CodingKey {
        case DepartureStopNameZh
        case DestinationStopNameZh

    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        DepartureStopNameZh = try values.decode(String.self, forKey: .DepartureStopNameZh)
        DestinationStopNameZh = try values.decode(String.self, forKey: .DestinationStopNameZh)
    }
}

struct busRoute: Codable {
    var StopUID: String
    var Zh_tw: String
    
    enum CodingKeys: String, CodingKey {
        case StopUID
        case Zh_tw = "StopName"
    }

    enum LocationKeys: String, CodingKey {
        case Zh_tw
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let StopName = try values.nestedContainer(keyedBy: LocationKeys.self, forKey: .Zh_tw)
        
        Zh_tw = try StopName.decode(String.self, forKey: .Zh_tw)
        StopUID = try values.decode(String.self, forKey: .StopUID)
    }
}

struct busRouteStore: Codable {
    var Stops: [busRoute]
}
