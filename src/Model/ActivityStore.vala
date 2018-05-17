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

using Gee;
using Gtk;

namespace Activities.Model {

    public class ActivityStore : Gtk.ListStore {

        // HACK - I would not need that if ListStore even gave me the created/deleted values...
        public signal void created(Activity activity);
        public signal void updated(Activity activity);
        public signal void deleted(Activity activity);

        internal DateTime? last_synchronization;

        public ActivityStore() {
            this.set_column_types({typeof (Activity)});
            this.set_default_sort_func(sort_by_date);
            this.set_sort_column_id(SortColumn.DEFAULT, SortType.DESCENDING);
        }

        private int sort_by_date(TreeModel model, TreeIter iter_a, TreeIter iter_b) {
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

        public Activity new_activity() {
            var local_id = "activity";
            local_id += "_" + new GLib.DateTime.now_utc().to_unix().to_string();
            local_id += "_" + GLib.Random.int_range(0, 999).to_string();

            var activity = new Activity(local_id);
            add(activity);
            return activity;
        }

        public bool contains(Activity activity) {
            return find(activity) != null;
        }

        private TreeIter? find(Activity activity) {
            TreeIter? found = null;
            this.@foreach((model, path, iter) => {
                GLib.Value v;
                this.get_value(iter, 0, out v);
                if (activity.local_id == ((Activity) v).local_id ||
                    activity.remote_id != null && activity.remote_id == ((Activity) v).remote_id) {
                    found = iter;
                    return true;
                }
                return false;
            });
            return found;
        }

        public void add(Activity activity) {
            if (contains(activity)) {
                warning("%s is already in the store", activity.to_string());
                return;
            }

            debug("Adding to the store: %s", activity.to_string());

            Gtk.TreeIter iter;
            this.append(out iter);
            this.@set(iter, 0, activity);

            this.created(activity);
        }

        public void update(Activity activity) {
            var iter = find(activity);
            if (iter == null) {
                warning("Can't find %s in the store", activity.to_string());
                return;
            }

            debug("Updating the store: %s", activity.to_string());
            this.@set(iter, 0, activity);

            this.updated(activity);
        }

        public void @delete(Activity activity) {
            var iter = find(activity);
            if (iter == null) {
                warning("Can't find %s in the store", activity.to_string());
            } else {
                debug("Removing in the store: %s", activity.to_string());
                this.remove(ref iter);

                this.deleted(activity);
            }
        }
    }
}

