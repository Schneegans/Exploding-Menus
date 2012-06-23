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

public class Menu {

    public const int LABEL_HEIGHT = 32;
    
    public const int ACTIVE_ITEM_RADIUS = 35;
    
    public const int SELECTABLE_PIE_RADIUS = 55;
    public const int SELECTABLE_ITEM_RADIUS = 18;
    public const int SELECTABLE_ITEM_RADIUS_SMALL = 12;
    
    public const int PREVIEW_PIE_RADIUS = 15;
    public const int PREVIEW_ITEM_RADIUS = 3;
    
    public const int TRAIL_ITEM_RADIUS = SELECTABLE_ITEM_RADIUS_SMALL;
    public const int TRAIL_PREVIEW_PIE_RADIUS = PREVIEW_PIE_RADIUS;
    public const int TRAIL_PREVIEW_ITEM_RADIUS = PREVIEW_ITEM_RADIUS;

    public const int SLICE_HINT_RADIUS = 250;
    public const double SLICE_HINT_GAP = 0.0;
    public const double ANIMATION_TIME = 0.3;
    public const double FADE_OUT_TIME = 0.5;
    
    public const int WARP_ZONE = 200;

    private static BindingManager bindings = null;
    private static Menu menu;
    
    public static void init() {
    
        menu = new Menu();
    
        bindings = new BindingManager();
        bindings.bind(new Trigger.from_string("button3"), "button2");
        
        bindings.on_press.connect((id) => {
            menu.show();
        });
    }
    
    private InvisibleWindow window;
    private MenuItem root;
    private Mark mark;
    private AnimatedValue alpha;
    
    private Vector center;
    private Vector pause_location;
    private bool released;
    private bool closing;
    
    public Menu() {
        window = new InvisibleWindow();
        center = new Vector(0, 0);
        pause_location = new Vector(0, 0);
        mark   = new Mark();
        alpha  = new AnimatedValue.linear(0, 1, ANIMATION_TIME);
        
        setup_menu();
        
        mark.on_direction_changed.connect(() => {
            if (!closing) {
                if (!released && root.in_marking_mode() && root.child_is_hovered()) {
                    do_action();
                } 
            }
        });
        
        mark.on_long_stroke.connect(() => {
            do_action();
        });
        
        mark.on_paused.connect(() => {
            if (!closing) {
                if (!released && root.in_marking_mode() && root.submenu_is_hovered()) {
                    root.set_marking_mode(false);
                    do_action();
                    pause_location = window.get_mouse_pos();
                } 
            }
        });
        
        mark.on_stutter.connect(() => {
            do_action();
        });
        
        window.on_motion.connect((x, y, state) => {
            if (!released && !root.in_marking_mode() && (state & Gdk.ModifierType.BUTTON3_MASK) != 0) {
                if (Vector.direction(window.get_mouse_pos(), pause_location).length() > SELECTABLE_PIE_RADIUS) {
                    root.set_marking_mode(true);
                    root.update_position(center, Menu.ANIMATION_TIME);
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
                    root.set_marking_mode(false);
                    do_action();
                } else if (!released) {
                    root.set_marking_mode(false);
                } else {
                    root.update_position(center, 0.0);
                    do_action();
                }
                released = true;
            }
        });
        
        window.on_scroll.connect((up) => {
           
        });
    }
    
    public void show() {
        setup_menu();
        mark.reset();
        
        released = false;
        closing = false;
        
        alpha.reset_target(1, ANIMATION_TIME);
        
        window.open();
        center = window.get_mouse_pos();
        pause_location = window.get_mouse_pos();
        
        root.update_position(center, 0.0);
        mark.update(center);
    }
    
    private void do_action() {
        var mouse = window.get_mouse_pos();
        
        if (!root.activate(mouse)) {
            warp_pointer();
            var activated = root.got_selected();
            
            root.update_position(center, ANIMATION_TIME);
            root.close(activated);
            closing = true;
            
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
    
    private void setup_menu() {
    
        root = new MenuItem("Hauptmenü", "");
        
            var file = new MenuItem("Datei", "");
                file.add_child(new MenuItem("Neu...", ""));
                file.add_child(new MenuItem("Öffnen...", ""));
                file.add_child(new MenuItem("Speichern", ""));
                
                var tmp = new MenuItem("Speichern als", "");
                    tmp.add_child(new MenuItem("Text-Datei", ""));
                    tmp.add_child(new MenuItem("Bild-Datei", ""));
                    tmp.add_child(new MenuItem("Sound-Datei", ""));
                    tmp.add_child(new MenuItem("Video-Datei", ""));
                file.add_child(tmp);
                
                file.add_child(new MenuItem("Zurücksetzen", ""));
                file.add_child(new MenuItem("Drucken...", ""));
                file.add_child(new MenuItem("Druckvorschau", ""));
            
            root.add_child(file);
            
            var edit = new MenuItem("Bearbeiten", "");
                edit.add_child(new MenuItem("Rückgängig", ""));
                edit.add_child(new MenuItem("Wiederholen", ""));
                edit.add_child(new MenuItem("Ausschneiden", ""));
                edit.add_child(new MenuItem("Kopieren", ""));
                edit.add_child(new MenuItem("Einfügen", ""));
                edit.add_child(new MenuItem("Einstellungen", ""));
            root.add_child(edit);
            
            var view = new MenuItem("Ansicht", "");
                view.add_child(new MenuItem("Vollbild", ""));
                
                tmp = new MenuItem("Hervorhebungsmodus", "");
                
                    tmp.add_child(new MenuItem("Reiner Text", ""));
                    
                    var tmp2 = new MenuItem("Quellcode", "");
                        tmp2.add_child(new MenuItem("HTML", ""));
                        tmp2.add_child(new MenuItem("C++", ""));
                        tmp2.add_child(new MenuItem("Vala", ""));
                        tmp2.add_child(new MenuItem("Python", ""));
                        tmp2.add_child(new MenuItem("Ruby", ""));
                        tmp2.add_child(new MenuItem("Shell", ""));
                    tmp.add_child(tmp2);
                    
                    tmp2 = new MenuItem("Auszeichnung", "");
                        tmp2.add_child(new MenuItem("BibTex", ""));
                        tmp2.add_child(new MenuItem("Latex", ""));
                        tmp2.add_child(new MenuItem("XSLT", ""));
                        tmp2.add_child(new MenuItem("XML", ""));
                    tmp.add_child(tmp2);
                
                    tmp2 = new MenuItem("Wissenschaftlich", "");
                        tmp2.add_child(new MenuItem("MatLab", ""));
                        tmp2.add_child(new MenuItem("GAP", ""));
                        tmp2.add_child(new MenuItem("Octave", ""));
                        tmp2.add_child(new MenuItem("R", ""));
                    tmp.add_child(tmp2);
                    
                view.add_child(tmp);
                
            root.add_child(view);
            
            var search = new MenuItem("Suchen", "");
                search.add_child(new MenuItem("Suchen...", ""));
                search.add_child(new MenuItem("Ersetzen...", ""));
                search.add_child(new MenuItem("Gehe zu Zeile...", ""));
            root.add_child(search);
            
            var tools = new MenuItem("Werkzeuge", "");
                tools.add_child(new MenuItem("Rechtschreibung prüfen...", ""));
                tools.add_child(new MenuItem("Rechtschreibfehler hervorheben", ""));
                
                tmp = new MenuItem("Sprache festlegen", "");
                    tmp.add_child(new MenuItem("Deutsch", ""));
                    tmp.add_child(new MenuItem("Englisch (Britisch)", ""));
                    tmp.add_child(new MenuItem("Englisch (Amerikanisch)", ""));
                tools.add_child(tmp);
                
                tools.add_child(new MenuItem("Statistik zum Dokument...", ""));
            root.add_child(tools);
            
            var project = new MenuItem("Projekt", "");
                project.add_child(new MenuItem("Erstellen", ""));
                project.add_child(new MenuItem("Säubern", ""));
                project.add_child(new MenuItem("Ausführen", ""));
                project.add_child(new MenuItem("Einstellungen", ""));
            root.add_child(project);
            
            var documents = new MenuItem("Dokumente", "");
                documents.add_child(new MenuItem("Alle speichern", ""));
                documents.add_child(new MenuItem("Alle schließen", ""));
            root.add_child(documents);
            
            var help = new MenuItem("Hilfe", "");
                help.add_child(new MenuItem("Inhalte...", ""));
                help.add_child(new MenuItem("Online Hilfe erhalten...", ""));
                help.add_child(new MenuItem("Diese Anwendung Übersetzen...", ""));
                help.add_child(new MenuItem("Info...", ""));
            root.add_child(help);
        
        root.set_state(MenuItem.State.ACTIVE);
        root.realize();
    }
}

}
