use crate::weather::{WeatherCondition, WeatherData};
use rand::Rng;
use rand::SeedableRng;
use rand::rngs::StdRng;

const WIDTH: usize = 80;
const HEIGHT: usize = 24;

pub struct AsciiRenderer {
    frame_count: usize,
    rng: StdRng,
}

impl AsciiRenderer {
    pub fn new() -> Self {
        Self {
            frame_count: 0,
            rng: StdRng::from_entropy(),
        }
    }

    pub fn render(&mut self, weather: Option<&WeatherData>, metric: bool) -> String {
        let binding = crate::weather::generate_demo_weather();
        let data = weather.unwrap_or(&binding);
        
        let mut buffer = vec![vec![' '; WIDTH]; HEIGHT];
        
        self.render_sky(data);
        self.render_sun_moon(data);
        self.render_clouds(data);
        self.render_precipitation(data);
        self.render_house();
        self.render_ground(data);
        self.render_info(data, metric);
        
        self.frame_count += 1;
        
        buffer
            .iter()
            .map(|row| row.iter().collect::<String>())
            .collect::<Vec<_>>()
            .join("\n")
    }

    fn render_sky(&mut self, weather: &WeatherData) -> Vec<Vec<char>> {
        let mut buffer = vec![vec![' '; WIDTH]; HEIGHT - 8];
        let sky_char = if weather.is_day { '.' } else { '.' };
        for y in 0..HEIGHT - 8 {
            for x in 0..WIDTH {
                if self.rng.gen_range(0..100) < (if weather.is_day { 3 } else { 8 }) {
                    buffer[y][x] = sky_char;
                }
            }
        }
        buffer
    }

    fn render_sun_moon(&self, weather: &WeatherData) -> (char, usize, usize) {
        if weather.is_day {
            ('☀', 65, 2)
        } else {
            ('🌙', 65, 2)
        }
    }

    fn render_clouds(&self, weather: &WeatherData) -> Vec<&'static str> {
        match weather.condition {
            WeatherCondition::Clear => vec!["   _   ", "  ( )  ", "   ~   "],
            WeatherCondition::PartlyCloudy => vec!["  __   ", " ( _ ) ", "   ~   "],
            WeatherCondition::Cloudy | WeatherCondition::Overcast => vec!["  ___  ", " ( _ ) ", " (___) "],
            _ => vec!["  ___  ", " ( _ ) ", " (___) "],
        }
    }

    fn render_precipitation(&mut self, weather: &WeatherData) -> Vec<(usize, usize, char)> {
        let mut drops = Vec::new();
        
        if weather.condition.is_raining() || weather.condition.is_snowing() {
            let intensity = (weather.precipitation * 3.0) as usize;
            let intensity = intensity.min(20);
            
            let (symbol, drift) = if weather.condition.is_snowing() {
                ('*', -1)
            } else {
                ('|', 1)
            };
            
            for _ in 0..intensity {
                let x = self.rng.gen_range(0..WIDTH);
                let y = self.rng.gen_range(5..HEIGHT - 8);
                
                let new_y = (y as i32 + drift as i32 + self.frame_count as i32 % 3) as usize;
                if new_y < HEIGHT - 8 && new_y >= 5 {
                    drops.push((new_y, x, symbol));
                }
            }
        }
        
        if weather.condition.is_stormy() && self.frame_count % 60 < 5 {
            let x = self.rng.gen_range(10..WIDTH - 10);
            drops.push((8, x, '⚡'));
        }
        
        drops
    }

    fn render_house(&self) -> Vec<(usize, usize, char)> {
        let mut chars = Vec::new();
        let house_x = 30;
        let ground_y = HEIGHT - 8;
        
        chars.push((ground_y, house_x + 5, '/'));
        chars.push((ground_y, house_x + 6, '\\'));
        chars.push((ground_y, house_x + 7, '_'));
        chars.push((ground_y, house_x + 8, '_'));
        chars.push((ground_y, house_x + 9, '\\'));
        
        for i in 1..=3 {
            chars.push((ground_y + i, house_x + 4, '|'));
            chars.push((ground_y + i, house_x + 10, '|'));
        }
        
        for i in 5..=9 {
            chars.push((ground_y + 2, house_x + i, '_'));
        }
        
        chars.push((ground_y + 1, house_x + 7, '█'));
        
        for i in 0..4 {
            chars.push((ground_y + i, house_x + 14, '|'));
        }
        for i in 13..=15 {
            chars.push((ground_y + 2, house_x + i, '_'));
        }
        
        for i in 0..4 {
            chars.push((ground_y + i, house_x + 20, '|'));
        }
        for i in 19..=21 {
            chars.push((ground_y + 2, house_x + i, '_'));
        }
        
        for i in 0..3 {
            chars.push((ground_y - 2 - i, house_x + 7 - i, '/'));
            chars.push((ground_y - 2 - i, house_x + 7 + i, '\\'));
        }
        for i in 4..=10 {
            chars.push((ground_y - 3, house_x + i, '_'));
        }
        
        chars
    }

    fn render_ground(&mut self, weather: &WeatherData) -> (Vec<(usize, usize, char)>, char) {
        let ground_y = HEIGHT - 8;
        let mut chars = Vec::new();
        
        for x in 0..WIDTH {
            let c = if weather.is_day && weather.condition != WeatherCondition::Snow 
                && weather.condition != WeatherCondition::SnowGrains 
                && weather.condition != WeatherCondition::SnowShowers {
                '_'
            } else {
                '~'
            };
            chars.push((ground_y, x, c));
        }
        
        let ground_char = if weather.condition == WeatherCondition::Snow {
            '*'
        } else if !weather.is_day {
            '.'
        } else {
            ','
        };
        
        for y in ground_y + 1..HEIGHT {
            for x in 0..WIDTH {
                if self.rng.gen_range(0..100) < 30 {
                    chars.push((y, x, ground_char));
                }
            }
        }
        
        chars.push((ground_y - 2, 10, '^'));
        chars.push((ground_y - 1, 10, '^'));
        chars.push((ground_y, 10, '|'));
        chars.push((ground_y + 1, 10, '|'));
        
        chars.push((ground_y - 1, 65, '^'));
        chars.push((ground_y, 65, '|'));
        chars.push((ground_y + 1, 65, '|'));
        
        (chars, ground_char)
    }

    fn render_info(&self, weather: &WeatherData, metric: bool) -> String {
        let temp_unit = if metric { "°C" } else { "°F" };
        format!("{} {:.0}{} | Wind: {:.0} km/h", 
            weather.condition.as_str(), 
            weather.temperature, 
            temp_unit,
            weather.wind_speed
        )
    }
}
