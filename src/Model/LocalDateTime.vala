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

    public class LocalDateTime : GLib.Object {

        private short year { public get; set; }
        private short month { public get; set; }
        private short day { public get; set; }
        private short hours { public get; set; }
        private short minutes { public get; set; }
        private short seconds { public get; set; }

        internal LocalDateTime(short year, short month, short day, short hours, short minutes, short seconds) {
            this.year = year;
            this.month = month;
            this.day = day;
            this.hours = hours;
            this.minutes = minutes;
            this.seconds = seconds;
        }

        public string to_ISO_8601_string() {
            return "%04d-%02d-%02dT%02d:%02d:%02d".printf(year, month, day, hours, minutes, seconds);
        }
    }
}
