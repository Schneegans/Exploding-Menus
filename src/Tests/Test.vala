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

public class Test : GLib.Object {

    private static InstructionWindow instruction;
    private static BindingManager bindings = null;
    
    private static bool ready = false;
    private static int state = 0;

    public static void init() {
        instruction = new InstructionWindow();
        
        bindings = new BindingManager();
        bindings.bind(new Trigger.from_string("space"), "buh");
        
        bindings.on_press.connect((id) => {
            if (ready) {
                ++state;
                next_stage();
            }
        });
        
        instruction.open();
        
        MenuManager.init("real_circular");
        
        next_stage();
    }
    
    private static async void next_stage() {
        switch (state) {
            case 0: 
                instruction.set_text("Willkommen zum ultimativen <b>Test</b>!" + continue_hint());
                break;
                
            case 1: 
                instruction.set_text("Bitte fünfmal Menü aufmachen!");
                break;
                
            case 2:
                instruction.set_text("Bitte fünfmal Menü aufmachen!" + continue_hint());
                break;
        }
        
        ready = true;
    }
    
    private static string continue_hint() {
        return "\n\n<span size='15000' style='italic'>Weiter mit Leertaste...</span>";
    }
}
