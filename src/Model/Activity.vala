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

        internal string local_id { public get; set; }
        internal string remote_id { public get; set; }
        internal string description { public get; set; }
        internal Task task { public get; set; }
        internal LocalDateTime start_date { public get; set; }
        internal LocalDateTime? end_date { public get; set; }
        internal Gee.Set<string> tags { public get; set; }

        internal Activity() {}
    }
}