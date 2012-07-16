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

public class CoralMenuItem {
    
    public const double FG_R = 0.2;
    public const double FG_G = 0.2;
    public const double FG_B = 0.2;
    
    public const double BG_R = 0.9;
    public const double BG_G = 0.9;
    public const double BG_B = 0.9;
    
    public const double SEL_R = 0.8;
    public const double SEL_G = 0.2;
    public const double SEL_B = 0.3;

    public string label;
    public string icon_name;
    
    public enum State { INVISIBLE, PREVIEW, EXPANDED, ACTIVE, INACTIVE }
    
    private weak CoralMenuItem parent = null;
    
    private AnimatedValue offset_x = null;
    private AnimatedValue offset_y = null;
    private AnimatedValue draw_radius = null;
    private AnimatedValue label_alpha = null;
    private AnimatedValue small_label_alpha = null;
    
    private double direction = 0.0;
    private int depth = 0;
    private bool hovered = false;
    private bool closing = false;
    
    private Vector last_mouse_location = null;
    private double mouse_direction = -1;
    
    private State state = State.INVISIBLE;
    
    
    private Gee.ArrayList<CoralMenuItem> children;
    
    public CoralMenuItem(string label, string icon_name) {
        this.label = label;
        this.icon_name = icon_name;
        
        this.children = new Gee.ArrayList<CoralMenuItem>();
        
        this.offset_x = new AnimatedValue.cubic(AnimatedValue.Direction.OUT, 0, 0, 0, 1);
        this.offset_y = new AnimatedValue.cubic(AnimatedValue.Direction.OUT, 0, 0, 0, 1);
        this.draw_radius = new AnimatedValue.cubic(AnimatedValue.Direction.OUT, 0, 0, 0, 1);
        this.label_alpha = new AnimatedValue.linear(0, 0, 0);
        this.small_label_alpha = new AnimatedValue.linear(0, 0, 0);
    }
    
    public void add_child(CoralMenuItem child) {
        this.children.add(child);
        child.parent = this;
    }
    
    public void realize(double parent_direction, int index, int parent_child_count) {
        if (parent == null) {
            
            this.depth = 0;
            this.direction = 0.0;
            
        } else {

            double total_angle = /*parent.parent == null ? 2*GLib.Math.PI :*/ CoralMenu.CHILDREN_ANGLE;
            double max_item_angle = /*parent.parent == null ? 2*GLib.Math.PI :*/ CoralMenu.MAX_ITEM_ANGLE;
            
            this.depth = parent.depth + 1;
            this.direction = get_item_direction(parent_direction, index, parent_child_count, total_angle, max_item_angle);
        }
        
        for (int i=0; i<children.size; ++i) {
            children[i].realize(this.direction, i, children.size);
        }
    }
    
    public string get_path() {
        if (parent == null) return "";
        if (parent.parent == null) return label;
        return parent.get_path() + "|" + label;
    }
    
    public void close(bool delayed) {
    
        closing = true;
    
        if (delayed) {
            for(int i=0; i<children.size; ++i) {
            
                children[i].close(delayed);
            
                if (children[i].state != State.EXPANDED && parent != null) {
                    children[i].set_state(State.PREVIEW);
                    children[i].update_offset(i, children.size);
                } 
            }
            
            GLib.Timeout.add((uint)(CoralMenu.FADE_OUT_TIME*1000), () => {
                this.label_alpha.reset_target(0.0, CoralMenu.ANIMATION_TIME);
                this.small_label_alpha.reset_target(0.0, CoralMenu.ANIMATION_TIME);
                return false;
            });   
            
        } else {
            foreach (var child in children)
                child.close(delayed);
                
            this.label_alpha.reset_target(0.0, CoralMenu.ANIMATION_TIME);
            this.small_label_alpha.reset_target(0.0, CoralMenu.ANIMATION_TIME);
        }               
    }
    
    public string activate(Vector mouse) {
        
        foreach (var child in children) {
            if (child.state == State.EXPANDED) 
                return child.activate(mouse);
        }
        
        if (hovered && children.size > 0)
            return "_keep_open";
        else if (hovered)
            return get_path(); 

        return "_cancel";
    }
    
    public void set_state(State new_state) {
        this.state = new_state;
    
        switch (new_state) {
            case State.INVISIBLE:
                foreach (var child in children)
                    child.set_state(State.INVISIBLE);
                break;
            
            case State.PREVIEW:
                foreach (var child in children)
                    child.set_state(State.INVISIBLE);
                break;
                
            case State.EXPANDED:
                if (children.size > 0) {
                    foreach (var child in children)
                        child.set_state(State.ACTIVE);
                    if (parent != null)
                        foreach (var sibling in parent.children)
                            if (sibling != this)
                                sibling.set_state(State.INACTIVE);
                } else {
                    if (parent != null)
                        foreach (var sibling in parent.children)
                            if (sibling != this)
                                sibling.set_state(State.ACTIVE);
                }
                break;
                
            case State.ACTIVE:
                foreach (var child in children)
                    child.set_state(State.PREVIEW);
                break;
                
            case State.INACTIVE:
                foreach (var child in children)
                    child.set_state(State.PREVIEW);
                break;
        }
    }
    
    public void update(InvisibleWindow window, Vector parent_center, double frame_time) {
    
        this.update_mouse_direction(window);
    
        this.offset_x.update(frame_time);   
        this.offset_y.update(frame_time);
        this.draw_radius.update(frame_time);
        this.label_alpha.update(frame_time);
        this.small_label_alpha.update(frame_time);
        
        Vector center = new Vector((int)offset_x.end + parent_center.x, (int)offset_y.end + parent_center.y);
        
        if (parent == null)
            clamp_to_screen(parent_center);
        
        if (!closing) {
            if (parent != null && (state == State.ACTIVE || state == State.INACTIVE || state == State.EXPANDED)) {
                double total_angle = /*parent.parent == null ? 2*GLib.Math.PI :*/ CoralMenu.CHILDREN_ANGLE;
                double max_item_angle = /*parent.parent == null ? 2*GLib.Math.PI :*/ CoralMenu.MAX_ITEM_ANGLE;
                double item_angle = get_angle_per_item(parent.children.size, total_angle, max_item_angle);
                double max_angle = direction + item_angle*0.5*0.9;
                double min_angle = direction - item_angle*0.5*0.9;
                double max_distance = Vector.distance(center, parent_center) + CoralMenu.ITEM_RADIUS;
                
                if (state == State.ACTIVE || state == State.EXPANDED)
                    max_distance += 80;
                
                double bottom_radius = GLib.Math.tan(get_angle_per_item(parent.children.size, total_angle, max_item_angle)*0.5) * CoralMenu.INNER_ITEM_RADIUS;
                double min_distance = CoralMenu.INNER_ITEM_RADIUS - bottom_radius;

                this.hovered = mouse_is_inside_cone(window, parent_center, max_angle, min_angle, max_distance, min_distance);
            }
            
            if (parent != null && this.hovered && state != State.EXPANDED) {
            
                int expanded_sibling = -1;
                
                for (int i=0; i < parent.children.size; ++i) {
                    if (parent.children[i].state == State.EXPANDED) {
                        expanded_sibling = i;
                        break;
                    }
                }
                
                double first_child_angle = 0;
                double last_child_angle = 0;
                
                if (expanded_sibling >= 0 && parent.children[expanded_sibling].children.size > 0) {
                    first_child_angle = parent.children[expanded_sibling].children[0].direction;
                    last_child_angle =  parent.children[expanded_sibling].children[parent.children[expanded_sibling].children.size-1].direction;
                }
                
                // nicht(ein sibling is expanded und mouse bewegt sich in richtung dessen childs)
                if (!(expanded_sibling >= 0 && angle_is_between(mouse_direction, first_child_angle, last_child_angle))) {
                    set_state(State.EXPANDED);
                    
                    
                    
                    if (parent != null) {
                        for (int i=0; i<parent.children.size; ++i)
                            parent.children[i].update_offset(i, parent.children.size);
                    } else {
                        update_offset(0, 0);
                    }
                    
                    
                    
                } else {
                    this.hovered = false;
                }
            } else if(!this.hovered && state == State.EXPANDED) {
            
                double first_child_angle = 0;
                double last_child_angle = 0;
                
                if (children.size > 0) {
                    first_child_angle = children[0].direction;
                    last_child_angle = children[children.size-1].direction;
                }
                
                // mouse bewegt sich nicht in richtung eines childs
                if (!(angle_is_between(mouse_direction, first_child_angle, last_child_angle)) || children.size == 0) {
                    double parent_distance = Vector.direction(parent_center, center).length();
                    if (children.size == 0 || mouse_is_inside_circle(window, parent_center, parent_distance)) {

                        if (parent != null) {
                            for (int i=0; i<parent.children.size; ++i) {
                                parent.children[i].set_state(State.ACTIVE);
                                parent.children[i].update_offset(i, parent.children.size);
                            }
                        } else {

                            set_state(State.ACTIVE);
                            update_offset(0, 0);
                        }
                    }
                }
            }
        }
        
        foreach (var child in children) {
            child.update(window, center, frame_time);
        }
    }
    
    public void draw_labels_bg(Cairo.Context ctx, InvisibleWindow window, Vector parent_center) {
        Vector center = new Vector((int)offset_x.val + parent_center.x, (int)offset_y.val + parent_center.y);
        
        if (parent != null && state != State.INVISIBLE) {
            draw_label_bg(ctx, window, center);
        }
        
        foreach (var child in children) {
            if (!child.hovered)
                child.draw_labels_bg(ctx, window, center);
        }
        
        foreach (var child in children) {
            if (child.hovered)
                child.draw_labels_bg(ctx, window, center);
        }
    }
    
    public void draw_labels(Cairo.Context ctx, InvisibleWindow window, Vector parent_center) {
        Vector center = new Vector((int)offset_x.val + parent_center.x, (int)offset_y.val + parent_center.y);
        
        if (parent != null && state != State.INVISIBLE) {
            draw_label(ctx, window, center);
        }
        
        foreach (var child in children) {
            child.draw_labels(ctx, window, center);
        }
    }
    
    public void draw_bg(Cairo.Context ctx, InvisibleWindow window, Vector parent_center) {
        Vector center = new Vector((int)offset_x.val + parent_center.x, (int)offset_y.val + parent_center.y);
        
        foreach (var child in children) {
            child.draw_bg(ctx, window, center);
        }
        
        if (parent != null && state != State.INVISIBLE) {
            
            double fac = (1 - (1.0/(depth+1)))*0.9 + 0.1;
        
            ctx.set_source_rgb(BG_R*fac, BG_G*fac, BG_B*fac);
            ctx.set_line_width(draw_radius.val*2+8);
            ctx.set_line_join(Cairo.LineJoin.ROUND);
            ctx.set_line_cap(Cairo.LineCap.ROUND);
            ctx.move_to(center.x, center.y);
            ctx.line_to(parent_center.x, parent_center.y);
            ctx.stroke();
        }
    }
    
    public void draw(Cairo.Context ctx, InvisibleWindow window, Vector parent_center) {
        Vector center = new Vector((int)offset_x.val + parent_center.x, (int)offset_y.val + parent_center.y);

        foreach (var child in children) {
            child.draw(ctx, window, center);
        }
       
        if (parent != null && state != State.INVISIBLE) {
            if (this.hovered || state == State.EXPANDED)
                ctx.set_source_rgb(SEL_R, SEL_G, SEL_B);
            else
                ctx.set_source_rgb(FG_R, FG_G, FG_B);
                
            
            

            if (state == State.PREVIEW) {
            
                ctx.arc(center.x, center.y, draw_radius.val*0.9, 0, GLib.Math.PI*2);
                ctx.fill();
                
            } else {
            
//                if (label == "Karl" || label == "Heinz" || label == "Bauer")
//                    ctx.set_source_rgb(1, 1, 0);
            
                double total_angle = /*parent.parent == null ? 2*GLib.Math.PI :*/ CoralMenu.CHILDREN_ANGLE;
                double max_item_angle = /*parent.parent == null ? 2*GLib.Math.PI :*/ CoralMenu.MAX_ITEM_ANGLE;

            
                var bottom_center = Vector.sum(direction_to_coords(this.direction, CoralMenu.INNER_ITEM_RADIUS), parent_center);
                var bottom_radius = GLib.Math.tan(get_angle_per_item(parent.children.size, total_angle, max_item_angle)*0.5) * CoralMenu.INNER_ITEM_RADIUS;
                
                double top_arc_radius = GLib.Math.PI;
                ctx.arc(center.x, center.y, draw_radius.val*0.9, direction - top_arc_radius*0.5, direction + top_arc_radius*0.5);
                
                double bottom_arc_radius = GLib.Math.PI;
                ctx.arc(bottom_center.x, bottom_center.y, bottom_radius*0.8, direction + bottom_arc_radius*0.5, direction - bottom_arc_radius*0.5);
                ctx.fill();
                
                draw_small_label(ctx, window, center);
            }
        }
            
    }
    
    public void update_offset(int index, int parent_child_count) {
        
        if (parent == null) {
            
            //this.offset_x.reset_target(0, CoralMenu.ANIMATION_TIME);
            //this.offset_y.reset_target(0, CoralMenu.ANIMATION_TIME);
            this.draw_radius.reset_target(30, CoralMenu.ANIMATION_TIME);
            this.label_alpha.reset_target(0, CoralMenu.ANIMATION_TIME);
            this.small_label_alpha.reset_target(0, CoralMenu.ANIMATION_TIME);
            
        } else {
        
            double new_label_alpha = 0;
            double new_small_label_alpha = 1;
            double total_angle = /*parent.parent == null ? 2*GLib.Math.PI :*/ CoralMenu.CHILDREN_ANGLE;
            double max_item_angle = /*parent.parent == null ? 2*GLib.Math.PI :*/ CoralMenu.MAX_ITEM_ANGLE;
            double new_radius = get_item_radius(parent_child_count, total_angle, max_item_angle);
            
            if (state == State.ACTIVE || (hovered && (state != State.EXPANDED || children.size == 0))) {
                new_label_alpha = 1.0;
                new_small_label_alpha = 0.5;
            }
                
            double new_distance = get_item_distance(parent_child_count, total_angle, max_item_angle);
            
            if (state == State.EXPANDED)
                new_distance += CoralMenu.EXPANDED_ITEM_OFFSET;
            
            var new_offset = direction_to_coords(this.direction, new_distance);
        
            this.offset_x.reset_target(new_offset.x, CoralMenu.ANIMATION_TIME);
            this.offset_y.reset_target(new_offset.y, CoralMenu.ANIMATION_TIME);
            this.draw_radius.reset_target(new_radius, CoralMenu.ANIMATION_TIME);
            this.label_alpha.reset_target(new_label_alpha, CoralMenu.ANIMATION_TIME);
            this.small_label_alpha.reset_target(new_small_label_alpha, CoralMenu.ANIMATION_TIME);
        }
        
        for (int i=0; i<children.size; ++i) {
            children[i].update_offset(i, children.size);
        }
    }
    
    private void draw_label_bg(Cairo.Context ctx, InvisibleWindow window, Vector center) {
        
        if (label_alpha.val > 0.05) {
        
            var layout = window.create_pango_layout(label);
            var label_size = new Vector(0, 0);
            layout.get_pixel_size(out label_size.x, out label_size.y);
            
            if (hovered)    ctx.set_source_rgba(SEL_R, SEL_G, SEL_B, label_alpha.val*label_alpha.val*0.9);
            else            ctx.set_source_rgba(BG_R, BG_G, BG_B, label_alpha.val*label_alpha.val*0.9);
            
//            if (label == "Karl" || label == "Heinz" || label == "Bauer")
//                ctx.set_source_rgba(1, 1, 0, label_alpha.val*label_alpha.val*0.9);
            
            ctx.set_line_width(CoralMenu.LABEL_HEIGHT+10);
            ctx.set_line_join(Cairo.LineJoin.ROUND);
            ctx.set_line_cap(Cairo.LineCap.ROUND);
            ctx.move_to(center.x, center.y);
            
            var corner = Vector.sum(direction_to_coords(this.direction, 40), center);
            
            ctx.line_to(corner.x, corner.y);
            
            if (direction > GLib.Math.PI*0.5 && direction < GLib.Math.PI*1.5) {
                ctx.line_to(corner.x - label_size.x, corner.y);
            } else {
                ctx.line_to(corner.x + label_size.x, corner.y);
            }
            
            ctx.stroke();
        }
    }
    
    private void draw_label(Cairo.Context ctx, InvisibleWindow window, Vector center) {
        
        if (label_alpha.val > 0.05) {
        
            var layout = window.create_pango_layout(label);
            var label_size = new Vector(0, 0);
            layout.get_pixel_size(out label_size.x, out label_size.y);
            
             var corner = Vector.sum(direction_to_coords(this.direction, 40), center);
            
            if (direction > GLib.Math.PI*0.5 && direction < GLib.Math.PI*1.5) {
                ctx.move_to(corner.x - label_size.x, corner.y - 6);
            } else {
                ctx.move_to(corner.x, corner.y - 6);
            }
            
            ctx.set_source_rgba(0,0,0, label_alpha.val*label_alpha.val);
            Pango.cairo_update_layout(ctx, layout);
            Pango.cairo_show_layout(ctx, layout);
            ctx.stroke();
        }
    }
    
    private void draw_small_label(Cairo.Context ctx, InvisibleWindow window, Vector center) {
        
        if (small_label_alpha.val > 0.05) {
        
            string text = "";
            
            for(int i=0; i<GLib.Math.fmin(3, label.length); ++i)
                text += label.get_char(label.index_of_nth_char(i)).to_string();
            
            var layout = window.create_pango_layout(text);
            var label_size = new Vector(0, 0);
            layout.get_pixel_size(out label_size.x, out label_size.y);
            
            ctx.set_source_rgba(BG_R, BG_G, BG_B, small_label_alpha.val*small_label_alpha.val*0.9);
            
            ctx.move_to(center.x - label_size.x*0.5, center.y - label_size.y*0.5);
            
            Pango.cairo_update_layout(ctx, layout);
            Pango.cairo_show_layout(ctx, layout);
            ctx.stroke();
        }
    }
    
    private double get_item_direction(double parent_direction, int index, int parent_child_count, double total_angle, double max_item_angle) {
        double item_angle = get_angle_per_item(parent_child_count, total_angle, max_item_angle);
        
        double direction = parent_direction - 0.5*parent_child_count*item_angle + (index+0.5)*item_angle;
        
        if (direction > 2*GLib.Math.PI)
            direction -= 2*GLib.Math.PI;
            
        if (direction < 0)
            direction += 2*GLib.Math.PI;
        
        return direction;
    }
    
    private double get_angle_per_item(int parent_child_count, double total_angle, double max_item_angle) {
        double item_angle = total_angle/parent_child_count;
               item_angle = item_angle > max_item_angle ? max_item_angle : item_angle;
        return item_angle;
    }
    
    private double get_item_distance(int parent_child_count, double total_angle, double max_item_angle) {
        if (state == State.INVISIBLE)
            return 0;
        
        if (state == State.PREVIEW) 
            return CoralMenu.ITEM_RADIUS;
        
        double item_angle = get_angle_per_item(parent_child_count, total_angle, max_item_angle);
        double distance = CoralMenu.ITEM_RADIUS / GLib.Math.sin(item_angle*0.5);
        
        distance = distance > CoralMenu.MAX_ITEM_DISTANCE ? CoralMenu.MAX_ITEM_DISTANCE : distance;
        
        return distance;
    }
    
    private double get_item_radius(int parent_child_count, double total_angle, double max_item_angle) {
        if (state == State.INVISIBLE)
            return 0;
        
        if (state == State.PREVIEW) {
            double item_angle = get_angle_per_item(parent_child_count, total_angle, max_item_angle);
            double radius = GLib.Math.sin(item_angle*0.5)*CoralMenu.ITEM_RADIUS;
            return radius;
        }
        
        double item_angle = get_angle_per_item(parent_child_count, total_angle, max_item_angle);
        double max_item_radius = GLib.Math.sin(item_angle*0.5)*CoralMenu.MAX_ITEM_DISTANCE;
        
        return CoralMenu.ITEM_RADIUS > max_item_radius? max_item_radius : CoralMenu.ITEM_RADIUS;
    }
    
    private Vector direction_to_coords(double direction, double distance) {
        return new Vector(GLib.Math.cos(direction)*distance, GLib.Math.sin(direction)*distance);
    }
    
    private bool angle_is_between(double angle, double min_angle, double max_angle) {
        if (max_angle > min_angle) {
            return angle < max_angle && angle > min_angle;
        } 
        
        return angle > min_angle || angle < max_angle;
    }

    private bool mouse_is_inside_circle(InvisibleWindow window, Vector center, double radius) {
        var mouse = window.get_mouse_pos(false);
        var diff = Vector.direction(center, mouse);

        return diff.length_sqr() < radius*radius;
    }
    
    private bool mouse_is_inside_cone(InvisibleWindow window, Vector center, double max_angle, double min_angle, double max_distance, double min_distance) {
        var mouse = get_mouse_angle(window, center);
        
        if (!angle_is_between(mouse, fmod(min_angle, GLib.Math.PI*2), fmod(max_angle, GLib.Math.PI*2)))
            return false;
            
        if (Vector.distance(center, window.get_mouse_pos(false)) < min_distance)
            return false;
            
        if (Vector.distance(center, window.get_mouse_pos(false)) > max_distance)
            return false;
            
        return true;
    }
    
    private double get_mouse_angle(InvisibleWindow window, Vector center) {
        var mouse = window.get_mouse_pos(false);
        var diff = Vector.direction(center, mouse);
        double angle = 0;

        if (diff.length_sqr() > 1) {
            
            if (diff.x == 0) {
                angle = diff.y < 0 ? 1.5*GLib.Math.PI : 0.5*GLib.Math.PI;
            } else if (diff.y == 0) {
                angle = diff.x > 0 ? 0 : GLib.Math.PI;
            } else {
                angle = GLib.Math.atan(-diff.y/diff.x);
                
                if (-diff.y > 0 && diff.x > 0)
                    angle = 2*GLib.Math.PI - angle;
                else if (diff.x < 0)
                    angle = GLib.Math.PI - angle;
                else
                    angle = -angle;
            }
            
            if (angle < 0.0) angle += 2.0*GLib.Math.PI;
        }
        
        return angle;
    }
    
    private double fmod(double in_value, double mod) {
        double result = in_value;
        while (result >= mod)
            result -= mod;
            
        while (result < 0.0)
            result += mod;
        
        return result;
    }
    
    private void update_mouse_direction(InvisibleWindow window) {
        if (last_mouse_location == null)
            last_mouse_location = window.get_mouse_pos(false);
        
        Vector mouse_pos = window.get_mouse_pos(false);
        
        if (mouse_pos.x == last_mouse_location.x && mouse_pos.y == last_mouse_location.y) {
            mouse_direction = -1;
        } else {
            mouse_direction = get_mouse_angle(window, last_mouse_location);
            last_mouse_location = mouse_pos;
        }
    }
    
    private void clamp_to_screen(Vector parent_center) {
        
        var screen = Gdk.Screen.get_default();
        
        var min = new Vector(screen.width(),screen.height());
        var max = new Vector(0,0);
        
        get_bounding_box(ref max, ref min, parent_center);
        
        var warp = new Vector(0,0);
        
        if (min.x < CoralMenu.WARP_ZONE)                warp.x = CoralMenu.WARP_ZONE - min.x;
        if (max.x > screen.width()-CoralMenu.WARP_ZONE) warp.x = - CoralMenu.WARP_ZONE - max.x + screen.width();
        
        if (min.y < CoralMenu.WARP_ZONE)                 warp.y = CoralMenu.WARP_ZONE - min.y;
        if (max.y > screen.height()-CoralMenu.WARP_ZONE) warp.y = - CoralMenu.WARP_ZONE - max.y + screen.height();
        
        offset_x.reset_target(offset_x.end + warp.x, CoralMenu.ANIMATION_TIME);
        offset_y.reset_target(offset_y.end + warp.y, CoralMenu.ANIMATION_TIME);
    
        last_mouse_location = null;
        mouse_direction = -1;
    }
    
    private void get_bounding_box(ref Vector max, ref Vector min, Vector parent_center) {
        Vector center = new Vector((int)offset_x.val + parent_center.x, (int)offset_y.val + parent_center.y);
        
        if (center.x < min.x) min.x = center.x;
        if (center.y < min.y) min.y = center.y;
        if (center.x > max.x) max.x = center.x;
        if (center.y > max.y) max.y = center.y;
        
        foreach (var child in children)
            child.get_bounding_box(ref max, ref min, center);
    }
}





