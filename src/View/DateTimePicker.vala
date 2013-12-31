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

namespace Activities.View {

    internal class DateTimePicker : Gtk.Box {

        public signal void date_time_changed(GLib.DateTime date_time);

        public GLib.DateTime date_time { get; private set; }

        private Granite.Widgets.DatePicker date_picker;
        private Granite.Widgets.TimePicker time_picker;

        internal DateTimePicker() {
            this.with_format((_("%B %e, %Y")));
        }

        internal DateTimePicker.with_format(string format) {
            this.date_picker = new Granite.Widgets.DatePicker.with_format(format);
            this.date_picker.changed.connect(this.on_changed);

            this.time_picker = new Granite.Widgets.TimePicker();
            this.time_picker.time_changed.connect(this.on_changed);

            this.layout();

            this.date_time = new DateTime.now_local();
        }

        private void layout() {
            this.orientation = Gtk.Orientation.HORIZONTAL;
            this.spacing = 5;
            this.pack_start(this.date_picker, false, false, 0);
            this.pack_start(this.time_picker, false, false, 0);
        }

        private void on_changed() {
            var date = date_picker.date;
            var time = time_picker.time;

            this.date_time = new GLib.DateTime.local(
                date.get_year(), date.get_month(), date.get_day_of_month(),
                time.get_hour(), time.get_minute(), 0);
            date_time_changed(this.date_time);
        }
    }
}