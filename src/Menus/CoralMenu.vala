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

public class CoralMenu: GLib.Object, Menu {

    public const int LABEL_HEIGHT = 30;
    public const int ITEM_RADIUS = 20;
    public const int INNER_ITEM_RADIUS = 40;
    public const int CENTER_RADIUS = 50;
    public const int EXPANDED_ITEM_OFFSET = 20;
    public const double CHILDREN_ANGLE = GLib.Math.PI*2.0/2.2;
    
    public const double MAX_ITEM_ANGLE = CHILDREN_ANGLE/7;
    public const double MAX_ITEM_DISTANCE = 300;
    
    public const double ANIMATION_TIME = 0.3;
    public const double FADE_OUT_TIME = 0.5;
    
    public const int WARP_ZONE = 200;

    private InvisibleWindow window;
    private CoralMenuItem root;
    private AnimatedValue alpha;
    
    private uint open_time;
    
    private Vector center;
    private bool released;
    private bool closing;
    
    public CoralMenu() {
        window = new InvisibleWindow();
        center = new Vector(0, 0);
        alpha  = new AnimatedValue.linear(0, 1, ANIMATION_TIME);
        
        window.on_draw.connect((ctx, frame_time) => {
            
            if (alpha.val < 0.05) {
                alpha.update(frame_time);
                return;
            }
            
            alpha.update(frame_time);
            
            root.update(window, center, frame_time);
            
            ctx.push_group();
            ctx.set_source_rgba(0,0,0, 0.3);
            ctx.paint();
            
            root.draw_bg(ctx, window, center);
            root.draw(ctx, window, center);
            
            ctx.pop_group_to_source();
            ctx.paint_with_alpha(alpha.val);
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
                if (released) {
                    do_action(true);
                }
                released = true;
            }
        });
    }
    
    public void set_structure(MenuItem top) {
        root = create_items(top);
        root.realize(0,0,0);
        root.set_state(CoralMenuItem.State.EXPANDED);
    }
    
    private CoralMenuItem create_items(MenuItem source) {
        
        var destination = new CoralMenuItem(source.name, source.icon);
        
        foreach (var child in source.children) {
            destination.add_child(create_items(child));
        }
        
        return destination;
    }
    
    public void show() {
        released = false;
        closing = false;
        
        alpha.reset_target(1, ANIMATION_TIME);
        
        window.open();
        center = window.get_mouse_pos();
        
        warp_pointer();
        
        root.update_offset(0, 0);
        
        open_time = Time.get_now();
    }
    
    private void do_action(bool cancel_marking_mode) {
        var mouse = window.get_mouse_pos();
        var activated_item = root.activate(mouse);
        
        if (activated_item != "_keep_open") {
            warp_pointer();
            var activated = activated_item != "_cancel";
            
            root.update_offset(0, 0);
            root.close(activated);
            closing = true;

            if (activated_item == "_cancel") on_cancel();
            else                             on_select(activated_item, Time.get_now() - open_time);          
            
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
            warp_pointer();
            root.update_offset(0, 0);
            
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
