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

    public class JIRABackend : RemoteBackend {

        private string base_url = "https://jira.atlassian.com";

        public override string get_id() {
            return "jira";
        }

        public override string get_name() {
            return "JIRA";
        }

        public override override string get_icon_name() {
            return "TODO";
        }

        public override Gee.Collection<Task> find_tasks(string query) {
            // TODO
            return new Gee.ArrayList<Task>();
        }

        protected override Gee.Collection<Activity> fetch_activities(int days) {
            var session = new Soup.SessionSync();

            var issue_id = "JRA-9";
            var url = base_url + "/rest/api/latest/" + "/issue/" + issue_id + "/worklog";
            var request = session.request_http("GET", url);


            return new Gee.ArrayList<Activity>();
        }

        protected override void create_remote_activity(Activity activity) {
            // TODO
        }

        protected override void update_remote_activity(Activity activity) {
            // TODO
        }

        protected override void delete_remote_activity(Activity activity) {
            // TODO
        }
    }
}