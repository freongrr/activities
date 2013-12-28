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

    // TODO : this does not have to be an interface
    //         maybe we should have a ActivitySource and TaskSource
    public interface Project : GLib.Object {

        public abstract string get_uid();

        public abstract string get_localized_name();

        public abstract Backend get_backend();

        public abstract Gee.List<Activity> get_activities();
    }

    public class DummyProject : GLib.Object, Project {

        private string uid;
        private string localized_name;
        private Gee.List<Activity> activities;
        private Backend backend;

        public DummyProject(string uid, string localized_name) {
            this.uid = uid;
            this.localized_name = localized_name;
            this.backend = new DummyBackend();
            this.activities = new Gee.ArrayList<Activity>();

            var task1 = new Task();
            task1.uid = "t1";
            task1.key = "TK-01";
            task1.description = "Reading email";
            task1.closed = false;

            var task2 = new Task();
            task2.uid = "t2";
            task2.key = "TK-08";
            task2.description = "Work";
            task2.closed = false;

            var dummyActivity = new Model.Activity();
            dummyActivity.uid = "a1";
            dummyActivity.description = "";
            dummyActivity.task = task1;
            dummyActivity.start_date = new LocalDateTime(2013, 12, 25, 9, 0, 0);
            dummyActivity.end_date = new LocalDateTime(2013, 12, 25, 12, 0, 0);

            activities.add(dummyActivity);

            dummyActivity = new Model.Activity();
            dummyActivity.uid = "a2";
            dummyActivity.description = "Work on project A";
            dummyActivity.task = task2;
            dummyActivity.start_date = new LocalDateTime(2013, 12, 25, 13, 0, 0);
            dummyActivity.end_date = new LocalDateTime(2013, 12, 25, 17, 30, 0);

            activities.add(dummyActivity);

            dummyActivity = new Model.Activity();
            dummyActivity.uid = "a3";
            dummyActivity.description = "Bug fixing";
            dummyActivity.task = task2;
            dummyActivity.start_date = new LocalDateTime(2013, 12, 24, 8, 45, 0);
            dummyActivity.end_date = new LocalDateTime(2013, 12, 24, 17, 15, 0);

            activities.add(dummyActivity);
        }

        public string get_uid() {
            return this.uid;
        }

        public string get_localized_name() {
            return this.localized_name;
        }

        public Backend get_backend() {
            return this.backend;
        }

        public Gee.List<Activity> get_activities() {
            return this.activities;
        }
    }
}
