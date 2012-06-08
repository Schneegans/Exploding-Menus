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

public class ExplodingMenu {

    private static BindingManager bindings = null;
    
    private static ExplodingMenu menu;
    
    public static void init() {
    
        menu = new ExplodingMenu();
    
        bindings = new BindingManager();
        bindings.bind(new Trigger.from_string("button3"), "button2");
        
        bindings.on_press.connect((id) => {
            menu.show();
        });
    }
    
    private InvisibleWindow window;
    
    private MenuItem[] items;
    private MenuItemPreview top_preview = null;
    private MenuItemPreview bottom_preview = null;
    
    private int[] line_x;
    private int[] line_y;
    
    private AnimatedValue pos_x;
    private AnimatedValue pos_y;
    
    private AnimatedValue fade_out_timer;
    
    private int active_item = -1;
    private int current_offset = 0;
    private int activated_item = -1;
    
    private bool marking = true;
    
    public ExplodingMenu() {
        window = new InvisibleWindow();
        
        pos_x = new AnimatedValue.cubic(AnimatedValue.Direction.OUT, 0, 0, 0, 0.0);
        pos_y = new AnimatedValue.cubic(AnimatedValue.Direction.OUT, 0, 0, 0, 0.0);
        fade_out_timer = new AnimatedValue.linear(1, 0, 0.5);
        
        line_x = {};
        line_y = {};
        
        items = {};
        items += new MenuItem("Rückgängig", "stock_undo");
        items += new MenuItem("Wiederholen", "stock_redo");
        items += new MenuItem("Ausschneiden", "stock_cut");
        items += new MenuItem("Kopieren", "stock_copy");
        items += new MenuItem("Einfügen", "stock_paste");
        items += new MenuItem("Löschen", "stock_delete");
        items += new MenuItem("Neu", "filenew");
        items += new MenuItem("Öffnen...", "stock_open");
        items += new MenuItem("Speichern", "stock_save");
        items += new MenuItem("Speichern als...", "stock_save");
        items += new MenuItem("Zurücksetzen", "revert");
        items += new MenuItem("Druckvorschau", "stock_print");
        items += new MenuItem("Drucken...", "stock_print");
        items += new MenuItem("Eigenschaften...", "stock_settings");
        items += new MenuItem("Hilfe...", "stock_help");
        items += new MenuItem("Beenden", "stock_exit");


        
        window.on_draw.connect((ctx, frame_time) => {
            
            pos_x.update(frame_time);
            pos_y.update(frame_time);
            
            double mouse_x, mouse_y;
            window.get_mouse_pos(out mouse_x, out mouse_y);
            
            if (activated_item >= 0) {
                
                fade_out_timer.update(frame_time);
                items[activated_item].draw(ctx, window, (int)pos_x.val, (int)pos_y.val, activated_item%6, true, frame_time);
                
                if (fade_out_timer.val == 0) {
                    window.close();
                    fade_out_timer = new AnimatedValue.linear(1, 0, 0.5);
                }
                
            } else {
                
                double diff_x = mouse_x - line_x[line_x.length-1];
                double diff_y = mouse_y - line_y[line_y.length-1];
                
                double distance_sqr = GLib.Math.pow(diff_x, 2) + GLib.Math.pow(diff_y, 2);
                double loc = 0;
                
                if (distance_sqr > 1000) {
                    
                    double angle = 0;
                    
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
                    
                    angle -= 5.5*(2.0*GLib.Math.PI/8.0);
                    if (angle < 0.0) angle += 2.0*GLib.Math.PI;
                    
                    loc = 8.0*angle/(2.0*GLib.Math.PI);
                }
                
                bool active = loc > 0;
                active_item = -1;
                
                if      (active && (loc >= 7.0))              active_item = 0+current_offset;
                else if (active && (loc >= 6.0 && loc < 7.0)) active_item = 2+current_offset;
                else if (active && (loc >= 5.0 && loc < 6.0)) active_item = 4+current_offset;
                else if (active && (loc >= 1.0 && loc < 2.0)) active_item = 1+current_offset;
                else if (active && (loc >= 2.0 && loc < 3.0)) active_item = 3+current_offset;
                else if (active && (loc >= 3.0 && loc < 4.0)) active_item = 5+current_offset;
                else if (active && (loc >= 4.0 && loc < 5.0)) active_item = -2;
                else if (active && (loc >= 0.0 && loc < 1.0)) active_item = -3;
                
                if (bottom_preview != null)
                    bottom_preview.draw(ctx, window, (int)pos_x.val, (int)pos_y.val, active_item == -2, frame_time);    
                
                if (top_preview != null)
                    top_preview.draw(ctx, window, (int)pos_x.val, (int)pos_y.val, active_item == -3, frame_time);   
                
                for (int i=0; i<6 && i < items.length-current_offset; ++i) {
                    items[i+current_offset].draw(ctx, window, (int)pos_x.val, (int)pos_y.val, i, active_item == i+current_offset, frame_time);
                }
            }
            
            ctx.set_line_width(5);
            ctx.set_source_rgba (0.0, 0.0, 0.0, 0.4);
            
            for (int i=0; i<line_x.length; ++i) {
                ctx.move_to(line_x[i], line_y[i]);
                
                if (i+1<line_x.length)          ctx.line_to(line_x[i+1], line_y[i+1]);
                else if (activated_item < 0)    ctx.line_to(mouse_x, mouse_y);
            }
            
            
            ctx.stroke();
        });
        
        window.on_press.connect((button) => {
            
        
        });
        
        window.on_release.connect((button) => {
            
            if (active_item == -2 && current_offset + 6 < items.length) {
                scroll(false);
                
                int x = 0, y = 0;
                window.get_mouse_pos(out x, out y);
                
                line_x += x;
                line_y += y;
                
                move_to(x, y);
                
            } else if (active_item == -3 && current_offset > 0) {
                scroll(true);
                
                int x = 0, y = 0;
                window.get_mouse_pos(out x, out y);
                
                line_x += x;
                line_y += y;
                
                move_to(x, y);
            
            } else if (active_item >= 0) {
                activated_item = active_item;
                
                int x = 0, y = 0;
                window.get_mouse_pos(out x, out y);
                
                line_x += x;
                line_y += y;
                
            } else if (!marking || button != 3) {
                    window.close();
            }
            
            marking = false;
        });
        
        window.on_scroll.connect((up) => {
            scroll(up);
            
            int x = 0, y = 0;
            window.get_mouse_pos(out x, out y);   
            
            line_x[line_x.length-1] = x;
            line_y[line_y.length-1] = y;
            
            move_to(x, y);
        });
    }
    
    public void show() {
        window.open();
        
        current_offset = 0;
        activated_item = -1;
        active_item = -1;
        marking = true;
        
        line_x = {};
        line_y = {};
        
        scroll_previews();
        
        int x = 0, y = 0;
        window.get_mouse_pos(out x, out y);
        
        line_x += x;
        line_y += y;
        
        move_to(x, y);
        
        pos_x.reset_target(x, 0);
        pos_y.reset_target(y, 0);
    }
    
    private void move_to(int x, int y) {
        pos_x.reset_target(x, 0.2);
        pos_y.reset_target(y, 0.2);
    }
    
    private void scroll(bool up) {
        if (up && current_offset > 0) {
            current_offset -= 6;
            scroll_previews(true, up);
            scroll_items(up);
        } else if (!up && current_offset + 6 < items.length) {
            current_offset += 6;
            scroll_previews(true, up);
            scroll_items(up);
        }
    }
    
    private void scroll_previews(bool animate = false, bool up = true) {
        if (items.length-current_offset > 6) {
            bottom_preview = new MenuItemPreview(false, animate, !up);
            
            for (int i=6+current_offset; i<items.length; ++i) {
                bottom_preview.add_entry(items[i].label, items[i].icon_name);
            }
        } else {
            bottom_preview = null;
        }
        
        if (current_offset > 0) {
            top_preview = new MenuItemPreview(true, animate, up);
            
            for (int i=0; i<current_offset; ++i) {
                top_preview.add_entry(items[i].label, items[i].icon_name);
            }
        } else {
            top_preview = null;
        }
    }
    
    private void scroll_items(bool up) {
        for (int i=current_offset; i<6+current_offset && i < items.length; ++i) {
            items[i].animate(up);
        }
    }
}

}
