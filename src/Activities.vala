/***
  BEGIN LICENSE

  Copyright(C) 2013-2014 Fabien Cortina <fabien.cortina@gmail.com>

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program. If not, see <http://www.gnu.org/licenses/>.

  END LICENSE
***/

namespace Activities {

    namespace CommandLineOption {
        private static bool PRINT_VERSION = false;
    }

    public class Application : Granite.Application {

        construct {
            this.build_data_dir = Build.DATADIR;
            this.build_pkg_data_dir = Build.PKGDATADIR;
            this.build_release_name = Build.RELEASE_NAME;
            this.build_version = Build.VERSION;
            this.build_version_info = Build.VERSION_INFO;

            this.program_name = "Activities";
            this.exec_name = "activities";

            this.app_years = "2013-2014";
            this.application_id = "lp.fabien.cortina.activities";
            this.app_icon = "preferences-system-time";
            this.app_launcher = "activities.desktop";

            this.main_url = "https://launchpad.net/~fabien.cortina";
            this.bug_url = "https://bugs.launchpad.net/~fabien.cortina";
            this.help_url = "https://answers.launchpad.net/~fabien.cortina";
            this.translate_url = "https://translations.launchpad.net/~fabien.cortina";

            this.about_authors = {"Fabien Cortina <fabien.cortina@gmail.com>"};
            this.about_license_type = Gtk.License.GPL_3_0;
        }

        private Settings.SavedState saved_state;
        private View.MainWindow main_window;

        protected override void activate() {
            if (get_windows() != null) {
                get_windows().data.present(); // present window if app is already running
                return;
            }

            this.saved_state = new Settings.SavedState();

            create_main_window();
            create_toolbar();

            add_window(main_window);
            main_window.show_all();

            Gtk.main();
        }

        private void create_main_window() {
            main_window = new View.MainWindow(this.program_name);
            main_window.destroy.connect((e) => { Gtk.main_quit(); });
            main_window.delete_event.connect((e) => { update_saved_state(); return false; });

            // TODO : is there no better way to register shortcuts???
            main_window.key_press_event.connect((e) => {
                switch (e.keyval) {
                    case Gdk.Key.@q:
                        if ((e.state & Gdk.ModifierType.CONTROL_MASK) != 0) {
                            main_window.destroy();
                        }
                        break;
                }
                return false;
            });

            restore_state();
        }

        private void restore_state() {
            debug("Restoring from saved state");
            main_window.default_width = saved_state.window_width;
            main_window.default_height = saved_state.window_height;
            main_window.window_position = Gtk.WindowPosition.CENTER;

            if (saved_state.window_state == Settings.WindowState.MAXIMIZED) {
                main_window.maximize();
            } else if (saved_state.window_state == Settings.WindowState.FULLSCREEN) {
                main_window.fullscreen();
            }
        }

        private void update_saved_state() {
            debug("Updating saved state");

            // Save state
            if ((main_window.get_window().get_state() & Settings.WindowState.MAXIMIZED) != 0) {
                saved_state.window_state = Settings.WindowState.MAXIMIZED;
            } else if ((main_window.get_window().get_state() & Settings.WindowState.FULLSCREEN) != 0) {
                saved_state.window_state = Settings.WindowState.FULLSCREEN;
            } else {
                saved_state.window_state = Settings.WindowState.NORMAL;
            }

            // Save size
            if (saved_state.window_state == Settings.WindowState.NORMAL) {
                int width, height;
                main_window.get_size(out width, out height);
                saved_state.window_width = width;
                saved_state.window_height = height;
            }
        }

        private void create_toolbar() {
            View.AppToolbar toolbar = new View.AppToolbar();
            toolbar.menu.about  .activate.connect(() => show_about(main_window));
            toolbar.title = this.program_name;
            toolbar.subtitle = "Keep track of your time";
            main_window.set_titlebar(toolbar);
        }
    }

    public static int main(string[] args) {
        var context = new OptionContext("Activities");
        context.set_help_enabled(true);
        context.add_main_entries(command_line_options, "activities");
        context.add_group(Gtk.get_option_group(true));

        try {
            context.parse(ref args);
        } catch (Error e) {
            warning(e.message);
        }

        if (CommandLineOption.PRINT_VERSION) {
            stdout.printf("Activities %s\n", Build.VERSION);
            stdout.printf("Copyright 2013 Fabien Cortina.\n");
            return 0;
        }

        Gtk.init(ref args);

        Application app = new Application();
        return app.run(args);
    }

    private static const OptionEntry[] command_line_options = {
        { "version", 'v', 0, OptionArg.NONE, out CommandLineOption.PRINT_VERSION, "Print version info and exit", null },
        { null }
    };
}