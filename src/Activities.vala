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
        private static bool VERSION = false;
    }

    public class Application : Granite.Application {

        construct {
            Granite.Services.Logger.initialize("Activities");
            Granite.Services.Logger.DisplayLevel = Granite.Services.LogLevel.DEBUG;

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
        private Settings.ProjectDefinitions project_definitions;
        private Model.ProjectManager project_manager;
        private View.MainWindow main_window;

        protected override void activate() {
            if (get_windows() != null) {
                get_windows().data.present(); // present window if app is already running
                return;
            }

            this.saved_state = new Settings.SavedState();
            this.project_definitions = new Settings.ProjectDefinitions();

            this.project_manager = new Model.ProjectManager(this.project_definitions);

            create_main_window();
            create_toolbar();

            add_window(main_window);
            main_window.show_all();

            this.project_manager.load_projects();

            // Add a dummy project
            if (this.project_manager.projects.size == 0) {
//                var jira_backend = Model.JIRABackend.get_default();
//                var jira_project = this.project_manager.create_project("jira_project", "Project 1", jira_backend);
//                this.project_manager.add_project(jira_project);

                var dummy_backend = new Model.DummyBackend();
                var local_project = this.project_manager.create_project("dummy_project", "Work", dummy_backend);
                this.project_manager.add_project(local_project);
            }

            // TODO : synchronize

            Gtk.main();
        }

        private void create_main_window() {
            this.main_window = new View.MainWindow(this.program_name);
            this.main_window.destroy.connect((e) => { Gtk.main_quit(); });
            this.main_window.delete_event.connect((e) => { update_saved_state(); return false; });

            // TODO : this could stay a pure view thing I could not care about
            this.main_window.activity_selected.connect((a) => {
                this.main_window.visible_activity = a;
            });

            this.main_window.activity_updated.connect((a) => {
                // TODO : update the store here or in the view?
                if (this.main_window.visible_project != null) {
                    var current_store = this.main_window.visible_project.store;
                    current_store.update_record(a);
                }
            });

            // TODO : is there no better way to register shortcuts???
            this.main_window.key_press_event.connect((e) => {
                switch (e.keyval) {
                    case Gdk.Key.@q:
                        if ((e.state & Gdk.ModifierType.CONTROL_MASK) != 0) {
                            main_window.destroy();
                        }
                        break;
                }
                return false;
            });

            this.project_manager.project_added.connect((s) => {
                this.main_window.add_project(s);
            });

            this.project_manager.project_added.connect((p) => {
                this.main_window.remove_project(p);
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
            toolbar.title = this.program_name;
            this.main_window.project_selected.connect((p) => {
                debug("Project selected: %s", p == null ? "NULL" : p.name);
                if (p == null) {
                    toolbar.subtitle = "No project selected";
                } else {
                    toolbar.subtitle = p.name;
                }
            });

            // TODO
            toolbar.synchronize_button.clicked.connect(() => this.on_synchronize_activities());
            toolbar.new_button.clicked.connect(() => this.on_new_activity());
            toolbar.resume_button.clicked.connect(() => stdout.printf("Resume button clicked\n"));
            toolbar.stop_button.clicked.connect(() => stdout.printf("Stop button clicked\n"));
            toolbar.delete_button.clicked.connect(() => stdout.printf("Delete button clicked\n"));
            toolbar.menu.about.activate.connect(() => show_about(main_window));

            this.main_window.set_titlebar(toolbar);
            this.main_window.activity_selected.connect((a) => {
                // TODO : test the status (e.g. the activity is started/finished)
                toolbar.resume_button.sensitive = (a != null);
                toolbar.stop_button.sensitive = (a != null);
                toolbar.delete_button.sensitive = (a != null);
            });
        }

        private void on_synchronize_activities() {
            foreach (var project in this.project_manager.projects) {
                debug("Synchronizing %s...", project.name);
                project.backend.synchronize(project.store);
            }
        }

        private void on_new_activity() {
            stdout.printf("New Activity\n");
            var local_id = "activity";
            local_id += "_" + new GLib.DateTime.now_utc().to_unix().to_string();
            local_id += "_" + GLib.Random.int_range(0, 999).to_string();
            this.main_window.visible_activity = new Model.Activity(local_id);
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

        if (CommandLineOption.VERSION) {
            stdout.printf("Activities %s\n", Build.VERSION);
            stdout.printf("Copyright 2013 Fabien Cortina.\n");
            return 0;
        }

        Gtk.init(ref args);

        Application app = new Application();
        return app.run(args);
    }

    private static const OptionEntry[] command_line_options = {
        { "version", 'v', 0, OptionArg.NONE, out CommandLineOption.VERSION, "Print version info and exit", null },
        { null }
    };
}