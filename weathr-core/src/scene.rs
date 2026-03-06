pub mod scene {
    pub struct WorldScene {
        pub width: usize,
        pub height: usize,
    }

    impl WorldScene {
        pub fn new(width: usize, height: usize) -> Self {
            Self { width, height }
        }

        pub fn update_size(&mut self, width: usize, height: usize) {
            self.width = width;
            self.height = height;
        }
    }
}
