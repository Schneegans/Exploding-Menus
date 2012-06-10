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

public class MenuItem {

    public string label;
    public string icon_name;
    
    private AnimatedValue pos_x = null;
    private AnimatedValue pos_y = null;
    private AnimatedValue scale = null;
    
    private bool selectable = false;
    
    public MenuItem(string label, string icon_name) {
        this.label = label;
        this.icon_name = icon_name;
        
        this.pos_x = new AnimatedValue.cubic(AnimatedValue.Direction.OUT, 1, 1, 0);
        this.pos_y = new AnimatedValue.cubic(AnimatedValue.Direction.OUT, 1, 1, 0);
        this.scale = new AnimatedValue.cubic(AnimatedValue.Direction.OUT, 1, 1, 0);
    }
    
    public void draw(Cairo.Context ctx, Gtk.Window window, int center_x, int center_y, bool prelight, double frame_time) {
    
        pos_x.update(frame_time);   
        pos_y.update(frame_time);
        scale.update(frame_time);

        render_shadowed_rectangle(ctx, window, (int)(pos_x.val + center_x), (int)(pos_y.val + center_y)+2, (int)(ExplodingMenu.ITEM_WIDTH*scale.val), (int)(ExplodingMenu.ITEM_HEIGHT*scale.val)-4);
        
        window.get_style_context().add_class(Gtk.STYLE_CLASS_MENUITEM);
        
        if (prelight) {
            window.get_style_context().set_state(Gtk.StateFlags.ACTIVE);
            window.get_style_context().render_background(ctx, (int)(pos_x.val + center_x)+1, (int)(pos_y.val + center_y)+2, (int)(ExplodingMenu.ITEM_WIDTH*scale.val)-2, (int)(ExplodingMenu.ITEM_HEIGHT*scale.val)-4);
            
        } else if (!selectable) {
            window.get_style_context().set_state(Gtk.StateFlags.INSENSITIVE);
            window.get_style_context().render_background(ctx, (int)(pos_x.val + center_x)+1, (int)(pos_y.val + center_y)+2, (int)(ExplodingMenu.ITEM_WIDTH*scale.val)-2, (int)(ExplodingMenu.ITEM_HEIGHT*scale.val)-4);
        }
        
        window.get_style_context().set_state(Gtk.StateFlags.NORMAL);
        
//        
//        window.get_style_context().remove_class(Gtk.STYLE_CLASS_MENUITEM);
//        window.get_style_context().add_class(Gtk.STYLE_CLASS_RADIO);
//        window.get_style_context().render_option(ctx, pivot_x-17, pivot_y-17, 34, 34);
//        window.get_style_context().remove_class(Gtk.STYLE_CLASS_RADIO);
//        window.get_style_context().add_class(Gtk.STYLE_CLASS_MENUITEM);
//        
        var layout = window.create_pango_layout(label);
        if (pos_x.val < 0)
            layout.set_alignment(Pango.Alignment.RIGHT);
        layout.set_font_description(Pango.FontDescription.from_string("%d".printf((int)(5.0*scale.val+5))));
        layout.set_width((int)((ExplodingMenu.ITEM_WIDTH-2*ExplodingMenu.ITEM_HEIGHT)*Pango.SCALE*scale.val));
        window.get_style_context().render_layout(ctx,  (int)((pos_x.val + center_x)+(ExplodingMenu.ITEM_HEIGHT)*scale.val), (int)((pos_y.val + center_y)+2+7*scale.val), layout);
        
        if (icon_name != "") {
            int icon_size = (int)((ExplodingMenu.ITEM_HEIGHT/2)*scale.val);
        
            var icon = new Icon(icon_name, icon_size);
            
            if (pos_x.val < 0)  window.get_style_context().render_icon(ctx, icon.to_pixbuf(), (int)(pos_x.val + center_x)-5-icon_size+ExplodingMenu.ITEM_WIDTH*scale.val, (int)(pos_y.val + center_y)+5);
            else                window.get_style_context().render_icon(ctx, icon.to_pixbuf(), (int)(pos_x.val + center_x)+5, (int)(pos_y.val + center_y)+5);
        }
 
        window.get_style_context().remove_class(Gtk.STYLE_CLASS_MENUITEM);
        window.get_style_context().set_state(Gtk.StateFlags.NORMAL);   
    }
    
    public void set_position(int position, int current_offset, bool animate) {

        int x, y;
        double s;

        bool left = position%2 == 0;
        
        int max_active_row = (current_offset + ExplodingMenu.SLICE_PAIRS*2)/2-1;
        int min_active_row = current_offset/2;
        double center_row = (max_active_row + min_active_row)*0.5;
        int current_row = position/2;
        
        double center_row_distance = current_row - center_row;

        if (current_row >= min_active_row && current_row <= max_active_row) {
            
            // center items
            
            selectable = true;
        
            s = 1.0;
            y = (int)((center_row_distance - 0.5) * ExplodingMenu.ITEM_HEIGHT);
            
            int offset_x = (int)((1.0 - 2*(GLib.Math.fabs(center_row_distance)+0.4)/ExplodingMenu.SLICE_PAIRS)*ExplodingMenu.LABEL_RADIUS);
            
            if (left) x = -ExplodingMenu.ITEM_WIDTH-offset_x;
            else      x = offset_x;
            
        } else if (center_row_distance > 0) {
        
            // bottom items
            
            selectable = false;
        
            s = ExplodingMenu.MIN_SCALE;
            y = (int)((center_row_distance - ExplodingMenu.SLICE_PAIRS/2) * ExplodingMenu.ITEM_HEIGHT*s + ExplodingMenu.SLICE_PAIRS/2*ExplodingMenu.ITEM_HEIGHT);
            
            y += (current_row - max_active_row - 1)/ExplodingMenu.SLICE_PAIRS*20;
            
            if (left) x = (int)(-ExplodingMenu.ITEM_WIDTH*s-ExplodingMenu.CENTER_RADIUS/3);
            else      x = (int)( ExplodingMenu.CENTER_RADIUS/3);
            
        } else {
        
            // top items
            
            selectable = false;
        
            s = ExplodingMenu.MIN_SCALE;
            y = (int)((center_row_distance + ExplodingMenu.SLICE_PAIRS/2 - 1) * ExplodingMenu.ITEM_HEIGHT*s - ExplodingMenu.SLICE_PAIRS/2*ExplodingMenu.ITEM_HEIGHT);
            
            y -= (min_active_row - current_row - 1)/ExplodingMenu.SLICE_PAIRS*20; 
            
            if (left) x = (int)(-ExplodingMenu.ITEM_WIDTH*s-ExplodingMenu.CENTER_RADIUS/3);
            else      x = (int)( ExplodingMenu.CENTER_RADIUS/3);
        }
        
        double duration = animate ? ExplodingMenu.ANIMATION_TIME : 0.0;

        pos_x.reset_target(x, duration);
        pos_y.reset_target(y, duration);
        scale.reset_target(s, duration);
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
