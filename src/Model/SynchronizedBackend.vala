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

    public abstract class SynchronizedBackend : Object, Backend {

        private Gee.List<Activity> created_locally;
        private Gee.List<Activity> updated_locally;
        private Gee.List<Activity> deleted_locally;

        protected SynchronizedBackend() {
            this.created_localy = new Gee.LinkedList<Activity>();
            this.updated_localy = new Gee.LinkedList<Activity>();
            this.deleted_localy = new Gee.LinkedList<Activity>();
        }

        public void create_activity(Activity activity) {
            lock (this) {
                this.created_locally.add(activity);
                // TODO : automatically trigger the synchronization?
            }
        }

        public void update_activity(Activity activity) {
            lock (this) {
                this.updated_locally.add(activity);
                // TODO : automatically trigger the synchronization?
            }
        }

        public void delete_activity(Activity activity) {
            lock (this) {
                this.deleted_locally.add(activity);
                // TODO : automatically trigger the synchronization?
            }
        }

        public void synchronize() {
            lock (this) {
                this.merge_remote_changes();
                this.push_local_changes();
            }
        }

        private void merge_remote_changes() {
            var remote_activities = this.fetch_remote_changes();
            foreach (var remote_activity in remote_activities) {
                var local_activity = this.get_by_remote_id(remote_activity.remote_id);
                if (local_activity == null) {
                    this.created(remote_activity);
                } else if (this.is_pending_synchronization(local_activity)) {
                    // TODO : conflict!
                } else {
                    this.updated(remote_activity);
                }
            }

            // TODO : removing activities deleted remotely is tricky!
            // 1. get the local activities for the last X days
            // 2. ask the backend if this remote_id exists
            // 3. handle conflicts when the local activity is pending changes
        }

        private Gee.Collection<Activity> fetch_remote_changes() {
            // TODO : if we already asked we only need to get the difference (1 day / since X hours)
            return this.fetch_activities(7);
        }

        private Activity? get_by_remote_id(string remote_id) {
            // TODO : should we keep a list around? or make this abstract?
            var result = null;
            this.list_store.@foreach((model, path, iter) => {
                GLib.Value v;
                this.list_store.get_value(iter, 0, out v);
                if (remote_id == ((Activity) v).remote_id) {
                    result = (Activity) v;
                    return true;
                }
                return false;
            });
            return result;
        }

        private bool is_pending_synchronization(Activity activity) {
            return this.created_locally.contains(activity) ||
                this.updated_locally.contains(activity) ||
                this.deleted_locally.contains(activity);
        }

        private void push_local_changes() {
            foreach (var activity in this.created_locally) {
                // TODO : what do wedo about the remote id?
                this.create_remote_activity(activity);
            }

            foreach (var activity in this.updated_locally) {
                this.update_remote_activity(activity);
            }

            foreach (var activity in this.deleted_locally) {
                this.delete_remote_activity(activity);
            }

            this.created_locally.clear();
            this.updated_locally.clear();
            this.deleted_locally.clear();
        }

        protected abstract Gee.Collection<Activity> fetch_activities(int days);
        protected abstract Gee.Collection<Activity> create_remote_activity(Activity activity);
        protected abstract Gee.Collection<Activity> update_remote_activity(Activity activity);
        protected abstract Gee.Collection<Activity> delete_remote_activity(Activity activity);
    }
}