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

        public void load_projects() {
            for (int i = 0; i < this.project_definitions.count; i++) {
                var project_id = this.project_definitions.ids[i];
                var project_name = this.project_definitions.names[i];
                var backend_name = this.project_definitions.backends[i];

                var backend = new DummyBackend(); // TODO : properly instantiate the class
                var project = create_project(project_id, project_name, backend);
                this.add_project(project);
            }
        }

        // TODO : not sure this method should be public...
        public Project create_project(string project_id, string project_name, Backend backend) {
            var store = new ActivityStore();

            // Populate the store using the Serializer
            var serializer = new DummySerializer(project_id); // TODO : proper serializer
            var activities = serializer.load_activities();
            foreach (var a in activities) {
                store.add_record(a);
            }

            // Set the serializer after populating the store to avoid saving the activities for nothing
            store.serializer = serializer;

            // And shove it all in a Project
            return new Project(project_id, project_name, backend, store);
        }

        public void add_project(Project project) {
            if (this.projects.add(project)) {
                this.project_added(project);
                // TODO : add it to ProjectDefinitions
            }
        }

        public void remove_project(Project project) {
            if (this.projects.remove(project)) {
                this.project_removed(project);
                // TODO : remove from ProjectDefinitions
            }
        }
    }
}