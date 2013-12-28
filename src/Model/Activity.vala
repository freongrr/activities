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

    public class Activity : GLib.Object {

        // TODO : protected setters?
        public string uid { get; set; }
        public string task_uid { get; set; }
        public string description { get; set; }
        // TODO : what type for the date?
        public int64 start_date { get; set; }
        public int64? end_date { get; set; }
        // TODO : tags
    }
}
