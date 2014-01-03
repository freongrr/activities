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

    public class Activity : GLib.Object {

        // TODO : This should be nullable. i.e. new activity
        internal string local_id { public get; set; }
        internal string remote_id { public get; set; }
        internal string description { public get; set; }
        internal Task task { public get; set; }
        internal GLib.DateTime start_date { public get; set; }
        internal GLib.DateTime? end_date { public get; set; }
        internal Gee.Set<string> tags { public get; set; default = new Gee.HashSet<string>(); }

        internal Activity() {}

        public string to_string() {
            return "Activity {local_id=%s, remote_id=%s, description=%s, task=%s, start_date=%s, end_date=%s, tags=%d}".printf(
                this.local_id,
                this.remote_id,
                this.description,
                this.task == null ? "(null)" : this.task.to_string(),
                this.start_date == null ? "(null)" : this.start_date.to_string(),
                this.end_date == null ? "(null)" : this.end_date.to_string(),
                this.tags.size);
        }
    }
}