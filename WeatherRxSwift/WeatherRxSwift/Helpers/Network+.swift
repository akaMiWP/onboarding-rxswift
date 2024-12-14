//

import Foundation

func getURL(city: String) -> URL {
    let key = Bundle.main.infoDictionary?["API_KEY"] as! String
    var url = URL(string: "https://api.openweathermap.org/data/2.5/weather")!
    url.append(queryItems: [.init(name: "q", value: city)])
    url.append(queryItems: [.init(name: "appid", value: key)])
    return url
}
