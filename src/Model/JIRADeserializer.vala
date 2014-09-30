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

    public class JIRADeserializer : Object {

        private delegate void iterate_func(Json.Node element_node);

        internal string? username_filter;
        internal Gee.LinkedList<Task> tasks;
        internal Gee.LinkedList<Activity> activities;

        public JIRADeserializer() {
            this.tasks = new Gee.LinkedList<Task>();
            this.activities = new Gee.LinkedList<Activity>();
        }

        internal void deserialize_search_results(Json.Node node) throws JIRAErrors {
            debug("Deserializing search results");
            if (node.get_node_type () != Json.NodeType.OBJECT) {
                throw new JIRAErrors.INVALID_FORMAT("Unexpected element type %s",
                    node.type_name());
            }

            var wrapper = node.get_object();
            this.iterate_on_member(wrapper, "issues", (element_node) => {
                try {
                    this.deserialize_issue(element_node);
                } catch (JIRAErrors e) {
                    warning("Could not deserialize results: %s", e.message);
                }
            });
        }

        private void deserialize_issue(Json.Node node) throws JIRAErrors {
            debug("Deserializing issue");
            if (node.get_node_type () != Json.NodeType.OBJECT) {
                throw new JIRAErrors.INVALID_FORMAT("Unexpected element type %s",
                    node.type_name());
            }

            var issue = node.get_object();
            var fields = this.get_object_member(issue, "fields");

            // TODO : what do we use for the local id?
            var task = new Task(this.get_string_member(issue, "id"));
            task.remote_id = this.get_string_member(issue, "id");
            task.key = this.get_string_member(issue, "key");
            task.description = this.get_optional_string_member(fields, "summary");
            // TODO : closed flag?

            if (fields.has_member("worklog")) {
                var worklog = fields.get_member("worklog");
                this.deserialize_worklogs(worklog, task);
            }

            this.tasks.add(task);
        }

        private void deserialize_worklogs(Json.Node node, Model.Task? current_task)
                throws JIRAErrors {
            debug("Deserializing worklog wrapper");
            if (node.get_node_type () != Json.NodeType.OBJECT) {
                throw new JIRAErrors.INVALID_FORMAT("Unexpected element type %s",
                    node.type_name());
            }

            var wrapper = node.get_object();
            this.iterate_on_member(wrapper, "worklogs", (element_node) => {
                try {
                    this.deserialize_worklog(element_node, current_task);
                } catch (JIRAErrors e) {
                    warning("Could not deserialize worklog %s", e.message);
                }
            });
        }

        private void deserialize_worklog(Json.Node node, Model.Task? current_task)
                throws JIRAErrors {
            debug("Deserializing worklog");
            if (node.get_node_type () != Json.NodeType.OBJECT) {
                throw new JIRAErrors.INVALID_FORMAT("Unexpected element type %s",
                    node.type_name());
            }

            var worklog = node.get_object();
            var author = this.get_object_member(worklog, "author");
            var author_name = this.get_string_member(author, "name");

            // Only keep worklog for the current user
            // TODO : filter by date
            if (this.username_filter != null && author_name != this.username_filter) {
                return;
            }

            ulong seconds = 0;
            if (this.get_optional_string_member(worklog, "timeSpentSeconds") != "") {
                var second_str = worklog.get_string_member("timeSpentSeconds");
                seconds = long.parse(second_str);
            } else {
                var time_str = this.get_string_member(worklog, "timeSpent");
                seconds = this.parse_time(time_str);
            }

            // TODO : we lose the TimeZone!
            var start_time = GLib.TimeVal();
            var started = this.get_string_member(worklog, "started");
            start_time.from_iso8601(started);

            var end_time = start_time;
            end_time.add((long) seconds * 1000 * 1000);

            // TODO : proper local id
            var activity = new Activity(this.get_string_member(worklog, "id"));
            activity.remote_id = this.get_string_member(worklog, "id");
            activity.task = current_task;
            activity.description = this.get_optional_string_member(worklog, "comment");
            activity.start_date = new DateTime.from_timeval_local(start_time);
            activity.end_date = new DateTime.from_timeval_local(end_time);

            this.activities.add(activity);
        }

        private Json.Object get_object_member(Json.Object object, string member_name)
                throws JIRAErrors {
            if (!object.has_member(member_name)) {
                throw new JIRAErrors.INVALID_FORMAT("Object has no member '%s'", member_name);
            }

            var member = object.get_member(member_name);
            if (member.get_node_type () != Json.NodeType.OBJECT) {
                throw new JIRAErrors.INVALID_FORMAT("Member '%s' is not an object: %s",
                    member_name, member.type_name());
            }

            return member.get_object();
        }

        private string get_string_member(Json.Object object, string member_name)
                throws JIRAErrors {
            if (!object.has_member(member_name)) {
                throw new JIRAErrors.INVALID_FORMAT("Object has no member '%s'", member_name);
            }

            return object.get_string_member(member_name);
        }

        private string get_optional_string_member(Json.Object object, string member_name)
                throws JIRAErrors {
            if (!object.has_member(member_name)) {
                return "";
            } else {
                return object.get_string_member(member_name) ?? "";
            }
        }

        private void iterate_on_member(Json.Object object, string member_name, iterate_func function)
                throws JIRAErrors {
            if (!object.has_member(member_name)) {
                throw new JIRAErrors.INVALID_FORMAT("Object has no member called '%s'",
                    member_name);
            }

            var member = object.get_member(member_name);
            if (member.get_node_type () != Json.NodeType.ARRAY) {
                throw new JIRAErrors.INVALID_FORMAT("Member '%s' is not an array: %s",
                    member_name, member.type_name());
            }

            var array = member.get_array();
            array.foreach_element((array, index, element_node) => {
                function(element_node);
            });
        }

        // TODO : regexps?
        private ulong parse_time(string time) {
            debug("parsing '%s'", time);
            float n = 0;
            char c = 'z';
            ulong total = 0;
            foreach (var part in time.split(" ")) {
                if (part.scanf("%f%c", &n, &c) == 2) {
                    switch (c) {
                    case 'w':
                        total += (uint) (n * 60 * 60 * 24 * 7);
                        break;
                    case 'd':
                        total += (uint) (n * 60 * 60 * 24);
                        break;
                    case 'h':
                        total += (uint) (n * 60 * 60);
                        break;
                    case 'm':
                        total += (uint) (n * 60);
                        break;
                    case 's':
                        total += (uint) n;
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
    }
}