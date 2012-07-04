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

            double total_angle = parent.parent == null ? 2*GLib.Math.PI : CoralMenu.CHILDREN_ANGLE;
            double max_item_angle = parent.parent == null ? 2*GLib.Math.PI : CoralMenu.MAX_ITEM_ANGLE;
            
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
        return parent.get_path() + " | " + label;
    }
    
    public void close(bool delayed) {
        foreach (var child in children)
            child.close(delayed);
//        
//        if (delayed) {
//            GLib.Timeout.add((uint)(CoralMenu.FADE_OUT_TIME*1000), () => {
//                this.label_alpha.reset_target(0.0, CoralMenu.ANIMATION_TIME);
//                return false;
//            });           
//        } else {
//            this.label_alpha.reset_target(0.0, CoralMenu.ANIMATION_TIME);
//        }                 
    }
    
    public string activate(Vector mouse) {
        
       switch (state) {
           
        }

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
                foreach (var child in children)
                    child.set_state(State.ACTIVE);
                if (parent != null)
                    foreach (var sibling in parent.children)
                        if (sibling != this)
                            sibling.set_state(State.INACTIVE);
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
        this.offset_x.update(frame_time);   
        this.offset_y.update(frame_time);
        this.draw_radius.update(frame_time);
        this.label_alpha.update(frame_time);
        this.small_label_alpha.update(frame_time);
        
        Vector center = new Vector((int)offset_x.end + parent_center.x, (int)offset_y.end + parent_center.y);
        
        if (parent != null && (state == State.ACTIVE || state == State.INACTIVE || state == State.EXPANDED)) {
            double total_angle = parent.parent == null ? 2*GLib.Math.PI : CoralMenu.CHILDREN_ANGLE;
            double max_item_angle = parent.parent == null ? 2*GLib.Math.PI : CoralMenu.MAX_ITEM_ANGLE;
            double item_angle = get_angle_per_item(parent.children.size, total_angle, max_item_angle);
            double max_angle = direction + item_angle*0.5*0.8;
            double min_angle = direction - item_angle*0.5*0.8;
            double max_distance = Vector.distance(center, parent_center) + CoralMenu.ITEM_RADIUS;
            double bottom_radius = GLib.Math.tan(get_angle_per_item(parent.children.size, total_angle, max_item_angle)*0.5) * CoralMenu.INNER_ITEM_RADIUS;
            double min_distance = CoralMenu.INNER_ITEM_RADIUS - bottom_radius;
            
            this.hovered = mouse_is_inside_cone(window, parent_center, max_angle, min_angle, max_distance, min_distance);
        }
        
        if (this.hovered && state != State.EXPANDED) {
            set_state(State.EXPANDED);
            
            if (parent != null) {
                for (int i=0; i<parent.children.size; ++i)
                    parent.children[i].update_offset(i, parent.children.size);
            } else {
                update_offset(0, 0);
            }
        } else if(!this.hovered && state == State.EXPANDED) {
            
            double parent_distance = Vector.direction(parent_center, center).length();
            if (mouse_is_inside_circle(window, parent_center, parent_distance)) {
            
                
            
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
        
        foreach (var child in children) {
            child.update(window, center, frame_time);
        }
    }
    
    public void draw_bg(Cairo.Context ctx, InvisibleWindow window, Vector parent_center) {
        Vector center = new Vector((int)offset_x.val + parent_center.x, (int)offset_y.val + parent_center.y);
        
        if (parent != null && state != State.INVISIBLE) {
            draw_label(ctx, window, center);
        }
        
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
            
                double total_angle = parent.parent == null ? 2*GLib.Math.PI : CoralMenu.CHILDREN_ANGLE;
                double max_item_angle = parent.parent == null ? 2*GLib.Math.PI : CoralMenu.MAX_ITEM_ANGLE;

            
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
            
            this.offset_x.reset_target(0, CoralMenu.ANIMATION_TIME);
            this.offset_y.reset_target(0, CoralMenu.ANIMATION_TIME);
            this.draw_radius.reset_target(30, CoralMenu.ANIMATION_TIME);
            this.label_alpha.reset_target(0, CoralMenu.ANIMATION_TIME);
            this.small_label_alpha.reset_target(0, CoralMenu.ANIMATION_TIME);
            
        } else {
        
            double new_label_alpha = 0;
            double new_small_label_alpha = 0;
            double total_angle = parent.parent == null ? 2*GLib.Math.PI : CoralMenu.CHILDREN_ANGLE;
            double max_item_angle = parent.parent == null ? 2*GLib.Math.PI : CoralMenu.MAX_ITEM_ANGLE;
            double new_radius = get_item_radius(parent_child_count, total_angle, max_item_angle);
            
            if (state == State.ACTIVE) {
                new_label_alpha = 1.0;
            }
            
            if (state == State.INACTIVE) {
                new_small_label_alpha = 1.0;
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
    
    private void draw_label(Cairo.Context ctx, InvisibleWindow window, Vector center) {
        
        if (label_alpha.val > 0.05) {
        
            var layout = window.create_pango_layout(label);
            var label_size = new Vector(0, 0);
            layout.get_pixel_size(out label_size.x, out label_size.y);
            
            ctx.set_source_rgba(BG_R, BG_G, BG_B, label_alpha.val*label_alpha.val*0.9);
            ctx.set_line_width(CoralMenu.LABEL_HEIGHT);
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
        
            string text = label;
            
            if (label.length > 1) text = label[0:2] + "...";
            
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
    
    private double get_preview_radius(int parent_child_count, double total_angle, double max_item_angle) {
        double item_angle = get_angle_per_item(parent_child_count, total_angle, max_item_angle);
               
        double radius = GLib.Math.sin(item_angle*0.5)*CoralMenu.ITEM_RADIUS;
        
        return radius;
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
        var mouse = window.get_mouse_pos();
        var diff = Vector.direction(center, mouse);

        return diff.length_sqr() < radius*radius;
    }
    
    private bool mouse_is_inside_cone(InvisibleWindow window, Vector center, double max_angle, double min_angle, double max_distance, double min_distance) {
        var mouse = get_mouse_angle(window, center);
        
        if (!angle_is_between(mouse, min_angle, max_angle))
            return false;
            
        if (Vector.distance(center, window.get_mouse_pos()) < min_distance)
            return false;
            
        if (Vector.distance(center, window.get_mouse_pos()) > max_distance)
            return false;
            
        return true;
    }
    
    private double get_mouse_angle(InvisibleWindow window, Vector center) {
        var mouse = window.get_mouse_pos();
        var diff = Vector.direction(center, mouse);
        double angle = 0;

        if (diff.length_sqr() > TraceMenu.ACTIVE_ITEM_RADIUS*TraceMenu.ACTIVE_ITEM_RADIUS) {
            
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
    
}
