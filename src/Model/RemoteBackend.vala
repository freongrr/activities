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

    public interface RemoteBackend : Backend {

        public void synchronize(ActivityStore activity_store) {
            // TODO : how do I prevent modifications while synchronize
            this.merge_remote_changes(activity_store);
            this.push_local_changes(activity_store);
        }

        private void merge_remote_changes(ActivityStore activity_store) {
            // TODO : if we already asked we only need to get the difference (1 day / since X hours)
            var remote_activities = this.fetch_activities(7);

            foreach (var remote_activity in remote_activities) {
                var local_activity = this.find_local_activity(activity_store, remote_activity.remote_id);
                if (local_activity == null) {
                    activity_store.add_record(remote_activity);
                } else if (this.is_pending_synchronization(local_activity)) {
                    // TODO : how do we handle conflicts?
                } else {
                    activity_store.update_record(remote_activity);
                }
            }

            // TODO : removing activities deleted remotely is tricky!
            // 1. get the local activities for the last X days
            // 2. ask the backend if this remote_id exists
            // 3. handle conflicts when the local activity is pending changes
        }

        private Activity? find_local_activity(ActivityStore activity_store, string remote_id) {
            Activity? result = null;
            activity_store.@foreach((model, path, iter) => {
                GLib.Value v;
                activity_store.get_value(iter, 0, out v);
                if (remote_id == ((Activity) v).remote_id) {
                    result = (Activity) v;
                    return true;
                }
                return false;
            });
            return result;
        }

        private bool is_pending_synchronization(Activity activity) {
            return activity.status != Status.UP_TO_DATE;
        }

        private void push_local_changes(ActivityStore activity_store) {
            activity_store.@foreach((model, path, iter) => {
                GLib.Value v;
                activity_store.get_value(iter, 0, out v);

                var activity = (Activity) v;
                if (activity.status == Status.CREATED_LOCALLY) {
                    // TODO : what do wedo about the remote id?
                    this.create_remote_activity(activity);
                    activity.status = Status.UP_TO_DATE;
                } else if (activity.status == Status.UPDATED_LOCALLY) {
                    this.update_remote_activity(activity);
                    activity.status = Status.UP_TO_DATE;
                } else if (activity.status == Status.DELETED_LOCALLY) {
                    this.delete_remote_activity(activity);
                    activity.status = Status.UP_TO_DATE;
                }

                return false;
            });
        }

        protected abstract Gee.Collection<Activity> fetch_activities(int days);
        protected abstract Gee.Collection<Activity> create_remote_activity(Activity activity);
        protected abstract Gee.Collection<Activity> update_remote_activity(Activity activity);
        protected abstract Gee.Collection<Activity> delete_remote_activity(Activity activity);
    }
}