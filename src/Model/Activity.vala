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

    internal enum Status {
        UP_TO_DATE,
        CREATED_LOCALLY,
        UPDATED_LOCALLY,
        DELETED_LOCALLY;

        // TODO : there's no way this is the proper way to do it...
        public static Status value_of(string name) {
            EnumClass class_ref = (EnumClass) typeof (Status).class_ref();
            unowned EnumValue? eval = class_ref.get_value_by_name (name);
            if (eval == null) {
			    return Status.CREATED_LOCALLY;
		    } else {
                return (Status) eval.value;
            }
        }
    }

    public class Activity : GLib.Object {

        internal Status status { get; set; }

        internal string local_id { public get; set; }
        internal string? remote_id { public get; set; }
        internal string description { public get; set; }
        internal Task? task { public get; set; }
        internal GLib.DateTime? start_date { public get; set; }
        internal GLib.DateTime? end_date { public get; set; }
        internal Gee.Set<string> tags { public get; set; }

        public Activity(string local_id) {
            this.status = Status.UP_TO_DATE;
            this.local_id = local_id;
            this.description = "";
            this.start_date = new DateTime.now_local();
            this.tags = new Gee.HashSet<string>();
        }

        public Activity.copy_from(Activity a) {
            this.status = a.status;
            this.local_id = a.local_id;
            this.remote_id = a.remote_id;
            this.description = a.description;
            this.task = a.task == null ? null : new Model.Task.copy_from(a.task);
            this.start_date = a.start_date;
            this.end_date = a.end_date;
            this.tags = new Gee.HashSet<string>();
            this.tags.add_all(a.tags);
        }

        public string to_string() {
            return "Activity {status=%s, local_id=%s, remote_id=%s, description=%s, task=%s, start_date=%s, end_date=%s, tags=%d}".printf(
                this.status.to_string(),
                this.local_id,
                this.remote_id ?? "(null)",
                this.description,
                this.task == null ? "(null)" : this.task.to_string(),
                this.start_date == null ? "(null)" : this.start_date.to_string(),
                this.end_date == null ? "(null)" : this.end_date.to_string(),
                this.tags.size);
        }
    }
}