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

        // TODO : it's silly to have the state in the serializer AND in the store
        private Gee.Map<string, Task> tasks;
        private Gee.Collection<Activity> activities;
        private File file;
        private bool loaded = false;

        internal FileSerializer(string project_id) {
            this.tasks = new Gee.HashMap<string, Task>();
            this.activities = new Gee.LinkedList<Activity>();

            var home = File.new_for_path(Environment.get_home_dir());
            this.file = home.get_child(project_id + "_activities.json");
        }

        internal Gee.Collection<Task> load_tasks() throws SerializationErrors {
            if (!loaded) {
                load_everything();
            }
            return tasks.values;
        }

        internal Gee.Collection<Activity> load_activities() throws SerializationErrors {
            if (!loaded) {
                load_everything();
            }
            return activities;
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
                        this.tasks.@set(task.local_id, task);
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
                        this.activities.add(activity);
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

        private Activity? deserialize_activity(Json.Node node) {
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
            if (task_id != null) {
                activity.task = this.tasks.@get(task_id);
            }
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
            this.activities.add(activity);
            if (activity.task != null) {
                this.tasks.@set(activity.task.local_id, activity.task);
            }
            this.save_all();
        }

        internal void update_activity(Activity activity) {
            message("Storing an updated activity: %s", activity.to_string());

            // I have to turn that into a simple warning because new activities can't be
            // inserted using create_activity() as the store does not give us the value...
            if (!remove_activity(activity)) {
                warning("Could not find the activity!");
            }

            this.activities.add(activity);
            if (activity.task != null) {
                this.tasks.@set(activity.task.local_id, activity.task);
            }

            this.save_all();
        }

        internal void delete_activity(Activity activity) {
            message("Deleting an activity: %s", activity.to_string());
            if (!remove_activity(activity)) {
                warning("Could not find the activity!");
            } else {
                // TODO : when do we remove unused task?
                this.save_all();
            }
        }

        // HACK - can I override equals so that Collection.remove() works?
        private bool remove_activity(Activity activity) {
            var local_id = activity.local_id;
            foreach (var a in this.activities) {
                if (local_id == a.local_id) {
                    this.activities.remove(a);
                    return true;
                }
            }
            return false;
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
            foreach (var activity in this.activities) {
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

            if (activity.start_date != null) {
                builder.set_member_name("start_date");
                builder.add_string_value(serialize_date_time(activity.start_date));
            }

            if (activity.end_date != null) {
                builder.set_member_name("end_date");
                builder.add_string_value(serialize_date_time(activity.end_date));
            }

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

        private string serialize_date_time(DateTime dt) {
            var time_val = GLib.TimeVal();
            dt.to_timeval(out time_val);
            return time_val.to_iso8601() + " " + dt.get_timezone_abbreviation();
        }
    }
}