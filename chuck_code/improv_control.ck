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
//    osc_in[i].event("/3/xy", "f f") @=> osc_in_event[i];
//    osc_in[i].event("/3/xy", "f f") @=> osc_in_event[i];
//    osc_in[i].event("/1/multixy3/1", "f f") @=> osc_in_event[i];
//    osc_in[i].event("/1/multixy3/1", "f f") @=> osc_in_event[i];
//    osc_in[i].event("/xy1/xy1", "f f") @=> osc_in_event[i];
    osc_in[i].event("/touch", "f f") @=> osc_in_event[i];

}

// setup OSC out to processing
OscSend osc_proc_out;
osc_proc_out.setHost(proc_client, proc_outport);

// setup MIDI
// setup midi
0 => int midi_device;                         // number of the device to open (see: chuck --probe)
MidiIn midiIn;
MidiMsg midi_msg;
if( !midiIn.open( midi_device ) )
    <<< "WARNING no MIDI device found with number ", midi_device>>>;
else
    <<< "MIDI device:", midiIn.num(), " -> ", midiIn.name() >>>;

// global variables for game and music calculation
[36, 38, 41, 43, 45, 48, 50, 53, 55, 57, 60, 62, 65, 67, 69, 72, 74, 77, 79, 81] @=> int g_scale[];    // 2 8ve of pentatonic the scale that notes are played on
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
LPF lp_flt[g_num_players];
HPF hp_flt[g_num_players];
ADSR env[g_num_players];
Pan2 panr[g_num_players];
0.8 => panr[0].pan;
-0.8 => panr[1].pan;

SawOsc osc1 => lp_flt[0] => hp_flt[0] => env[0] => panr[0] => dac;
PulseOsc osc2 => lp_flt[1] => hp_flt[1] => env[1] => panr[1] => dac;
JCRev rvrb;
env[0] => Gain wet_gain;
env[1] => wet_gain;
wet_gain => rvrb => dac;
0.15 => wet_gain.gain;

for (0 => int i; i < g_num_players; i++) {
    env[i].keyOff();
    env[i].set(5::ms, 30::ms, 0.3, 300::ms);
    2.0 => lp_flt[i].Q;
    1.5 => hp_flt[i].Q;
}
    
// function for playing notes   
fun void playsynth(int player, int note, float parm1)    
{   
    if (player == 0) 
        Std.mtof(note) => osc1.freq;
    else
        Std.mtof(note) => osc2.freq;
    
    // cacl filter params
    //150.0 + 10000.0*parm1 => flt[player].freq;
    0.3 => float thr1;
    0.6 => float thr2;
    Std.mtof(note)*1.5 => float lo_base;
    Std.mtof(note)*0.2 => float hi_base;
    if (parm1 < thr1 ) {
        hi_base => hp_flt[player].freq;
        lo_base + 10000.0*parm1/thr2 => lp_flt[player].freq; 
    }
    else if (parm1 < thr2) {
        hi_base + 3000.0*(parm1-thr1)/(1.0 - thr1) => hp_flt[player].freq;
        lo_base + 10000.0*parm1/thr2 => lp_flt[player].freq; 
    }
    else {
        hi_base + 3000.0*(parm1-thr1)/(1.0 - thr1) => hp_flt[player].freq;
        lo_base + 10000.0 => lp_flt[player].freq; 
    }
    
    <<< "filts ", hp_flt[player].freq(), lp_flt[player].freq() >>>;  // DEBUG
    
    env[player].keyOn();
    50::ms => now;
    env[player].keyOff();
}

// spork listeners --------------------------------------------
spork ~ eventListener(0);
spork ~ eventListener(1);
spork ~ midiCtl();

// make time --------------------------------------------------
while( 1 )
{
    1::second => now;
}


// processes for listening for osc events ---------------------
fun void eventListener(int player)
{
    player => int pl;
    while( 1 )
    {
        osc_in_event[pl] => now;
        while( osc_in_event[pl].nextMsg() )
        {
            osc_in_event[pl].getFloat() => float x_in;
            osc_in_event[pl].getFloat() => float y_procc_in;
            g_vert_max - y_procc_in => float y_synth_in;
            
            calcNote(y_synth_in) => int note;
            
            if( g_print_osc_debug )
            {
                <<< " in event from player: ", pl, x_in, y_synth_in, note >>>;
            }
            // play note
            spork ~playsynth(pl, note, x_in);
            
            // send message to processing
            sendEventToProcc(pl, x_in, y_procc_in);
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

// process for reading midi-control
float g_midi_in_x;
fun void midiCtl()
{
    while( true )
    {
        // wait on the event 'midiIn'
        midiIn => now;       
        // get the message(s)
        while( midiIn.recv(midi_msg) )
        {
            if (midi_msg.data1 == 176 && midi_msg.data2 == 13) {
                midi_msg.data3 / 127.0 => g_midi_in_x;
                calcNote(midi_msg.data3 / 127.0) => int note;
            }
            else if (midi_msg.data1 == 176 && midi_msg.data2 == 14) {
                midi_msg.data3 / 127.0 => float midi_in_y;
                calcNote(midi_in_y) => int note;
                spork ~playsynth(0, note, g_midi_in_x);
            }
            else {
                <<< "midi in: ", midi_msg.data1, midi_msg.data2, midi_msg.data3 >>>; 
            }
        }
    }
}