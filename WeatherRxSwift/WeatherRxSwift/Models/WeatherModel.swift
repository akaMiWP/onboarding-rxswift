// 

struct WeatherModel: Decodable, Equatable {
    
    struct Coordinate: Decodable, Equatable {
        let lat: Double
        let lon: Double
    }
    
    struct Weather: Decodable, Equatable {
        let main: String
        let description: String
    }
    
    struct Details: Decodable, Equatable {
        let temp: Double
        let feelsLike: Double
    }
    
    enum CodingKeys: String, CodingKey {
        case coordinate="coord"
        case weather
        case details="main"
        case name
    }
    
    let coordinate: Coordinate
    let weather: [Weather]
    let details: Details
    let name: String
    
    static let defaultModel: WeatherModel = .init(
        coordinate: .init(lat: 0, lon: 0),
        weather: [.init(main: "unknown", description: "unknown")],
        details: .init(temp: 0, feelsLike: 0),
        name: "unknown"
    )
}
