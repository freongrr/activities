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

    public class ActivityListView : Gtk.TreeView {

        public ActivityListView(Model.ActivityListStore store) {
            set_model(store);

            append_column(create_column());
        }

        private static Gtk.TreeViewColumn create_column() {
            //var renderer = new ActivityListCellRenderer();
            var column = new Gtk.TreeViewColumn();
            column.set_title("Activity");
//            column.set_attributes(renderer, "activity_attribute", 0);
            column.set_resizable(true);
  
//            column.set_sizing(Gtk.TreeViewColumnSizing.FIXED);
//            column.set_fixed_width(200);

            return column;
        }
    }
}
