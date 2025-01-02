//
//  WeatherModel.swift
//  01157025_final
//
//  Created by user10 on 2024/12/31.
//

import SwiftUI
import Combine
class WeatherViewModel: ObservableObject {
    @Published var temperature: Double?
    @Published var feelsLikeTemperature: Double? // 體感溫度
    @Published var humidity: Int? // 濕度
    @Published var windSpeed: Double? // 風速
    @Published var pressure: Int? // 氣壓
    @Published var cloudiness: Int? // 雲量
    @Published var weatherIcon: String?
    @Published var city: String = "Taipei"

    func fetchWeather() {
        let apiKey = "0a64953090bf9e803cb442b8ccf3710e"
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(apiKey)&units=metric"

        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }

            do {
                let decodedData = try JSONDecoder().decode(WeatherResponse.self, from: data)
                DispatchQueue.main.async {
                    self.temperature = decodedData.main.temp
                    self.feelsLikeTemperature = decodedData.main.feels_like
                    self.humidity = decodedData.main.humidity
                    self.windSpeed = decodedData.wind.speed
                    self.pressure = decodedData.main.pressure
                    self.cloudiness = decodedData.clouds.all
                    self.weatherIcon = decodedData.weather.first?.icon
                    self.city = decodedData.name
                }
            } catch {
                print("Error decoding weather data: \(error)")
            }
        }.resume()
    }
}

struct WeatherResponse: Codable {
    struct Main: Codable {
        let temp: Double
        let feels_like: Double
        let humidity: Int
        let pressure: Int
    }
    struct Weather: Codable {
        let icon: String
    }
    struct Wind: Codable {
        let speed: Double
    }
    struct Clouds: Codable {
        let all: Int
    }
    let main: Main
    let weather: [Weather]
    let wind: Wind
    let clouds: Clouds
    let name: String
}
