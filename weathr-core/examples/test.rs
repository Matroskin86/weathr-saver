use weathr::weathr_init;
use weathr::weathr_render_frame;
use weathr::weathr_free_string;

fn main() {
    println!("Starting weathr test...");
    
    unsafe {
        weathr_init();
        println!("weathr_init() called");
        
        let frame = weathr_render_frame();
        if frame.is_null() {
            println!("ERROR: weathr_render_frame() returned NULL");
        } else {
            let s = std::ffi::CStr::from_ptr(frame).to_string_lossy();
            println!("Frame received:\n{}", s);
            weathr_free_string(frame);
        }
    }
    
    println!("Test complete!");
}
