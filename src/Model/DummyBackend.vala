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

namespace Activities.Model {

    public class DummyBackend : Object, Backend {

        private Collection<Task> tasks;
        private Collection<Activity> activities;

        public DummyBackend() {
            this.tasks = new ArrayList<Task>();
            this.activities = new ArrayList<Activity>();

            var task1 = new Task("t1");
            task1.key = "TK-01";
            task1.description = "Reading email";
            task1.closed = false;
            this.tasks.add(task1);

            var task2 = new Task("t2");
            task2.key = "TK-08";
            task2.description = "Project A";
            task2.notes = "TODO :\n - specs\n - ???\n - profit";
            task2.closed = false;
            this.tasks.add(task2);

            var task3 = new Task("t3");
            task3.key = null;
            task3.description = "Important Project";
            this.tasks.add(task3);

            var activity = new Model.Activity("a1");
            activity.description = "";
            activity.task = task2;
            activity.start_date = new DateTime.local(2013, 12, 25, 9, 0, 0);
            activity.end_date = new DateTime.local(2013, 12, 25, 12, 0, 0);
            this.activities.add(activity);

            activity = new Model.Activity("a2");
            activity.description = "Work on project A";
            activity.task = task2;
            activity.start_date = new DateTime.local(2013, 12, 25, 13, 0, 0);
            activity.end_date = new DateTime.local(2013, 12, 25, 17, 30, 0);
            this.activities.add(activity);

            activity = new Model.Activity("a3");
            activity.description = "Bug fixing";
            activity.task = task2;
            activity.start_date = new DateTime.local(2013, 12, 24, 9, 15, 0);
            activity.end_date = new DateTime.local(2013, 12, 24, 10, 30, 0);
            this.activities.add(activity);
        }

        public string get_id() {
            return "dummy_backend";
        }

        public string get_name() {
            return "Dummy Backend";
        }

        public string get_icon_name() {
            return "dummy-backend-icon";
        }

        public void synchronize_tasks(TaskStore task_store) {
            task_store.clear();
            foreach (var t in this.tasks) {
                task_store.add(t);
            }
        }

        public void synchronize_activities(ActivityStore activity_store) {
            activity_store.clear();
            foreach (var a in this.activities) {
                activity_store.add(a);
            }
        }
    }
}