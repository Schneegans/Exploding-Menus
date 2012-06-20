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

    public const int LABEL_HEIGHT = 36;
    
    public const int ACTIVE_ITEM_RADIUS = 35;
    
    public const int SELECTABLE_PIE_RADIUS = 55;
    public const int SELECTABLE_ITEM_RADIUS = 18;
    public const int SELECTABLE_ITEM_RADIUS_SMALL = 12;
    
    public const int PREVIEW_PIE_RADIUS = 16;
    public const int PREVIEW_ITEM_RADIUS = 5;
    
    public const int TRAIL_ITEM_RADIUS = SELECTABLE_ITEM_RADIUS_SMALL;
    public const int TRAIL_PREVIEW_PIE_RADIUS = PREVIEW_PIE_RADIUS;
    public const int TRAIL_PREVIEW_ITEM_RADIUS = PREVIEW_ITEM_RADIUS;

    public const int SLICE_HINT_RADIUS = 250;
    public const double SLICE_HINT_GAP = 0.0;
    public const double ANIMATION_TIME = 0.2;
    public const double FADE_OUT_TIME = 0.5;

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
    
    private Vector center;
    private bool first_release;
    
    public Menu() {
        window = new InvisibleWindow();
        center = new Vector(0, 0);
        
        setup_menu();
        
        window.on_draw.connect((ctx, frame_time) => {
            root.draw(ctx, window, MenuItem.Direction.S, false, frame_time);
        });
        
        window.on_press.connect((button) => {
            first_release = false;
        });
        
        window.on_release.connect((button) => {
            if (!first_release) {
                if (button == 3 || !root.activate(window.get_mouse_pos())) {
                    
                    var activated = root.got_selected();
                    
                    move(root.get_move_offset());
                    
                    root.update_position(center, MenuItem.Direction.S, ANIMATION_TIME);
                    root.close(activated);
                    
                    if (activated) {
                        GLib.Timeout.add((uint)((FADE_OUT_TIME+ANIMATION_TIME)*1000), () => {
                            window.hide();
                            return false;
                        });
                    } else {
                        GLib.Timeout.add((uint)((ANIMATION_TIME)*1000), () => {
                            window.hide();
                            return false;
                        });
                    }
                } else {
                    root.update_position(center, MenuItem.Direction.S, ANIMATION_TIME);
                }
            }
        });
        
        window.on_scroll.connect((up) => {
           
        });
    }
    
    public void show() {
        setup_menu();
        
        first_release = true;
        
        window.open();
        center = window.get_mouse_pos();
        root.set_state(MenuItem.State.ACTIVE);
        root.update_position(center, MenuItem.Direction.S, 0.0);
    }
    
    private void move(Vector s) {
        center.x += s.x;
        center.y += s.y;
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
                    tmp.add_child(new MenuItem("HTML", ""));
                    tmp.add_child(new MenuItem("C++", ""));
                    tmp.add_child(new MenuItem("Vala", ""));
                    tmp.add_child(new MenuItem("Python", ""));
                    tmp.add_child(new MenuItem("Ruby", ""));
                    tmp.add_child(new MenuItem("Shell", ""));
                view.add_child(tmp);
                
            root.add_child(view);
            
            var search = new MenuItem("Suchen", "");
            root.add_child(search);
            
            var tools = new MenuItem("Werkzeuge", "");
            root.add_child(tools);
            
            var project = new MenuItem("Projekt", "");
            root.add_child(project);
            
            var documents = new MenuItem("Dokumente", "");
            root.add_child(documents);
            
            var help = new MenuItem("Hilfe", "");
            root.add_child(help);
        
    }
}

}
