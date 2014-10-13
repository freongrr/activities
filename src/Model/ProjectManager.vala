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

    public class ProjectManager : Object {

        public Gee.HashSet<Project> projects { get; private set; }

        public signal void project_added(Project project);
        public signal void project_removed(Project project);

        private Settings.ProjectDefinitions project_definitions;

        public ProjectManager(Settings.ProjectDefinitions project_definitions) {
            this.projects = new Gee.HashSet<Project>();
            this.project_definitions = project_definitions;
        }

        // TODO : use Granite.Services.SettingsSerializable instead
        public void load_projects() {
            int projects = this.project_definitions.count;
            message("Restoring %d projects", projects);
            for (int i = 0; i < projects; i++) {
                var project_id = this.project_definitions.ids[i];
                var project_name = this.project_definitions.names[i];
                var backend_name = this.project_definitions.backends[i];

                debug("Restoring id=%s, name=%s, backend=%s",
                    project_id, project_name, backend_name);

                var backend = new DummyBackend(); // TODO : properly instantiate the class
                var project = create_project(project_id, project_name, backend);

                this.projects.add(project);
                this.project_added(project);
            }
        }

        // TODO : not sure this method should be public...
        public Project create_project(string project_id, string project_name, Backend backend) {
            var activity_store = new ActivityStore();
            var task_store = new TaskStore();

            // Populate the store using the Serializer
            var serializer = new FileSerializer(project_id);

            try {
                var tasks = serializer.load_tasks();
                foreach (var t in tasks) {
                    task_store.add(t);
                }
                var activities = serializer.load_activities();
                foreach (var a in activities) {
                    activity_store.add(a);
                }
            } catch (SerializationErrors e) {
                if (e is SerializationErrors.FILE_NOT_FOUND) {
                    message("Nothing to deserialize: %s", e.message);
                } else {
                    critical("Could not deserialize the tasks/activities: %s", e.message);
                }
            }

            listen_for_task_changes(serializer, task_store);
            listen_for_activity_changes(serializer, activity_store);

            // And shove it all in a Project
            return new Project(project_id, project_name, backend, task_store, activity_store);
        }

        private void listen_for_task_changes(Serializer serializer, TaskStore store) {
            store.created.connect((path, iter) => {
                // TODO : serialize here or wait for the activity to be saved?
            });
            store.updated.connect((path, iter) => {
                // TODO : serialize here or wait for the activity to be saved?
            });
            store.deleted.connect((path) => {
                // TODO : serialize here or wait for the activity to be saved?
            });
        }

        private void listen_for_activity_changes(Serializer serializer, ActivityStore store) {
            store.created.connect((activity) => {
                serializer.create_activity(activity);
            });
            store.updated.connect((activity) => {
                serializer.update_activity(activity);
            });
            store.deleted.connect((activity) => {
                serializer.delete_activity(activity);
            });
        }

        public void add_project(Project project) {
            if (this.projects.add(project)) {
                this.project_added(project);
                this.add_project_definition(project);
                // TODO : monitor changes to Project to *update* the configuration
            }
        }

        private void add_project_definition(Project new_project) {
            // Disabling for now, as I can't save the username/password
            return;

stdout.printf("Storing project id=%s, name=%s, backend=%s\n", new_project.id, new_project.name, new_project.backend.get_type().name());

            this.project_definitions.count = this.project_definitions.ids.length + 1;
stdout.printf("  this.project_definitions.count: %d\n", this.project_definitions.count);
            this.project_definitions.ids = this.append(this.project_definitions.ids, new_project.id);
stdout.printf("  this.project_definitions.ids: %d\n", this.project_definitions.ids.length);
            this.project_definitions.names = this.append(this.project_definitions.names, new_project.name);
stdout.printf("  this.project_definitions.names: %d\n", this.project_definitions.names.length);
            this.project_definitions.backends = this.append(this.project_definitions.backends, new_project.backend.get_type().name());
stdout.printf("  this.project_definitions.backends: %d\n", this.project_definitions.backends.length);
        }

        private string[] append(string[] array, string new_value) {
            string[] new_array = new string[array.length + 1];
            for (int i = 0; i < array.length; i++) {
                new_array[i] = array[i];
            }
            new_array[array.length] = new_value;
            return new_array;
        }

        public void remove_project(Project project) {
            if (this.projects.remove(project)) {
                this.project_removed(project);
                // TODO : remove from ProjectDefinitions
            }
        }
    }
}