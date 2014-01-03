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

        public signal void activity_selected(Model.Activity? activity);

        public Model.Activity visible_activity {
            get {
                return this.activity_detail_view.activity;
            }

            set {
                this.activity_detail_view.activity = value;
                this.select_activity(value);
            }
        }

        private Model.ActivityListStore activity_list_store;
        private Granite.Widgets.SourceList project_list;
        private View.ActivityListView activity_list_view;
        private ActivityDetailView activity_detail_view;

        // TODO : pass the store?
        public MainWindow(string title) {
            this.title = title;
            this.icon_name = "preferences-system-time";
            this.set_size_request(700, 400);

            this.create_project_list();
            this.create_activity_list_view();
            this.create_activity_detail_view();
            this.layout();
        }

        private void create_project_list() {
            // TODO : expand the source list by default
            this.project_list = new Granite.Widgets.SourceList();
            this.project_list.set_size_request(150, -1);

            // HACK - this is just to see it on the screen
            var local_item = new Granite.Widgets.SourceList.ExpandableItem("Local");
            var trash_item = new Granite.Widgets.SourceList.Item ("Trash");
            local_item.add(trash_item);

            this.project_list.root.add(local_item);
        }

        private void create_activity_list_view() {
            this.activity_list_store = new Model.ActivityListStore();

            this.activity_list_view = new View.ActivityListView(this.activity_list_store);
            this.activity_list_view.set_size_request(200, -1);
            this.activity_list_view.get_selection().changed.connect(() => {
                stdout.printf("Selection changed\n");
                Gtk.TreeModel model;
                Gtk.TreeIter iter;
                if (this.activity_list_view.get_selection().get_selected(out model, out iter)) {
                    GLib.Value v;
                    this.activity_list_store.get_value(iter, 0, out v);
                    stdout.printf("Selection => %s\n", ((Model.Activity) v).to_string());
                    this.activity_selected((Model.Activity) v);
                } else {
                    stdout.printf("Selection => NULL\n");
                    this.activity_selected(null);
                }
            });
        }

        private void create_activity_detail_view() {
            this.activity_detail_view = new ActivityDetailView();
            // TODO : listen to events
        }

        private void layout() {
            var split_panel = new Granite.Widgets.ThinPaned();
            split_panel.pack1(this.activity_list_view, false, true);
            split_panel.pack2(this.activity_detail_view, true, false);

            var split_split_panel = new Granite.Widgets.ThinPaned();
            split_split_panel.pack1(this.project_list, false, true);
            split_split_panel.pack2(split_panel, true, true);
            this.add(split_split_panel);
        }

        private void select_activity(Model.Activity activity) {
            bool found = false;
            var selection = this.activity_list_view.get_selection();

            this.activity_list_store.@foreach((model, path, iter) => {
                GLib.Value v;
                this.activity_list_store.get_value(iter, 0, out v);
                if (v == activity) {
                    found = true;
                    if (!selection.iter_is_selected(iter)) {
                        selection.select_iter(iter);
                    }
                    return true;
                }
                return false;
            });

            if (!found) {
                selection.unselect_all();
            }
        }

        public void add_project(Model.Project project) {
            var parent_item = this.get_backend_parent_item(project);

            // TODO : icons
            var project_item = new Granite.Widgets.SourceList.Item(project.name);
            parent_item.add(project_item);

            stdout.printf("Activities in project %s: %d\n", project.name, project.activities.size);
            // TODO : this is just a test. this should be done when the selection changes
            foreach (var activity in project.activities) {
                activity_list_store.add(activity);
            }
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