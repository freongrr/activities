// Copyright Fabien Cortina <fabien.cortina@gmail.com>

namespace TimeShift.Settings {

    public enum WindowState {
        NORMAL = 0,
        MAXIMIZED = 1,
        FULLSCREEN = 2
    }

    public class SavedState : Granite.Services.Settings {

        public int window_width { get; set; }
        public int window_height { get; set; }
        public WindowState window_state { get; set; }

        public SavedState() {
            base("fabien.timeshift.savedstate");
        }
    }
}