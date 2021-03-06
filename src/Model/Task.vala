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

    // TODO : status

    public class Task : GLib.Object {

        internal string local_id { public get; set; }
        internal string? remote_id { public get; set; }
        internal string? key { public get; set; }
        internal string description { public get; set; }
        internal string notes { public get; set; }
        internal bool closed { public get; set; }

        // TODO : icon (i.e. bug/feature request), priority

        public Task(string local_id) {
            this.local_id = local_id;
            this.description = "";
            this.notes = "";
            this.closed = false;
        }

        public Task.copy_from(Task t) {
            this.local_id = t.local_id;
            this.remote_id = t.remote_id;
            this.key = t.key;
            this.description = t.description;
            this.notes = t.notes;
            this.closed = t.closed;
        }

        public string to_string() {
            return "Task {local_id=%s, remote_id=%s, key=%s, description=%s, notes=%s, closed=%s}".printf(
                this.local_id,
                this.remote_id ?? "(null)",
                this.key ?? "(null)",
                this.description,
                this.notes,
                this.closed.to_string());
        }
    }
}
