// improv_control.ck

// logging file stuff ----------------------------------------------------------
"../logs/out" => string base_filename;                    // default file name
if( me.args() > 0 ) me.arg(0) => base_filename;   // look at command line for new file name

string file_names[4];
FileIO fout[3];
WvOut wav_out; // for recording audio out

// open files for writing
0 => int g_file_num;
fun void openFiles()
{
    g_file_num => int num;
    base_filename + "_plyr1_" + num + ".txt" => file_names[0];
    base_filename + "_plyr2_" + num + ".txt" => file_names[1];
    base_filename + "_bnds_" + num + ".txt" => file_names[2];
    base_filename + "_audio_" + num + ".wav" => file_names[3];
    for (0 => int i; i < 3; i++) {
        fout[i].open( file_names[i], FileIO.WRITE );
        if( !fout[i].good() ) {
            cherr <= "can't open file for writing " <= file_names[i] <= IO.newline();
            me.exit();
        }
    }
    
    file_names[3] => wav_out.wavFilename;
    dac => wav_out => blackhole;
    
    g_file_num++;
}

fun void closeFiles()
{
    for (0 => int i; i < 3; i++) {
        fout[i].close();
    }
    wav_out.closeFile(file_names[3]);
    dac =< wav_out =< blackhole;
}



// networking stuff  -----------------------------------------------------------
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
    //osc_in[i].event("/3/xy", "f f") @=> osc_in_event[i];   // use this one for touchOSC "simple"
    osc_in[i].event("/touch", "f f") @=> osc_in_event[i];    // use this one for touchOSC custom ipad or iphone
}

// setup OSC out to processing
OscSend osc_proc_out;
osc_proc_out.setHost(proc_client, proc_outport);

// stuff for the sequencer -------------------------------------------------------
100 => int bpm;
4 => int ticks_per_beat;   // 1 tick = 16th note
4 => int beats_per_bar;    // 4/4 time
4 => int bars_per_pattern; // 4-bar loop

// event for ticks
class tickEvent extends Event
{
    int tick_num;
}

60::second * (1.0/bpm) * (1.0/ticks_per_beat) => dur tick_t;  // seconds per tick = sec/min * min/beat * beat/tick
ticks_per_beat * beats_per_bar * bars_per_pattern => int g_pattern_len; // ticks per pattern 

// parameter boundaries
[0.0, 0.0] @=> float g_lower_p[];   // pitch
[1.0, 1.0] @=> float g_upper_p[];
[0.0, 0.0] @=> float g_lower_t[];   // timbre
[1.0, 1.0] @=> float g_upper_t[];
[0.0, 0.0] @=> float g_lower_d[];   // density
[1.0, 1.0] @=> float g_upper_d[];

// the program1
// for playing
// 1     2    3    4   5    6     7   8     1     2    3    4   5    6     7   8
[[0.0, 0.6, 0.5, 0.0, 0.1, 0.0, 0.0, 0.0],[0.0, 0.0, 0.0, 0.0, 0.55, 0.0, 0.7, 0.0]] @=> float g_prg_lower_t[][];   // pitch
[[1.0, 1.0, 1.0, 1.0, 0.45, 1.0, 0.4, 1.0],[0.0, 0.0, 0.5, 1.0, 0.9, 1.0, 1.0, 1.0]] @=> float g_prg_upper_t[][];
[[0.0, 0.0, 0.5, 0.0, 0.4, 0.2, 0.0, 0.2],[0.0, 0.0, 0.0, 0.75, 0.2, 0.6, 0.0, 0.6]] @=> float g_prg_lower_p[][];
[[0.4, 1.0, 1.0, 0.25, 0.6, 0.5, 0.25, 0.8],[0.0, 0.0, 0.5, 1.0, 0.5, 0.8, 1.0, 1.0]] @=> float g_prg_upper_p[][];

// for demo 
//[[0.5, 0.0, 0.1, 0.0, 0.0, 0.0, 0.0, 0.6],[0.0, 0.0, 0.55, 0.0, 0.7, 0.0, 0.0, 0.0]] @=> float g_prg_lower_t[][];   // pitch
//[[1.0, 1.0, 0.45, 1.0, 0.4, 1.0, 1.0, 1.0],[0.5, 1.0, 0.9, 1.0, 1.0, 1.0, 0.0, 0.0]] @=> float g_prg_upper_t[][];
//[[0.5, 0.0, 0.4, 0.2, 0.0, 0.2, 0.0, 0.0],[0.0, 0.75, 0.2, 0.6, 0.0, 0.6, 0.0, 0.0]] @=> float g_prg_lower_p[][];
//[[1.0, 0.25, 0.6, 0.5, 0.25, 0.8, 0.4, 1.0],[0.5, 1.0, 0.5, 0.8, 1.0, 1.0, 0.0, 0.0]] @=> float g_prg_upper_p[][];


[[0.4, 0.2, 0.5, 0.0, 0.5, 0.3, 0.0, 0.0],[0.2, 0.2, 0.5, 0.5, 0.0, 0.3, 0.0, 0.0]] @=> float g_prg_lower_d[][];   // density
[[0.8, 0.8, 1.0, 0.5, 1.0, 1.0, 0.6, 1.0],[0.8, 0.8, 1.0, 1.0, 0.5, 1.0, 0.6, 1.0]] @=> float g_prg_upper_d[][];
[[1, 1, 1, 1, 1, 1, 1, 1],[0, 0, 1, 1, 1, 1, 1, 0]] @=> int g_prg_box_on[][];
[[60, 54, 48, 44, 36, 24, 48, 58],[60, 54, 48, 44, 24, 36, 48, 58]] @=> int g_prg_notes[][]; // number of notes to play

[64, 64] @=> int g_notes_left[];


8 => int g_game_len;      // number of program steps in a game
0 => int g_current_prg;   // current location in game
-1 => int g_chord_ct;     // number of half-note chords we've played
1 => int g_prev_chord;    // chord number of previou chord played
    
[[0.0, 1.0, 0.0, 1.0],[0.0, 1.0, 0.0, 1.0]] @=> float g_param_squares[][];  // boundaries for good notes [low pitch, high pitch, low timbre, high timbre]
[0, 0] @=> int g_square_on[];

0 => int g_seq_on;
0 => int g_tick_ct;
0 => int g_send_bounds;


fun void sendGameParams()
{
    if ( g_send_bounds ) {
        <<< "sending program ", g_current_prg >>>;  // DEBUG
        sendBoundsToProcc(0);
        sendBoundsToProcc(1);
    }   
    // send program counts left
    osc_proc_out.startMsg("/remaining", "i");
    g_game_len - g_current_prg => osc_proc_out.addInt;
}
    
// send bounds to Processing
fun void sendBoundsToProcc(int player)
{
    // set square for synthesis
    g_prg_lower_p[player][g_current_prg] => g_param_squares[player][0];
    g_prg_upper_p[player][g_current_prg] => g_param_squares[player][1];
    g_prg_lower_t[player][g_current_prg] => g_param_squares[player][2];
    g_prg_upper_t[player][g_current_prg] => g_param_squares[player][3];
    g_prg_box_on[player][g_current_prg] => g_square_on[player];
    
    // set number of notes left and send to procc
    g_prg_notes[player][g_current_prg] => g_notes_left[player];
    osc_proc_out.startMsg("/notes_remaining", "i i ");
    player => osc_proc_out.addInt;
    g_notes_left[player] => osc_proc_out.addInt;
    
    // send pitch and timbre to procc
    osc_proc_out.startMsg("/rect", "i f f f f");
    player => osc_proc_out.addInt;
    g_prg_lower_p[player][g_current_prg] => osc_proc_out.addFloat;
    g_prg_upper_p[player][g_current_prg] => osc_proc_out.addFloat;
    g_prg_lower_t[player][g_current_prg] => osc_proc_out.addFloat;
    g_prg_upper_t[player][g_current_prg] => osc_proc_out.addFloat;
    
    // send density
    //osc_proc_out.startMsg("/dens_limit", "i f f");
    //player => osc_proc_out.addInt;
    //g_prg_lower_d[player][g_current_prg] => osc_proc_out.addFloat;
    //g_prg_upper_d[player][g_current_prg] => osc_proc_out.addFloat;
    
    // send square on/off
    osc_proc_out.startMsg("/rect_on", "i i");
    player => osc_proc_out.addInt;
    g_prg_box_on[player][g_current_prg] => osc_proc_out.addInt;
    
    // write bounds to text file
    writeBounds();
}

// turn off all extra display elements
fun void sendAllBoundsOff()
{   
    // set squares to off
    0 => g_square_on[0];
    0 => g_square_on[1];
    
    // set number of notes left and send to procc
    osc_proc_out.startMsg("/notes_remaining", "i i ");
    0 => osc_proc_out.addInt;
    0 => osc_proc_out.addInt;
    osc_proc_out.startMsg("/notes_remaining", "i i ");
    1 => osc_proc_out.addInt;
    0 => osc_proc_out.addInt;
       
    // send squares off
    osc_proc_out.startMsg("/rect_on", "i i");
    0 => osc_proc_out.addInt;
    0 => osc_proc_out.addInt;
    osc_proc_out.startMsg("/rect_on", "i i");
    1 => osc_proc_out.addInt;
    0 => osc_proc_out.addInt;
}


tickEvent tick_e;
tickEvent half_note_e;

// audio processing for drums
SndBuf hh_buf => Gain hh_gain => dac; // hi hat
SndBuf kk_buf => Gain kk_gain => dac; // kick
SndBuf sn_buf => Gain sn_gain => dac; // snare
SndBuf cr_buf => Gain cr_gain => dac; // crash

"hihat.wav"  => hh_buf.read;
"kick.wav"   => kk_buf.read;
"snare.wav"  => sn_buf.read;
"crash.wav" => cr_buf.read;
Std.dbtorms(100 - 7) => hh_buf.gain;
Std.dbtorms(100 - 12) => kk_buf.gain;
Std.dbtorms(100 - 922) => sn_buf.gain;
Std.dbtorms(100 - 7) => cr_buf.gain;

hh_buf.samples() => hh_buf.pos;
kk_buf.samples() => kk_buf.pos;
sn_buf.samples() => sn_buf.pos;
cr_buf.samples() => cr_buf.pos;

[Std.dbtorms(100-12), Std.dbtorms(100-9), Std.dbtorms(100-6)] @=> float note_gains[];

// audio for accompaniment
5 => int g_num_chords;
SndBuf chords[g_num_chords];
"Gm.wav" => chords[0].read;
"Cm7.wav" => chords[1].read;
"Eb.wav" => chords[2].read;
"Dm7.wav" => chords[3].read;
"Gm-2.wav" => chords[4].read;
for (0 => int i; i < g_num_chords; i++ ) {
    chords[i].samples() => chords[i].pos;
    Std.dbtorms(100 - 28) => chords[i].gain;
    chords[i] => dac;
}

// process to play sequencer 
fun void startStopSequencer()
{
    if ( g_seq_on ) {     // stop the sequencer
        0 => g_seq_on;
        <<< "stopping sequencer ", "" >>>;
        0 => cr_buf.pos;                                            // play crash
        tick_t * 16 => now;                                         // wait a measure
        chords[g_prev_chord].samples() => chords[g_prev_chord].pos; // then stop chord
        0 => g_notes_left[0];                                       // turn off synths
        0 => g_notes_left[1];
        closeFiles();
        sendAllBoundsOff();
    }
    else {             // start the sequencer
        openFiles();
        if (!g_send_bounds ) {
            sendAllBoundsOff();
            [64, 64] @=> g_notes_left;
        }
        1 => g_seq_on;     
        0 => g_tick_ct;
        0 => g_current_prg;
        -1 => g_chord_ct;
        <<< "starting sequencer", "">>>;
        sendGameParams();
    }
}

fun void tickClock()
{
    while( 1 ) {
        tick_t => now;
        // g_tick_ct => tick_e.tick_num;
        g_tick_ct % g_pattern_len => tick_e.tick_num;
        tick_e.broadcast();
        g_tick_ct++;
        if ( !(g_tick_ct % g_pattern_len) ) {
            //if (g_tick_ct == g_pattern_len) {
            //0 => g_tick_ct;
            if( g_seq_on )
                sendNextProgram();
        }
    }
}
         

   
// the chord accompaniment
[0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 2, 3, 4, 4, 2, 3, 4, 4, 2, 3, 4, 4, 2, 3, 4, 4 ] @=> int g_chord_seq[];
fun void halfNoteHandler( tickEvent event )
{
    while( 1 ) {
        event => now;
        if (g_seq_on && ((event.tick_num % 8) == 0)) {        // if this is a half-note
            g_chord_ct++;
            playCurrentChord();
        }
    }
}
    
fun void playCurrentChord() {
    // stop previous chord:
    chords[g_prev_chord].samples() => chords[g_prev_chord].pos;
    // start new chord:
    g_chord_seq[ g_chord_ct % g_chord_seq.cap() ] => g_prev_chord;
    5000 => chords[g_prev_chord].pos;  // start partway in to avoid attack sound  
} 

fun void sendNextProgram()
{
    g_current_prg++;
    if (g_current_prg == g_game_len ) {
        startStopSequencer();
        <<< "game finished!", "" >>>;
    }
    else {
        sendGameParams();
    }
}

// send time progress
fun void sendTimeProgress( tickEvent event )
{
    while( 1 ) {
        event => now;
        if ( g_seq_on && ((event.tick_num % 4) == 0) ) {
            osc_proc_out.startMsg("/time", "f");
            (event.tick_num + 4)$float  / g_pattern_len => float temp; 
            temp => osc_proc_out.addFloat;
            //<<< "time progress", temp >>>;  // DEBUG
        }
    }
}

// note density stuff --------------------------------------------------------------
// fill a circular buffer with note times
// to calculate density: calculate number of events within a time window,
// where the window is the lesser of g_window_len or the range or times in the buffer
class densityQueue
{
    15 => static int queue_len;
    time buffer[queue_len];
    0 => int write_ptr;
    queue_len - 1 => int read_ptr;
    
    3::second => dur time_window;
    
    fun void addEvent( time note_time )
    {
        //<<< "DEBUG", "addEvent" >>>;  
        note_time => buffer[ write_ptr ];
        write_ptr--;
        read_ptr--;
        if (write_ptr < 0)
            queue_len - 1 => write_ptr;
        if (read_ptr < 0)
            queue_len - 1 => read_ptr;
    }
    
    fun float calcDensity( time current_time )
    {
        current_time - time_window => time early_time;
        write_ptr+1 => int temp_ptr;
        if (temp_ptr >= queue_len)
            0 => temp_ptr;
        buffer[ temp_ptr ] => time note_time;
        0 => int num_notes;
        0.0 => float density;
        
        while( (note_time > early_time) && (num_notes < queue_len-1 ) ) {
        //while( (num_notes < queue_len-1 ) ) {
            num_notes++;
            temp_ptr++;
            if (temp_ptr >= queue_len)
                0 => temp_ptr;
            buffer[ temp_ptr ] => note_time;
            //<<< "num note early", num_notes, note_time, early_time >>>;
        } 
        (current_time - note_time) / tick_t => float norm;
        num_notes / norm => density;
        if (density > 1.0)
            1.0 => density;
        return density;             
    } 
}

densityQueue que[g_num_players];
  
// stuff for instruments -----------------------------------------------------------
//[36, 38, 41, 43, 45, 48, 50, 53, 55, 57, 60, 62, 65, 67, 69, 72, 74, 77, 79, 81] @=> int g_scale[];    // 4 8ve of pentatonic the scale that notes are played on
[58-24, 60-24, 62-24, 65-24, 67-24, 58-12, 60-12, 62-12, 65-12, 67-12, 58, 60, 62, 65, 67, 58+12, 60+12, 62+12, 65+12, 67+12] @=> int g_scale[];    // 2 8ve of pentatonic the scale for 'I shot the sherriff'
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

// stuff for synthesizing instrument sound
LPF lp_flt[g_num_players];
HPF hp_flt[g_num_players];
ADSR env[g_num_players];
Pan2 panr[g_num_players];
Gain ring[g_num_players];
Noise noiz[g_num_players];
Step step[g_num_players];
Gain noiz_mix[g_num_players];

SawOsc osc1 => lp_flt[0] => hp_flt[0] => ring[0] => env[0] =>  panr[0] => dac;
PulseOsc osc2 => lp_flt[1] => hp_flt[1] => ring[1] => env[1] => panr[1] => dac;
noiz[0] => noiz_mix[0] => ring[0];
noiz[1] => noiz_mix[1] => ring[1];
step[0] => noiz_mix[0];
step[1] => noiz_mix[1];

JCRev rvrb;
env[0] => Gain wet_gain;
env[1] => wet_gain;
wet_gain => rvrb => dac;
// set params: 
0.1 => wet_gain.gain;
0.9 => panr[0].pan;
-0.9 => panr[1].pan;
Std.dbtorms(100 - 10)  => osc2.gain;
for (0 => int i; i < g_num_players; i++) {
    3 => ring[i].op;
    env[i].keyOff();
    env[i].set(5::ms, 30::ms, 0.3, 300::ms);
    0.3  => env[i].gain;
    2.0 => lp_flt[i].Q;
    1.5 => hp_flt[i].Q;
    0.0 => noiz[i].gain;
    1.0 => step[i].next;
}

    
// stuff for playing notes
[0,0] @=> int g_synth_latch[];
float g_synth_parms[2][2];

// sets parameters for next note
fun void playSynth(int player, float parmX, float parmY)    
{   
    //<<< "note from player ", player >>>;   // DEBUG
    parmX => g_synth_parms[player][0];
    parmY => g_synth_parms[player][1];
    
    calcNote(parmY) => int note;

    if (player == 0) 
        Std.mtof(note) => osc1.freq;
    else
        Std.mtof(note) => osc2.freq;
    
    // calc filter params
    0.3 => float thr1;
    0.6 => float thr2;
    Std.mtof(note)*1.5 => float lo_base;
    Std.mtof(note)*0.2 => float hi_base;
    if (parmX < thr1 ) {
        hi_base => hp_flt[player].freq;
        lo_base + 10000.0*parmX/thr2 => lp_flt[player].freq; 
    }
    else if (parmX < thr2) {
        hi_base + 3000.0*(parmX-thr1)/(1.0 - thr1) => hp_flt[player].freq;
        lo_base + 10000.0*parmX/thr2 => lp_flt[player].freq; 
    }
    else {
        hi_base + 3000.0*(parmX-thr1)/(1.0 - thr1) => hp_flt[player].freq;
        lo_base + 10000.0 => lp_flt[player].freq; 
    }
    
    // equalize for gain
    Std.dbtorms( 95*(1-parmX) + 100*parmX) => lp_flt[player].gain;
    
    // calc noise amount depending on whether inside or outside squares, and by how much
    [0, 0] @=> int outside[];                 // 1 if outside square
    [100.0, 100.0] @=> float dist[];          // distance to nearest boundary
    for (0 => int sqr; sqr < 2; sqr++) {
        if ( g_square_on[sqr] && (parmX < g_param_squares[sqr][2])) {
            1 => outside[sqr];
            g_param_squares[sqr][2] - parmX => dist[sqr];
            //<<< "outside", sqr, " A" >>>; // DEBUG
        }  
        if ( g_square_on[sqr] && (parmX > g_param_squares[sqr][3])) {
            1 => outside[sqr];
            parmX - g_param_squares[sqr][3] => float temp_dist;
            if (temp_dist < dist[sqr])
                temp_dist => dist[sqr];
           //<<< "outside", sqr, " B" >>>; // DEBUG
 
        }
        if ( g_square_on[sqr] && (parmY < g_param_squares[sqr][0])) {
            1 => outside[sqr];
            g_param_squares[sqr][0] - parmY => float temp_dist;
            if (temp_dist < dist[sqr])
                temp_dist => dist[sqr];
            //<<< "outside", sqr, " C" >>>; // DEBUG
 
        }
        if ( g_square_on[sqr] && (parmY > g_param_squares[sqr][1])) {
            1 => outside[sqr];
            parmY - g_param_squares[sqr][1] => float temp_dist;
            if (temp_dist < dist[sqr])
                temp_dist => dist[sqr];
            //<<< "outside", sqr, " D" >>>; // DEBUG
 
        }
    } 
    0.0 => float distort;
    // are we outside both? if so, pick the smallest distance
    if ( outside[0] && outside[1] ){
        if (dist[0] < dist[1] )
            dist[0] => distort;
        else
            dist[1] => distort;
    }
    else if ( outside[0] && (g_square_on[1] == 0)) {
        dist[0] => distort;
    }
    else if ( outside[1] && (g_square_on[0] == 0)) {
        dist[1] => distort;
    }
    
    // calc parameters based on distortion amount
    if ( distort > 0.0 ) {
        0.4 + 0.6*distort => float temp_d;
        temp_d => noiz[player].gain;
        1.0 - temp_d => step[player].gain;
    }
    else {
        0.0 => noiz[player].gain;
        1.0 => step[player].gain;
    }
    
    1 => g_synth_latch[player];    
}

// actually start a note
fun void triggerSynth( int player )
{
    if (g_notes_left[player]) {
        // play note
        env[player].keyOn();
        //que[player].addEvent( now );  // for calculating note density
        
        // update count and send msg to procc
        if (g_send_bounds) {
            g_notes_left[player]--;
            osc_proc_out.startMsg("/notes_remaining", "i i ");
            player => osc_proc_out.addInt;
            g_notes_left[player] => osc_proc_out.addInt;
        }
        
        // write to text file
        writeNote(player, g_synth_parms[player][0], g_synth_parms[player][1]);
         
        // turn off note
        50::ms => now;
        env[player].keyOff();
    }
    // <<<"DEBUG notes left ", player, g_notes_left [player] >>>;
}    
    
// wait 'til a tick.  if a note is scheduled, trigger it.
fun void synthTimer( tickEvent event )
{
    while( 1 ) {
        event => now;
        for (0 => int i; i < g_num_players; i++) 
        {
            if (g_synth_latch[i] ) {
                spork ~ triggerSynth(i);
                0 => g_synth_latch[i];
            }
        }
    }
}


fun void reportDensities()
{
    while( 1 ) {
        que[0].calcDensity( now ) => float dens1;
        que[1].calcDensity( now ) => float dens2;
        //<<< " Densities: ", dens1, dens2 >>>;    // DEBUG
        
        // send messages to processing
        osc_proc_out.startMsg("/dens", "i f ");
        0 => osc_proc_out.addInt;
        dens1 => osc_proc_out.addFloat;

        osc_proc_out.startMsg("/dens", "i f ");
        1 => osc_proc_out.addInt;
        dens2 => osc_proc_out.addFloat;
        
        0.25::second => now;
    }
}


// spork processes -----------------------------------------------------------------
spork ~ eventListener(0);
spork ~ eventListener(1);
spork ~ tickClock();
spork ~ synthTimer( tick_e );
spork ~ keyboardListener();
spork ~ sendTimeProgress( tick_e );
//spork ~ reportDensities();  
spork ~ seqHandler1( tick_e );
spork ~ seqHandler2( tick_e );
spork ~ seqHandler3( tick_e );
spork ~ seqHandler4( tick_e );
spork ~ halfNoteHandler( tick_e );
  

// make time ---------------------------------------------------------------------
while( 1 )
{
    1::second => now;
}

// more functions and processes ---------------------------------------------------
// processes for listening for osc events 
fun void eventListener(int player)
{
    player => int pl;
    while( 1 ) {
        osc_in_event[pl] => now;
        while( osc_in_event[pl].nextMsg() ) {
            osc_in_event[pl].getFloat() => float x_in;
            osc_in_event[pl].getFloat() => float y_procc_in;
            g_vert_max - y_procc_in => float y_synth_in;
                        
            if( g_print_osc_debug ) {
                //<<< " in event from player: ", pl, x_in, y_synth_in, note >>>;
            }
            
            // play note
            playSynth(pl, x_in, y_synth_in);
            
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

// the hi-hat sequence
fun void seqHandler1( tickEvent event )
{
    // 1, e, &, a, 2, e, &, a, 3, e, &, a, 4, e, &, a,   
    [1, 0, 2, 0, 1, 0, 2, 1, 1, 0, 2, 0, 1, 2, 2, 3 ] @=> int seq[];
    while( 1 ) {
        event => now;
        if (g_seq_on ) {
            seq[ event.tick_num % seq.cap() ] => int note;
            if ( note ) {
                note_gains[ note -1 ] => hh_gain.gain;
                0 => hh_buf.pos;
            }
        }
    }
}

// the kick sequence
fun void seqHandler2( tickEvent event )
{
    // 1, e, &, a, 2, e, &, a, 3, e, &, a, 4, e, &, a,   
    [2, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 2, 0, 1, 0 ] @=> int seq[];
    while( 1 ) {
        event => now;
        if (g_seq_on ) {
            seq[ event.tick_num % seq.cap() ] => int note;
            if ( note ) {
                note_gains[ note -1 ] => kk_gain.gain;
                0 => kk_buf.pos;
            }
        }
    }
}
    
// the snare sequence
fun void seqHandler3( tickEvent event )
{
  // 1, e, &, a, 2, e, &, a, 3, e, &, a, 4, e, &, a, 1, e, &, a, 2, e, &, a, 3, e, &, a, 4, e, &, a,     
    [0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 3, 1, 0, 0,
     0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 1, 3, 1, 3, 0  ] @=> int seq[];
    while( 1 ) {
        event => now;
        if (g_seq_on ) {
            seq[ event.tick_num % seq.cap() ] => int note;
            if ( note ) {
                note_gains[ note-1 ] => sn_gain.gain;
                0 => sn_buf.pos;
            }
        }
    }
}

// the crash sequence
fun void seqHandler4( tickEvent event )
{
    while( 1 ) {
        event => now;
        if (g_seq_on ) {
            if ( event.tick_num == 0) {
                0 => cr_buf.pos;
            }
        }
    }
} 

// write note data to txt file
fun void writeNote(int pl, float x, float y)
{
    if ( fout[pl].good() )
        fout[pl] <= g_tick_ct <= ", " <= x <= ", " <= y <= IO.newline();
}

// write program bounds data to txt file
fun void writeBounds()
{
    if ( fout[2].good() ) {
        fout[2] <= g_tick_ct <= ", ";
        
        fout[2] <= g_prg_box_on[0][g_current_prg] <= ", ";       // box 1, on/off
        fout[2] <= g_prg_lower_t[0][g_current_prg] <= ", ";      // box 1, lower t
        fout[2] <= g_prg_upper_t[0][g_current_prg] <= ", ";      // box 1, upper t
        fout[2] <= g_prg_lower_p[0][g_current_prg] <= ", ";      // box 1, lower p
        fout[2] <= g_prg_upper_p[0][g_current_prg] <= ", ";      // box 1, upper p
        
        fout[2] <= g_prg_box_on[1][g_current_prg] <= ", ";       // box 2, on/off
        fout[2] <= g_prg_lower_t[1][g_current_prg] <= ", ";      // box 2, lower t
        fout[2] <= g_prg_upper_t[1][g_current_prg] <= ", ";      // box 2, upper t
        fout[2] <= g_prg_lower_p[1][g_current_prg] <= ", ";      // box 2, lower p
        fout[2] <= g_prg_upper_p[1][g_current_prg] <= ", ";      // box 2, upper p
        
        fout[2] <= g_prg_notes[0][g_current_prg] <= ", ";        // number of notes for player 1
        fout[2] <= g_prg_notes[1][g_current_prg] <= ", ";        // number of notes for player 2
        fout[2] <= IO.newline();
    }
}     

// keyboard listener 
fun void keyboardListener()
{
    Hid hiKbd;
    HidMsg msgKbd;
    
    // open keyboard
    0 => int device;
    if( !hiKbd.openKeyboard( device ) ) me.exit();
    <<< "keyboard '", hiKbd.name(), "' ready" >>>;
    
    while ( 1 )  {
        // wait on event
        hiKbd => now;
        while( hiKbd.recv( msgKbd ) ) {
            // check for action type
            if( msgKbd.isButtonDown() ) {                
                //if( msgKbd.which == 44) {   // space key
                if( msgKbd.which == 30) {    // '1' key
                    1 => g_send_bounds;
                    startStopSequencer();
                }
                else if( msgKbd.which == 31) {    // '2' key
                    0 => g_send_bounds;
                    startStopSequencer();
                }
                else if( msgKbd.which == 32) {    // '3' key
                    sendAllBoundsOff();
                }
                else {
                    //<<< "unknown key ", msgKbd.which >>>;
                }
            }
        }
    }
}
