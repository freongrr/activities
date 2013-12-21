/***
  Copyright(C) 2013-2014 Fabien Cortina <fabien.cortina@gmail.com>
  This program is free software: you can redistribute it and/or modify it
  under the terms of the GNU Lesser General Public License version 3, as published
  by the Free Software Foundation.
  This program is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranties of
  MERCHANTABILITY, SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR
  PURPOSE. See the GNU General Public License for more details.
  You should have received a copy of the GNU General Public License along
  with this program. If not, see
***/

namespace Activities.View {

    public class MainWindow : Gtk.Window {

        public MainWindow(string title) {
            this.title = title;
            this.icon_name = "preferences-system-time";
            this.set_size_request(700, 400);
//            this.default_width = savedState.window_width;
//            this.default_height = savedState.window_height;
//            this.window_position = Gtk.WindowPosition.CENTER;

            // TODO : UI goes here
            this.add(new Gtk.Label("Hello Again World!"));

//            if (savedState.window_state == Settings.WindowState.MAXIMIZED) {
//                this.maximize();
//            } else if (savedState.window_state == Settings.WindowState.FULLSCREEN) {
//                this.fullscreen();
//            }
        }

/*
        void updateSavedState() {
            debug("Updating saved state");

            // Save window state
            if ((this.get_window().get_state() & Settings.WindowState.MAXIMIZED) != 0) {
                savedState.window_state = Settings.WindowState.MAXIMIZED;
            } else if ((this.get_window().get_state() & Settings.WindowState.FULLSCREEN) != 0) {
                savedState.window_state = Settings.WindowState.FULLSCREEN;
            } else {
                savedState.window_state = Settings.WindowState.NORMAL;
            }

            // Save window size
            if (savedState.window_state == Settings.WindowState.NORMAL) {
                int width, height;
                this.get_size(out width, out height);
                savedState.window_width = width;
                savedState.window_height = height;
            }
        }
*/
    }
}