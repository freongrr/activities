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

    public class DummyProjects {

        public Backend dummy_backend { get; private set; }
        public Project work_project { get; private set; }
        public Project personal_project { get; private set; }

        public DummyProjects() {
            this.dummy_backend = create_dummy_backend();
            this.work_project = create_work_project();
            this.personal_project = create_personal_project();
        }

        private Backend create_dummy_backend() {
            var backend = new DummyBackend();
            backend.id = "dummy";
            backend.name = "Dummy";
            backend.icon_name = "activities_backend_dummy";

            var task1 = new Task();
            task1.local_id = "t1";
            task1.key = "TK-01";
            task1.description = "Reading email";
            task1.closed = false;
            backend.tasks.add(task1);

            var task2 = new Task();
            task2.local_id = "t2";
            task2.key = "TK-08";
            task2.description = "Project A";
            task2.notes = "TODO :\n - specs\n - ???\n - profit";
            task2.closed = false;
            backend.tasks.add(task2);

            var activity = new Model.Activity();
            activity.local_id = "a1";
            activity.description = "";
            activity.task = task1;
            activity.start_date = new DateTime.local(2013, 12, 25, 9, 0, 0);
            activity.end_date = new DateTime.local(2013, 12, 25, 12, 0, 0);
            backend.activities.add(activity);

            activity = new Model.Activity();
            activity.local_id = "a2";
            activity.description = "Work on project A";
            activity.task = task2;
            activity.start_date = new DateTime.local(2013, 12, 25, 13, 0, 0);
            activity.end_date = new DateTime.local(2013, 12, 25, 17, 30, 0);
            backend.activities.add(activity);

            activity = new Model.Activity();
            activity.local_id = "a3";
            activity.description = "Bug fixing";
            activity.task = task2;
            activity.start_date = new DateTime.local(2013, 12, 24, 8, 45, 0);
            activity.end_date = new DateTime.local(2013, 12, 24, 17, 15, 0);
            backend.activities.add(activity);

            return backend;
        }

        private Project create_work_project() {
            var project = new Project();
            project.id = "p1";
            project.name = "Work";
            project.backend = dummy_backend;
            project.activities = dummy_backend.get_activities(100);

            return project;
        }

        private Project create_personal_project() {
            var project = new Project();
            project.id = "p2";
            project.name = "Personal";
            project.backend = dummy_backend;
            project.activities = new Gee.ArrayList<Activity>();

            return project;
        }
    }

    internal class DummyBackend : Backend, GLib.Object {

        internal string id;
        internal string name;
        internal string icon_name;
        internal Gee.List<Task> tasks = new  Gee.LinkedList<Task>();
        internal Gee.List<Activity> activities =  new Gee.LinkedList<Activity>();

        public string get_id() {
            return this.id;
        }

        public string get_name() {
            return this.name;
        }

        public string get_icon_name() {
            return this.icon_name;
        }

        public void create_activity(Activity activity) {
        }

        public void update_activity(Activity activity) {
        }

        public void delete_activity(Activity activity) {
        }

        public Gee.Collection<Task> find_tasks(string query) {
            return this.tasks;
        }
    }
}