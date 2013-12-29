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

    public class ActivityListRendered : Gtk.CellRenderer {

        private const int MARGIN = 4;
        private const int LINE_SPACING = 5;
        private const int FONT_SIZE_TASK = 10;
        private const int FONT_SIZE_TIME = 10;
        private const int FONT_SIZE_DESCRIPTION = 9;

        // Public attribute set by the TreeView
        public Model.Activity activity { get; set; }

        public ActivityListRendered() {
        }

        public override void get_size(Gtk.Widget widget, Gdk.Rectangle? cell_area, out int x_offset, 
            out int y_offset, out int width, out int height) {
            x_offset = 0;
            y_offset = 0;
            width = 100;
            height = 50;
        }

        public override void render(Cairo.Context context, Gtk.Widget widget, Gdk.Rectangle background_area, 
            Gdk.Rectangle cell_area, Gtk.CellRendererState flags) {

            var render_context = new RenderContext(context, widget, cell_area, flags);
            render_context.render(this.activity);
        }
    }

    internal class RenderContext {

        private const int MARGIN = 4;
        private const int LINE_SPACING = 5;
        private const int FONT_SIZE_TASK = 10;
        private const int FONT_SIZE_TIME = 10;
        private const int FONT_SIZE_DESCRIPTION = 9;

        private Cairo.Context context;
        private Gtk.Widget widget;
        private Gdk.Rectangle cell_area;
        private Gtk.CellRendererState flags;
        private bool selected;

        private int top;
        private int time_width;

        internal RenderContext(Cairo.Context context, Gtk.Widget widget, Gdk.Rectangle cell_area, Gtk.CellRendererState flags) {
            this.context = context;
            this.widget = widget;
            this.cell_area = cell_area;
            this.flags = flags;

            this.selected = (flags & Gtk.CellRendererState.SELECTED) != 0;
            this.top = cell_area.y + MARGIN;
        }

        internal void render(Model.Activity activity) {
            this.render_time(activity);
            this.render_task(activity);
            this.render_description(activity);
            this.draw_separator();
        }

        private void render_time(Model.Activity activity) {
            string text = "NULL";
            if (activity != null && activity.task != null) {
                if (activity.end_date != null) {
                    // TODO : show the duration instead?
                    text = activity.start_date.to_short_time_string() +
                           " - " + activity.end_date.to_short_time_string();
                } else {
                    text = activity.start_date.to_short_time_string() + " - now";
                }
            }

            Pango.FontDescription font = new Pango.FontDescription();
            font.set_size(FONT_SIZE_TIME * Pango.SCALE);
            font.set_weight(Pango.Weight.BOLD);

            Pango.AttrList attributes = new Pango.AttrList();
            attributes.insert(this.get_attr_fg_color());

            Pango.Layout layout = this.widget.create_pango_layout(null);
            layout.set_attributes(attributes);
            layout.set_font_description(font);
            layout.set_text(text, -1);
            layout.set_ellipsize(Pango.EllipsizeMode.END);

            Pango.Rectangle? ink_rectangle;
            Pango.Rectangle? logical_rectangle;
            layout.get_pixel_extents(out ink_rectangle, out logical_rectangle);

            this.time_width = ink_rectangle.width;

            this.context.move_to(this.cell_area.x + this.cell_area.width - ink_rectangle.width, this.top);
            Pango.cairo_show_layout(this.context, layout);
        }

        private void render_task(Model.Activity activity) {
            string text = "NULL";
            if (activity != null && activity.task != null) {
                text = activity.task.key + " - " + activity.task.description;
            }

            Pango.FontDescription font = new Pango.FontDescription();
            font.set_size(FONT_SIZE_TASK * Pango.SCALE);
            font.set_weight(Pango.Weight.BOLD);

            Pango.AttrList attributes = new Pango.AttrList();
            attributes.insert(this.get_attr_fg_color());

            Pango.Layout layout = this.widget.create_pango_layout(null);
            layout.set_attributes(attributes);
            layout.set_font_description(font);
            layout.set_text(text, -1);
            layout.set_width((this.cell_area.width - this.time_width - MARGIN * 2) * Pango.SCALE);
            layout.set_ellipsize(Pango.EllipsizeMode.END);

            context.move_to(this.cell_area.x + MARGIN, this.top);
            Pango.cairo_show_layout(this.context, layout);

            Pango.Rectangle? ink_rectangle;
            Pango.Rectangle? logical_rectangle;
            layout.get_pixel_extents(out ink_rectangle, out logical_rectangle);

            this.top += ink_rectangle.y + ink_rectangle.height + LINE_SPACING;
        }

        private void render_description(Model.Activity activity) {
            string text = "NULL";
            if (activity != null) {
                text = activity.description;
            }

            Pango.FontDescription font = new Pango.FontDescription();
            font.set_size(FONT_SIZE_DESCRIPTION * Pango.SCALE);

            Pango.AttrList attributes = new Pango.AttrList();
            attributes.insert(this.get_attr_fg_color());

            Pango.Layout layout = this.widget.create_pango_layout(null);
            layout.set_attributes(attributes);
            layout.set_font_description(font);
            layout.set_text(text, -1);
            layout.set_width((this.cell_area.width - MARGIN * 2) * Pango.SCALE);
            layout.set_ellipsize(Pango.EllipsizeMode.END);

            context.move_to(this.cell_area.x + MARGIN, this.top);
            Pango.cairo_show_layout(this.context, layout);

            Pango.Rectangle? ink_rectangle;
            Pango.Rectangle? logical_rectangle;
            layout.get_pixel_extents(out ink_rectangle, out logical_rectangle);

            this.top += ink_rectangle.y + ink_rectangle.height + LINE_SPACING;
        }

        private void draw_separator() {
            // TODO : way too many magic numbers here
            this.context.set_line_width(1);
     	    this.context.set_source_rgb(0.1, 0.1, 0.1);
            this.context.move_to(this.cell_area.x - 3, this.cell_area.y + this.cell_area.height + 3);
            this.context.line_to(this.cell_area.x + this.cell_area.width + 3, this.cell_area.y + this.cell_area.height + 3);
            this.context.stroke();
        }

        private Pango.Attribute get_attr_fg_color() {
            if (this.selected) {
                Gdk.RGBA def = { 0.33, 0.33, 0.33, 0.1 };
                return this.get_pango_foreground_attr(this.widget.get_style_context(), "selected_fg_color", def);
            } else {
                return Pango.attr_foreground_new(0x57, 0x57, 0x57);
            }
        }

        private Pango.Attribute get_pango_foreground_attr(Gtk.StyleContext style_cx, string name, Gdk.RGBA def) {
            Gdk.RGBA color;
            bool found = style_cx.lookup_color(name, out color);
            if (!found) {
                color = def;
            }
            return Pango.attr_foreground_new(
                this.gdk_to_pango(color.red),
                this.gdk_to_pango(color.blue),
                this.gdk_to_pango(color.green));
        }

        private uint16 gdk_to_pango(double gdk) {
            return (uint16) (gdk.clamp(0.0, 1.0) * 65535.0);
        }
    }
}
