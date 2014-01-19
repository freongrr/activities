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
            var tasks = new Gee.LinkedList<Task>();
            var activities = new Gee.LinkedList<Activity>();

            try {
                this.search("project = 'SP' AND updated > '-7d'", 0, 25, tasks, activities);
            } catch (Errors e) {
                error("Error fetching activies: %s", e.message);
            }

            // TODO : iter over all the activities to keep the recent ones

            return activities;
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

        private void search(string predicate, int start_at, int max_results,
             Gee.Collection<Task> tasks, Gee.Collection<Activity> activities)
             throws Errors {
            debug("Searching issues: '%s' %d-%d", predicate, start_at, max_results);

            var url = this.api_url();
            url.path("search");
            url.parameter("jql", predicate);
            url.parameter_int("startAt", start_at);
            url.parameter_int("maxResults", max_results);
            url.parameter("fields", "id,key,summary,worklog");

            var json = this.http_get(url.to_string());
            var node = this.parse_json(json);

            this.deserialize_search_results(node, tasks, activities);
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

        private void deserialize_search_results(Json.Node node, Gee.Collection<Task> tasks,
            Gee.Collection<Activity> activities) throws Errors {

            debug("Deserializing search results");
            if (node.get_node_type () != Json.NodeType.OBJECT) {
                throw new Errors.INVALID_FORMAT("Unexpected element type %s", node.type_name());
            }

            var result_object = node.get_object();
            this.iterate_on_member(result_object, "issues", (element_node) => {
                try {
                    var task = this.deserialize_issue(element_node, activities);
                    tasks.add(task);
                } catch (Errors e) {
                    warning("Could not deserialize worklog %s", e.message);
                }
            });
        }

        private Task deserialize_issue(Json.Node node, Gee.Collection<Activity> activities) throws Errors {
            debug("Deserializing issue");
            if (node.get_node_type () != Json.NodeType.OBJECT) {
                throw new Errors.INVALID_FORMAT("Unexpected element type %s", node.type_name());
            }

            // TODO : test if the fields exist (or wrap that in a function that throws errors)

            var issue = node.get_object();
            var fields = issue.get_object_member("fields");

            // TODO : what do we use for the local id?
            var task = new Task(issue.get_string_member("id"));
            task.remote_id = issue.get_string_member("id");
            task.key = issue.get_string_member("key");
            task.description = fields.get_string_member("summary");
            // TODO : closed flag?

            if (fields.has_member("worklog")) {
                var worklog = fields.get_member("worklog");

                var task_activities = new Gee.LinkedList<Activity>();
                this.deserialize_worklogs(worklog, task_activities);

                debug("Task has %d activities", task_activities.size);
                foreach (var activity in task_activities) {
                    activity.task = task;
                    activities.add(activity);
                }
            }

            return task;
        }

        private void deserialize_worklogs(Json.Node node, Gee.Collection<Activity> activities) throws Errors {
            debug("Deserializing worklog wrapper: %s", node == null ? "NULL" : node.type_name());

            if (node.get_node_type () != Json.NodeType.OBJECT) {
                throw new Errors.INVALID_FORMAT("Unexpected element type %s", node.type_name());
            }

            var wrapper = node.get_object();
            this.iterate_on_member(wrapper, "worklogs", (element_node) => {
                try {
                    var activity = this.deserialize_worklog(element_node);
                    if (activity != null) {
                        activities.add(activity);
                    }
                } catch (Errors e) {
                    warning("Could not deserialize worklog %s", e.message);
                }
            });
        }

        private Activity? deserialize_worklog(Json.Node node) throws Errors {
            debug("Deserializing worklog");
            if (node.get_node_type () != Json.NodeType.OBJECT) {
                throw new Errors.INVALID_FORMAT("Unexpected element type %s", node.type_name());
            }

            // TODO : test if the members exist

            var worklog = node.get_object();
            var author = worklog.get_member("author").get_object();
            var author_name = author.get_string_member("name");

            // Only keep worklog for the current user
            if (author_name != this.username) {
                return null;
            }

            var remote_id = worklog.get_string_member("id");
            var comment = worklog.get_string_member("comment");
            var started = worklog.get_string_member("started");

            ulong seconds = 0;
            if (worklog.get_string_member("timeSpentSeconds") != null) {
                var second_str = worklog.get_string_member("timeSpentSeconds");
                seconds = long.parse(second_str);
            } else {
                var time_str = worklog.get_string_member("timeSpent");
                seconds = this.parse_time(time_str);
            }

            var start_time = GLib.TimeVal();
            start_time.from_iso8601(started);

            var end_time = start_time;
            end_time.add((long) seconds * 1000 * 1000);

            // TODO : less than ideal...
            var local_id = remote_id;

            var activity = new Activity(local_id);
            activity.remote_id = remote_id;
            activity.description = comment ?? "";
            activity.start_date = new DateTime.from_timeval_local(start_time);
            activity.end_date = new DateTime.from_timeval_local(end_time);
            return activity;
        }

        /* Even more internal... */

        delegate void iterate_func(Json.Node element_node);

        private void iterate_on_member(Json.Object object, string member_name, iterate_func function) {
            if (!object.has_member(member_name)) {
                warning("Object has no member called '%s'", member_name);
                return;
            }

            var member = object.get_member(member_name);
            if (member.get_node_type () != Json.NodeType.ARRAY) {
                warning("Member '%s' is not an array: %s", member_name, member.type_name());
                return;
            }

            var array = member.get_array();
            array.foreach_element((array, index, element_node) => {
                function(element_node);
            });
        }

        // TODO : regexps?
        private ulong parse_time(string time) {
            debug("parsing '%s'", time);
            int n = 0;
            char c = 'z';
            ulong total = 0;
            foreach (var part in time.split(" ")) {
                if (part.scanf("%d%c", &n, &c) == 2) {
                    switch (c) {
                    case 'w':
                        total += ((long) n * 60 * 60 * 24 * 7);
                        break;
                    case 'd':
                        total += ((long) n * 60 * 60 * 24);
                        break;
                    case 'h':
                        total += ((long) n * 60 * 60);
                        break;
                    case 'm':
                        total += ((long) n * 60);
                        break;
                    case 's':
                        total += n;
                        break;
                    default:
                        warning("Unexpected part: %s", part);
                        break;
                    }
                } else {
                    warning("Unexpected part: %s", part);
                }
            }
            debug("total=" + total.to_string());
            return total;
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