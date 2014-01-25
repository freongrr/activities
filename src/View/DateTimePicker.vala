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

        public signal void date_time_changed(GLib.DateTime? date_time);

        private Granite.Widgets.DatePicker date_picker;
        private Granite.Widgets.TimePicker time_picker;

        private GLib.DateTime _date_time = new DateTime.now_local();

        public GLib.DateTime date_time {
            get {
                return this._date_time;
            }
            set {
                warn_if_fail(value != null);
                debug("New value: %s", value.to_string());
                this._date_time = value;
                refresh_view();
            }
        }

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
            debug("Something changed");
            if (!this.sensitive) {
                warning("Picker is disabled ");
            } else if (date_picker.date == null) {
                warning("Date is null");
            } else if (time_picker.time == null) {
                warning("Time is null");
            } else {
                var date = date_picker.date;
                var time = time_picker.time;

                message("Updating with %s - %s", date.to_string(), time.to_string());
                var new_date_time = new GLib.DateTime.local(
                    date.get_year(), date.get_month(), date.get_day_of_month(),
                    time.get_hour(), time.get_minute(), 0);

                if (this._date_time == null || this._date_time != new_date_time) {
                    debug("Date/time changed: %s", new_date_time.to_string());
                    this._date_time = new_date_time;
                    date_time_changed(this._date_time);
                }
            }
        }

        private void refresh_view() {
            debug("Refreshing view");
            this.date_picker.date = this._date_time;
            this.time_picker.time = this._date_time;
        }
    }
}