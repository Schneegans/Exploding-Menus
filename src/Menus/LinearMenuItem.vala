/* 
Copyright (c) 2011-2012 by Simon Schneegans

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

public class LinearMenuItem {
    
    public const double FG_R = 0.2;
    public const double FG_G = 0.2;
    public const double FG_B = 0.2;
    
    public const double BG_R = 0.9;
    public const double BG_G = 0.9;
    public const double BG_B = 0.9;
    
    public const double SEL_R = 0.8;
    public const double SEL_G = 0.2;
    public const double SEL_B = 0.3;
    
    public const int ITEM_HEIGHT = 24;
    public const int ADD_WIDTH = 55;
    public const int OVERLAP_WIDTH = 6;
    public const int MIN_WIDTH = 150;

    public string label;
    public string icon_name;
    
    public enum State { INVISIBLE, SELECTABLE, HOVERED, SELECTED }
    
    private weak LinearMenuItem parent = null;

    private State state = State.INVISIBLE;
    private bool closing = false;
    private uint hover_start_time;
    
    private int hovered_child = -1;
    private int active_child = -1;
    private Vector last_mouse;
    
    private Gee.ArrayList<LinearMenuItem> children;
    
    public LinearMenuItem(string label, string icon_name) {
        this.label = label;
        this.icon_name = icon_name;
        this.last_mouse = new Vector(0,0);
        
        this.children = new Gee.ArrayList<LinearMenuItem>();
    }
    
    public void add_child(LinearMenuItem child) {
        this.children.add(child);
        child.parent = this;
    }
    
    public void close() {
        foreach (var child in children)
            child.close();
            
        closing = true;
    }
    
    public bool submenu_is_hovered() {
        
        if (active_child < 0)
            return false;
        
        if (children[active_child].hovered_child >= 0)
            return true;
            
        return children[active_child].submenu_is_hovered();
    }
    
    public string activate(Vector mouse) {
        
        if (hovered_child >= 0) {
            if (children[hovered_child].children.size > 0) {
                children[hovered_child].set_state(State.SELECTED);
                active_child = hovered_child;
                return "_keep_open";
               
            } else {
                return children[hovered_child].get_path();
            }
        }
        
        if (active_child >= 0)
            return children[active_child].activate(mouse);

        return "_cancel";
    }
    
    public void set_state(State new_state) {
        this.state = new_state;
    
        switch (new_state) {
            case State.HOVERED: case State.SELECTED:
                for (int i=0; i<children.size; ++i)
                    children[i].set_state(State.SELECTABLE);
                break;
        }
    }
    
    public string get_path() {
        if (parent == null) return "";
        if (parent.parent == null) return label;
        return parent.get_path() + " | " + label;
    }
    
    public void draw(Cairo.Context ctx, InvisibleWindow window, Vector topleft, double parent_width, double frame_time) {
        
        var menu_size = new Vector(get_width(window), get_height(window));       
        var mouse = window.get_mouse_pos();
        
        var pos = topleft.copy();
        
        if (pos.x + menu_size.x > window.width()) {
            pos.x = pos.x - parent_width - menu_size.x + OVERLAP_WIDTH;
        }
        
        if (pos.y + menu_size.y > window.height()) {
            pos.y = window.height() - menu_size.y;
        }
        
        // get hovered item
        if (submenu_is_hovered()) {
            hovered_child = -1;
        } else {
            if (mouse.x > pos.x && mouse.x < pos.x + menu_size.x &&
                mouse.y > pos.y && mouse.y < pos.y + menu_size.y) {
                
                if ((mouse.x - last_mouse.x < mouse.y - last_mouse.y) || last_mouse.y >= mouse.y)
                    hovered_child = (int)((mouse.y - pos.y)/ITEM_HEIGHT);
                
                if (hovered_child != active_child)
                    active_child = -1;
                
            } else {
                bool a_child_is_active = false;
                for (int i=0; i<children.size; ++i) {
                    if (children[i].state == State.SELECTED) {
                        a_child_is_active = true;
                        break;
                    }
                }
                
                if (!a_child_is_active)
                    active_child = -1;
                    
                hovered_child = -1;
            }
            
            for (int i=0; i<children.size; ++i) {
                if (i == hovered_child || i == active_child) {
                    if (children[i].state != State.SELECTED) {
                        if (children[i].state != State.HOVERED) {
                            children[i].set_state(State.HOVERED);
                            children[i].hover_start_time = Time.get_now();
                        } else if (children[i].children.size > 0 && children[i].hover_start_time + 250 < Time.get_now()) {
                            children[i].set_state(State.SELECTED);
                            active_child = i;
                        }
                    }
                } else {
                    children[i].set_state(State.SELECTABLE);
                }
            }
        }
        
        // draw entire bg
        
        ctx.set_source_rgb(FG_R, FG_G, FG_B);
        draw_round_rectangle(ctx, new Vector(pos.x-2, pos.y-2), 
                                  new Vector(pos.x+menu_size.x+2, pos.y+menu_size.y+2), 7);
        
        ctx.set_source_rgb(BG_R, BG_G, BG_B);
        draw_round_rectangle(ctx, pos, Vector.sum(pos, menu_size), 5);

        Vector top_left = pos.copy();
        
        foreach (var child in children) {
        
            // draw selected bg
            
            if (child.label == "Karl" || child.label == "Heinz" || child.label == "Bauer") {
                ctx.set_source_rgb(1, 1, 0);
                draw_round_rectangle(ctx, top_left, Vector.sum(top_left, new Vector(menu_size.x, ITEM_HEIGHT)), 5);
            }
            
            if (child.state == State.HOVERED || child.state == State.SELECTED) {
                ctx.set_source_rgb(SEL_R, SEL_G, SEL_B);
                draw_round_rectangle(ctx, top_left, Vector.sum(top_left, new Vector(menu_size.x, ITEM_HEIGHT)), 5);
            }
            
            
            
            // draw icon
            if (child.icon_name != "") {
                int icon_size = ITEM_HEIGHT-8;
                var icon = new Icon(child.icon_name, icon_size);
                
                window.get_style_context().render_icon(ctx, icon.to_pixbuf(), top_left.x+4, top_left.y+4);
            }
            
            
            // draw label
            ctx.set_source_rgb(0.0, 0.0, 0.0);
            var layout = window.create_pango_layout(child.label);
            
            ctx.move_to(top_left.x + 5 + ITEM_HEIGHT, top_left.y + 4);
            
            Pango.cairo_update_layout(ctx, layout);
            Pango.cairo_show_layout(ctx, layout);
            ctx.stroke();

            
            // draw arrow
            if (child.children.size > 0) {
                window.get_style_context().render_arrow(ctx, GLib.Math.PI*0.5, top_left.x-25+menu_size.x, top_left.y+6, ITEM_HEIGHT/2);
            }

            top_left.y += ITEM_HEIGHT;
        }
        
        top_left = pos.copy();
        foreach (var child in children) {
            // draw children
            if (child.state == State.SELECTED && child.children.size > 0) {
                child.draw(ctx, window, Vector.sum(top_left, new Vector(menu_size.x-OVERLAP_WIDTH, 0)), menu_size.x, frame_time);
            }
            top_left.y += ITEM_HEIGHT;
        }
        
        last_mouse = mouse.copy();
    }
    
    private double get_height(InvisibleWindow window) {
        return children.size*ITEM_HEIGHT;
    }
    
    private double get_width(InvisibleWindow window) {
        double width = 0;
        
        foreach (var child in children) {
            var layout = window.create_pango_layout(child.label);
            var label_size = new Vector(0, 0);
            layout.get_pixel_size(out label_size.x, out label_size.y);
            
            if (label_size.x > width)
                width = label_size.x;
        }
        
        width += ADD_WIDTH;
        width += ITEM_HEIGHT;
        
        return width < MIN_WIDTH ? MIN_WIDTH : width;
    }
    
    private void draw_round_rectangle(Cairo.Context ctx, Vector top_left, Vector bottom_right, double radius) {
    
        double a = top_left.x;
        double b = bottom_right.x;
        double c = top_left.y;
        double d = bottom_right.y;
    
        ctx.arc(a + radius, c + radius, radius, 2*(GLib.Math.PI/2), 3*(GLib.Math.PI/2));
        ctx.arc(b - radius, c + radius, radius, 3*(GLib.Math.PI/2), 4*(GLib.Math.PI/2));
        ctx.arc(b - radius, d - radius, radius, 0*(GLib.Math.PI/2), 1*(GLib.Math.PI/2));
        ctx.arc(a + radius, d - radius, radius, 1*(GLib.Math.PI/2), 2*(GLib.Math.PI/2));
        ctx.close_path();
        ctx.fill();
    }
}
