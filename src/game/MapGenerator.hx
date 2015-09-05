package game;

class MapTest {
    static public function main() {
        var w = 64;
        var h = 64;
        var low_val = 2;
        var high_val = 9;
        var num_deposits = 7;
        var map = Map.gen(w, h, low_val, high_val, num_deposits);
        if(map[0][0] == -1)
            return -1;
        Map.print(map, w, h);
        return 0;
    }
}
class Map {
    //Generates a random map of width w and height h
    //Places randomly sized deposits with random
    //resource values at random places.
    //w, h = map dimensions
    //low_val, high_val = value of deposit
    //num_deposits = number of deposits to place.
    static public function gen(w:Int, h:Int, low_val:Int,
                               high_val:Int, num_deposits:Int) {
        var map = Array2D.create(w, h);
        var valid = Array2D.create(w, h);
        for(y in 0...h){
            for(x in 0...w){
                //First, implement starting positions
                //How much of the map is starting space?
                var wcorner = 1/16*w;
                var hcorner = 1/4*h;

                if((x >= 0 && x <= wcorner) || (x >= w-wcorner && x < w)){
                    if((y >= 0 && y <= hcorner) || (y >= h-hcorner && y < h)){
                        map[y][x] = 0;

                    }
                    else{
                        map[y][x] = 1;
                    }
                }
                else{
                    map[y][x] = 1;
                }
            }

        }
        //Generate deposits
        for(i in 0...num_deposits){
                var good = 0;
                var tries = w*h/2;
                while(good == 0){
                    var x = Std.random(w);
                    var y = Std.random(h);
                    var value = low_val + Std.random(high_val - low_val);
                    //Check if there is room for the deposit.
                    //Try a number of times before giving up!
                    if(check_dir(map, x, y, value, value, w, h) == 1){
                        place_deposit(map, x, y, value);
                        good = 1;
                        //trace('placed!');
                    }
                    else{
                        tries = tries -1;
                        if(tries == 0){
                            trace("Error: Can't place deposit!");
                            map[0][0] = -1;
                            return map;
                        }
                    }
                }

        }
        return map;
    }


    //Places a randomly sized deposit with a given
    //resource value at x,y coordinate
    //map is map
    //x,y = placement location
    //value = value of deposit
    static private function place_deposit(map:Array<Array<Int>>, x:Int, y:Int,
                                          value:Int) {
        //place the deposit core
        map[y][x] = 1+value;

        var cur_val = value;
        var square_size = 1;
        //Build squares around the core, diminishing in value by 1 for each square
        //Stop when you reach dirt.
        while(cur_val > 1){
            for(j in y-square_size...y+square_size+1){
                for(i in x-square_size...x+square_size+1){
                    if(map[j][i] == 1){
                        map[j][i] = cur_val;
                    }
                }
            }
            // trace(cur_val);
            // trace("\n");
            // trace(square_size);
            // trace("\n\n");
            cur_val = cur_val -1;
            square_size = square_size + 1;

        }
        erode_corners(map, x, y, value);
    }
    //erodes the corners of the square to make it "ALIVE!!!"
    //map is map
    //x,y = placement location
    //value = value of deposit
    static private function erode_corners(map:Array<Array<Int>>, x:Int, y:Int,
                                          value:Int) {
        //Number of squares to erode.
        //var erode_cnt = 1 + Std.random(value*2-1);
        var erode_cnt = Std.int(value * value / 2);
        // var erode_cnt = 1 << (value) - 2*value;
        // if(erode_cnt < 0)
        //     erode_cnt = value;
        // else if (erode_cnt >= value*value)
        //     erode_cnt = value*value - 4*value;
        //We want to go to the 1 value after the deposit.
        var dx = value - 1;
        var dy = value - 1;
        //Keep track of what was modified.  You can only erode pieces adjacent
        //to already eroded squares.  Dirt is eroded by default.
        var mod_array = Array2D.create(y+dy+1, y+dy+1);
        for(y1 in 0...y+dy+1){
            for(x1 in 0...x+dx+1){
                if(map[y1][x1] == 1){
                    mod_array[y1][x1] = 1;
                }
            }
        }
        for(i in 0...erode_cnt){
            var good = 0;
            while(good == 0){
                var e_x = x-dx + Std.random(2*dx);
                var e_y = y-dy + Std.random(2*dy);
                var erode_found = 0;
                /*for(y1 in e_y-1...e_y+2){
                    for(x1 in e_x-1...e_x+2){
                        if(mod_array[y1][x1] >= 1){
                            erode_found = erode_found1;

                        }
                    }
                }
                if(erode_found == 1 && map[e_y][e_x] != 1){
                    map[e_y][e_x] = map[e_y][e_x] - 1;
                    mod_array[e_y][e_x] = 1;
                    good = 1;
                }*/
                if(map[e_y][e_x] != 1){
                    map[e_y][e_x] = map[e_y][e_x] - Std.random(4) - 1;
                    if(map[e_y][e_x] < 1)
                        map[e_y][e_x] = 1;
                    mod_array[e_y][e_x] = 1;
                    good = 1;
                }
            }
        }
    }

    //Checks x1 spaces in the x direction around a point,
    //y1 spaces in the y direction.  Returns zero if any
    //squares are out of bounds or zero.
    //map is map
    //x,y are the coordinates of the point;
    //dx,dy are the amounts to check in either direction
    //w,h are the size of the array
    static private function check_dir(map:Array<Array<Int>>, x:Int, y:Int,
                                      dx:Int, dy:Int, w:Int, h:Int) {
        for(y1 in y-dy...y+dy+1){
            if(y1 < 0 || y1 >= h){
                return 0;
            }
            for(x1 in x-dx...x+dx+1){
                if(x1 < 0 || x1 >= w){
                    return 0;
                }
                if(map[y1][x1] != 1)
                    return 0;
            }
        }
        return 1;
    }


    static public function print(map:Array<Array<Int>>, w:Int, h:Int) {
        var str:String = "";
        for(y in 0...h)
        {
            str = str + "\n";
            for(x in 0...w)
            {

                str = str + map[y][x];
            }
        }
        trace(str);
    }
}
class Array2D
{
    public static function create(w:Int, h:Int)
    {
        var a = [];
        for (y in 0...h)
        {
            a[y] = [];
            for (x in 0...w)
            {
                a[y][x] = 0;
            }
        }
        return a;
    }
}