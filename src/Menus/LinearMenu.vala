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

public class LinearMenu: GLib.Object, Menu {

    public const double ANIMATION_TIME = 0.1;

    private InvisibleWindow window;
    private LinearMenuItem root;
    
    private AnimatedValue alpha;
    
    private uint open_time;
    
    private Vector center;
    private bool closing;
    
    public LinearMenu() {
        window = new InvisibleWindow();
        center = new Vector(0, 0);
        alpha  = new AnimatedValue.linear(0, 1, ANIMATION_TIME);
        
        window.on_draw.connect((ctx, frame_time) => {
            
            if (alpha.val < 0.05) {
                alpha.update(frame_time);
                return;
            }
            
            alpha.update(frame_time);
            
            ctx.push_group();
            
            root.draw(ctx, window, center, 0, frame_time);
            
            ctx.pop_group_to_source();
            ctx.paint_with_alpha(alpha.val);
        });
        
        window.on_press.connect((button) => {
            if (!closing) {
                do_action();
            }
        });
        
        window.on_release.connect((button) => {

        });
    }
    
    public void set_structure(MenuItem top) {
        root = create_items(top);
        root.set_state(LinearMenuItem.State.SELECTED);
    }
    
    private LinearMenuItem create_items(MenuItem source) {
        
        var destination = new LinearMenuItem(source.name, source.icon);
        
        foreach (var child in source.children) {
            destination.add_child(create_items(child));
        }
        
        return destination;
    }
    
    public void show() {
        closing = false;
        
        alpha.reset_target(1, ANIMATION_TIME);
        
        window.open();
        center = window.get_mouse_pos();
        
        open_time = Time.get_now();
    }
    
    private void do_action() {
        var mouse = window.get_mouse_pos();
        var activated_item = root.activate(mouse);
        
        if (activated_item != "_keep_open") {
            root.close();
            closing = true;
            
            alpha.reset_target(0, ANIMATION_TIME);
            
            if (activated_item == "_cancel") on_cancel();
            else                             on_select(activated_item, Time.get_now() - open_time);
            
            GLib.Timeout.add((uint)((ANIMATION_TIME)*1000), () => {
                window.hide();
                return false;
            });
        } 
    }
}
