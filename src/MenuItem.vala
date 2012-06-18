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
    
    public enum Direction { N, NE, E, SE, S, SW, W, NW }
    public enum LabelDirection { LEFT, RIGHT, TOP_LEFT, BOTTOM_RIGHT }
    
    private AnimatedValue pos_x = null;
    private AnimatedValue pos_y = null;
    private AnimatedValue scale = null;
    
    private Gee.ArrayList<MenuItem> children;
    
    public MenuItem(string label, string icon_name) {
        this.label = label;
        this.icon_name = icon_name;
        
        this.children = new Gee.ArrayList<MenuItem>();
        
        this.pos_x = new AnimatedValue.cubic(AnimatedValue.Direction.OUT, 1, 1, 0);
        this.pos_y = new AnimatedValue.cubic(AnimatedValue.Direction.OUT, 1, 1, 0);
        this.scale = new AnimatedValue.cubic(AnimatedValue.Direction.OUT, 0.5, 1, Menu.ANIMATION_TIME);
    }
    
    public void add_child(MenuItem child) {
        this.children.add(child);
    }
    
    public void draw(Cairo.Context ctx, InvisibleWindow window, Vector center, 
                     Direction dir, bool prelight, double frame_time) {

        this.pos_x.update(frame_time);   
        this.pos_y.update(frame_time);
        this.scale.update(frame_time);

        var pos = direction_to_coords(dir, Menu.ITEM_RADIUS);
            pos.x += center.x;
            pos.y += center.y;
            
        var layout = window.create_pango_layout(label);
        var label_size = new Vector(0, 0);
        layout.get_pixel_size(out label_size.x, out label_size.y);
        
        var label_pos = new Vector(pos.x, pos.y-7);
        
        // draw label background
        ctx.set_source_rgb(0.9, 0.9, 0.9);
        ctx.set_line_width(Menu.ITEM_HEIGHT);
        ctx.set_line_join(Cairo.LineJoin.ROUND);
        ctx.set_line_cap(Cairo.LineCap.ROUND);
        ctx.move_to(pos.x, pos.y);
        
        switch (get_label_direction(dir)) {
            case LabelDirection.LEFT:
                ctx.line_to(pos.x-label_size.x - Menu.ITEM_HEIGHT/2 , pos.y);
                label_pos.x -= label_size.x + Menu.ITEM_HEIGHT/2;
                break;
            case LabelDirection.RIGHT:
                ctx.line_to(pos.x+label_size.x + Menu.ITEM_HEIGHT/2, pos.y);
                label_pos.x += Menu.ITEM_HEIGHT/2;
                break;
            case LabelDirection.TOP_LEFT:
                ctx.line_to(pos.x, pos.y - Menu.ITEM_HEIGHT/2 - 5);
                ctx.line_to(pos.x-label_size.x, pos.y - Menu.ITEM_HEIGHT/2 - 5);
                label_pos.x -= label_size.x;
                label_pos.y -= Menu.ITEM_HEIGHT/2 + 5;
                break;
            case LabelDirection.BOTTOM_RIGHT:
                ctx.line_to(pos.x, pos.y + Menu.ITEM_HEIGHT/2 + 5);
                ctx.line_to(pos.x+label_size.x, pos.y + Menu.ITEM_HEIGHT/2 + 5);
                label_pos.y += Menu.ITEM_HEIGHT/2 + 5;
                break;
        }
        
        ctx.stroke();
        
        // draw circle
        if (prelight) ctx.set_source_rgb(0.7, 0.2, 0.1);
        else          ctx.set_source_rgb(0.4, 0.4, 0.4);
        
        if (children.size == 0) ctx.arc(pos.x, pos.y, Menu.CIRCLE_NORMAL_RADIUS, 0, GLib.Math.PI*2);
        else                    ctx.arc(pos.x, pos.y, Menu.CIRCLE_NORMAL_SUB_RADIUS, 0, GLib.Math.PI*2);
        ctx.fill();
        
        // draw label
        if (prelight) ctx.set_source_rgb(0.7, 0.2, 0.1);
        else          ctx.set_source_rgb(0.0, 0.0, 0.0);

        ctx.move_to(label_pos.x, label_pos.y);
        Pango.cairo_update_layout(ctx, layout);
        Pango.cairo_show_layout(ctx, layout);
        ctx.stroke();

        // draw child circles
        for (int i=0; i<children.size; ++i) {
            var child_dir = index_to_direction(i, children.size, (dir+4)%8);
            children[i].draw_preview(ctx, window, pos, child_dir, prelight, frame_time);
        }
    }
    
    public void draw_root(Cairo.Context ctx, InvisibleWindow window, Vector center, double frame_time) {
        this.pos_x.update(frame_time);   
        this.pos_y.update(frame_time);
        this.scale.update(frame_time);
        
        var active = a_slice_is_active(window, center);
        var active_dir = get_mouse_direction(window, center);
        
        // draw sector of active item
        for (int i=0; i<children.size; ++i) {
            var dir = index_to_direction(i, children.size, Direction.S);
            
            if (active && dir == active_dir)
                children[i].draw_sector(ctx, window, center, dir, frame_time);
        }
        
        // draw items
        for (int i=0; i<children.size; ++i) {
            var dir = index_to_direction(i, children.size, Direction.S);
            children[i].draw(ctx, window, center, dir, active && dir == active_dir, frame_time);
        }
    }
    
    public void draw_preview(Cairo.Context ctx, InvisibleWindow window, Vector center, 
                             Direction dir, bool prelight, double frame_time) {
        this.pos_x.update(frame_time);   
        this.pos_y.update(frame_time);
        this.scale.update(frame_time);

        var pos = direction_to_coords(dir, Menu.CIRCLE_NORMAL_SUB_RADIUS + Menu.CIRCLE_PREVIEW_RADIUS);
            pos.x += center.x;
            pos.y += center.y;
        
        if (prelight) ctx.set_source_rgb(0.7, 0.2, 0.1);
        else          ctx.set_source_rgb(0.4, 0.4, 0.4);
        
        ctx.arc(pos.x, pos.y, Menu.CIRCLE_PREVIEW_RADIUS, 0, GLib.Math.PI*2);
        ctx.fill();
    }
    
    public void draw_sector(Cairo.Context ctx, InvisibleWindow window, Vector center, 
                             Direction dir, double frame_time) {
        
        double start_angle = (dir-2)*(GLib.Math.PI/4)-GLib.Math.PI/8+Menu.SLICE_HINT_GAP;
        double end_angle = (dir-2)*(GLib.Math.PI/4)+GLib.Math.PI/8-Menu.SLICE_HINT_GAP;
        
        var gradient = new Cairo.Pattern.radial(center.x, center.y, Menu.ACTIVE_RADIUS, center.x, center.y, Menu.SLICE_HINT_RADIUS);

        gradient.add_color_stop_rgba(0.0, 0.7, 0.2, 0.1, 0.4);
        gradient.add_color_stop_rgba(1.0, 0.7, 0.2, 0.1, 0.0);

        ctx.set_source(gradient);
    
        ctx.arc_negative(center.x, center.y, Menu.ACTIVE_RADIUS, end_angle, start_angle);
        ctx.arc(center.x, center.y, Menu.SLICE_HINT_RADIUS, start_angle, end_angle);
        ctx.close_path();
        ctx.fill();
    }
    
    private Direction index_to_direction(int index, int item_count, Direction parent_direction) {
        var possible_directions = get_possible_directions(item_count, parent_direction);
        
        Direction result = Direction.N;
        for (int i=0; i<=index; ++i) {
            result = get_first_item_direction(ref possible_directions);
        }
    
        return result;
    }
    
    private Gee.ArrayList<Direction> get_possible_directions(int item_count, Direction parent_direction) {
        var e = new Gee.ArrayList<Direction>();
        
        switch (item_count) {
            case 1: 
                e.add((parent_direction + 4)%8);
                break;
            case 2: 
                e.add((parent_direction + 2)%8);
                e.add((parent_direction - 2)%8);
                break;
            case 3: 
                e.add((parent_direction + 2)%8);
                e.add((parent_direction - 2)%8);
                e.add((parent_direction + 4)%8);
                break;
            case 4: 
                e.add((parent_direction + 1)%8);
                e.add((parent_direction - 1)%8);
                e.add((parent_direction + 3)%8);
                e.add((parent_direction - 3)%8);
                break;
            case 5: 
                e.add((parent_direction + 1)%8);
                e.add((parent_direction - 1)%8);
                e.add((parent_direction + 3)%8);
                e.add((parent_direction - 3)%8);
                e.add((parent_direction + 4)%8);
                break;
            case 6: 
                e.add((parent_direction + 1)%8);
                e.add((parent_direction - 1)%8);
                e.add((parent_direction + 2)%8);
                e.add((parent_direction - 2)%8);
                e.add((parent_direction + 3)%8);
                e.add((parent_direction - 3)%8);
                break;
            case 7: 
                e.add((parent_direction + 1)%8);
                e.add((parent_direction - 1)%8);
                e.add((parent_direction + 2)%8);
                e.add((parent_direction - 2)%8);
                e.add((parent_direction + 3)%8);
                e.add((parent_direction - 3)%8);
                e.add((parent_direction + 4)%8);
                break;
            case 8: 
                e.add((parent_direction + 1)%8);
                e.add((parent_direction - 1)%8);
                e.add((parent_direction + 2)%8);
                e.add((parent_direction - 2)%8);
                e.add((parent_direction + 3)%8);
                e.add((parent_direction - 3)%8);
                e.add((parent_direction + 4)%8);
                e.add(parent_direction);
                break;
        }
        
        return e;
    }   
    
    private Direction get_first_item_direction(ref Gee.ArrayList<Direction> possible_directions) {
        var priorities = new Gee.ArrayList<Direction>();
            priorities.add(Direction.N);
            priorities.add(Direction.NW);
            priorities.add(Direction.W);
            priorities.add(Direction.SW);
            priorities.add(Direction.NE);
            priorities.add(Direction.E);
            priorities.add(Direction.SE);
            priorities.add(Direction.S);

        foreach (var dir in priorities) {
            if (possible_directions.contains(dir)) {
                possible_directions.remove(dir);
                return dir;
            }
        }
        
        //stub!
        return Direction.N;
    }
    
    private Vector direction_to_coords(Direction in_direction, int radius) {
        
        Vector rel = new Vector(0, 0);
        
        switch (in_direction) {
            case Direction.N: 
                rel.x =  0;
                rel.y = -radius;
                break;
            case Direction.E: 
                rel.y =  0;
                rel.x =  radius;
                break;
            case Direction.S: 
                rel.x =  0;
                rel.y =  radius;
                break;
            case Direction.W: 
                rel.y =  0;
                rel.x = -radius;
                break;
            case Direction.NE: 
                rel.x = (int)( 0.707106781*radius);
                rel.y = (int)(-0.707106781*radius);
                break;
            case Direction.NW: 
                rel.x = (int)(-0.707106781*radius);
                rel.y = (int)(-0.707106781*radius);
                break;
            case Direction.SE: 
                rel.x = (int)( 0.707106781*radius);
                rel.y = (int)( 0.707106781*radius);
                break;
            case Direction.SW: 
                rel.x = (int)(-0.707106781*radius);
                rel.y = (int)( 0.707106781*radius);
                break;
        }
        
        return rel;
    }
    
    private LabelDirection get_label_direction(Direction in_direction) {
        switch (in_direction) {
            case Direction.N:   return LabelDirection.TOP_LEFT;
            case Direction.E:   return LabelDirection.RIGHT;
            case Direction.S:   return LabelDirection.BOTTOM_RIGHT;
            case Direction.W:   return LabelDirection.LEFT;
            case Direction.NE:  return LabelDirection.RIGHT;
            case Direction.NW:  return LabelDirection.LEFT;
            case Direction.SE:  return LabelDirection.RIGHT;
            case Direction.SW:  return LabelDirection.LEFT;
        }
        
        //stub!
        return LabelDirection.BOTTOM_RIGHT;
    }
    
    private bool a_slice_is_active(InvisibleWindow window, Vector center) {
        var mouse = new Vector(0, 0);
        window.get_mouse_pos(out mouse.x, out mouse.y);
        
        var diff = new Vector(mouse.x - center.x, mouse.y - center.y);
        
        return diff.length_sqr() > Menu.ACTIVE_RADIUS*Menu.ACTIVE_RADIUS; 
    }
    
    private Direction get_mouse_direction(InvisibleWindow window, Vector center) {
        var mouse = new Vector(0, 0);
        window.get_mouse_pos(out mouse.x, out mouse.y);
        
        Direction loc = Direction.N;
        
        int sectors = 8;
        double angle = 0;
        
        double diff_x = mouse.x - center.x;
        double diff_y = mouse.y - center.y;

        double distance_sqr = GLib.Math.pow(diff_x, 2) + GLib.Math.pow(diff_y, 2);
        
        if (distance_sqr > Menu.ACTIVE_RADIUS*Menu.ACTIVE_RADIUS) {
            
            if (diff_x == 0) {
                angle = diff_y < 0 ? 1.5*GLib.Math.PI : 0.5*GLib.Math.PI;
            } else if (diff_y == 0) {
                angle = diff_x > 0 ? 0 : GLib.Math.PI;
            } else {
                angle = GLib.Math.atan(-diff_y/diff_x);
                
                if (-diff_y > 0 && diff_x > 0)
                    angle = 2*GLib.Math.PI - angle;
                else if (diff_x < 0)
                    angle = GLib.Math.PI - angle;
                else
                    angle = -angle;
            }
            
            if (angle < 0.0) angle += 2.0*GLib.Math.PI;
            
            double locf = sectors*angle/(2.0*GLib.Math.PI) - ((1.5*sectors - 1)*0.5);
            
            if (locf < 0)
                locf += sectors;
            
            loc = (Direction)(locf);
        }
        
        return loc;
    }
    
}

}
