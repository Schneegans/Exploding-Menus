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

public class Mark : GLib.Object {

    public signal void on_direction_changed();
    public signal void on_long_stroke();
    public signal void on_paused();
    public signal void on_stutter();
    
    private const int SAMPLING_DISTANCE = 20;
    
    private const double MIN_THRESHOLD_ANGLE = 2.0*GLib.Math.PI/18.0;
    private const double MAX_THRESHOLD_ANGLE = GLib.Math.PI - 2.0*GLib.Math.PI/18.0;
    
    private Vector mark_start = null;
    private Vector sample_start = null;
    private Vector last_sample_start = null;
    private uint last_motion_time = 0;
    
    public Mark() {}
    
    public void reset() {
        mark_start = null;
        sample_start = null;
        last_sample_start = null;
    }

    public void update(Vector mouse) {
        if (mark_start == null) {
            mark_start = mouse.copy();
            sample_start = mouse.copy();
            last_motion_time = get_now();
            return;
        } 
        
        if (Vector.distance(mouse, sample_start) > SAMPLING_DISTANCE) {
            
            if (last_sample_start != null) {
                double angle = Vector.angle(Vector.direction(last_sample_start, sample_start), Vector.direction(sample_start, mouse));
                
                if (angle < MAX_THRESHOLD_ANGLE && angle > MIN_THRESHOLD_ANGLE) {
                    on_direction_changed();        
                    reset();
                    return;
                }
            }
        
            last_sample_start = sample_start;
            sample_start = mouse.copy();
            last_motion_time = get_now();
        }
        
        if (get_now() - last_motion_time > 500) {
            on_paused();    
            reset();
            return;
        }
        
    }
    
    private uint get_now() {
        var now = new DateTime.now_local();
        return now.get_microsecond()/1000 + now.get_second()*1000;
    }

}

}
