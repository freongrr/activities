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

namespace Activities.Model {

    public class ActivityStore : Gtk.ListStore {

        internal Serializer serializer;

        public ActivityStore() {
            this.set_column_types({typeof (Activity)});
            // this.set_default_sort_func(sort_by_date);
            this.set_sort_column_id(Gtk.SortColumn.DEFAULT, Gtk.SortType.DESCENDING);
        }

        public void add_record(Activity activity) {
            Gtk.TreeIter iter;
            this.append(out iter);
            this.set_value(iter, 0, activity);

            if (this.serializer != null) {
                this.serializer.create_activity(activity);
            }
        }

        public void update_record(Activity activity) {
            this.@foreach((model, path, iter) => {
                GLib.Value v;
                this.get_value(iter, 0, out v);
                if (activity.local_id == ((Activity) v).local_id) {
                    this.set_value(iter, 0, activity);
                    return true;
                }
                return false;
            });

            if (this.serializer != null) {
                this.serializer.update_activity(activity);
            }
        }

        public void delete_record(Activity activity) {
            this.@foreach((model, path, iter) => {
                GLib.Value v;
                this.get_value(iter, 0, out v);
                if (v == activity) {
                    this.remove(iter);
                    return true;
                }
                return false;
            });

            if (this.serializer != null) {
                this.serializer.delete_activity(activity);
            }
        }
    }
}