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

namespace Activities.Model {

    internal class DummySerializer : Object, Serializer {

        internal Collection<Task> load_tasks() {
            return new ArrayList<Task>();
        }

        internal Collection<Activity> load_activities() {
            return new ArrayList<Activity>();
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