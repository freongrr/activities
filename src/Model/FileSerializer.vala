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
using Activities.Utils;

namespace Activities.Model {

    internal class FileSerializer : Object, Serializer {

        // TODO : it's silly to have the state in the serializer AND in the store
        private Map<string, Task> tasks;
        private Map<string, Activity> activities;
        private File file;
        private bool loaded = false;

        internal FileSerializer(string project_id) {
            this.tasks = new HashMap<string, Task>();
            this.activities = new HashMap<string, Activity>();

            var home = File.new_for_path(Environment.get_home_dir());
            this.file = home.get_child(project_id + "_activities.json");
        }

        internal Collection<Task> load_tasks() throws SerializationErrors {
            if (!loaded) {
                load_everything();
            }
            return tasks.values;
        }

        internal Collection<Activity> load_activities() throws SerializationErrors {
            if (!loaded) {
                load_everything();
            }
            return activities.values;
        }

        private void load_everything() throws SerializationErrors {
            this.tasks.clear();
            this.activities.clear();

            message("Loading from %s", this.file.get_parse_name());
            if (!this.file.query_exists()) {
		        throw new SerializationErrors.FILE_NOT_FOUND(
                    "File not found: %s", this.file.get_parse_name());
            }

            debug("Parsing...");
            var parser = new Json.Parser();
            try {
                parser.load_from_file(this.file.get_path());
	        } catch (Error e) {
		        throw new SerializationErrors.INVALID_FORMAT(
                    "Unable to parse '%s': %s", this.file.get_path(), e.message);
        	}

            var root = parser.get_root();
            if (root.get_node_type () != Json.NodeType.OBJECT) {
                throw new SerializationErrors.INVALID_FORMAT("Root should be an object");
            }

            var task_nodes = root.get_object().get_member("tasks");
            if (task_nodes != null) {
                if (task_nodes.get_node_type() != Json.NodeType.ARRAY) {
                    throw new SerializationErrors.INVALID_FORMAT(
                        "Unexpected element type %s", task_nodes.type_name());
                }

                task_nodes.get_array().foreach_element((array, index, element_node) => {
                    var task = this.deserialize_task(element_node);
                    if (task != null) {
                        this.tasks[task.local_id] = task;
                    }
                });
            }

            var activity_nodes = root.get_object().get_member("activities");
            if (activity_nodes != null) {
                if (activity_nodes.get_node_type() != Json.NodeType.ARRAY) {
                    throw new SerializationErrors.INVALID_FORMAT(
                        "Unexpected element type %s", activity_nodes.type_name());
                }

                activity_nodes.get_array().foreach_element((array, index, element_node) => {
                    var activity = this.deserialize_activity(element_node);
                    if (activity != null) {
                        this.activities[activity.local_id] = activity;
                    }
                });
            }

            loaded = true;
        }

        private Task? deserialize_task(Json.Node node) {
            debug("Deserializing task");
            if (node.get_node_type () != Json.NodeType.OBJECT) {
                critical("Unexpected element type %s", node.type_name());
                return null;
            }

            var object = node.get_object();

            var task = new Task(JSON.get_string(object, "local_id"));
            task.remote_id = JSON.get_string(object, "remote_id");
            task.key = JSON.get_string(object, "key");
            task.description = JSON.get_string(object, "description") ?? "";
            task.notes = JSON.get_string(object, "notes");
            task.closed = JSON.get_boolean(object, "closed");

            debug(" -> " + task.to_string());
            return task;
        }

        private Activity? deserialize_activity(Json.Node node) {
            debug("Deserializing activity");
            if (node.get_node_type () != Json.NodeType.OBJECT) {
                critical("Unexpected element type %s", node.type_name());
                return null;
            }

            var object = node.get_object();

            var status = JSON.get_string(object, "status");
            var task_id = JSON.get_string(object, "task_id");
        	var tags = JSON.get_array(object, "tags");

            var activity = new Activity(JSON.get_string(object, "local_id"));
            activity.remote_id = JSON.get_string(object, "remote_id");
            activity.description = JSON.get_string(object, "description");
            if (task_id != null) {
                activity.task = this.tasks[task_id];
            }
            activity.start_date = JSON.get_date_time(object, "start_date");
            activity.end_date = JSON.get_date_time(object, "end_date");
            activity.status = Status.value_of(status);
            activity.tags = new HashSet<string>();
            if (tags != null) {
                tags.foreach_element((array, index, element_node) => {
                    var tag = element_node.get_string();
                    debug("  tag: " + tag);
                    activity.tags.add(tag);
                });
            }

            debug(" -> " + activity.to_string());
            return activity;
        }

        internal void create_activity(Activity activity) {
            this.activities[activity.local_id] = activity;
            if (activity.task != null) {
                this.tasks[activity.task.local_id] = activity.task;
            }
            this.save_all();
        }

        internal void update_activity(Activity activity) {
            message("Storing an updated activity: %s", activity.to_string());

            this.activities[activity.local_id] = activity;
            if (activity.task != null) {
                this.tasks[activity.task.local_id] = activity.task;
            }

            this.save_all();
        }

        internal void delete_activity(Activity activity) {
            message("Deleting an activity: %s", activity.to_string());
            if (!activities.unset(activity.local_id)) {
                warning("Could not find the activity!");
            } else {
                // TODO : when do we remove unused task?
                this.save_all();
            }
        }

        // TODO : it's inefficient to save all every time!
        private void save_all() {
            var builder = new Json.Builder();

            builder.begin_object();
            builder.set_member_name("tasks");
            builder.begin_array();
            foreach (var task in this.tasks.values) {
                serialize_task(builder, task);
            }
            builder.end_array();

            builder.set_member_name("activities");
            builder.begin_array();
            foreach (var activity in this.activities.values) {
                serialize_activity(builder, activity);
            }
            builder.end_array();
            builder.end_object();

            var generator = new Json.Generator();
            generator.root = builder.get_root();
            generator.pretty = true;
            generator.indent = 4;
            generator.indent_char = ' ';

            try {
                generator.to_file(this.file.get_parse_name());
            } catch (Error e) {
                // TODO : bubble up?
                critical("Error generating to file: %s", e.message);
            }
        }

        private void serialize_task(Json.Builder builder, Task task) {
            // TODO
            builder.begin_object();
            builder.set_member_name("local_id");
            builder.add_string_value(task.local_id);
            builder.set_member_name("key");
            builder.add_string_value(task.key);
            builder.end_object();
        }

        private void serialize_activity(Json.Builder builder, Activity activity) {
            builder.begin_object();

            builder.set_member_name("local_id");
            builder.add_string_value(activity.local_id);

            if (activity.remote_id != null) {
                builder.set_member_name("remote_id");
                builder.add_string_value(activity.remote_id);
            }

            builder.set_member_name("description");
            builder.add_string_value(activity.description);

            if (activity.task != null) {
                builder.set_member_name("task_id");
                builder.add_string_value(activity.task.local_id);
            }

            JSON.set_date_time(builder, "start_date", activity.start_date);
            JSON.set_date_time(builder, "end_date", activity.end_date);
            builder.set_member_name("status");
            builder.add_string_value(activity.status.to_string());

            builder.set_member_name("tags");
            builder.begin_array();
            foreach (string tag in activity.tags) {
                builder.add_string_value(tag);
            }
            builder.end_array();

            builder.end_object();
        }
    }
}