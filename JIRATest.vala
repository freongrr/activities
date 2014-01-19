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

    errordomain MyError {
        DENIED, REQUEST, IO, INVALID_FORMAT
    }

    public class JIRATest : Object {

        private static const string DEFAULT_LOCATION = "http://jira.dev.tradingscreen.com:8080";

        private Soup.URI base_uri;
        private Soup.Session session;

        public JIRATest(string uri, string username, string password) {
            this.base_uri = new Soup.URI(uri);

            this.session = new Soup.Session();

            var logger = new Soup.Logger(Soup.LoggerLogLevel.BODY, -1);
            this.session.add_feature(logger);

            var auth = (Soup.Auth) Object.new(typeof(Soup.AuthBasic));
            auth.authenticate(username, password);

            var auth_manager = (Soup.AuthManager) this.session.get_feature(typeof(Soup.AuthManager));
            auth_manager.use_auth(this.base_uri, auth);
            this.session.add_feature(auth_manager);
        }

        // TODO : use Soup.URI instead
        private UrlBuilder api_url() {
            return new UrlBuilder().protocol("http").host("jira.dev.tradingscreen.com").port(8080).path("rest/api/latest");
        }

        private void search(string predicate, int start_at, int max_results) throws MyError {
            var url = this.api_url();
            url.path("search");
            url.parameter("jql", predicate);
            url.parameter_int("startAt", start_at);
            url.parameter_int("maxResults", max_results);
            url.parameter("fields", "id,key,summary,worklog");

            var node = this.request(url.to_string());

            this.deserialize_search_results(node);
            // TODO
        }

        private void work_log(string issue_id_or_key) throws MyError {
            var url = this.api_url();
            url.path("issue").path(issue_id_or_key).path("worklog");
            //url.parameter_int("startAt", start_at);
            //url.parameter_int("maxResults", max_results);
            //url.parameter("fields", "id,key,summary,worklog");

            var node = this.request(url.to_string());
            this.deserialize_worklogs(node);
        }

        private Json.Node request(string url) throws MyError {
            var json = this.http_get(url);
            return this.parse_json(json);
        }

        private string http_get(string url) throws MyError {
            try {
                Soup.Message message = new Soup.Message("GET", url);
                this.session.send_message(message);

                if (message.status_code == Soup.Status.BAD_REQUEST) {
                    // TODO : extract the errorMessages
                    var error_message = (string) message.response_body.data;
                    throw new MyError.REQUEST("Invalid request: %s", error_message);
                } else if (message.status_code != Soup.Status.OK) {
                    var status_message = Soup.Status.get_phrase(message.status_code);
                    throw new MyError.REQUEST("Bad response: %s", status_message);
                }

                return (string) message.response_body.data;
            } catch (Error e) {
                throw new MyError.REQUEST("Request failed %s", e.message);
            }
        }

        private Json.Node parse_json(string json) throws MyError {
            try {
                Json.Parser parser = new Json.Parser();
                parser.load_from_data(json);
                return parser.get_root();
            } catch (Error e) {
                throw new MyError.INVALID_FORMAT("Can't parse response: %s", e.message);
            }
        }

        private void deserialize_search_results(Json.Node node) throws MyError {
            if (node.get_node_type () != Json.NodeType.OBJECT) {
                throw new MyError.INVALID_FORMAT("Unexpected element type %s", node.type_name());
            }

            // TODO : store in a list and return it

            var wrapper = node.get_object();
            var issues = wrapper.get_array_member("issues");
            issues.foreach_element((array, index, element_node) => {
                try {
                    this.deserialize_issue(element_node);
                    // TODO : add to a list
                } catch (MyError e) {
                    warning("Could not deserialize worklog %s", e.message);
                }
            });
        }

        private void deserialize_issue(Json.Node node) throws MyError {
            if (node.get_node_type () != Json.NodeType.OBJECT) {
                throw new MyError.INVALID_FORMAT("Unexpected element type %s", node.type_name());
            }

            var issue = node.get_object();
            var fields = issue.get_object_member("fields");

            var remote_id = issue.get_string_member("id");
            var key = issue.get_string_member("key");
            var summary = fields.get_string_member("summary");

            stdout.printf("--- Task ---\n");
            stdout.printf("id: %s\n", remote_id);
            stdout.printf("key: %s\n", key);
            stdout.printf("summary: %s\n", summary);

            var worklog_wrapper = fields.get_member("worklog");
            this.deserialize_worklogs(worklog_wrapper);
        }

        private void deserialize_worklogs(Json.Node node) throws MyError {
            if (node.get_node_type () != Json.NodeType.OBJECT) {
                throw new MyError.INVALID_FORMAT("Unexpected element type %s", node.type_name());
            }

            // TODO : store in a list and return it

            var wrapper = node.get_object();
            var entries = wrapper.get_array_member("worklogs");
            entries.foreach_element((array, index, element_node) => {
                try {
                    this.deserialize_worklog(element_node);
                    // TODO : add to the list
                } catch (MyError e) {
                    warning("Could not deserialize worklog %s", e.message);
                }
            });
        }

        private void deserialize_worklog(Json.Node node) throws MyError {
            if (node.get_node_type () != Json.NodeType.OBJECT) {
                throw new MyError.INVALID_FORMAT("Unexpected element type %s", node.type_name());
            }

            var worklog = node.get_object();
            var remote_id = worklog.get_string_member("id");
            var comment = worklog.get_string_member("comment");
            var started = worklog.get_string_member("started");
            var seconds = worklog.get_string_member("timeSpentSeconds");

            stdout.printf("--- Activity ---\n");
            stdout.printf("id: %s\n", remote_id);
            stdout.printf("comment: %s\n", comment);
            stdout.printf("started: %s\n", started);
            stdout.printf("seconds: %s\n", seconds);
        }

        public static int main(string[] args) {
            try {
                var default_username = GLib.Environment.get_variable("USER");

                string location = prompt("JIRA Location", DEFAULT_LOCATION, false);
                string username = prompt("Username", default_username, false);
                string password = prompt("Pasword", "", false);

                var test = new JIRATest(location, username, password);
                //test.search("updated > \"-7d\"", 0, 10);
                test.search("key = \"SP-3214\"", 0, 99);
            } catch (MyError e) {
                stderr.printf("MyError: %s\n", e.message);
            } catch (Error e) {
                stderr.printf("Error: %s\n", e.message);
            }
            return 0;
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