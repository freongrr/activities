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

    public interface Source : GLib.Object {

        /** Returns the type: "Local", "JIRA", etc */
        public abstract string get_backend();

        /** Returns the name: "Work", "Personal", etc */
        public abstract string get_name();
    }

    public class DummySource : GLib.Object, Source {

        public string name { get; set; }

        public DummySource(string name) {
            this.name = name;
        }

        public string get_backend() {
            return "Dummy";
        }

        public string get_name() {
            return name;
        }
    }
}
