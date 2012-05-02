// improv_control.ck

// global vars
1 => int g_print_osc_debug;

// setup OSC input
OscRecv osc_in_1;
8000 => osc_in_1.port;
osc_in_1.listen();
osc_in_1.event("/3/xy", "f f") @=> OscEvent osc_in_event_1;

// change proccessing recieve port
// change processing IP address

// spork listeners --------------------------------------------
spork ~ event_1_listener();

// make time --------------------------------------------------
while( 1 )
{
    1::second => now;
}


// processes for listening for osc events ---------------------
fun void event_1_listener()
{
    while( 1 )
    {
        osc_in_event_1 => now;
        while( osc_in_event_1.nextMsg() )
        {
            osc_in_event_1.getFloat() => float x_in;
            osc_in_event_1.getFloat() => float y_in;
            
            if( g_print_osc_debug )
            {
                <<< " in event 1: ", x_in, y_in >>>;
            }
        }
    }
}




