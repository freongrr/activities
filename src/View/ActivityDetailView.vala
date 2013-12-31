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

    internal class ActivityDetailView : Gtk.Box {

        private const string DATE_FORMAT = (_("%B %e, %Y"));

        private Gtk.Entry task_entry;
        private Gtk.Entry description_entry;
        private Gtk.Entry tags_entry;
        private Granite.Widgets.DatePicker start_date_picker;
        private Granite.Widgets.TimePicker start_time_picker;
        private Granite.Widgets.DatePicker end_date_picker;
        private Granite.Widgets.TimePicker end_time_picker;
        private Gtk.TextView notes_text_view;

        internal ActivityDetailView() {
            this.task_entry = new Gtk.Entry();
            this.task_entry.changed.connect(this.on_changed);

            this.description_entry = new Gtk.Entry();
            this.description_entry.changed.connect(this.on_changed);

            this.start_date_picker = new Granite.Widgets.DatePicker.with_format(DATE_FORMAT);
            this.start_date_picker.changed.connect(this.on_changed);

            this.start_time_picker = new Granite.Widgets.TimePicker();
            this.start_time_picker.time_changed.connect(this.on_changed);

            this.end_date_picker = new Granite.Widgets.DatePicker.with_format(DATE_FORMAT);
            this.end_date_picker.changed.connect(this.on_changed);

            this.end_time_picker = new Granite.Widgets.TimePicker();
            this.end_time_picker.time_changed.connect(this.on_changed);

            this.tags_entry = new Gtk.Entry();
            this.tags_entry.changed.connect(this.on_changed);

            this.notes_text_view = new Gtk.TextView();
            this.notes_text_view.buffer.changed.connect(this.on_changed);

            this.layout();
        }

        private void layout() {
            this.orientation = Gtk.Orientation.VERTICAL;
            this.border_width = 10;
            this.spacing = 5;

            this.pack_start(this.create_label("Task"), false, false, 0);
            this.pack_start(this.task_entry, false, false, 0);
            this.pack_start(this.create_label("Start"), false, false, 0);
            this.pack_start(this.create_start_date_row(), false, false, 0);
            this.pack_start(this.create_label("End"), false, false, 0);
            this.pack_start(this.create_end_date_row(), false, false, 0);
            this.pack_start(this.create_label("Description"), false, false, 0);
            this.pack_start(this.description_entry, false, false, 0);
            this.pack_start(this.create_label("Tags"), false, false, 0);
            this.pack_start(this.tags_entry, false, false, 0);
            this.pack_start(this.create_label("Notes"), false, false, 0);
            this.pack_start(this.create_frame(this.notes_text_view), true, true, 0);
        }
 
        private Gtk.Label create_label(string text) {
            var label = new Gtk.Label(text);
            label.xalign = 0;
            return label;
        }

        private Gtk.Widget create_start_date_row() {
            var h_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 5);
            h_box.pack_start(this.start_date_picker, false, false, 0);
            h_box.pack_start(this.start_time_picker, false, false, 0);
            return h_box;
        }

        private Gtk.Widget create_end_date_row() {
            var h_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 5);
            h_box.pack_start(this.end_date_picker, false, false, 0);
            h_box.pack_start(this.end_time_picker, false, false, 0);
            return h_box;
        }

        private Gtk.Widget create_frame(Gtk.Widget widget) {
            Gtk.ScrolledWindow scroll = new Gtk.ScrolledWindow(null, null);
            scroll.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
            scroll.add(widget);

            // TODO : no shadow because of a bug?
            // http://stackoverflow.com/questions/13001990/why-is-there-no-a-border-on-this-gtkframe
            Gtk.Frame frame = new Gtk.Frame(null);
            frame.shadow_type = Gtk.ShadowType.IN;
            frame.add(scroll);

            return frame;
        }

        private void on_changed() {
            // TODO
        }
    }
}