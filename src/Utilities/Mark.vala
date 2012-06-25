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

public class Mark : GLib.Object {

    public signal void on_direction_changed();
    public signal void on_long_stroke();
    public signal void on_paused();
    public signal void on_stutter();
    
    private const int SAMPLING_DISTANCE = 5;
    
    private const double THRESHOLD_ANGLE = GLib.Math.PI/30.0;
    
    private Vector[] stroke;
    private uint last_motion_time = 0;
    
    public Mark() {
        reset();
    }
    
    public void reset() {
        stroke = {};
    }
    
    public void draw(Cairo.Context ctx) {
        ctx.set_source_rgb(1, 0, 0);
        
        for(int i=0; i<stroke.length;++i) {
            ctx.arc(stroke[i].x, stroke[i].y, 10, 0, GLib.Math.PI*2);
            ctx.fill();
        }
    }

    public void update(Vector mouse) {
    

        if (stroke.length == 0) {
            stroke += mouse;
            last_motion_time = get_now();
            return;
        } 
        
        double dist = Vector.distance(mouse, stroke[stroke.length-1]);

        if (dist > SAMPLING_DISTANCE) {
            int insert_samples = (int)(dist/SAMPLING_DISTANCE);
            var last = stroke[stroke.length-1];

            for (int i=1; i<=dist/SAMPLING_DISTANCE; ++i) {
                double t = (double)i/insert_samples;
                stroke += new Vector(t*mouse.x + (1-t)*last.x, t*mouse.y + (1-t)*last.y);
            }
            last_motion_time = get_now();
        }
            
        if (stroke.length >= 2) {
        
            double angle = Vector.angle(get_stroke_direction(), Vector.direction(stroke[0], mouse));
            
            if (angle > THRESHOLD_ANGLE) {
                on_direction_changed();        
                reset();
                return;
            }
        }
        
        if (get_now() - last_motion_time > 400) {
            on_paused();    
            reset();
            return;
        }
        
        

    }
    
    private uint get_now() {
        var now = new DateTime.now_local();
        return now.get_microsecond()/1000 + now.get_second()*1000;
    }
    
    private Vector get_stroke_direction() {
        Vector result = new Vector(0, 0);
        
        if (stroke.length > 1) {
            for(int i=1; i<stroke.length;++i) {
                result.x += stroke[i].x / (stroke.length-1);
                result.y += stroke[i].y / (stroke.length-1);
            }
        }
        
        return Vector.direction(stroke[0], result);
    }

}
