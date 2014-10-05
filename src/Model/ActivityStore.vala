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

        public signal void created(Activity activity);
        public signal void updated(Activity activity);
        public signal void deleted(Activity activity);

        internal DateTime? last_synchronization;

        public ActivityStore() {
            this.set_column_types({typeof (Activity)});
            this.set_default_sort_func(sort_by_date);
            this.set_sort_column_id(Gtk.SortColumn.DEFAULT, Gtk.SortType.DESCENDING);
        }

        private int sort_by_date(Gtk.TreeModel model, Gtk.TreeIter iter_a, Gtk.TreeIter iter_b) {
            GLib.Value value_a;
            this.get_value(iter_a, 0, out value_a);

            GLib.Value value_b;
            this.get_value(iter_b, 0, out value_b);

            var start_date_a = ((Activity) value_a).start_date;
            var start_date_b = ((Activity) value_b).start_date;

            if (start_date_a == null) {
                return start_date_b == null ? 0 : -1;
            } else if (start_date_b == null) {
                return 1;
            } else {
                return start_date_a.compare(start_date_b);
            }
        }

        public void add_record(Activity activity) {
            message("Adding an activity in the store");
            Gtk.TreeIter iter;
            this.append(out iter);
            this.set_value(iter, 0, activity);

            this.created(activity);
        }

        public void update_record(Activity activity) {
            bool found = false;
            this.@foreach((model, path, iter) => {
                GLib.Value v;
                this.get_value(iter, 0, out v);
                if (activity.local_id == ((Activity) v).local_id) {
                    found = true;
                    message("Updating the activity in the store");
                    this.set_value(iter, 0, activity);
                    return true;
                }
                return false;
            });

            if (found) {
                this.updated(activity);
            } else {
                warning("Could not find the activity to update in the store");
            }
        }

        public void delete_record(Activity activity) {
            bool found = false;
            this.@foreach((model, path, iter) => {
                GLib.Value v;
                this.get_value(iter, 0, out v);
                if (activity.local_id == ((Activity) v).local_id) {
                    found = true;
                    message("Removing the activity in the store");
                    this.remove(iter);
                    return true;
                }
                return false;
            });

            if (found) {
                this.deleted(activity);
            } else {
                warning("Could not find the activity to remove in the store");
            }
        }
    }
}