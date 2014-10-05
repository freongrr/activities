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

namespace Activities.Utils {

    public class JSON {

        public static string? get_string(Json.Object object, string name) {
            var member = object.get_member(name);
            if (member != null) {
                return member.get_string();
            } else {
                return null;
            }
        }

        public static bool get_boolean(Json.Object object, string name) {
            var member = object.get_member(name);
            if (member != null) {
                return member.get_boolean();
            } else {
                return false;
            }
        }

        public static DateTime? get_date_time(Json.Object object, string name) {
            var date_time_string = get_string(object, name);
            if (date_time_string == null) {
                return null;
            }
            // TODO : we lose the TimeZone!
            var time_val = GLib.TimeVal();
            time_val.from_iso8601(date_time_string);
            return new DateTime.from_timeval_local(time_val);
        }

        public static Json.Array? get_array(Json.Object object, string name) {
            var member = object.get_member(name);
            if (member != null) {
                return member.get_array();
            } else {
                return null;
            }
        }

        public static void set_string(Json.Builder builder, string name, string? s) {
            if (s == null) {
                return;
            }
            builder.set_member_name(name);
            builder.add_string_value(s);
        }

        public static void set_boolean(Json.Builder builder, string name, bool b) {
            builder.set_member_name(name);
            builder.add_boolean_value(b);
        }

        public static void set_date_time(Json.Builder builder, string name, DateTime? date_time) {
            if (date_time == null) {
                return;
            }
            builder.set_member_name(name);
            builder.add_string_value(serialize_date_time(date_time));
        }

        private static string serialize_date_time(DateTime dt) {
            var time_val = GLib.TimeVal();
            dt.to_timeval(out time_val);
            return time_val.to_iso8601() + " " + dt.get_timezone_abbreviation();
        }
    }
}