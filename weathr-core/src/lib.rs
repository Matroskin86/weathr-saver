mod weather;
mod renderer;
mod scene;

use parking_lot::Mutex;
use once_cell::sync::Lazy;
use std::ffi::{CString, CStr};
use std::ptr;
use std::sync::atomic::{AtomicBool, Ordering};

static INITIALIZED: AtomicBool = AtomicBool::new(false);
static RENDERER: Lazy<Mutex<renderer::AsciiRenderer>> = Lazy::new(|| {
    Mutex::new(renderer::AsciiRenderer::new())
});
static WEATHER_DATA: Lazy<Mutex<Option<weather::WeatherData>>> = Lazy::new(|| Mutex::new(None));
static LAST_FETCH: Lazy<Mutex<std::time::Instant>> = Lazy::new(|| Mutex::new(std::time::Instant::now()));
static LATITUDE: Lazy<Mutex<f64>> = Lazy::new(|| Mutex::new(52.52));
static LONGITUDE: Lazy<Mutex<f64>> = Lazy::new(|| Mutex::new(13.41));
static USE_METRIC: Lazy<Mutex<bool>> = Lazy::new(|| Mutex::new(true));
static CITY_NAME: Lazy<Mutex<String>> = Lazy::new(|| Mutex::new(String::new()));

const REFRESH_INTERVAL_SECS: u64 = 600;
const FRAME_WIDTH: usize = 80;
const FRAME_HEIGHT: usize = 24;

#[no_mangle]
pub extern "C" fn weathr_init() -> i32 {
    if INITIALIZED.load(Ordering::SeqCst) {
        return 0;
    }

    INITIALIZED.store(true, Ordering::SeqCst);
    let _ = weathr_update();
    0
}

#[no_mangle]
pub extern "C" fn weathr_init_with_location(lat: f64, lon: f64, metric: bool, city: *const libc::c_char) {
    *LATITUDE.lock() = lat;
    *LONGITUDE.lock() = lon;
    *USE_METRIC.lock() = metric;
    
    if !city.is_null() {
        let c_str = unsafe { CStr::from_ptr(city) };
        if let Ok(s) = c_str.to_str() {
            *CITY_NAME.lock() = s.to_string();
        }
    }
    
    weathr_init();
}

#[no_mangle]
pub extern "C" fn weathr_update() -> i32 {
    let lat = *LATITUDE.lock();
    let lon = *LONGITUDE.lock();
    let metric = *USE_METRIC.lock();
    
    match weather::fetch_weather(lat, lon, metric) {
        Ok(data) => {
            *WEATHER_DATA.lock() = Some(data);
            *LAST_FETCH.lock() = std::time::Instant::now();
            0
        }
        Err(e) => {
            eprintln!("Failed to fetch weather: {}", e);
            -1
        }
    }
}

#[no_mangle]
pub extern "C" fn weathr_update_if_needed() -> i32 {
    let last_fetch = *LAST_FETCH.lock();
    let elapsed = last_fetch.elapsed().as_secs();
    
    if elapsed >= REFRESH_INTERVAL_SECS {
        weathr_update()
    } else {
        0
    }
}

#[no_mangle]
pub extern "C" fn weathr_render_frame() -> *mut libc::c_char {
    let weather = WEATHER_DATA.lock();
    let weather = weather.as_ref();
    
    let mut renderer = RENDERER.lock();
    let frame = renderer.render(weather, *USE_METRIC.lock());
    
    let c_string = CString::new(frame).unwrap_or_else(|_| CString::new("").unwrap());
    c_string.into_raw()
}

#[no_mangle]
pub extern "C" fn weathr_free_string(s: *mut libc::c_char) {
    if !s.is_null() {
        unsafe {
            let _ = CString::from_raw(s);
        }
    }
}

#[no_mangle]
pub extern "C" fn weathr_get_width() -> usize {
    FRAME_WIDTH
}

#[no_mangle]
pub extern "C" fn weathr_get_height() -> usize {
    FRAME_HEIGHT
}

#[no_mangle]
pub extern "C" fn weathr_set_location(lat: f64, lon: f64) {
    *LATITUDE.lock() = lat;
    *LONGITUDE.lock() = lon;
}

#[no_mangle]
pub extern "C" fn weathr_set_units(metric: bool) {
    *USE_METRIC.lock() = metric;
}

#[no_mangle]
pub extern "C" fn weathr_set_city(city: *const libc::c_char) {
    if !city.is_null() {
        let c_str = unsafe { CStr::from_ptr(city) };
        if let Ok(s) = c_str.to_str() {
            *CITY_NAME.lock() = s.to_string();
        }
    }
}
