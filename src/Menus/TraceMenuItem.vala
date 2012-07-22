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

public class TraceMenuItem {
    
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
    
    public enum Direction { N, NE, E, SE, S, SW, W, NW }
    public enum LabelDirection { LEFT, RIGHT, TOP_LEFT, BOTTOM_RIGHT }
    public enum State { INVISIBLE, PREVIEW, INSPECT, INSPECT_CHILD, SELECTABLE, 
                        ACTIVE, TRAIL, TRAIL_PREVIEW, SELECTED, AT_MOUSE }
    
    private weak TraceMenuItem parent = null;
    
    private AnimatedValue draw_center_x = null;
    private AnimatedValue draw_center_y = null;
    private AnimatedValue draw_radius = null;
    private AnimatedValue label_alpha = null;
    
    private State state = State.INVISIBLE;
    private Direction direction;
    private double max_angle;
    private double back_max_angle;
    private double min_angle; 
    private double back_min_angle;
    
    private bool is_meta = false;
    
    private bool marking_mode = false;
    private bool closing = false;
    
    private int hovered_child = -1;
    private int active_child = -1;
    private Vector center_offset;
    
    private Vector last_mouse_location;
    
    private Gee.ArrayList<TraceMenuItem> children;
    
    public TraceMenuItem(string label, string icon_name, bool meta) {
        this.label = label;
        this.icon_name = icon_name;
        this.center_offset = new Vector(0,0);
        this.last_mouse_location = new Vector(0,0);
        this.is_meta = meta;
        
        this.children = new Gee.ArrayList<TraceMenuItem>();
        
        this.draw_center_x = new AnimatedValue.cubic(AnimatedValue.Direction.OUT, 1, 1, 0, 0.8);
        this.draw_center_y = new AnimatedValue.cubic(AnimatedValue.Direction.OUT, 1, 1, 0, 0.8);
        this.draw_radius = new AnimatedValue.cubic(AnimatedValue.Direction.OUT, 0, 0, 0, 0.8);
        this.label_alpha = new AnimatedValue.linear(1, 1, 1);
    }
    
    public void set_marking_mode(bool marking) {
        this.marking_mode = marking;
        
        foreach (var child in children)
            child.set_marking_mode(marking);
    }
    
    public void move(Vector offset) {
        this.center_offset.x += offset.x;
        this.center_offset.y += offset.y;
    }
    
    public void move_parents(Vector offset) {
        if (parent != null) parent.move_parents(offset);
        else move(offset);
    }
    
    public void add_child(TraceMenuItem child) {
        this.children.add(child);
        child.parent = this;
    }
    
    public string get_path() {
        if (parent == null) return "";
        
        if (is_meta) {
            if (parent.parent == null) return "";
            return parent.get_path();
        }
        
        if (parent.parent == null) 
            return label;
        
        if (parent.is_meta && parent.parent.parent != null)
            return parent.parent.get_path() + "|" + label;
            
        if (parent.is_meta) 
            return label;
        
        return parent.get_path() + "|" + label;
    
    }
    
    public void close(bool delayed) {
        foreach (var child in children)
            child.close(delayed);
            
        closing = true;
        
        if (delayed) {
            GLib.Timeout.add((uint)(TraceMenu.FADE_OUT_TIME*1000), () => {
                //this.draw_radius.reset_target(0.0, TraceMenu.ANIMATION_TIME);
                this.label_alpha.reset_target(0.0, TraceMenu.ANIMATION_TIME);
                return false;
            });           
        } else {
           // this.draw_radius.reset_target(0.0, TraceMenu.ANIMATION_TIME);
            this.label_alpha.reset_target(0.0, TraceMenu.ANIMATION_TIME);
        }                 
    }
    
    public bool in_marking_mode() {
        return marking_mode;
    }
    
    public bool submenu_is_hovered() {
        if (hovered_child >= 0 && children[hovered_child].children.size > 0)
            return true;
        
        foreach (var child in children)
            if (child.submenu_is_hovered())
                return true;
                
        return false;
    }
    
    public bool child_is_hovered() {
        if (hovered_child >= 0)
            return true;
        
        foreach (var child in children)
            if (child.submenu_is_hovered())
                return true;
                
        return false;
    }
    
    public bool got_selected() {
        if (this.state == State.SELECTED)
            return true;
        
        foreach (var child in children)
            if (child.got_selected())
                return true;
                
        return false;
    }
    
    public string activate(Vector mouse) {
        
        switch (this.state) {            
            case State.AT_MOUSE:   
            case State.SELECTABLE:
            case State.INSPECT:
                
                double distance = GLib.Math.sqrt(mouse.x*mouse.x + mouse.y*mouse.y);
                if (distance < 200) distance = 200;
                var offset = direction_to_coords(this.direction, (int)distance);
                move(offset);
                offset.x = mouse.x - offset.x;
                offset.y = mouse.y - offset.y;
                move_parents(offset);
                
                if (children.size > 0) {
                    set_state(State.ACTIVE);
                    return "_keep_open";
                }
                
                set_state(State.SELECTED);

                return get_path();
                
            case State.ACTIVE:
                if (hovered_child >= 0) {
                    string keep_open = "_keep_open";
                
                    for (int i=0; i<children.size; ++i) {
                        if (i == hovered_child) {
                           keep_open = children[i].activate(new Vector(mouse.x - draw_center_x.end, mouse.y - draw_center_y.end));
                        } else {
                           children[i].set_state(State.TRAIL_PREVIEW);
                        }
                    }
                    set_state(State.TRAIL);
                    active_child = hovered_child;
                    
                    return keep_open;
                } else if (marking_mode) {
                    for (int i=0; i<children.size; ++i) {
                        children[i].set_state(State.SELECTABLE);
                    }
                    return "_keep_open";
                }
                break;
                
            case State.TRAIL:
                if (active_child >= 0) {
                    if (children[active_child].hovered_child == -2) {
                        children[active_child].set_state(State.SELECTABLE);
                        children[active_child].center_offset = new Vector(0,0);
                        active_child = -1;
                        set_state(State.ACTIVE);
                        
                        move_parents(new Vector(-draw_center_x.end + mouse.x, -draw_center_y.end + mouse.y));
                        
                        return "_keep_open";
                    } 
                    
                    return children[active_child].activate(new Vector(mouse.x - draw_center_x.end, mouse.y - draw_center_y.end));
                }
                break;
        }

        return "_cancel";
    }
    
    public void set_state(State new_state) {
        this.state = new_state;
    
        switch (new_state) {
            case State.TRAIL_PREVIEW:
            case State.PREVIEW:
                for (int i=0; i<children.size; ++i)
                    children[i].set_state(State.INVISIBLE);
                break;
                
            case State.SELECTABLE:
            case State.INSPECT_CHILD:
            case State.AT_MOUSE:
                for (int i=0; i<children.size; ++i)
                    children[i].set_state(State.PREVIEW);
                break;
                
            case State.ACTIVE:
                for (int i=0; i<children.size; ++i)
                    children[i].set_state(State.SELECTABLE);
                break;
                
            case State.INSPECT:
                for (int i=0; i<children.size; ++i)
                    children[i].set_state(State.INSPECT_CHILD);
                break;
        }
    }
    
    public void draw(Cairo.Context ctx, InvisibleWindow window, Vector parent_center,
                     bool prelight, double frame_time) {
                     
        this.draw_center_x.update(frame_time);   
        this.draw_center_y.update(frame_time);
        this.draw_radius.update(frame_time);
        this.label_alpha.update(frame_time);
        
        Vector center = new Vector((int)draw_center_x.val + parent_center.x, (int)draw_center_y.val + parent_center.y);
        
        hovered_child = -1;
        
         switch (state) {
            case State.PREVIEW: case State.TRAIL_PREVIEW:
            
                // draw label
                draw_label(ctx, window, center, direction, prelight);
                
                if (prelight) ctx.set_source_rgb(SEL_R, SEL_G, SEL_B);
                else          ctx.set_source_rgb(FG_R, FG_G, FG_B);
                
                ctx.arc(center.x, center.y, draw_radius.val, 0, GLib.Math.PI*2);
                ctx.fill();
                break;
                
            case State.AT_MOUSE:
            
                update_position(Vector.direction(parent_center, window.get_mouse_pos(false)), 0);
                label_alpha.reset_target(1.0, 0);
                
                
                if (parent.hovered_child >= 0) {
                    // draw label
                    draw_label(ctx, window, center, direction, true);
                    
                    // draw circle
                    ctx.set_source_rgb(SEL_R, SEL_G, SEL_B);
                    
                    ctx.arc(center.x, center.y, draw_radius.val, 0, GLib.Math.PI*2);
                    ctx.fill();
                
                
                    // draw child circles
                    for (int i=0; i<children.size; ++i) {
                        children[i].draw(ctx, window, center, prelight, frame_time);
                    }
                }
                break;
        
            case State.INSPECT:
            case State.SELECTABLE:
            
                // draw label
                if (!marking_mode) {
                    if (is_meta)  draw_meta_label(ctx, window, center, direction, prelight);
                    else          draw_label(ctx, window, center, direction, prelight);
                }
                
                // draw circle
                if (prelight) ctx.set_source_rgb(SEL_R, SEL_G, SEL_B);
                else          ctx.set_source_rgb(FG_R, FG_G, FG_B);
                
                if (parent != null && is_meta) {
                    ctx.move_to(parent_center.x, parent_center.y);
                    ctx.set_line_width(draw_radius.val);
                    ctx.line_to(center.x, center.y);
                    ctx.stroke();
                }

                ctx.arc(center.x, center.y, draw_radius.val, 0, GLib.Math.PI*2);
                ctx.fill();
                
                // draw child circles
                if (!marking_mode) {
                    for (int i=0; i<children.size; ++i) {
                        if (state == State.INSPECT) {
                           // children[i].center_offset = Vector.direction(center, mouse);
                            children[i].draw(ctx, window, center, prelight, frame_time);
                        } else {
                            children[i].draw(ctx, window, center, prelight, frame_time);
                        }
                    }
                }
                break;
            
            case State.INSPECT_CHILD:
            case State.SELECTED:
                
                // draw label
                draw_label(ctx, window, center, direction, prelight);
                
                // draw circle
                if (prelight) ctx.set_source_rgb(SEL_R, SEL_G, SEL_B);
                else          ctx.set_source_rgb(FG_R, FG_G, FG_B);
                
                ctx.arc(center.x, center.y, draw_radius.val, 0, GLib.Math.PI*2);
                ctx.fill();
                
                // draw child circles
                if (!marking_mode) {
                    for (int i=0; i<children.size; ++i) {
                        children[i].draw(ctx, window, center, prelight, frame_time);
                    }
                }
                break;
                
            case State.ACTIVE:
            
                // get hovered / active child
                var active = a_slice_is_active(window, center);
                var mouse_angle = get_mouse_angle(window, center);
                
                // draw sector of active item
                for (int i=0; i<children.size; ++i) {
                    if (active && angle_is_between(mouse_angle, children[i].min_angle, children[i].max_angle)) {
                        hovered_child = i;
                        
                        if (!marking_mode) 
                            draw_sector(ctx, center, children[i].min_angle, children[i].max_angle, true, children[i].label_alpha.val, frame_time);
                            
                    } else if (!marking_mode) {
                        draw_sector(ctx, center, children[i].min_angle, children[i].max_angle, false, children[i].label_alpha.val, frame_time);
                    }
                }
                
                if (hovered_child == -1 && active && angle_is_between(mouse_angle, back_min_angle, back_max_angle)) {
                    hovered_child = -2;
                }
                
                if (marking_mode && hovered_child >= 0 && children[hovered_child].state != State.AT_MOUSE) {
                    for (int i=0; i<children.size; ++i) {
                        if (hovered_child == i) children[i].set_state(State.AT_MOUSE);
                        else {
                            children[i].set_state(State.SELECTABLE);
                            
                            var child_center = direction_to_coords(children[i].direction, TraceMenu.TRAIL_PREVIEW_PIE_RADIUS);
                            children[i].update_position(child_center, 0);
                        }
                    }
                }
            
                if (marking_mode) {
                    if (hovered_child == -1)
                        prelight = true;
                } 
                
                // draw child circles
                for (int i=0; i<children.size; ++i) {
                    children[i].draw(ctx, window, center, (active && i == hovered_child) || (prelight && marking_mode), frame_time);
                }
                
                
                if (marking_mode) {
                    ctx.set_source_rgb(FG_R, FG_G, FG_B);
                    ctx.set_line_cap(Cairo.LineCap.ROUND);
                    ctx.move_to(center.x, center.y);
                    
                    ctx.set_line_width(draw_radius.val);
                    ctx.line_to(window.get_mouse_pos(false).x, window.get_mouse_pos(false).y);
                    ctx.stroke();
                    
                    if (!is_meta)
                        draw_label(ctx, window, center, direction, prelight);
                    
                    if (prelight || got_selected()) ctx.set_source_rgb(SEL_R, SEL_G, SEL_B);
                    else                            ctx.set_source_rgb(FG_R, FG_G, FG_B);
                    
                    ctx.arc(center.x, center.y, draw_radius.val, 0, GLib.Math.PI*2);
                    ctx.fill();  
                    
                } else if (is_meta) {
                    
                    ctx.set_source_rgb(FG_R, FG_G, FG_B);
                    ctx.arc(center.x, center.y, draw_radius.val, 0, GLib.Math.PI*2);
                    ctx.fill();
                    
                } else {
                    
                    ctx.set_source_rgb(FG_R, FG_G, FG_B);
                    ctx.arc(center.x, center.y, draw_radius.val, 0, GLib.Math.PI*2);
                    ctx.fill();

                    // draw label
                    var img = new RenderedText(label, (int)(TraceMenu.ACTIVE_ITEM_RADIUS*0.8)*2, (int)(TraceMenu.ACTIVE_ITEM_RADIUS*0.8)*2, "ubuntu 10", new Color.from_rgb(1, 1, 1), 1);
                    ctx.translate(center.x, center.y);
                    img.paint_on(ctx, GLib.Math.fmax(0, 2*label_alpha.val-1));
                    ctx.translate(-center.x, -center.y);
                }
                break;
                
            case State.TRAIL:
            
                // draw highlight if immediate child hovers
                if (!marking_mode && children[active_child].active_child < 0) {
                    var child_pos = new Vector((int)children[active_child].draw_center_x.val, (int)children[active_child].draw_center_y.val);
                        child_pos.x += center.x;
                        child_pos.y += center.y;
                    draw_sector(ctx, child_pos, children[active_child].back_min_angle, children[active_child].back_max_angle, children[active_child].hovered_child == -2, children[active_child].label_alpha.val, frame_time);
                }
                if (children[active_child].hovered_child == -2)
                    prelight = true;

                var active_child_dir = index_to_direction(active_child, children.size, (direction+4)%8);
                
                // draw center circle
                if ((marking_mode && !is_meta) || (!is_meta && !(children[active_child].is_meta && children[active_child].active_child < 0))) {
                    if (marking_mode) draw_label(ctx, window, center, direction, prelight);
                    else              draw_label(ctx, window, center, (active_child_dir+4)%8, prelight);
                }
                
                // draw line to child circle
                if (prelight) ctx.set_source_rgb(SEL_R, SEL_G, SEL_B);
                else          ctx.set_source_rgb(FG_R, FG_G, FG_B);

                var offset = direction_to_coords(active_child_dir, TraceMenu.TRAIL_PREVIEW_PIE_RADIUS);
                    offset.x += center.x;
                    offset.y += center.y;
                ctx.set_line_cap(Cairo.LineCap.ROUND);
                ctx.move_to(offset.x, offset.y);
                
                ctx.set_line_width(children[active_child].is_meta ? TraceMenu.SELECTABLE_ITEM_RADIUS_SMALL : draw_radius.val);
                ctx.line_to((int)children[active_child].draw_center_x.val + center.x, (int)children[active_child].draw_center_y.val + center.y);
                ctx.stroke();
                
                if (prelight) ctx.set_source_rgb(SEL_R, SEL_G, SEL_B);
                else          ctx.set_source_rgb(FG_R, FG_G, FG_B);
                
                ctx.arc(center.x, center.y, draw_radius.val, 0, GLib.Math.PI*2);
                ctx.fill();  
                
                if (!marking_mode && children[active_child].is_meta && children[active_child].active_child < 0) {
                    // draw label
                    var img = new RenderedText(label, (int)(TraceMenu.ACTIVE_ITEM_RADIUS*0.8)*2, (int)(TraceMenu.ACTIVE_ITEM_RADIUS*0.8)*2, "ubuntu 10", new Color.from_rgb(1, 1, 1), 1);
                    ctx.translate(center.x, center.y);
                    img.paint_on(ctx, GLib.Math.fmax(0, 2*label_alpha.val-1));
                    ctx.translate(-center.x, -center.y);
                }
                
                // draw child circles
                for (int i=0; i<children.size; ++i) {
                    children[i].draw(ctx, window, center, prelight && (i != active_child || !marking_mode), frame_time);
                }
                
                break;
        }
    }
    
    public void realize() {
        update_direction(TraceMenuItem.Direction.S);
    }
    
    private void update_direction(Direction dir) {
        this.direction = dir;
        
        for (int i=0; i<children.size; ++i) {
            var child_dir = index_to_direction(i, children.size, (dir+4)%8);
            children[i].update_direction(child_dir);
            children[i].set_min_max_angle(i, children.size, (dir+4)%8);
        }
    }
    
    public void update_position(Vector offset, double time) {
        
        var center = new Vector(offset.x + center_offset.x, offset.y + center_offset.y);
        draw_center_x.reset_target(center.x, time);
        draw_center_y.reset_target(center.y, time);
        
        switch (state) {
         
            case State.INVISIBLE:
                draw_radius.reset_target(0.0, time);
                label_alpha.reset_target(0.0, time);
                break;
                
            case State.TRAIL_PREVIEW:
                draw_radius.reset_target(TraceMenu.TRAIL_PREVIEW_ITEM_RADIUS, time);
                label_alpha.reset_target(0.0, time);
                
                for (int i=0; i<children.size; ++i) {
                    children[i].update_position(new Vector(0,0), time);
                }
                break;
         
            case State.PREVIEW:
                draw_radius.reset_target(TraceMenu.PREVIEW_ITEM_RADIUS, time);
                label_alpha.reset_target(0.0, time);
                
                for (int i=0; i<children.size; ++i) {
                    children[i].update_position(new Vector(0,0), time);
                }
                break;
                
            case State.AT_MOUSE:
                if (children.size > 0) {
                    draw_radius.reset_target(TraceMenu.SELECTABLE_ITEM_RADIUS_SMALL, time);
                    label_alpha.reset_target(1.0, time);
                    
                    for (int i=0; i<children.size; ++i) {
                        var child_center = direction_to_coords(children[i].direction, TraceMenu.PREVIEW_PIE_RADIUS);
                        children[i].update_position(child_center, time);
                    }
                    
                } else {
                    draw_radius.reset_target(TraceMenu.SELECTABLE_ITEM_RADIUS, time);
                    label_alpha.reset_target(1.0, time);
                }
                break;
            
            case State.SELECTABLE: 
                if (children.size > 0) {
                    draw_radius.reset_target(marking_mode ? TraceMenu.PREVIEW_ITEM_RADIUS : TraceMenu.SELECTABLE_ITEM_RADIUS_SMALL, time);
                    label_alpha.reset_target(marking_mode ? 0.0 : 1.0, time);
                    
                    for (int i=0; i<children.size; ++i) {
                        var child_center = direction_to_coords(children[i].direction, TraceMenu.PREVIEW_PIE_RADIUS);
                        children[i].update_position(child_center, time);
                    }
                    
                } else {
                    draw_radius.reset_target(marking_mode ? TraceMenu.PREVIEW_ITEM_RADIUS : TraceMenu.SELECTABLE_ITEM_RADIUS, time);
                    label_alpha.reset_target(marking_mode ? 0.0 : 1.0, time);
                }
                break;
            
            case State.INSPECT_CHILD:    
            case State.SELECTED:
                if (children.size > 0) {
                    draw_radius.reset_target(marking_mode ? TraceMenu.PREVIEW_ITEM_RADIUS : TraceMenu.SELECTABLE_ITEM_RADIUS_SMALL, time);
                    label_alpha.reset_target(marking_mode ? 0.0 : 1.0, time);
                    
                    for (int i=0; i<children.size; ++i) {
                        var child_center = direction_to_coords(children[i].direction, TraceMenu.PREVIEW_PIE_RADIUS);
                        children[i].update_position(child_center, time);
                    }
                    
                } else {
                    draw_radius.reset_target(TraceMenu.SELECTABLE_ITEM_RADIUS, time);
                    label_alpha.reset_target(1.0, time);
                }
                break;
                
            case State.ACTIVE:
                draw_radius.reset_target(marking_mode ? TraceMenu.TRAIL_ITEM_RADIUS : TraceMenu.ACTIVE_ITEM_RADIUS, time);
                label_alpha.reset_target(1.0, time);
                
                for (int i=0; i<children.size; ++i) {
                    int distance = TraceMenu.SELECTABLE_PIE_RADIUS;
                    
                    if (marking_mode) distance = TraceMenu.TRAIL_PREVIEW_PIE_RADIUS;
                    else if (children[i].is_meta)  distance = 150;
                    
                    var child_center = direction_to_coords(children[i].direction, distance);
                    children[i].update_position(child_center, time);
                }
                break;
                
            case State.TRAIL:
                
                bool is_meta_parent = children[active_child].is_meta && children[active_child].active_child < 0 && !marking_mode;
            
                if (is_meta_parent) draw_radius.reset_target(TraceMenu.ACTIVE_ITEM_RADIUS, time);
                else                draw_radius.reset_target(TraceMenu.TRAIL_ITEM_RADIUS, time);
                label_alpha.reset_target(1.0, time);
                
                for (int i=0; i<children.size; ++i) {
                    if (i != active_child) {
                        var child_center = direction_to_coords(children[i].direction, is_meta_parent ? TraceMenu.ACTIVE_ITEM_RADIUS + TraceMenu.PREVIEW_ITEM_RADIUS : TraceMenu.TRAIL_PREVIEW_PIE_RADIUS);
                        children[i].update_position(child_center, time);
                    } else {
                        children[i].update_position(new Vector(0,0), time);
                    }
                }
                break;
        }
    }
    
    private void draw_label(Cairo.Context ctx, InvisibleWindow window, Vector center, Direction dir, bool prelight) {
        
        if (label_alpha.val > 0) {
        
            var layout = window.create_pango_layout(label);
            var label_size = new Vector(0, 0);
            layout.get_pixel_size(out label_size.x, out label_size.y);

            // draw label background
            ctx.set_source_rgba(BG_R, BG_G, BG_B, label_alpha.val);
            ctx.set_line_width(TraceMenu.LABEL_HEIGHT*label_alpha.val);
            ctx.set_line_join(Cairo.LineJoin.ROUND);
            ctx.set_line_cap(Cairo.LineCap.ROUND);
            ctx.move_to(center.x, center.y);
            
            var label_pos = new Vector(center.x, center.y-7);
            
            switch (dir) {
                case Direction.W:
                    label_size.x += TraceMenu.LABEL_HEIGHT*0.7;
                    ctx.line_to(center.x-(label_size.x)*label_alpha.val , center.y);
                    label_pos.x -= label_size.x ;
                    break;
                case Direction.SW:
                case Direction.NW:
                    label_size.x += TraceMenu.LABEL_HEIGHT*0.7;
                    label_size.x += TraceMenu.SELECTABLE_PIE_RADIUS*0.293;
                    ctx.line_to(center.x-(label_size.x)*label_alpha.val , center.y);
                    label_pos.x -= label_size.x ;
                    
                    break;
                case Direction.E:
                    label_size.x += TraceMenu.LABEL_HEIGHT*0.7;
                    ctx.line_to(center.x+(label_size.x)*label_alpha.val, center.y);
                    label_pos.x += TraceMenu.LABEL_HEIGHT*0.7;
                    break;
                case Direction.SE:
                case Direction.NE:
                    label_size.x += TraceMenu.LABEL_HEIGHT*0.7;
                    label_size.x += TraceMenu.SELECTABLE_PIE_RADIUS*0.293;
                    ctx.line_to(center.x+(label_size.x)*label_alpha.val, center.y);
                    label_pos.x += TraceMenu.SELECTABLE_PIE_RADIUS*0.293;
                    label_pos.x += TraceMenu.LABEL_HEIGHT*0.7;
                    break;
                case Direction.N:
                    ctx.line_to(center.x, center.y - (TraceMenu.LABEL_HEIGHT/2 + 10)*label_alpha.val);
                    ctx.line_to(center.x-(label_size.x/2)*label_alpha.val, center.y - (TraceMenu.LABEL_HEIGHT/2 + 10)*label_alpha.val);
                    ctx.line_to(center.x+(label_size.x/2)*label_alpha.val, center.y - (TraceMenu.LABEL_HEIGHT/2 + 10)*label_alpha.val);
                    label_pos.x -= label_size.x/2;
                    label_pos.y -= TraceMenu.LABEL_HEIGHT/2 + 13;
                    break;
                case Direction.S:
                    ctx.line_to(center.x, center.y + (TraceMenu.LABEL_HEIGHT/2 + 10)*label_alpha.val);
                    ctx.line_to(center.x+(label_size.x/2)*label_alpha.val, center.y + (TraceMenu.LABEL_HEIGHT/2 + 10)*label_alpha.val);
                    ctx.line_to(center.x-(label_size.x/2)*label_alpha.val, center.y + (TraceMenu.LABEL_HEIGHT/2 + 10)*label_alpha.val);
                    label_pos.y += TraceMenu.LABEL_HEIGHT/2 + 13;
                    label_pos.x -= label_size.x/2;
                    break;
            }
            
            ctx.stroke();

            // draw label
            if (prelight) ctx.set_source_rgba(SEL_R, SEL_G, SEL_B, label_alpha.val);
            else ctx.set_source_rgba(0.0, 0.0, 0.0, GLib.Math.fmax(0, 2*label_alpha.val-1));

            ctx.move_to(label_pos.x, label_pos.y);
            Pango.cairo_update_layout(ctx, layout);
            Pango.cairo_show_layout(ctx, layout);
            ctx.stroke();
        }
    }
    
    private void draw_meta_label(Cairo.Context ctx, InvisibleWindow window, Vector center, Direction dir, bool prelight) {
        
        if (label_alpha.val > 0) {
        
            var layout = window.create_pango_layout(label);
            var label_size = new Vector(0, 0);
            layout.get_pixel_size(out label_size.x, out label_size.y);

            // draw label background
            ctx.set_source_rgba(BG_R, BG_G, BG_B, label_alpha.val);
            
            
            var label_pos = new Vector(center.x, center.y);
            
            double inc = TraceMenu.LABEL_HEIGHT*0.7;
            
            switch (dir) {
                case Direction.W:
                    label_size.x += inc;
                    label_pos.x -= label_size.x;
                    label_pos.y -= label_size.y/2-7;
                    draw_rounded_rectangle(ctx, label_pos.x - 5, label_pos.y - 5, label_size.x + inc + 10, label_size.y +10, 10);
                    break;
                case Direction.SW:
                    label_size.x += inc;
                    label_pos.x -= label_size.x ;
                    label_pos.y -= label_size.y/4;
                    draw_rounded_rectangle(ctx, label_pos.x - 5, label_pos.y - 5, label_size.x + inc + 10, label_size.y +10, 10);
                    break;
                case Direction.NW:
                    label_size.x += inc;
                    label_pos.x -= label_size.x ;
                    label_pos.y -= label_size.y-TraceMenu.LABEL_HEIGHT;
                    draw_rounded_rectangle(ctx, label_pos.x - 5, label_pos.y - 5, label_size.x + inc + 10, label_size.y +10, 10);
                    break;
                case Direction.E:
                    label_size.x += inc;
                    label_pos.x += inc;
                    label_pos.y -= label_size.y/2;
                    draw_rounded_rectangle(ctx, label_pos.x - 2*inc, label_pos.y - 5, label_size.x + inc + 10, label_size.y +10, 10);
                    break;
                case Direction.SE:
                    label_size.x += inc;
                    label_pos.x += inc;
                    label_pos.y -= label_size.y/4-7;
                    draw_rounded_rectangle(ctx, label_pos.x - 2*inc, label_pos.y - 5, label_size.x + inc + 10, label_size.y +10, 10);
                    break;
                case Direction.NE:
                    label_size.x += inc;
                    label_pos.x += inc;
                    label_pos.y -= label_size.y-TraceMenu.LABEL_HEIGHT;
                    draw_rounded_rectangle(ctx, label_pos.x - 2*inc, label_pos.y - 5, label_size.x + inc + 10, label_size.y +10, 10);
                    break;
                case Direction.N:
                    label_pos.x -= label_size.x/2;
                    label_pos.y -= label_size.y+TraceMenu.LABEL_HEIGHT/2;
                    draw_rounded_rectangle(ctx, label_pos.x - 5, label_pos.y - 5, label_size.x + 10, label_size.y +inc+10, 10);
                    break;
                case Direction.S:
                    label_pos.y += TraceMenu.LABEL_HEIGHT/2;
                    label_pos.x -= label_size.x/2;
                    draw_rounded_rectangle(ctx, label_pos.x - 5, label_pos.y - 5 - inc, label_size.x + 10, label_size.y +inc+10, 10);
                    break;
            }

            // draw label
            if (prelight) ctx.set_source_rgba(SEL_R, SEL_G, SEL_B, label_alpha.val);
            else ctx.set_source_rgba(0.0, 0.0, 0.0, GLib.Math.fmax(0, 2*label_alpha.val-1));

            ctx.move_to(label_pos.x, label_pos.y);
            Pango.cairo_update_layout(ctx, layout);
            Pango.cairo_show_layout(ctx, layout);
            ctx.stroke();
        }
    }

    public void draw_sector(Cairo.Context ctx, Vector center, double min_angle, double max_angle, bool prelight, double alpha, double frame_time) {
        
        if (!closing && alpha > 0) {
            
            var gradient = new Cairo.Pattern.radial(center.x, center.y, TraceMenu.ACTIVE_ITEM_RADIUS, center.x, center.y, TraceMenu.SLICE_HINT_RADIUS);
            
            if (prelight) {
                gradient.add_color_stop_rgba(0.0, SEL_R, SEL_G, SEL_B, 0.8*alpha);
                gradient.add_color_stop_rgba(1.0, SEL_R, SEL_G, SEL_B, 0.0*alpha);
            } else {
                gradient.add_color_stop_rgba(0.0, FG_R, FG_G, FG_B, 0.3*alpha);
                gradient.add_color_stop_rgba(1.0, FG_R, FG_G, FG_B, 0.0*alpha);
            }
            ctx.set_source(gradient);
        
            ctx.arc_negative(center.x, center.y, TraceMenu.ACTIVE_ITEM_RADIUS, max_angle-0.02, min_angle+0.02);
            ctx.arc(center.x, center.y, TraceMenu.SLICE_HINT_RADIUS, min_angle+0.02, max_angle-0.02);
            ctx.close_path();
            ctx.fill();
        }
    }
    
    private void draw_rounded_rectangle(Cairo.Context ctx, double x, double y, double width, double height, double radius) {
        double degrees = GLib.Math.PI / 180.0;

        ctx.new_sub_path();
        ctx.arc (x + width - radius, y + radius, radius, -90 * degrees, 0 * degrees);
        ctx.arc (x + width - radius, y + height - radius, radius, 0 * degrees, 90 * degrees);
        ctx.arc (x + radius, y + height - radius, radius, 90 * degrees, 180 * degrees);
        ctx.arc (x + radius, y + radius, radius, 180 * degrees, 270 * degrees);
        ctx.close_path();

        ctx.set_source_rgb(BG_R, BG_G, BG_B);
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
    
    private bool angle_is_between(double angle, double min_angle, double max_angle) {
        if (max_angle > min_angle) {
            return angle < max_angle && angle > min_angle;
        } 
        
        return angle > min_angle || angle < max_angle;
    }
    
    private void set_min_max_angle(int index, int item_count, Direction parent_direction) {
        double[] item_angles = {};
        
        for (int i=0; i<item_count; ++i) {
            item_angles += direction_to_angle(index_to_direction(i, item_count, parent_direction));
        }
        
        double parent_angle = direction_to_angle(parent_direction);
        bool doubled = false;
        for (int i=0; i<item_angles.length; ++i) {
            if (item_angles[i] == parent_angle)
                doubled = true;
        }
        if (!doubled) {
            item_angles += parent_angle;
        }
        
        //sort
        bool swapped = true;
        int j = 0;

        while (swapped) {
            swapped = false;
            j++;
            for (int i=0; i<item_angles.length-j; ++i) {
                if (item_angles[i] > item_angles[i+1]) {
                    double tmp = item_angles[i];
                    item_angles[i] = item_angles[i+1];
                    item_angles[i+1] = tmp;
                    swapped = true;
                }
            }
        }
        
        // find angles around index
        var index_angle = direction_to_angle(index_to_direction(index, item_count, parent_direction));
        
        for (int i=0; i<item_angles.length; ++i) {
            if (item_angles[i] == index_angle) {
                max_angle = item_angles[(i+1)%item_angles.length];
                min_angle = item_angles[(i-1+item_angles.length)%item_angles.length];
                break;
            }
        }
        
        if (max_angle < index_angle) max_angle += 2*GLib.Math.PI;
        if (min_angle > index_angle) min_angle += 2*GLib.Math.PI;
        
        max_angle = (max_angle + index_angle)*0.5;
        min_angle = (min_angle + index_angle)*0.5;
        
        if (max_angle > 2*GLib.Math.PI) max_angle -= 2*GLib.Math.PI;
        if (min_angle > 2*GLib.Math.PI) min_angle -= 2*GLib.Math.PI;
        
        if (parent != null) {
            // find angles around parent
            for (int i=0; i<item_angles.length; ++i) {
                if (item_angles[i] == parent_angle) {
                    parent.back_max_angle = item_angles[(i+1)%item_angles.length];
                    parent.back_min_angle = item_angles[(i-1+item_angles.length)%item_angles.length];
                    break;
                }
            }
            
            if (parent.back_max_angle < parent_angle) parent.back_max_angle += 2*GLib.Math.PI;
            if (parent.back_min_angle > parent_angle) parent.back_min_angle += 2*GLib.Math.PI;
            
            parent.back_max_angle = (parent.back_max_angle + parent_angle)*0.5;
            parent.back_min_angle = (parent.back_min_angle + parent_angle)*0.5;
            
            if (parent.back_max_angle > 2*GLib.Math.PI) parent.back_max_angle -= 2*GLib.Math.PI;
            if (parent.back_min_angle > 2*GLib.Math.PI) parent.back_min_angle -= 2*GLib.Math.PI;
        }
    }
    
    private Gee.ArrayList<Direction> get_possible_directions(int item_count, Direction parent_direction) {
        var e = new Gee.ArrayList<Direction>();
        
        switch (item_count) {
            case 1: 
                e.add((parent_direction + 2)%8);
                break;
            case 2: 
                e.add((parent_direction + 2)%8);
                e.add((parent_direction - 2)%8);
                break;
            case 3: 
                e.add((parent_direction + 3)%8);
                e.add((parent_direction - 2)%8);
                e.add((parent_direction + 1)%8);
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
                e.add((parent_direction + 2)%8);
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
    
    private bool a_slice_is_active(InvisibleWindow window, Vector center) {
        return Vector.direction(window.get_mouse_pos(false), center).length_sqr() > TraceMenu.ACTIVE_ITEM_RADIUS*TraceMenu.ACTIVE_ITEM_RADIUS; 
    }
    
    private double get_mouse_angle(InvisibleWindow window, Vector center) {
        var mouse = window.get_mouse_pos(false);
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
    
    private double direction_to_angle(Direction in_direction) {
        switch (in_direction) {
            case Direction.N:   return GLib.Math.PI*1.5;
            case Direction.E:   return GLib.Math.PI*0.0;
            case Direction.S:   return GLib.Math.PI*0.5;
            case Direction.W:   return GLib.Math.PI*1.0;
            case Direction.NE:  return GLib.Math.PI*1.75;
            case Direction.NW:  return GLib.Math.PI*1.25;
            case Direction.SE:  return GLib.Math.PI*0.25;
            case Direction.SW:  return GLib.Math.PI*0.75;
        }
        
        //stub!
        return 0.0;
    }
    
}
