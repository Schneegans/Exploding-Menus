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
    public enum State { INVISIBLE, PREVIEW, SELECTABLE, ACTIVE, TRAIL, TRAIL_PREVIEW, SELECTED, AT_MOUSE }
    
    private weak MenuItem parent = null;
    
    private AnimatedValue draw_center_x = null;
    private AnimatedValue draw_center_y = null;
    private AnimatedValue draw_radius = null;
    private AnimatedValue label_alpha = null;
    
    private State state = State.INVISIBLE;
    
    private bool marking_mode = false;
    private bool closing = false;
    
    private int hovered_child = -1;
    private int active_child = -1;
    private Vector center_offset;
    
    private Gee.ArrayList<MenuItem> children;
    
    public MenuItem(string label, string icon_name) {
        this.label = label;
        this.icon_name = icon_name;
        this.center_offset = new Vector(0,0);
        
        this.children = new Gee.ArrayList<MenuItem>();
        
        this.draw_center_x = new AnimatedValue.cubic(AnimatedValue.Direction.OUT, 1, 1, 0);
        this.draw_center_y = new AnimatedValue.cubic(AnimatedValue.Direction.OUT, 1, 1, 0);
        this.draw_radius = new AnimatedValue.cubic(AnimatedValue.Direction.OUT, 0, 0, 0, 1);
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
    
    public void add_child(MenuItem child) {
        this.children.add(child);
        child.parent = this;
    }
    
    public void close(bool delayed) {
        foreach (var child in children)
            child.close(delayed);
            
        closing = true;
        
        if (delayed) {
            GLib.Timeout.add((uint)(Menu.FADE_OUT_TIME*1000), () => {
                this.draw_radius.reset_target(0.0, Menu.ANIMATION_TIME);
                this.label_alpha.reset_target(0.0, Menu.ANIMATION_TIME);
                return false;
            });           
        } else {
            this.draw_radius.reset_target(0.0, Menu.ANIMATION_TIME);
            this.label_alpha.reset_target(0.0, Menu.ANIMATION_TIME);
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
    
    public bool activate(Vector mouse) {
        
        switch (this.state) {
            case State.INVISIBLE:
                debug("INVISIBLE: %s", label);
                break;
                
            case State.PREVIEW: 
                debug("PREVIEW: %s", label);
                break;
                
            case State.TRAIL_PREVIEW:
                debug("TRAIL_PREVIEW: %s", label);
                break;
            
            case State.AT_MOUSE:   
            case State.SELECTABLE:
                
//                double distance = GLib.Math.sqrt(mouse_x*mouse_x + mouse_y*mouse_y);
//                var ideal_offset = direction_to_coords(index_to_direction(parent.hovered_child), distance);
                
//                move_parents(
                move(mouse);
//                move(new Vector(ideal_offset.x, ideal_offset.y));
                
                if (children.size > 0) {
                    set_state(State.ACTIVE);
                    return true;
                }
                
                set_state(State.SELECTED);
                debug("Selected: %s", label);
                break;
                
            case State.ACTIVE:
                if (hovered_child >= 0) {
                    bool keep_open = true;
                
                    for (int i=0; i<children.size; ++i) {
                        if (i == hovered_child) {
                           keep_open = children[i].activate(new Vector(mouse.x - draw_center_x.end, mouse.y - draw_center_y.end));
                        } else {
                           children[i].set_state(State.TRAIL_PREVIEW);
                        }
                    }
                    set_state(State.TRAIL);
                    active_child = hovered_child;
                    
                    // move parents
                    //parent_move_offset = new Vector(100, 100);
                    
                    return keep_open;
                } 
                break;
                
            case State.TRAIL:
                if (active_child >= 0) {
                    if (children[active_child].hovered_child == -2) {
                        children[active_child].set_state(State.SELECTABLE);
                        children[active_child].center_offset = new Vector(0,0);
                        active_child = -1;
                        set_state(State.ACTIVE);
                        
                        //move_parents(new Vector(30, 30));
                        move_parents(new Vector(-draw_center_x.end + mouse.x, -draw_center_y.end + mouse.y));
                        
                        return true;
                    } 
                    
                    return children[active_child].activate(new Vector(mouse.x - draw_center_x.end, mouse.y - draw_center_y.end));
                }
                break;
        }
        
        return false;
    }
    
    public void set_state(State new_state) {
        switch (new_state) {
            case State.INVISIBLE:
                this.state = State.INVISIBLE;

                break;
            case State.TRAIL_PREVIEW:
                this.state = State.TRAIL_PREVIEW;

                for (int i=0; i<children.size; ++i)
                    children[i].set_state(State.INVISIBLE);
                break;
            case State.PREVIEW:
                this.state = State.PREVIEW;

                for (int i=0; i<children.size; ++i)
                    children[i].set_state(State.INVISIBLE);
                break;
            case State.SELECTABLE:
                this.state = State.SELECTABLE;
                
                for (int i=0; i<children.size; ++i)
                    children[i].set_state(State.PREVIEW);
                break;
            case State.AT_MOUSE:
                this.state = State.AT_MOUSE;
                
                for (int i=0; i<children.size; ++i)
                    children[i].set_state(State.PREVIEW);
                break;
            case State.ACTIVE:
                this.state = State.ACTIVE;
                
                for (int i=0; i<children.size; ++i)
                    children[i].set_state(State.SELECTABLE);
                break;
            case State.TRAIL:
                this.state = State.TRAIL;
                
                break;
            case State.SELECTED:
                this.state = State.SELECTED;
                
                break;
        }
    }
    
    public void draw(Cairo.Context ctx, InvisibleWindow window, Vector parent_center,
                             Direction dir, bool prelight, double frame_time) {
        this.draw_center_x.update(frame_time);   
        this.draw_center_y.update(frame_time);
        this.draw_radius.update(frame_time);
        this.label_alpha.update(frame_time);
        
        Vector center = new Vector((int)draw_center_x.val + parent_center.x, (int)draw_center_y.val + parent_center.y);
        
        hovered_child = -1;
        
         switch (state) {
            case State.PREVIEW: case State.TRAIL_PREVIEW:
            
                // draw label
                draw_label(ctx, window, center, dir, prelight);
                
                if (prelight) ctx.set_source_rgb(SEL_R, SEL_G, SEL_B);
                else          ctx.set_source_rgb(FG_R, FG_G, FG_B);
                
                ctx.arc(center.x, center.y, draw_radius.val, 0, GLib.Math.PI*2);
                ctx.fill();
                break;
                
            case State.AT_MOUSE:
            
                update_position(Vector.direction(parent_center, window.get_mouse_pos()), dir, 0);
                label_alpha.reset_target(1.0, 0);
                
                // draw label
                draw_label(ctx, window, center, dir, prelight);
                
                // draw circle
                if (prelight || got_selected()) ctx.set_source_rgb(SEL_R, SEL_G, SEL_B);
                else                            ctx.set_source_rgb(FG_R, FG_G, FG_B);
                
                ctx.arc(center.x, center.y, draw_radius.val, 0, GLib.Math.PI*2);
                ctx.fill();
                
                // draw child circles
                for (int i=0; i<children.size; ++i) {
                    var child_dir = index_to_direction(i, children.size, (dir+4)%8);
                    children[i].draw(ctx, window, center, child_dir, prelight, frame_time);
                }
                break;
        
            case State.SELECTABLE: case State.SELECTED:
                
                // draw label
                draw_label(ctx, window, center, dir, prelight);
                
                // draw circle
                if (prelight || got_selected()) ctx.set_source_rgb(SEL_R, SEL_G, SEL_B);
                else                            ctx.set_source_rgb(FG_R, FG_G, FG_B);
                
                ctx.arc(center.x, center.y, draw_radius.val, 0, GLib.Math.PI*2);
                ctx.fill();
                
                // draw child circles
                if (!marking_mode) {
                    for (int i=0; i<children.size; ++i) {
                        var child_dir = index_to_direction(i, children.size, (dir+4)%8);
                        children[i].draw(ctx, window, center, child_dir, prelight, frame_time);
                    }
                }
                break;
                
            case State.ACTIVE:
            
                if (marking_mode) {
                    ctx.set_source_rgb(FG_R, FG_G, FG_B);
                    ctx.set_line_cap(Cairo.LineCap.ROUND);
                    ctx.move_to(center.x, center.y);
                    
                    ctx.set_line_width(draw_radius.val);
                    ctx.line_to(window.get_mouse_pos().x, window.get_mouse_pos().y);
                    ctx.stroke();
                }
                
                if (marking_mode) {
                    // draw center circle
                    draw_label(ctx, window, center, dir, prelight);
                    
                    if (prelight || got_selected()) ctx.set_source_rgb(SEL_R, SEL_G, SEL_B);
                    else                            ctx.set_source_rgb(FG_R, FG_G, FG_B);
                    
                    ctx.arc(center.x, center.y, draw_radius.val, 0, GLib.Math.PI*2);
                    ctx.fill();  
                    
                } else {
                    
                    ctx.set_source_rgb(FG_R, FG_G, FG_B);
                    ctx.arc(center.x, center.y, draw_radius.val, 0, GLib.Math.PI*2);
                    ctx.fill();
                
                    // draw label
                    var img = new RenderedText(label, (int)(Menu.ACTIVE_ITEM_RADIUS*0.8)*2, (int)(Menu.ACTIVE_ITEM_RADIUS*0.8)*2, "ubuntu 10", new Color.from_rgb(1, 1, 1), 1);
                    ctx.translate(center.x, center.y);
                    img.paint_on(ctx, GLib.Math.fmax(0, 2*label_alpha.val-1));
                    ctx.translate(-center.x, -center.y);
                }
                
                var active = a_slice_is_active(window, center);
                var active_dir = get_mouse_direction(window, center);
                
                // draw sector of active item
                for (int i=0; i<children.size; ++i) {
                    var child_dir = index_to_direction(i, children.size, (dir+4)%8);
                    
                    if (active && child_dir == active_dir) {
                        hovered_child = i;
                        
                        if (!marking_mode) 
                            draw_sector(ctx, window, center, child_dir, true, frame_time);
                            
                    } else if (!marking_mode) {
                        draw_sector(ctx, window, center, child_dir, false, frame_time);
                    }
                }
                
                if (hovered_child == -1 && active && active_dir == (dir+4)%8) {
                    hovered_child = -2;
                }
                
                if (marking_mode && hovered_child >= 0 && children[hovered_child].state != State.AT_MOUSE) {
                    for (int i=0; i<children.size; ++i) {
                        if (hovered_child == i) children[i].set_state(State.AT_MOUSE);
                        else {
                            children[i].set_state(State.SELECTABLE);
                            
                            var child_dir = index_to_direction(i, children.size, (dir+4)%8);
                            var child_center = direction_to_coords(child_dir, Menu.TRAIL_PREVIEW_PIE_RADIUS);
                            children[i].update_position(child_center, child_dir, 0.0);
                        }
                    }
                }
                
                // draw child circles
                for (int i=0; i<children.size; ++i) {
                    var child_dir = index_to_direction(i, children.size, (dir+4)%8);
                    children[i].draw(ctx, window, center, child_dir, active && child_dir == active_dir, frame_time);
                }
                break;
                
            case State.TRAIL:
            
                // draw highlight if immediate child hovers
                if (children[active_child].hovered_child == -2 && !marking_mode) {
                    var child_pos = new Vector((int)children[active_child].draw_center_x.val, (int)children[active_child].draw_center_y.val);
                        child_pos.x += center.x;
                        child_pos.y += center.y;
                    var child_dir = index_to_direction(active_child, children.size, (dir+4)%8);
                    draw_sector(ctx, window, child_pos, (child_dir+4)%8, true, frame_time);
                    
                    prelight = true;
                } else if (children[active_child].active_child == -1 && !got_selected()) {
                    var child_pos = new Vector((int)children[active_child].draw_center_x.val, (int)children[active_child].draw_center_y.val);
                    var child_dir = index_to_direction(active_child, children.size, (dir+4)%8);
                    draw_sector(ctx, window, child_pos, (child_dir+4)%8, false, frame_time);
                }
                
                var active_child_dir = index_to_direction(active_child, children.size, (dir+4)%8);
                
                // draw center circle
                if (marking_mode) draw_label(ctx, window, center, dir, prelight);
                else              draw_label(ctx, window, center, (active_child_dir+4)%8, prelight);
                
                if (prelight || got_selected()) ctx.set_source_rgb(SEL_R, SEL_G, SEL_B);
                else                            ctx.set_source_rgb(FG_R, FG_G, FG_B);
                
                ctx.arc(center.x, center.y, draw_radius.val, 0, GLib.Math.PI*2);
                ctx.fill();  
                
                // draw line to child circle
                if (prelight || got_selected()) ctx.set_source_rgb(SEL_R, SEL_G, SEL_B);
                else                            ctx.set_source_rgb(FG_R, FG_G, FG_B);
                
                
                var offset = direction_to_coords(active_child_dir, Menu.TRAIL_PREVIEW_PIE_RADIUS);
                    offset.x += center.x;
                    offset.y += center.y;
                ctx.set_line_cap(Cairo.LineCap.ROUND);
                ctx.move_to(offset.x, offset.y);
                
                ctx.set_line_width(draw_radius.val);
                ctx.line_to((int)children[active_child].draw_center_x.val + center.x, (int)children[active_child].draw_center_y.val + center.y);
                ctx.stroke();
                
                // draw child circles
                for (int i=0; i<children.size; ++i) {
                    var child_dir = index_to_direction(i, children.size, (dir+4)%8);
                    children[i].draw(ctx, window, center, child_dir, prelight, frame_time);
                }
                
                break;
        }
    }
    
    public void update_position(Vector offset, Direction dir, double time) {
        
        var center = new Vector(offset.x + center_offset.x, offset.y + center_offset.y);
        
        switch (state) {
         
            case State.INVISIBLE:
                draw_center_x.reset_target(center.x, time);
                draw_center_y.reset_target(center.y, time);
                draw_radius.reset_target(0.0, time);
                label_alpha.reset_target(0.0, time);
                
                break;
                
            case State.TRAIL_PREVIEW:
                draw_center_x.reset_target(center.x, time);
                draw_center_y.reset_target(center.y, time);
                draw_radius.reset_target(Menu.TRAIL_PREVIEW_ITEM_RADIUS, time);
                label_alpha.reset_target(0.0, time);
                
                for (int i=0; i<children.size; ++i) {
                    children[i].update_position(new Vector(0,0), dir, time);
                }
                
                break;
         
            case State.PREVIEW:
                draw_center_x.reset_target(center.x, time);
                draw_center_y.reset_target(center.y, time);
                draw_radius.reset_target(Menu.PREVIEW_ITEM_RADIUS, time);
                label_alpha.reset_target(0.0, time);
                
                for (int i=0; i<children.size; ++i) {
                    children[i].update_position(new Vector(0,0), dir, time);
                }
                
                break;
                
            case State.AT_MOUSE:
                if (children.size > 0) {
                    draw_center_x.reset_target(center.x, time);
                    draw_center_y.reset_target(center.y, time);
                    draw_radius.reset_target(Menu.SELECTABLE_ITEM_RADIUS_SMALL, time);
                    label_alpha.reset_target(1.0, time);
                    
                    for (int i=0; i<children.size; ++i) {
                        var child_dir = index_to_direction(i, children.size, (dir+4)%8);
                        var child_center = direction_to_coords(child_dir, Menu.PREVIEW_PIE_RADIUS);
                        children[i].update_position(child_center, child_dir, time);
                    }
                    
                } else {
                    draw_center_x.reset_target(center.x, time);
                    draw_center_y.reset_target(center.y, time);
                    draw_radius.reset_target(Menu.SELECTABLE_ITEM_RADIUS, time);
                    label_alpha.reset_target(1.0, time);
                }
                
                break;
        
            case State.SELECTABLE: case State.SELECTED:
                if (children.size > 0) {
                    draw_center_x.reset_target(center.x, time);
                    draw_center_y.reset_target(center.y, time);
                    draw_radius.reset_target(marking_mode ? Menu.PREVIEW_ITEM_RADIUS : Menu.SELECTABLE_ITEM_RADIUS_SMALL, time);
                    label_alpha.reset_target(marking_mode ? 0.0 : 1.0, time);
                    
                    for (int i=0; i<children.size; ++i) {
                        var child_dir = index_to_direction(i, children.size, (dir+4)%8);
                        var child_center = direction_to_coords(child_dir, Menu.PREVIEW_PIE_RADIUS);
                        children[i].update_position(child_center, child_dir, time);
                    }
                    
                } else {
                    draw_center_x.reset_target(center.x, time);
                    draw_center_y.reset_target(center.y, time);
                    draw_radius.reset_target(marking_mode ? Menu.PREVIEW_ITEM_RADIUS : Menu.SELECTABLE_ITEM_RADIUS, time);
                    label_alpha.reset_target(marking_mode ? 0.0 : 1.0, time);
                }
                
                break;
                
            case State.ACTIVE:

                draw_center_x.reset_target(center.x, time);
                draw_center_y.reset_target(center.y, time);
                draw_radius.reset_target(marking_mode ? Menu.TRAIL_ITEM_RADIUS : Menu.ACTIVE_ITEM_RADIUS, time);
                label_alpha.reset_target(1.0, time);
                
                for (int i=0; i<children.size; ++i) {
                    var child_dir = index_to_direction(i, children.size, (dir+4)%8);
                    var child_center = direction_to_coords(child_dir, marking_mode ? Menu.TRAIL_PREVIEW_PIE_RADIUS : Menu.SELECTABLE_PIE_RADIUS);
                    children[i].update_position(child_center, child_dir, time);
                }
                    
                break;
                
            case State.TRAIL:
            
                draw_center_x.reset_target(center.x, time);
                draw_center_y.reset_target(center.y, time);
                draw_radius.reset_target(Menu.TRAIL_ITEM_RADIUS, time);
                label_alpha.reset_target(1.0, time);
                
                for (int i=0; i<children.size; ++i) {
                    if (i != active_child) {
                        var child_dir = index_to_direction(i, children.size, (dir+4)%8);
                        var child_center = direction_to_coords(child_dir, Menu.TRAIL_PREVIEW_PIE_RADIUS);
                        children[i].update_position(child_center, child_dir, time);
                    } else {
                        var child_dir = index_to_direction(i, children.size, (dir+4)%8);
                        children[i].update_position(new Vector(0,0), child_dir, time);
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
            ctx.set_source_rgba(BG_R, BG_G, BG_B, label_alpha.val*0.7);
            ctx.set_line_width(Menu.LABEL_HEIGHT*label_alpha.val);
            ctx.set_line_join(Cairo.LineJoin.ROUND);
            ctx.set_line_cap(Cairo.LineCap.ROUND);
            ctx.move_to(center.x, center.y);
            
            var offset = direction_to_coords(dir, 25);
                offset.x += center.x;
                offset.y += center.y;
            ctx.line_to(offset.x, offset.y);
            
            var label_pos = new Vector(offset.x, offset.y-7);
            
            switch (get_label_direction(dir)) {
                case LabelDirection.LEFT:
                    ctx.line_to(offset.x-(label_size.x)*label_alpha.val , offset.y);
                    label_pos.x -= label_size.x ;
                    break;
                case LabelDirection.RIGHT:
                    ctx.line_to(offset.x+(label_size.x)*label_alpha.val, offset.y);
                    break;
                case LabelDirection.TOP_LEFT:
                    ctx.line_to(offset.x, offset.y - (Menu.LABEL_HEIGHT/2 + 5)*label_alpha.val);
                    ctx.line_to(offset.x-(label_size.x)*label_alpha.val, offset.y - (Menu.LABEL_HEIGHT/2 + 5)*label_alpha.val);
                    label_pos.x -= label_size.x;
                    label_pos.y -= Menu.LABEL_HEIGHT/2 + 8;
                    break;
                case LabelDirection.BOTTOM_RIGHT:
                    ctx.line_to(offset.x, offset.y + (Menu.LABEL_HEIGHT/2 + 5)*label_alpha.val);
                    ctx.line_to(offset.x+(label_size.x)*label_alpha.val, offset.y + (Menu.LABEL_HEIGHT/2 + 5)*label_alpha.val);
                    label_pos.y += Menu.LABEL_HEIGHT/2 + 8;
                    break;
            }
            
            ctx.stroke();

            // draw label
            if (prelight || got_selected()) ctx.set_source_rgba(SEL_R, SEL_G, SEL_B, label_alpha.val);
            else                            ctx.set_source_rgba(0.0, 0.0, 0.0, GLib.Math.fmax(0, 2*label_alpha.val-1));

            ctx.move_to(label_pos.x, label_pos.y);
            Pango.cairo_update_layout(ctx, layout);
            Pango.cairo_show_layout(ctx, layout);
            ctx.stroke();
        }
    }

    public void draw_sector(Cairo.Context ctx, InvisibleWindow window, Vector center,
                             Direction dir, bool prelight, double frame_time) {
        
        if (!closing) {
            double start_angle = (dir-2)*(GLib.Math.PI/4)-GLib.Math.PI/8+Menu.SLICE_HINT_GAP;
            double end_angle = (dir-2)*(GLib.Math.PI/4)+GLib.Math.PI/8-Menu.SLICE_HINT_GAP;

            // draw glow
            if (prelight) {

                var gradient = new Cairo.Pattern.radial(center.x, center.y, Menu.ACTIVE_ITEM_RADIUS, center.x, center.y, Menu.SLICE_HINT_RADIUS);

                gradient.add_color_stop_rgba(0.0, SEL_R, SEL_G, SEL_B, 0.6);
                gradient.add_color_stop_rgba(1.0, SEL_R, SEL_G, SEL_B, 0.0);

                ctx.set_source(gradient);
            
                ctx.arc_negative(center.x, center.y, Menu.ACTIVE_ITEM_RADIUS, end_angle, start_angle);
                ctx.arc(center.x, center.y, Menu.SLICE_HINT_RADIUS, start_angle, end_angle);
                ctx.close_path();
                ctx.fill();
            } else {
            
    //            var gradient = new Cairo.Pattern.radial(center.x, center.y, Menu.ACTIVE_ITEM_RADIUS, center.x, center.y, Menu.SLICE_HINT_RADIUS/2);
    //            
    //            gradient.add_color_stop_rgba(0.0, BG_R, BG_G, BG_B, 0.5);
    //            gradient.add_color_stop_rgba(0.7, BG_R, BG_G, BG_B, 0.5);
    //            gradient.add_color_stop_rgba(1.0, BG_R, BG_G, BG_B, 0.0);

    //            
    //            ctx.set_source(gradient);
    //        
    //            ctx.arc_negative(center.x, center.y, Menu.ACTIVE_ITEM_RADIUS, end_angle, start_angle);
    //            ctx.arc(center.x, center.y, Menu.SLICE_HINT_RADIUS/2, start_angle, end_angle);
    //            ctx.close_path();
    //            ctx.fill();
            }
        }
        
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
        var mouse = window.get_mouse_pos();
        
        var diff = new Vector(mouse.x - center.x, mouse.y - center.y);
        
        return diff.length_sqr() > Menu.ACTIVE_ITEM_RADIUS*Menu.ACTIVE_ITEM_RADIUS; 
    }
    
    private Direction get_mouse_direction(InvisibleWindow window, Vector center) {
        var mouse = window.get_mouse_pos();
        
        Direction loc = Direction.N;
        
        int sectors = 8;
        double angle = 0;
        
        double diff_x = mouse.x - center.x;
        double diff_y = mouse.y - center.y;

        double distance_sqr = GLib.Math.pow(diff_x, 2) + GLib.Math.pow(diff_y, 2);
        
        if (distance_sqr > Menu.ACTIVE_ITEM_RADIUS*Menu.ACTIVE_ITEM_RADIUS) {
            
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
