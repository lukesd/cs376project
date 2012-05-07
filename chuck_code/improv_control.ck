// improv_control.ck

// global vars
1 => int g_print_osc_debug;
8010 => int player1_inport;              // port for receiving osc from player 1
8012 => int proc_outport;                // port for sending osc messages to Processing
//"10.32.142.48" => string proc_client;       // IP address for Processing
"localhost" => string proc_client;       // IP address for Processing

// setup OSC input from iphones
OscRecv osc_in_1;
player1_inport => osc_in_1.port;                   // port for receiving osc from player 1
osc_in_1.listen();
osc_in_1.event("/3/xy", "f f") @=> OscEvent osc_in_event_1;

// setup OSC out to processing
OscSend osc_proc_out;
osc_proc_out.setHost(proc_client, proc_outport);

// global variables for game and music calculation
[60,62,63,65,67,69,70] @=> int g_scale[];    // the scale that notes are played on
g_scale.cap() => int g_num_notes;
0.0 => float g_vert_min;                   // minimum vertical input value from iphone
1.0 => float g_vert_max;                   // maximum vertical input value from iphone

// calculate note midi value from vertical position
fun int calcNote(float x)
{
    (g_vert_max - g_vert_min)/g_num_notes => float step_size;
    (Math.floor( (x - g_vert_min) / step_size ))$int => int scale_deg;
    if (scale_deg >= g_num_notes ) {
        g_num_notes - 1 => scale_deg;
    }
        
    g_scale[scale_deg] => int note;   
    return note;
}

<<<"test", calcNote(0.9) >>>;

// stuff for synthesizing sound
SawOsc osc1 => LPF flt1 => ADSR env1 => Pan2 panr1 => dac;
env1.keyOff();
env1.set(10::ms, 80::ms, 0.5, 300::ms);
2.0 => flt1.Q;
    
    
fun void playsynth1(int note, float parm1)    
{    
    Std.mtof(note) => osc1.freq;
    200.0 + 15000.0*parm1 => flt1.freq;
    env1.keyOn();
    50::ms => now;
    env1.keyOff();
}



// spork listeners --------------------------------------------
spork ~ event1Listener();

// make time --------------------------------------------------
while( 1 )
{
    1::second => now;
}


// processes for listening for osc events ---------------------
fun void event1Listener()
{
    while( 1 )
    {
        osc_in_event_1 => now;
        while( osc_in_event_1.nextMsg() )
        {
            osc_in_event_1.getFloat() => float x_in;
            osc_in_event_1.getFloat() => float y_procc_in;
            g_vert_max - y_procc_in => float y_synth_in;
            
            calcNote(y_synth_in) => int note;
            
            if( g_print_osc_debug )
            {
                <<< " in event 1: ", x_in, y_synth_in, note >>>;
            }
            // play note
            spork ~playsynth1(note, x_in);
            
            // send message to processing
            sendEventToProcc(1, x_in, y_procc_in);
        }
    }
}



// send new note events to processing
fun void sendEventToProcc(int player, float x, float y)
{
    osc_proc_out.startMsg("/new_note", "i f f");
    player => osc_proc_out.addInt;
    x => osc_proc_out.addFloat;
    y => osc_proc_out.addFloat;
}




