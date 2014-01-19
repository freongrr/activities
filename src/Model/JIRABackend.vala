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

    errordomain Errors {
        FORBIDDEN, REQUEST, INVALID_FORMAT
    }

    public class JIRABackend : RemoteBackend {

        private static const string DEFAULT_LOCATION = "http://jira.dev.tradingscreen.com:8080";

        private string username;
        private Soup.URI base_uri;
        private Soup.Session session;

        public JIRABackend(string uri, string username, string password) {
            this.username = username;
            this.base_uri = new Soup.URI(uri);

            this.session = new Soup.Session();
            this.session.timeout = 10;

            var logger = new Soup.Logger(Soup.LoggerLogLevel.BODY, -1);
            this.session.add_feature(logger);

            var auth = (Soup.Auth) Object.new(typeof(Soup.AuthBasic));
            auth.authenticate(username, password);

            var auth_manager = (Soup.AuthManager) this.session.get_feature(typeof(Soup.AuthManager));
            auth_manager.use_auth(this.base_uri, auth);
            this.session.add_feature(auth_manager);
        }

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
            try {
                return this.search("SP", days, 0, 99);
            } catch (Errors e) {
                critical("Error fetching activies: %s", e.message);
                return new Gee.ArrayList<Activity>();
            }
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

        /* INTERNAL */

        // I don't like Soup.URI
        private Utils.UrlBuilder api_url() {
            return new Utils.UrlBuilder()
                .protocol(this.base_uri.scheme)
                .host(this.base_uri.host)
                .port(this.base_uri.port)
                .path("rest/api/latest");
        }

        private Gee.Collection<Activity> search(string project, int days, int start_at, int max_results) throws Errors {
            var predicate = "project = '%s' AND updated > '-%dd'".printf(project, days);

            var url = this.api_url();
            url.path("search");
            url.parameter("jql", predicate);
            url.parameter_int("startAt", start_at);
            url.parameter_int("maxResults", max_results);
            url.parameter("fields", "id,key,summary,worklog");

            var json = this.http_get(url.to_string());
            var node = this.parse_json(json);

            var deserializer = new JIRADeserializer();
            deserializer.username_filter = this.username;
            deserializer.deserialize_search_results(node);

            return deserializer.activities;
        }

        private string http_get(string url) throws Errors {
            try {
                Soup.Message message = new Soup.Message("GET", url);
                this.session.send_message(message);

                if (message.status_code == Soup.Status.BAD_REQUEST) {
                    // TODO : extract the errorMessages
                    var error_message = (string) message.response_body.data;
                    throw new Errors.REQUEST("Invalid request: %s", error_message);
                } else if (message.status_code != Soup.Status.OK) {
                    var status_message = Soup.Status.get_phrase(message.status_code);
                    throw new Errors.REQUEST("Bad response: %s", status_message);
                }

                return (string) message.response_body.data;
            } catch (Error e) {
                throw new Errors.REQUEST("Request failed %s", e.message);
            }
        }

        private Json.Node parse_json(string json) throws Errors {
            try {
                Json.Parser parser = new Json.Parser();
                parser.load_from_data(json);
                return parser.get_root();
            } catch (Error e) {
                throw new Errors.INVALID_FORMAT("Can't parse response: %s", e.message);
            }
        }

        /* TESTING */

        public static JIRABackend get_default() {
            var default_username = GLib.Environment.get_variable("USER");

            var location = prompt("JIRA Location", DEFAULT_LOCATION, false);
            var username = prompt("Username", default_username, false);
            var password = prompt("Pasword", "", false);

            return new JIRABackend(location, username, password);
        }

        private static string prompt(string label, string default_answer, bool secret) {
            if (default_answer != "") {
                stdout.printf("%s [%s]: ", label, default_answer);
            } else {
                stdout.printf("%s: ", label);
            }

            string answer = stdin.read_line();
            if (answer == "") {
                return default_answer;
            } else {
                return answer;
            }
        }
    }
}