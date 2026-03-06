use serde::{Deserialize, Serialize};
use std::time::Duration;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct WeatherData {
        pub condition: WeatherCondition,
        pub temperature: f64,
        pub precipitation: f64,
        pub wind_speed: f64,
        pub wind_direction: f64,
        pub is_day: bool,
        pub humidity: f64,
    }

    #[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
    #[serde(rename_all = "kebab-case")]
    pub enum WeatherCondition {
        Clear,
        PartlyCloudy,
        Cloudy,
        Overcast,
        Fog,
        Drizzle,
        Rain,
        FreezingRain,
        RainShowers,
        Snow,
        SnowGrains,
        SnowShowers,
        Thunderstorm,
        ThunderstormHail,
    }

    impl WeatherCondition {
        pub fn from_code(code: i32) -> Self {
            match code {
                0 => WeatherCondition::Clear,
                1 => WeatherCondition::PartlyCloudy,
                2 => WeatherCondition::Cloudy,
                3 => WeatherCondition::Overcast,
                45 | 48 => WeatherCondition::Fog,
                51 | 53 | 55 => WeatherCondition::Drizzle,
                56 | 57 => WeatherCondition::FreezingRain,
                61 | 63 | 65 => WeatherCondition::Rain,
                66 | 67 => WeatherCondition::FreezingRain,
                80 | 81 | 82 => WeatherCondition::RainShowers,
                71 | 73 | 75 => WeatherCondition::Snow,
                77 => WeatherCondition::SnowGrains,
                85 | 86 => WeatherCondition::SnowShowers,
                95 | 96 | 99 => WeatherCondition::Thunderstorm,
                _ => WeatherCondition::Clear,
            }
        }

        pub fn is_raining(&self) -> bool {
            matches!(
                self,
                WeatherCondition::Drizzle
                    | WeatherCondition::Rain
                    | WeatherCondition::FreezingRain
                    | WeatherCondition::RainShowers
            )
        }

        pub fn is_snowing(&self) -> bool {
            matches!(
                self,
                WeatherCondition::Snow
                    | WeatherCondition::SnowGrains
                    | WeatherCondition::SnowShowers
            )
        }

        pub fn is_stormy(&self) -> bool {
            matches!(
                self,
                WeatherCondition::Thunderstorm | WeatherCondition::ThunderstormHail
            )
        }

        pub fn as_str(&self) -> &'static str {
            match self {
                WeatherCondition::Clear => "Clear",
                WeatherCondition::PartlyCloudy => "Partly Cloudy",
                WeatherCondition::Cloudy => "Cloudy",
                WeatherCondition::Overcast => "Overcast",
                WeatherCondition::Fog => "Fog",
                WeatherCondition::Drizzle => "Drizzle",
                WeatherCondition::Rain => "Rain",
                WeatherCondition::FreezingRain => "Freezing Rain",
                WeatherCondition::RainShowers => "Rain Showers",
                WeatherCondition::Snow => "Snow",
                WeatherCondition::SnowGrains => "Snow Grains",
                WeatherCondition::SnowShowers => "Snow Showers",
                WeatherCondition::Thunderstorm => "Thunderstorm",
                WeatherCondition::ThunderstormHail => "Thunderstorm with Hail",
            }
        }
    }

    #[derive(Debug, Deserialize)]
    struct OpenMeteoResponse {
        current: CurrentWeather,
    }

    #[derive(Debug, Deserialize)]
    struct CurrentWeather {
        temperature_2m: f64,
        relative_humidity_2m: f64,
        is_day: i32,
        precipitation: f64,
        weather_code: i32,
        wind_speed_10m: f64,
        wind_direction_10m: f64,
    }

    pub fn fetch_weather(lat: f64, lon: f64, metric: bool) -> Result<WeatherData, String> {
        let units = if metric { "metric" } else { "imperial" };
        
        let url = format!(
            "https://api.open-meteo.com/v1/forecast?latitude={}&longitude={}&current=temperature_2m,relative_humidity_2m,is_day,precipitation,weather_code,wind_speed_10m,wind_direction_10m&timezone=auto",
            lat, lon
        );

        let client = reqwest::blocking::Client::builder()
            .timeout(Duration::from_secs(30))
            .build()
            .map_err(|e| format!("HTTP client error: {}", e))?;

        let response = client
            .get(&url)
            .send()
            .map_err(|e| format!("Network error: {}", e))?;

        if !response.status().is_success() {
            return Err(format!("API error: {}", response.status()));
        }

        let data: OpenMeteoResponse = response
            .json()
            .map_err(|e| format!("Parse error: {}", e))?;

        Ok(WeatherData {
            condition: WeatherCondition::from_code(data.current.weather_code),
            temperature: data.current.temperature_2m,
            precipitation: data.current.precipitation,
            wind_speed: data.current.wind_speed_10m,
            wind_direction: data.current.wind_direction_10m,
            is_day: data.current.is_day == 1,
            humidity: data.current.relative_humidity_2m,
        })
    }

    pub fn generate_demo_weather() -> WeatherData {
        use rand::Rng;
        let mut rng = rand::thread_rng();
        
        let conditions = [
            WeatherCondition::Clear,
            WeatherCondition::PartlyCloudy,
            WeatherCondition::Cloudy,
            WeatherCondition::Rain,
            WeatherCondition::Snow,
        ];
        
        let condition = conditions[rng.gen_range(0..conditions.len())];
        
        WeatherData {
            condition,
            temperature: rng.gen_range(10.0..25.0),
            precipitation: if condition.is_raining() { rng.gen_range(1.0..5.0) } else { 0.0 },
            wind_speed: rng.gen_range(5.0..20.0),
            wind_direction: rng.gen_range(0.0..360.0),
            is_day: true,
            humidity: rng.gen_range(40.0..80.0),
        }
    }
