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

namespace Activities.View {

    public class MainWindow : Gtk.Window {

        public signal void project_selected(Model.Project? project);
        public signal void activity_selected(Model.Activity? activity);
        public signal void activity_updated(Model.Activity activity);

        public Model.Project visible_project {
            get {
                return _project;
            }

            set {
                this._project = value;
                if (value == null) {
                    // TODO !
                    debug("Showing project: NULL\n");
                    this.activity_list.model = new Model.ActivityStore();
                    this.activity_detail_view.task_store = new Model.TaskStore();
                    this.activity_detail_view.backend = new Model.DummyBackend(); // TODO
                } else {
                    debug("Showing project: %s\n", value.name);
                    this.activity_list.model = value.activity_store;
                    this.activity_detail_view.task_store = value.task_store;
                    this.activity_detail_view.backend = value.backend;
                }
                this.project_selected(value);
            }
        }

        public Model.Activity? visible_activity {
            get {
                return this.activity_detail_view.activity;
            }
            set {
                this.activity_detail_view.activity = value;
                this.select_activity(value);
            }
        }

        private Granite.Widgets.SourceList project_list;
        private View.ActivityList activity_list;
        private ActivityDetailView activity_detail_view;
        private Model.Project _project;

        public MainWindow(string title) {
            this.title = title;
            this.icon_name = "preferences-system-time";
            this.set_size_request(700, 400);

            this.create_project_list();
            this.create_activity_list();
            this.create_activity_detail_view();
            this.layout();
        }

        private void create_project_list() {
            // TODO : expand the source list by default
            this.project_list = new Granite.Widgets.SourceList();
            this.project_list.set_size_request(150, -1);

            // HACK - this is just to see it on the screen
            var local_item = new Granite.Widgets.SourceList.ExpandableItem("Local");
            var trash_item = new Granite.Widgets.SourceList.Item("Trash");
            local_item.add(trash_item);

            this.project_list.root.add(local_item);
        }

        private void create_activity_list() {
            // TODO : make this the All store that aggregates all projects
            var dummy_store = new Model.ActivityStore();

            this.activity_list = new View.ActivityList(dummy_store);
            this.activity_list.get_selection().changed.connect(() => {
                debug("Selection changed\n");
                Gtk.TreeModel model;
                Gtk.TreeIter iter;
                if (this.activity_list.get_selection().get_selected(out model, out iter)) {
                    GLib.Value v;
                    this.activity_list.model.get_value(iter, 0, out v);
                    debug("Selection => %s\n", ((Model.Activity) v).to_string());
                    this.activity_selected((Model.Activity) v);
                } else {
                    debug("Selection => NULL\n");
                    this.activity_selected(null);
                }
            });
        }

        private void create_activity_detail_view() {
            this.activity_detail_view = new ActivityDetailView();
            this.activity_detail_view.changed.connect(() => {
                this.activity_updated(activity_detail_view.activity);
            });
        }

        private void layout() {
            Gtk.ScrolledWindow scroller = new Gtk.ScrolledWindow(null, null);
            scroller.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
            scroller.set_size_request(200, -1);
            scroller.add(this.activity_list);

            // TODO : make the orientation a parmeter
            // TODO : when VERTICAL, the detail panel must be smaller
            var split_panel = new Granite.Widgets.ThinPaned(Gtk.Orientation.HORIZONTAL);
            split_panel.pack1(scroller, false, true);
            split_panel.pack2(this.activity_detail_view, true, false);

            var split_split_panel = new Granite.Widgets.ThinPaned();
            split_split_panel.pack1(this.project_list, false, true);
            split_split_panel.pack2(split_panel, true, true);
            this.add(split_split_panel);
        }

        private void select_activity(Model.Activity? activity) {
            var selection = this.activity_list.get_selection();

            bool found = false;
            if (activity != null) {
                this.activity_list.model.@foreach((model, path, iter) => {
                    GLib.Value v;
                    this.activity_list.model.get_value(iter, 0, out v);
                    if (v == activity) {
                        found = true;
                        if (!selection.iter_is_selected(iter)) {
                            selection.select_iter(iter);
                        }
                        return true;
                    }
                    return false;
                });
            }

            if (!found) {
                selection.unselect_all();
            }
        }

        public void add_project(Model.Project project) {
            // TODO : icons
            var project_item = new Granite.Widgets.SourceList.Item(project.name);

            var parent_item = this.get_backend_parent_item(project);
            parent_item.add(project_item);

            this.project_list.item_selected.connect((item) => {
                if (item == project_item) {
                    this.visible_project = project;
                }
            });

            // Show the most recent project
            this.visible_project = project;
        }

        public void remove_project(Model.Project project) {
            // TODO
        }

        private Granite.Widgets.SourceList.ExpandableItem get_backend_parent_item(Model.Project project) {
            var children_copy = new Gee.ArrayList<Granite.Widgets.SourceList.Item>();
            children_copy.add_all(this.project_list.root.children);

            foreach (var item in children_copy) {
                if (item is Granite.Widgets.SourceList.ExpandableItem) {
                    if (item.name == project.backend.get_name()) {
                        return (Granite.Widgets.SourceList.ExpandableItem) item;
                    }
                }
            }

            // TODO : icon
            var parent_item = new Granite.Widgets.SourceList.ExpandableItem(project.backend.get_name());
            this.project_list.root.add(parent_item);
            return parent_item;
        }
    }
}