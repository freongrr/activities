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

    public class TaskStore : Gtk.ListStore {

        public TaskStore() {
            this.set_column_types({typeof (Model.Task), typeof (string)});

            var task = new Model.Task("t1");
            task.key = "T-1";
            task.description = "Task 1";

            this.add(task);

            task = new Model.Task("t2");
            task.key = "T-2";
            task.description = "Second task";

            this.add(task);

            task = new Model.Task("t3");
            task.key = "T-3";
            task.description = "Third task";

            this.add(task);
        }

        public void add(Task task) {
            Gtk.TreeIter iter;
            this.append(out iter);
            this.@set(iter, 0, task);
            this.@set(iter, 1, task.key + " - " + task.description);
        }
    }
}