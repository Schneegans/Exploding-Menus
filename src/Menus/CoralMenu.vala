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
    public const int INNER_ITEM_RADIUS = 50;
    public const int CENTER_RADIUS = 30;
    public const int EXPANDED_ITEM_OFFSET = 20;
    public const double CHILDREN_ANGLE = GLib.Math.PI*2.0/2.1;
    
    public const double MAX_ITEM_ANGLE = CHILDREN_ANGLE/6;
    public const double MAX_ITEM_DISTANCE = 200;
    
    public const double ANIMATION_TIME = 0.3;
    public const double FADE_OUT_TIME = 0.5;
    
    public const int WARP_ZONE = 100;

    private InvisibleWindow window;
    private CoralMenuItem root;
    private AnimatedValue alpha;
    
    private uint open_time;
    
    private Vector center = null;
    private bool released;
    private bool closing;
    
    public CoralMenu() {
        window = new InvisibleWindow();
        alpha  = new AnimatedValue.linear(0, 1, ANIMATION_TIME);
        
        window.on_draw.connect((ctx, frame_time) => {
            
            if (alpha.val < 0.15) {
                alpha.update(frame_time);
                return;
            }
            
            alpha.update(frame_time);
            
            if (center == null)
                center = window.get_mouse_pos(false);
            
            root.update(window, center, frame_time);
            
            ctx.push_group();
            ctx.set_source_rgba(0,0,0, 0.3);
            ctx.paint();
            
            
            
            root.draw_labels_bg(ctx, window, center);
            root.draw_labels(ctx, window, center);
            root.draw_bg(ctx, window, center);
            root.draw(ctx, window, center);
            
            ctx.pop_group_to_source();
            ctx.paint_with_alpha(alpha.val);
        });
        
        window.on_press.connect((button) => {
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
    
    public bool is_open() {
        return window.visible;
    }
    
    public string get_mouse_path() {
        return "";
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
        center = null;
        
        alpha.reset_target(1, ANIMATION_TIME);
        
        window.open();
        
        root.update_offset(0, 0);
        
        open_time = Time.get_now();
    }
    
    private void do_action(bool cancel_marking_mode) {
        var mouse = window.get_mouse_pos(true);
        var activated_item = root.activate(mouse);
        
        if (activated_item != "_keep_open") {
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
            root.update_offset(0, 0);
        }
    }
}
