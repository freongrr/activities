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

    internal class FileSerializer : Object, Serializer {

        internal Gee.Collection<Activity> activities { get; set; }
        internal File file;

        internal FileSerializer(string project_id) {
            var home = File.new_for_path(Environment.get_home_dir());
            this.file = home.get_child(project_id + "_activities.json");
        }

        internal Gee.Collection<Activity> load_activities() throws SerializationErrors {
            if (!this.file.query_exists()) {
		        throw new SerializationErrors.FILE_ERROR("File not found: %s",
                    this.file.get_parse_name());
            }

            var parser = new Json.Parser();
            try {
                parser.load_from_file(this.file.get_path());
	        } catch (Error e) {
		        throw new SerializationErrors.FILE_ERROR("Unable to parse '%s': %s",
                    this.file.get_path(), e.message);
        	}

            var root = parser.get_root();
            if (root.get_node_type () != Json.NodeType.OBJECT) {
                throw new SerializationErrors.INVALID_FORMAT("Root should be an object");
            }

            var tasks = new Gee.HashMap<string, Task>();

            var task_nodes = root.get_object().get_member("tasks");
            if (task_nodes != null) {
                if (task_nodes.get_node_type() != Json.NodeType.ARRAY) {
                    throw new SerializationErrors.INVALID_FORMAT(
                        "Unexpected element type %s", task_nodes.type_name());
                }

                task_nodes.get_array().foreach_element((array, index, element_node) => {
                    var task = this.deserialize_task(element_node);
                    if (task != null) {
                        tasks.@set(task.local_id, task);
                    }
                });
            }

            var activities = new Gee.LinkedList<Activity>();

            var activity_nodes = root.get_object().get_member("activity");
            if (activity_nodes != null) {
                if (activity_nodes.get_node_type() != Json.NodeType.ARRAY) {
                    throw new SerializationErrors.INVALID_FORMAT(
                        "Unexpected element type %s", activity_nodes.type_name());
                }

                activity_nodes.get_array().foreach_element((array, index, element_node) => {
                    var activity = this.deserialize_activity(tasks, element_node);
                    if (activity != null) {
                        activities.add(activity);
                    }
                });
            }

            return activities;
        }

        private Task? deserialize_task(Json.Node node) {
            debug("Deserializing task");
            if (node.get_node_type () != Json.NodeType.OBJECT) {
                critical("Unexpected element type %s", node.type_name());
                return null;
            }

            var object = node.get_object();

            var local_id = object.get_string_member("local_id");
            var remote_id = object.get_string_member("remote_id");
            var key = object.get_string_member("key");
            var description = object.get_string_member("description");
            var notes = object.get_string_member("notes");
            var closed = object.get_boolean_member("closed");

            debug("  local_id: " + local_id);
            debug("  remote_id: " + remote_id);
            debug("  key: " + key);
            debug("  description: " + description);
            debug("  notes: " + notes);
            debug("  closed: " + closed.to_string());

            var task = new Task(local_id);
            task.remote_id = remote_id;
            task.key = key;
            task.description = description;
            task.notes = notes;
            task.closed = closed;

            return task;
        }

        private Activity? deserialize_activity(Gee.HashMap<string, Task> tasks, Json.Node node) {
            debug("Deserializing activity");
            if (node.get_node_type () != Json.NodeType.OBJECT) {
                critical("Unexpected element type %s", node.type_name());
                return null;
            }

            var object = node.get_object();

            var status = object.get_string_member("status");
            var local_id = object.get_string_member("local_id");
            var remote_id = object.get_string_member("remote_id");
            var description = object.get_string_member("description");
            var task_id = object.get_string_member("task_id");
            var start_date = object.get_string_member("start_date");
            var end_date = object.get_string_member("end_date");
        	var tags = object.get_array_member("tags");

            debug("  status: " + status);
            debug("  local_id: " + local_id);
            debug("  remote_id: " + remote_id);
            debug("  description: " + description);
            debug("  start_date: " + start_date);
            debug("  end_date: " + end_date);

            var activity = new Activity(local_id);
            activity.remote_id = remote_id;
            activity.description = description;
            activity.task = tasks.@get(task_id);
            activity.start_date = this.parse_date_time(start_date);
            activity.end_date = this.parse_date_time(end_date);
            activity.status = Status.value_of(status);
            activity.tags = new Gee.HashSet<string>();
            if (tags != null) {
                tags.foreach_element((array, index, element_node) => {
                    var tag = element_node.get_string();
                    debug("  tag: " + tag);
                    activity.tags.add(tag);
                });
            }

            return activity;
        }

        private DateTime? parse_date_time(string? date_time_string) {
            if (date_time_string == null) {
                return null;
            }
            // TODO : we lose the TimeZone!
            var time_val = GLib.TimeVal();
            time_val.from_iso8601(date_time_string);
            return new DateTime.from_timeval_local(time_val);
        }

        internal void create_activity(Activity activity) {
            message("NOOP - Storing a new activity: %s", activity.to_string());
        }

        internal void update_activity(Activity activity) {
            message("NOOP - Storing an updated activity: %s", activity.to_string());
        }

        internal void delete_activity(Activity activity) {
            message("NOOP - Deleting an activity: %s", activity.to_string());
        }
    }
}