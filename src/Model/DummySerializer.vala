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

    internal class DummySerializer : Object, Serializer {

        internal Gee.Collection<Activity> activities { get; set; }

        internal DummySerializer(string project_id) {
            this.activities = new Gee.LinkedList<Activity>();

            if (project_id == "dummy_project") {

                // Task 1

                var task = new Task("t1");
                task.key = "TK-01";
                task.description = "Reading email";
                task.closed = false;

                var activity = new Model.Activity("a1");
                activity.description = "";
                activity.task = task;
                activity.start_date = new DateTime.local(2013, 12, 25, 9, 0, 0);
                activity.end_date = new DateTime.local(2013, 12, 25, 12, 0, 0);
                this.activities.add(activity);

                // Task 2

                task = new Task("t2");
                task.key = "TK-08";
                task.description = "Project A";
                task.notes = "TODO :\n - specs\n - ???\n - profit";
                task.closed = false;

                activity = new Model.Activity("a2");
                activity.description = "Work on project A";
                activity.task = task;
                activity.start_date = new DateTime.local(2013, 12, 25, 13, 0, 0);
                activity.end_date = new DateTime.local(2013, 12, 25, 17, 30, 0);
                this.activities.add(activity);

                activity = new Model.Activity("a3");
                activity.description = "Bug fixing";
                activity.task = task;
                activity.start_date = new DateTime.local(2013, 12, 24, 9, 15, 0);
                activity.end_date = new DateTime.local(2013, 12, 24, 10, 30, 0);
                this.activities.add(activity);
            }
        }

        internal Gee.Collection<Activity> load_activities() {
            return this.activities;
        }

        internal void create_activity(Activity activity) {
        }

        internal void update_activity(Activity activity) {
        }

        internal void delete_activity(Activity activity) {
        }
    }
}