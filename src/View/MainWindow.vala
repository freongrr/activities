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

        private Granite.Widgets.SourceList source_list;

        public MainWindow(string title) {
            this.title = title;
            this.icon_name = "preferences-system-time";
            this.set_size_request(700, 400);

            this.source_list = new Granite.Widgets.SourceList();

            var local_item = new Granite.Widgets.SourceList.ExpandableItem("Local");
            var trash_item = new Granite.Widgets.SourceList.Item ("Trash");
            local_item.add(trash_item);
            this.source_list.root.add(local_item);

            var split_panel = new Granite.Widgets.ThinPaned();
            split_panel.pack1(source_list, true, false);
            split_panel.pack2(new Gtk.Label("Hello Again World!"), true, false);
            this.add(split_panel);

            // TODO : expand all by default
        }

        public void add_source(Model.Source source) {
            var parent_item = this.get_backend_parent_item(source);

            // TODO : icons
            var source_item = new Granite.Widgets.SourceList.Item(source.get_name());
            parent_item.add(source_item);
        }

        public void remove_source(Model.Source source) {
            // TODO
        }

        private Granite.Widgets.SourceList.ExpandableItem get_backend_parent_item(Model.Source source) {
            var children_copy = new Gee.ArrayList<Granite.Widgets.SourceList.Item>();
            children_copy.add_all(this.source_list.root.children);

            foreach (var item in children_copy) {
                if (item is Granite.Widgets.SourceList.ExpandableItem && item.name == source.get_backend()) {
                    return (Granite.Widgets.SourceList.ExpandableItem) item;
                }
            }

            // TODO : icon
            var parent_item = new Granite.Widgets.SourceList.ExpandableItem(source.get_backend());
            this.source_list.root.add(parent_item);
            return parent_item;
        }
    }
}
