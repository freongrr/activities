// Copyright Fabien Cortina <fabien.cortina@gmail.com>

namespace TimeShift.Settings {

    public enum WindowState {
        NORMAL = 0,
        MAXIMIZED = 1,
        FULLSCREEN = 2
    }

    public class SavedState : Granite.Services.Settings {

        public int windowWidth { get; set; }
        public int windowHeight { get; set; }
        public WindowState windowState { get; set; }

        public SavedState () {
            base ("fabien.timeshift.savedstate");
        }
    }
}
