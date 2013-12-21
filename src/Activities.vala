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

namespace Activities {

    namespace CommandLineOption {
        private static bool PRINT_VERSION = false;
    }

    private Application app;

    public static int main(string[] args) {

        var context = new OptionContext("Activities");
        context.set_help_enabled(true);
        context.add_main_entries(command_line_options, "activities");
        context.add_group(Gtk.get_option_group(true));

        try {
            context.parse(ref args);
        } catch(Error e) {
            warning(e.message);
        }

        if(CommandLineOption.PRINT_VERSION) {
            stdout.printf("Activities %s\n", Build.VERSION);
            stdout.printf("Copyright 2013 Fabien Cortina.\n");
            return 0;
        }

        Gtk.init(ref args);
        app = new Application();
        return app.run(args);
    }

    private static const OptionEntry[] command_line_options = {
        { "version", 'v', 0, OptionArg.NONE, out CommandLineOption.PRINT_VERSION, "Print version info and exit", null },
        { null }
    };

    public class Application : Granite.Application {

        construct {
            build_data_dir = Build.DATADIR;
            build_pkg_data_dir = Build.PKGDATADIR;
            build_release_name = Build.RELEASE_NAME;
            build_version = Build.VERSION;
            build_version_info = Build.VERSION_INFO;

            program_name = "Activities";
            exec_name = "activities";

            app_years = "2013-2014";
            application_id = "lp.fabien.cortina.activities"; // TODO ???
            app_icon = "clock";
            app_launcher = "activities.desktop";

            // TODO
            main_url = "https://launchpad.net/~fabien.cortina";
            bug_url = "https://bugs.launchpad.net/~fabien.cortina";
            help_url = "https://answers.launchpad.net/~fabien.cortina";
            translate_url = "https://translations.launchpad.net/~fabien.cortina";

            about_authors = {"Fabien Cortina <fabien.cortina@gmail.com>"};
            about_license_type = Gtk.License.GPL_3_0;
        }

        private Settings.SavedState savedState;
        private Gtk.Window window;

        protected override void activate() {
            if (get_windows() != null) {
                get_windows().data.present(); // present window if app is already running
                return;
            }

            initPreferences();
            initUI();
            window.show_all();

            Gtk.main();
        }

        void initPreferences() {
            savedState = new Settings.SavedState();
        }

        void initUI() {
            createWindow();
            createToolbar();

            // TODO : UI goes here
            window.add(new Gtk.Label("Hello Again World!"));

            add_window(window);

            if (savedState.window_state == Settings.WindowState.MAXIMIZED) {
                window.maximize();
            } else if (savedState.window_state == Settings.WindowState.FULLSCREEN) {
                window.fullscreen();
            }
        }

// TODO : move to an other class
        void createWindow() {
            window = new Gtk.Window();
            window.title = program_name;
            window.icon_name = "clock";
            window.set_size_request(700, 400);
            window.default_width = savedState.window_width;
            window.default_height = savedState.window_height;
            window.window_position = Gtk.WindowPosition.CENTER;

            window.delete_event.connect((e) => {
                updateSavedState();
                return false;
            });

            window.destroy.connect((e) => { Gtk.main_quit(); });

            // TODO : is there no better way to register shortcuts???
            window.key_press_event.connect((e) => {
                switch (e.keyval) {
                    case Gdk.Key.@q:
                        if ((e.state & Gdk.ModifierType.CONTROL_MASK) != 0) {
                            window.destroy();
                        }
                        break;
                }
                return false;
            });
        }

        void createToolbar() {
            View.AppToolbar toolbar = new View.AppToolbar();
            toolbar.menu.about.activate.connect(() => show_about(window));
            window.set_titlebar(toolbar);
        }

        void updateSavedState() {
            debug("Updating saved state");

            // Save window state
            if ((window.get_window().get_state() & Settings.WindowState.MAXIMIZED) != 0) {
                savedState.window_state = Settings.WindowState.MAXIMIZED;
            } else if ((window.get_window().get_state() & Settings.WindowState.FULLSCREEN) != 0) {
                savedState.window_state = Settings.WindowState.FULLSCREEN;
            } else {
                savedState.window_state = Settings.WindowState.NORMAL;
            }

            // Save window size
            if (savedState.window_state == Settings.WindowState.NORMAL) {
                int width, height;
                window.get_size(out width, out height);
                savedState.window_width = width;
                savedState.window_height = height;
            }
        }
    }
}