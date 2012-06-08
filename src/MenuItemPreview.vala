/* 
Copyright (c) 2011 by Simon Schneegans

This program is free software: you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the Free
Software Foundation, either version 3 of the License, or (at your option)
any later version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
more details.

You should have received a copy of the GNU General Public License along with
this program.  If not, see <http://www.gnu.org/licenses/>. 
*/

namespace GnomePie {

public class MenuItemPreview {

    private bool top;
    private AnimatedValue offset = null;
    
    private string[] labels;
    private string[] icons;
    
    public MenuItemPreview(bool top, bool animated = false, bool shrinking = false) {
        labels = {};
        icons = {};
        
        offset = new AnimatedValue.cubic(AnimatedValue.Direction.OUT, animated ? (shrinking ? 3*20+10+10 : -3*20-10-10) : 0, 0, 0.2, 0);
    
        this.top = top;
    }
    
    public void add_entry(string label, string icon) {
        labels += label;
        icons += icon;
    }
    
    public void draw(Cairo.Context ctx, Gtk.Window window, int center_x, int center_y, bool prelight, double frame_time) {
        
        offset.update(frame_time);
        
        int separator_count = (labels.length-1)/6;
        int width = 250;
        int height = (labels.length+1)/2 * 20 + 10 + 10*separator_count;
        int y = top ? (int)(center_y - 55 - height - offset.val) : (int)(center_y + 55 + offset.val);
        int x = center_x - width/2;
        
        render_shadowed_rectangle(ctx, window, x, y, width, height);
        
        window.get_style_context().add_class(Gtk.STYLE_CLASS_MENUITEM);
        
        if (prelight) {
            window.get_style_context().set_state(Gtk.StateFlags.ACTIVE);
            window.get_style_context().render_background(ctx, x+1, y, width-2, height);
        } 
        
        window.get_style_context().remove_class(Gtk.STYLE_CLASS_MENUITEM);
        window.get_style_context().add_class(Gtk.STYLE_CLASS_RADIO);
        window.get_style_context().render_option(ctx, center_x-17, center_y + (top ? -50: 50) - 17, 34, 34);
        window.get_style_context().remove_class(Gtk.STYLE_CLASS_RADIO);
        window.get_style_context().add_class(Gtk.STYLE_CLASS_MENUITEM);
        
        window.get_style_context().render_arrow(ctx, top ? 0 : GLib.Math.PI, center_x-12, center_y + (top ? -50: 50) - 12, 24);
        
        int current_y = y;
        if (top) current_y += 4;
        else     current_y += 12;
        
        for (int i=0; i<labels.length; ++i) {
            if (i%6 == 0 && i != 0) {
                window.get_style_context().render_line(ctx, x, current_y+2, x+width, current_y+2);
                current_y += 10;
            }
        
            var layout = window.create_pango_layout(labels[i]);
            layout.set_font_description(Pango.FontDescription.from_string("8"));
            layout.set_width((int)(150.0*Pango.SCALE));
            
            if (i%2 == 0) {
                
                layout.set_alignment(Pango.Alignment.RIGHT);
            
                window.get_style_context().render_layout(ctx, x - 30 + width/2 - 150, current_y, layout);
                
                if (icons[i] != "") {
                    var icon = new Icon(icons[i], 12);
                    window.get_style_context().render_icon(ctx, icon.to_pixbuf(), x-20+width/2 - 6, current_y);
                }
            } else {
                
        
                window.get_style_context().render_layout(ctx, x + 30 + width/2, current_y, layout);
                
                if (icons[i] != "") {
                    var icon = new Icon(icons[i], 12);
                    window.get_style_context().render_icon(ctx, icon.to_pixbuf(), x+20+width/2 - 6, current_y);
                }
            
                current_y += 20;
            }
        }
        
        window.get_style_context().remove_class(Gtk.STYLE_CLASS_MENUITEM);
        window.get_style_context().set_state(Gtk.StateFlags.NORMAL);   
    }
    
    private void render_shadowed_rectangle(Cairo.Context ctx, Gtk.Window window, int x, int y, int width, int height) {
        
        window.get_style_context().add_class(Gtk.STYLE_CLASS_MENU);
    
        int radius = 4;
        int offset_x = 0;
        int offset_y = 1;
        
        double r = 0.0;
        double g = 0.0;
        double b = 0.0;
        double a = 0.5;
        
        var left = new Cairo.Pattern.linear(x+offset_x + radius/2, 0, x+offset_x - radius/2, 0);
            left.add_color_stop_rgba(0.0, r, g, b, a);
            left.add_color_stop_rgba(1.0, r, g, b, 0.0);
            
            ctx.set_source(left);
            ctx.rectangle(x+offset_x - radius/2, 
                          y+offset_y + radius/2, 
                          radius, 
                          height-radius);
            ctx.fill();
            
        var right = new Cairo.Pattern.linear(x+offset_x - radius/2 + width, 0, x+offset_x + radius/2 + width, 0);
            right.add_color_stop_rgba(0.0, r, g, b, a);
            right.add_color_stop_rgba(1.0, r, g, b, 0.0);
            
            ctx.set_source(right);
            ctx.rectangle(x+offset_x - radius/2 + width, 
                          y+offset_y + radius/2, 
                          radius, 
                          height-radius);
            ctx.fill();
            
        var top = new Cairo.Pattern.linear(0, y+offset_y + radius/2, 0, y+offset_y - radius/2);
            top.add_color_stop_rgba(0.0, r, g, b, a);
            top.add_color_stop_rgba(1.0, r, g, b, 0.0);
            
            ctx.set_source(top);
            ctx.rectangle(x+offset_x + radius/2, 
                          y+offset_y - radius/2, 
                          width-radius, 
                          radius);
            ctx.fill();
            
        var bottom = new Cairo.Pattern.linear(0, y+offset_y - radius/2 + height, 0, y+offset_y + radius/2 + height);
            bottom.add_color_stop_rgba(0.0, r, g, b, a);
            bottom.add_color_stop_rgba(1.0, r, g, b, 0.0);
            
            ctx.set_source(bottom);
            ctx.rectangle(x+offset_x + radius/2, 
                          y+offset_y - radius/2 + height, 
                          width-radius, 
                          radius);
            ctx.fill();
            
        var topleft = new Cairo.Pattern.radial(x+offset_x + radius/2, y+offset_y + radius/2, 0,
                                               x+offset_x + radius/2, y+offset_y + radius/2, radius);
            topleft.add_color_stop_rgba(0.0, r, g, b, a);
            topleft.add_color_stop_rgba(1.0, r, g, b, 0.0);
            
            ctx.set_source(topleft);
            ctx.rectangle(x+offset_x - radius/2, 
                          y+offset_y - radius/2, 
                          radius, 
                          radius);
            ctx.fill();
            
        var topright = new Cairo.Pattern.radial(x+offset_x - radius/2 + width, y+offset_y + radius/2, 0,
                                                x+offset_x - radius/2 + width, y+offset_y + radius/2, radius);
            topright.add_color_stop_rgba(0.0, r, g, b, a);
            topright.add_color_stop_rgba(1.0, r, g, b, 0.0);
            
            ctx.set_source(topright);
            ctx.rectangle(x+offset_x - radius/2 + width, 
                          y+offset_y - radius/2, 
                          radius, 
                          radius);
            ctx.fill();
            
        var bottomleft = new Cairo.Pattern.radial(x+offset_x + radius/2, y+offset_y - radius/2 + height, 0,
                                                  x+offset_x + radius/2, y+offset_y - radius/2 + height, radius);
            bottomleft.add_color_stop_rgba(0.0, r, g, b, a);
            bottomleft.add_color_stop_rgba(1.0, r, g, b, 0.0);
            
            ctx.set_source(bottomleft);
            ctx.rectangle(x+offset_x - radius/2, 
                          y+offset_y - radius/2 + height, 
                          radius, 
                          radius);
            ctx.fill();
            
        var bottomright = new Cairo.Pattern.radial(x+offset_x - radius/2 + width, y+offset_y - radius/2 + height, 0,
                                                   x+offset_x - radius/2 + width, y+offset_y - radius/2 + height, radius);
            bottomright.add_color_stop_rgba(0.0, r, g, b, a);
            bottomright.add_color_stop_rgba(1.0, r, g, b, 0.0);
            
            ctx.set_source(bottomright);
            ctx.rectangle(x+offset_x - radius/2 + width, 
                          y+offset_y - radius/2 + height, 
                          radius, 
                          radius);
            ctx.fill();
        
        window.get_style_context().render_background(ctx, x, y, width, height);
        window.get_style_context().render_frame(ctx, x, y, width, height);
        
        window.get_style_context().remove_class(Gtk.STYLE_CLASS_MENU);
    }
    
    
}

}
