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

    public interface Backend : GLib.Object {

        public signal void created(Activity activity);
        public signal void updated(Activity activity);
        public signal void deleted(Activity activity);

        public abstract string get_id();
        public abstract string get_name();
        public abstract string get_icon_name();
        public abstract void create_activity(Activity activity);
        public abstract void update_activity(Activity activity);
        public abstract void delete_activity(Activity activity);
        public abstract Gee.Collection<Task> find_tasks(string query);
     }
}