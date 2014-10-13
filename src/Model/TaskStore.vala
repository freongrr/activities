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

    public class TaskStore : ListStore {

        // HACK - I would not need that if ListStore even gave me the created/deleted values...
        public signal void created(Task task);
        public signal void updated(Task task);
        public signal void deleted(Task task);

        internal DateTime? last_synchronization;

        public TaskStore() {
            this.set_column_types({typeof (Model.Task), typeof (string)});
        }

        public Task new_task() {
            var local_id = "task";
            local_id += "_" + new GLib.DateTime.now_utc().to_unix().to_string();
            local_id += "_" + GLib.Random.int_range(0, 999).to_string();

            var task = new Task(local_id);
            add(task);
            return task;
        }

        public bool contains(Task task) {
            return find(task) != null;
        }

        private TreeIter? find(Task task) {
            TreeIter? found = null;
            this.@foreach((model, path, iter) => {
                GLib.Value v;
                this.get_value(iter, 0, out v);
                if (task.local_id == ((Task) v).local_id ||
                    task.remote_id != null && task.remote_id == ((Task) v).remote_id) {
                    found = iter;
                    return true;
                }
                return false;
            });
            return found;
        }

        public void add(Task task) {
            if (contains(task)) {
                warning("%s is already in the store", task.to_string());
                return;
            }

            debug("Adding to the store: %s", task.to_string());

            Gtk.TreeIter iter;
            this.append(out iter);
            this.@set(iter, 0, task);
            this.@set(iter, 1, task.description);

            this.created(task);
        }

        public void update(Task task) {
            var iter = find(task);
            if (iter == null) {
                warning("Can't find %s in the store", task.to_string());
                return;
            }

            debug("Updating the store: %s", task.to_string());
            this.@set(iter, 0, task);
            this.@set(iter, 1, task.description);

            this.updated(task);
        }
    }
}
