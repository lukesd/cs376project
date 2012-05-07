// improv_control.ck

// global vars
1 => int g_print_osc_debug;
2 => int g_num_players;
int player_inport[g_num_players];
8010 => player_inport[0];                // port for receiving osc from player 1
8011 => player_inport[1];                // port for receiving osc from player 2
8012 => int proc_outport;                  // port for sending osc messages to Processing
//"10.32.142.48" => string proc_client;       // IP address for Processing
"localhost" => string proc_client;       // IP address for Processing

// setup OSC input from iphones
OscRecv osc_in[g_num_players];
OscEvent osc_in_event[g_num_players];
for (0 => int i; i < g_num_players; i++) {
    player_inport[i] => osc_in[i].port;                   // port for receiving osc from player
    osc_in[i].listen();
    osc_in[i].event("/3/xy", "f f") @=> osc_in_event[i];
}

// setup OSC out to processing
OscSend osc_proc_out;
osc_proc_out.setHost(proc_client, proc_outport);

// global variables for game and music calculation
// [60,62,63,65,67,69,70] @=> int g_scale[];    // the scale that notes are played on
[48, 50, 53, 55, 57, 60, 62, 65, 67, 69] @=> int g_scale[];    // 2 8ve of penta-tonic the scale that notes are played on
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

// stuff for synthesizing sound ---------------------------------
LPF flt[g_num_players];
ADSR env[g_num_players];
Pan2 panr[g_num_players];
-0.8 => panr[0].pan;
0.8 => panr[1].pan;

SawOsc osc1 => flt[0] => env[0] => panr[0] => dac;
PulseOsc osc2 => flt[1] => env[1] => panr[1] => dac;

for (0 => int i; i < g_num_players; i++) {
    env[i].keyOff();
    env[i].set(10::ms, 80::ms, 0.5, 300::ms);
    2.0 => flt[i].Q;
}
    
// function for playing notes   
fun void playsynth(int player, int note, float parm1)    
{   
    if (player == 0) 
        Std.mtof(note) => osc1.freq;
    else
        Std.mtof(note) => osc2.freq;
    
    200.0 + 15000.0*parm1 => flt[player].freq;
    env[player].keyOn();
    50::ms => now;
    env[player].keyOff();
}

// spork listeners --------------------------------------------
spork ~ eventListener(0);
spork ~ eventListener(1);

// make time --------------------------------------------------
while( 1 )
{
    1::second => now;
}


// processes for listening for osc events ---------------------
fun void eventListener(int player)
{
    while( 1 )
    {
        osc_in_event[player] => now;
        while( osc_in_event[player].nextMsg() )
        {
            osc_in_event[player].getFloat() => float x_in;
            osc_in_event[player].getFloat() => float y_procc_in;
            g_vert_max - y_procc_in => float y_synth_in;
            
            calcNote(y_synth_in) => int note;
            
            if( g_print_osc_debug )
            {
                <<< " in event from player: ", player, x_in, y_synth_in, note >>>;
            }
            // play note
            spork ~playsynth(player, note, x_in);
            
            // send message to processing
            sendEventToProcc(player, x_in, y_procc_in);
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




