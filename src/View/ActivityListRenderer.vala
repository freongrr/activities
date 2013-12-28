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

        // TODO : is this thread safe? I don't like passing so many arguments around...
        public override void render(Cairo.Context context, Gtk.Widget widget, Gdk.Rectangle background_area, 
            Gdk.Rectangle cell_area, Gtk.CellRendererState flags) {
debug("I'm here");

            bool selected = (flags & Gtk.CellRendererState.SELECTED) != 0;
            int top = cell_area.y + MARGIN;

            top = this.render_task(top, selected, context, widget, cell_area);
            top = this.render_description(top, selected, context, widget, cell_area);
            this.draw_separator(context, cell_area);
        }

        private int render_task(int top, bool selected, Cairo.Context context, Gtk.Widget widget, Gdk.Rectangle cell_area) {
            Pango.FontDescription font = new Pango.FontDescription();
            font.set_size(FONT_SIZE_TASK * Pango.SCALE);
            font.set_weight(Pango.Weight.BOLD);

            Pango.AttrList attributes = new Pango.AttrList();
            attributes.insert(this.get_attr_fg_color(widget, selected));

            Pango.Layout layout = widget.create_pango_layout(null);
            layout.set_attributes(attributes);
            layout.set_font_description(font);
            layout.set_text("TODO : Task", -1);
            layout.set_width((cell_area.width - MARGIN * 2) * Pango.SCALE);
            layout.set_ellipsize(Pango.EllipsizeMode.END);

            context.move_to(cell_area.x + MARGIN, top);
            Pango.cairo_show_layout(context, layout);

            Pango.Rectangle? ink_rectangle;
            Pango.Rectangle? logical_rectangle;
            layout.get_pixel_extents(out ink_rectangle, out logical_rectangle);

            return top + ink_rectangle.y + ink_rectangle.height + LINE_SPACING;
        }

        private int render_description(int top, bool selected, Cairo.Context context, Gtk.Widget widget, Gdk.Rectangle cell_area) {
            Pango.FontDescription font = new Pango.FontDescription();
            font.set_size(FONT_SIZE_DESCRIPTION * Pango.SCALE);

            Pango.AttrList attributes = new Pango.AttrList();
            attributes.insert(this.get_attr_fg_color(widget, selected));

            Pango.Layout layout = widget.create_pango_layout(null);
            layout.set_attributes(attributes);
            layout.set_font_description(font);
            layout.set_text(this.activity.description, -1);
            layout.set_width((cell_area.width - MARGIN * 2) * Pango.SCALE);
            layout.set_ellipsize(Pango.EllipsizeMode.END);

            context.move_to(cell_area.x + MARGIN, top);
            Pango.cairo_show_layout(context, layout);

            Pango.Rectangle? ink_rectangle;
            Pango.Rectangle? logical_rectangle;
            layout.get_pixel_extents(out ink_rectangle, out logical_rectangle);

            return top + ink_rectangle.y + ink_rectangle.height + LINE_SPACING;
        }

        private void draw_separator(Cairo.Context context, Gdk.Rectangle cell_area) {
            // TODO : way too many magic numbers here
            context.set_line_width(1);
     	    context.set_source_rgb(0.1, 0.1, 0.1);
            context.move_to(cell_area.x - 3, cell_area.y + cell_area.height + 3);
            context.line_to(cell_area.x + cell_area.width + 3	, cell_area.y + cell_area.height + 3);
            context.stroke();
        }

        private Pango.Attribute get_attr_fg_color(Gtk.Widget widget, bool selected) {
            if (selected) {
                Gdk.RGBA def = { 0.33, 0.33, 0.33, 0.1 };
                return get_pango_foreground_attr(widget.get_style_context(), "selected_fg_color", def);
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
