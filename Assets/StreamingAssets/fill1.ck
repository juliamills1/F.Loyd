// fill: kick, clap, bass

// synchronize to period
0.8::second => dur T;
T - (now % T) => now;

// bass oscillator
TriOsc s => dac;
0.0 => s.gain;
[4, 1, 7] @=> int scale[];

// drumkit routing
SndBuf kBuf => Gain kg => NRev n => dac;
SndBuf hBuf => Gain hg => NRev hn => dac;
SndBuf cBuf => Gain cg => n => dac;

// load drum samples into buffers
me.dir() + "808_Kick_Long.wav" => kBuf.read;
me.dir() + "808_Hat_Closed.wav" => hBuf.read;
me.dir() + "808_Clap.wav" => cBuf.read;

// set gain & reverb levels
0.1 => n.mix;
0.05 => hn.mix;
0.5 => kg.gain;
0.0 => hg.gain;
0.0 => cg.gain;

// infinite loop
while( true )
{
    // beat 1: kick
    0 => kBuf.pos;
    Math.random2f(.8,.9) => kBuf.gain;
    1::T => now;
    
    // beat 2: clap
    0 => cBuf.pos;
    0.5 => cg.gain;
    Math.random2f(.8,.9) => cBuf.gain;
    1::T => now;
    
    // beats 3 & 4
    // hi-hat rhythm: n8 n8 n16 n16 n16 n32 n32
    0 => int j;
    for (j; j < 7; j++)
    {
        0 => hBuf.pos;
        0.5 => hg.gain;
        0.15 + (j * 0.09) => hBuf.gain;
        
        // trigger bass on beat 3.5
        if (j == 1)
        {
            spork ~ bass();
        }
        
        if (j < 2)
        {
            0.5::T => now;
        }
        else if (j < 5)
        {
            0.25::T => now;
        }
        else
        {
            0.125::T => now;
        }
    }
}
0.0 => kg.gain;
0.0 => hg.gain;
0.0 => cg.gain;

// bass part
fun void bass()
{
    // iterate over 3 pitches
    // rhythm: n8 n8 n8
    0 => int i;
    for (i; i < 3; i++)
    {
        0.25 => s.gain;
        scale[i] => float freq;
        Std.mtof( 43 + freq ) => s.freq;
        0.5::T => now;
    }
    0.0 => s.gain;
}