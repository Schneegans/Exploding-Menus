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

public class TraceMenu: GLib.Object, Menu {

    public const int LABEL_HEIGHT = 32;
    
    public const int ACTIVE_ITEM_RADIUS = 35;
    
    public const int SELECTABLE_PIE_RADIUS = 55;
    public const int SELECTABLE_ITEM_RADIUS = 16;
    public const int SELECTABLE_ITEM_RADIUS_SMALL = 12;
    
    public const int PREVIEW_PIE_RADIUS = 15;
    public const int PREVIEW_ITEM_RADIUS = 3;
    
    public const int TRAIL_ITEM_RADIUS = SELECTABLE_ITEM_RADIUS_SMALL;
    public const int TRAIL_PREVIEW_PIE_RADIUS = PREVIEW_PIE_RADIUS;
    public const int TRAIL_PREVIEW_ITEM_RADIUS = PREVIEW_ITEM_RADIUS;

    public const int SLICE_HINT_RADIUS = 150;
    public const double SLICE_HINT_GAP = 0.0;
    public const double ANIMATION_TIME = 0.3;
    public const double FADE_OUT_TIME = 0.5;
    
    public const int WARP_ZONE = 200;

    
    private InvisibleWindow window;
    private TraceMenuItem root;
    private Mark mark;
    private AnimatedValue alpha;
    
    private uint open_time;
    
    private Vector center;
    private Vector pause_location;
    private bool released;
    private bool closing;
    
    public TraceMenu() {
        window = new InvisibleWindow();
        center = new Vector(0, 0);
        pause_location = new Vector(0, 0);
        mark   = new Mark();
        alpha  = new AnimatedValue.linear(0, 1, ANIMATION_TIME);

        mark.on_direction_changed.connect(() => {
            if (!closing) {
                if (!released && root.in_marking_mode() && root.child_is_hovered()) {
                    do_action(false);
                } 
            }
        });
        
        mark.on_long_stroke.connect(() => {
            do_action(false);
        });
        
        mark.on_paused.connect(() => {
            if (!closing) {
                if (!released && root.in_marking_mode() && root.submenu_is_hovered()) {
                    do_action(true);
                    pause_location = window.get_mouse_pos();
                } 
            }
        });
        
        mark.on_stutter.connect(() => {
            do_action(false);
        });
        
        window.on_motion.connect((x, y, state) => {
            if (!released && !root.in_marking_mode() && (state & Gdk.ModifierType.BUTTON3_MASK) != 0) {
                if (Vector.direction(window.get_mouse_pos(), pause_location).length() > SELECTABLE_PIE_RADIUS) {
                    root.set_marking_mode(true);
                    root.update_position(center, ANIMATION_TIME);
                }
            }
            
            if (root.in_marking_mode() && !closing) {
                mark.update(window.get_mouse_pos());
            }
        });
        
        window.on_draw.connect((ctx, frame_time) => {
            
            if (alpha.val < 0.05) {
                alpha.update(frame_time);
                return;
            }
            
            alpha.update(frame_time);
            
            ctx.push_group();
            ctx.set_source_rgba(0,0,0, 0.3);
            ctx.paint();
            
            root.draw(ctx, window, new Vector(0,0), false, frame_time);
            
            ctx.pop_group_to_source();
            ctx.paint_with_alpha(alpha.val);
            
            if (root.in_marking_mode() && !closing) {
                mark.update(window.get_mouse_pos());
            }
        });
        
        window.on_press.connect((button) => {
            if (button == 3) {
                root.close(false);
                closing = true;
                alpha.reset_target(0, ANIMATION_TIME);
                
                GLib.Timeout.add((uint)((ANIMATION_TIME)*1000), () => {
                    window.hide();
                    return false;
                });
            }
            released = true;
        });
        
        window.on_release.connect((button) => {
            if (!closing) {
                if (!released && root.in_marking_mode()) {                    
                    
                    do_action(true);
                } else if (released) {
                    root.update_position(center, 0.0);
                    do_action(true);
                }
                released = true;
            }
        });
        
        window.on_scroll.connect((up) => {
           
        });
    }
    
    public void set_structure(MenuItem top) {
        root = create_items(top);
        root.set_state(TraceMenuItem.State.ACTIVE);
        root.realize();
    }
    
    private TraceMenuItem create_items(MenuItem source) {
        
        var destination = new TraceMenuItem(source.name, source.icon);
        
        foreach (var child in source.children) {
            destination.add_child(create_items(child));
        }
        
        return destination;
    }
    
    public void show() {
        mark.reset();
        
        released = false;
        closing = false;
        
        alpha.reset_target(1, ANIMATION_TIME);
        
        window.open();
        center = window.get_mouse_pos();
        pause_location = window.get_mouse_pos();
        
        warp_pointer();
        
        root.update_position(center, 0.0);
        mark.update(center);
        
        open_time = Time.get_now();
    }
    
    private void do_action(bool cancel_marking_mode) {
        var mouse = window.get_mouse_pos();
        
        if (!root.activate(mouse)) {
            warp_pointer();
            var activated = root.got_selected();
            
            root.update_position(center, ANIMATION_TIME);
            root.close(activated);
            closing = true;

            message("Time: %u", Time.get_now() - open_time);            
            
            if (activated) {
                GLib.Timeout.add((uint)(FADE_OUT_TIME*1000), () => {
                    alpha.reset_target(0, ANIMATION_TIME);
                    GLib.Timeout.add((uint)((ANIMATION_TIME)*1000), () => {
                        window.hide();
                        return false;
                    });
                    return false;
                });
            } else {
                alpha.reset_target(0, ANIMATION_TIME);
                GLib.Timeout.add((uint)((ANIMATION_TIME)*1000), () => {
                    window.hide();
                    return false;
                });
            }
        } else {
            if (cancel_marking_mode)
                root.set_marking_mode(false);
            warp_pointer();
            root.update_position(center, ANIMATION_TIME);
            
        }
    }
    
    private void warp_pointer() {
        var mouse = window.get_mouse_pos();
        var display = Gdk.Display.get_default();
        var manager = display.get_device_manager();
        var screen = Gdk.Screen.get_default();
        
        var warp = new Vector(0,0);
        
        if (mouse.x < WARP_ZONE)                warp.x = WARP_ZONE - mouse.x;
        if (mouse.x > screen.width()-WARP_ZONE) warp.x = - WARP_ZONE - mouse.x + screen.width();
        
        if (mouse.y < WARP_ZONE)                 warp.y = WARP_ZONE - mouse.y;
        if (mouse.y > screen.height()-WARP_ZONE) warp.y = - WARP_ZONE - mouse.y + screen.height();
        
        center.x += warp.x;
        center.y += warp.y;

        unowned GLib.List<weak Gdk.Device?> list = manager.list_devices(Gdk.DeviceType.MASTER);
        
        int win_x = 0;
        int win_y = 0;
        
        window.get_window().get_origin(out win_x, out win_y);
        
        foreach(var device in list) {
            if (device.input_source == Gdk.InputSource.MOUSE) 
                device.warp(screen, (int)(mouse.x + warp.x + win_x), (int)(mouse.y + warp.y + win_y));
        }
    }
}
