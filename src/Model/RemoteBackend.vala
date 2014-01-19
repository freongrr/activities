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

    public abstract class RemoteBackend : Object, Backend {

        public void synchronize(ActivityStore activity_store) {
            debug("[%s] Starting synchronization", get_id());
            // TODO : how do I prevent modifications while synchronize
            this.merge_remote_changes(activity_store);
            this.push_local_changes(activity_store);

            activity_store.last_synchronization = new DateTime.now_local();
        }

        private void merge_remote_changes(ActivityStore activity_store) {
            var remote_activities = this.fetch_changes(activity_store);
            foreach (var remote_activity in remote_activities) {
                var local_activity = this.find_local_activity(activity_store, remote_activity.remote_id);
                if (local_activity == null) {
                    debug("[%s] Adding remote activity: %s", get_id(), remote_activity.to_string());
                    activity_store.add_record(remote_activity);
                } else if (this.is_pending_synchronization(local_activity)) {
                    warning("[%s] Conflicting activity: %s", get_id(), remote_activity.to_string());
                    // TODO : how do we handle conflicts?
                } else {
                    debug("[%s] Updating local activity: %s", get_id(), remote_activity.to_string());
                    activity_store.update_record(remote_activity);
                }
            }

            // TODO : removing activities deleted remotely is tricky!
            // 1. get the local activities for the last X days
            // 2. ask the backend if this remote_id exists
            // 3. handle conflicts when the local activity is pending changes
        }

        private Gee.Collection<Activity> fetch_changes(ActivityStore activity_store) {
            debug("[%s] Fetching remote changes", get_id());
            // If we already asked we only need to get the most recent changes
            if (activity_store.last_synchronization == null) {
                return this.fetch_activities(7 /* TODO : should be driven by a parameter of the Project/Backend */);
            } else {
                // TODO : pass a date time?
                return this.fetch_activities(1);
            }
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
                    debug("[%s] Pusing locally created activity: %s", get_id(), activity.to_string());
                    // TODO : what do wedo about the remote id?
                    this.create_remote_activity(activity);
                    activity.status = Status.UP_TO_DATE;
                } else if (activity.status == Status.UPDATED_LOCALLY) {
                    debug("[%s] Pusing locally updated activity: %s", get_id(), activity.to_string());
                    this.update_remote_activity(activity);
                    activity.status = Status.UP_TO_DATE;
                } else if (activity.status == Status.DELETED_LOCALLY) {
                    debug("[%s] Pusing locally deleted activity: %s", get_id(), activity.to_string());
                    this.delete_remote_activity(activity);
                    activity.status = Status.UP_TO_DATE;
                }

                return false;
            });
        }

        // TODO : I can't figure out how to make this an abstract implementation of Backend
        public abstract string get_id();
        public abstract string get_name();
        public abstract string get_icon_name();
        public abstract Gee.Collection<Task> find_tasks(string query);

        // TODO : this one should be async
        protected abstract Gee.Collection<Activity> fetch_activities(int days);
        protected abstract void create_remote_activity(Activity activity);
        protected abstract void update_remote_activity(Activity activity);
        protected abstract void delete_remote_activity(Activity activity);
    }
}