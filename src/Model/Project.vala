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

    public class Project : Object {

        public string id { get; private set; }
        public string name { get; private set; }
        public Backend backend { get; private set; }
        public ActivityStore store { get; private set; }

        internal Project(string id, string name, Backend backend, ActivityStore store) {
            this.id = id;
            this.name = name;
            this.backend = backend;
            this.store = store;
        }
    }
}