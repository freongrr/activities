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

        private Granite.Widgets.SourceList project_list;
        private Model.ActivityListStore activity_store;
        private ActivityDetailView detail_view;

        public MainWindow(string title) {
            this.title = title;
            this.icon_name = "preferences-system-time";
            this.set_size_request(700, 400);

            // Projects

            this.project_list = new Granite.Widgets.SourceList();
            this.project_list.set_size_request(150, -1);

            var local_item = new Granite.Widgets.SourceList.ExpandableItem("Local");
            var trash_item = new Granite.Widgets.SourceList.Item ("Trash");
            local_item.add(trash_item);

            this.project_list.root.add(local_item);

            // TODO : expand the source list by default

            // Activities

            this.activity_store = new Model.ActivityListStore();
            var activity_view = new View.ActivityListView(activity_store);
            activity_view.set_size_request(200, -1);

activity_view.get_selection().changed.connect(() => {
    Gtk.TreeModel model;
    Gtk.TreeIter iter;
    if (activity_view.get_selection().get_selected(out model, out iter)) {
        GLib.Value v;
        this.activity_store.get_value(iter, 0, out v);
        this.detail_view.activity = (Model.Activity) v;
    }
});

            // Details
            this.detail_view = new ActivityDetailView();

            // Layout

            var split_panel = new Granite.Widgets.ThinPaned();
            split_panel.pack1(activity_view, false, true);
            split_panel.pack2(detail_view, true, false);

            var split_split_panel = new Granite.Widgets.ThinPaned();
            split_split_panel.pack1(project_list, false, true);
            split_split_panel.pack2(split_panel, true, true);
            this.add(split_split_panel);
        }

        public void add_project(Model.Project project) {
            var parent_item = this.get_backend_parent_item(project);

            // TODO : icons
            var project_item = new Granite.Widgets.SourceList.Item(project.name);
            parent_item.add(project_item);

            stdout.printf("Activities in project %s: %d\n", project.name, project.activities.size);
            // TODO : this is just a test. this should be done when the selection changes
            foreach (var activity in project.activities) {
                activity_store.add(activity);
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