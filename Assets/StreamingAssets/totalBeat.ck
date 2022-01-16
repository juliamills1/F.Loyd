// full beat loop: kick, clap, hi-hat, bass, synth chords

// synchronize to period
.8::second => dur T;
T - (now % T) => now;

// drumkit routing
SndBuf kBuf => Gain kg => NRev n => LPF masterL => dac;
SndBuf hBuf => Gain hg => NRev hn => masterL => dac;
SndBuf cBuf => Gain cg => n => masterL => dac;

// load drum samples into buffers
me.dir() + "808_Kick_Long.wav" => kBuf.read;
me.dir() + "808_Hat_Closed.wav" => hBuf.read;
me.dir() + "808_Clap.wav" => cBuf.read;

// set reverb levels
0.08 => n.mix;
0.05 => hn.mix;

// set drum gains
0.5 => kg.gain;
0.0 => hg.gain;
0.0 => cg.gain;

// global LPF frequency control
0 => int lime;

// repeat x3 (12 bars)
0 => int a;
for(a; a < 3; a++)
{   
    // for each bar
    0 => int b;
    for(b; b < 4; b++)
    {
        // beat 1: kick, bass, hi-hat, chords
        theLime(lime) => masterL.freq;
        0 => kBuf.pos;
        Math.random2f(0.8, 0.9) => kBuf.gain;
        spork ~ bass();
        spork ~ hh();
        spork ~ poly(b);
        1::T => now;
    
        // beat 2: clap
        lime++;
        theLime(lime) => masterL.freq;
        0 => cBuf.pos;
        0.5 => cg.gain;
        Math.random2f(0.8, 0.9) => cBuf.gain;
        1::T => now;
    
        // beat 3
        lime++;
        theLime(lime) => masterL.freq;
        1::T => now;
    
        // beat 4
        lime++;
        theLime(lime) => masterL.freq;
        0 => cBuf.pos;
        0.5 => cg.gain;
        Math.random2f(0.8, 0.9) => cBuf.gain;
        1::T => now;
        lime++;
    }
}
0.0 => kg.gain;
0.0 => hg.gain;
0.0 => cg.gain;

// control global LPF frequency over time
fun float theLime(int lime)
{
    // 1st 4 bars: effectively no LPF
    if(lime < 16)
    {
        return 20000.0;
    }
    // 2nd 4 bars: 20k -> 4k
    else if(lime < 32)
    {
        return 20000.0 - ((lime % 16) * 1000);
    }
    // 3rd 4 bars: 4k -> 250
    else
    {
        return 4000.0 - ((lime % 16) * 250);
    }
}

// synth triads; takes current bar # as arg
fun void poly(int chord)
{
    // create three oscillators
    SqrOsc p1 => LPF l => NRev j => ADSR e => Gain g => dac;
    SqrOsc p2 => l => j => e => g => dac;
    SqrOsc p3 => l => j => e => g => dac;
    
    // set gain, reverb, and ADSR envelope values
    0.015 => p1.gain;
    0.015 => p2.gain;
    0.015 => p3.gain;
    0.05 => j.mix;
    e.set( 10::ms, 8::ms, .5, 5::ms );
    
    // pitch classes for each chord
    [0, 4, 7] @=> int chord1[];
    [4, 7, 10] @=> int chord2[];
    [1, 5, 8] @=> int chord3[];
    
    int thisChord[3];
    
    // set current pitch classes by bar 
    // (I'm sure there's a neater way to do this)
    // (but I couldn't find it in Chuck)
    if (chord == 0)
    {
        chord1[0] @=> thisChord[0];
        chord1[1] @=> thisChord[1];
        chord1[2] @=> thisChord[2];
    }
    else if (chord == 1)
    {
        chord2[0] @=> thisChord[0];
        chord2[1] @=> thisChord[1];
        chord2[2] @=> thisChord[2];
    }
    else
    {
        chord3[0] @=> thisChord[0];
        chord3[1] @=> thisChord[1];
        chord3[2] @=> thisChord[2];
    }
    
    // set oscillator frequencies
    thisChord[0] => float freq1;    
    Std.mtof(55 + freq1) => p1.freq;
    thisChord[1] => float freq2;    
    Std.mtof(55 + freq2) => p2.freq;
    thisChord[2] => float freq3;    
    Std.mtof(55 + freq3) => p3.freq;
    
    // loop over half a bar each time
    // rhythm: r8 n8 n8 n8
    0 => int i;
    for(i; i < 2; i++)
    {
        // apply global LPF
        theLime(lime) => l.freq;
        
        0.0 => g.gain;
        0.5::T => now;
        
        0.18 => g.gain;
        e.keyOn();
        0.5::T => now;
        e.keyOff();
        e.releaseTime() => now;
        
        theLime(lime) => l.freq;
        
        e.keyOn();
        0.5::T => now;
        e.keyOff();
        e.releaseTime() => now;
        
        e.keyOn();
        0.5::T => now;
        e.keyOff();
        e.releaseTime() => now;
    }
}

// bass part
fun void bass()
{
    TriOsc s => JCRev j => LPF l => dac;
    0.02 => j.mix;
    0.3 => s.gain;
    
    // pitch classes to choose from
    [ 0, 1, 4, 7, 8, 11] @=> int scale[];
    
    // always tonic for 1st note of bar
    scale[0] => float freq;    
    Std.mtof(43) => s.freq;
    
    // apply global LPF
    theLime(lime) => l.freq;
    
    // 1st n4d of bar: n4d or n8d n8d
    if (Math.randomf() < 0.2) 
    {
        1.5::T => now;
    }
    else
    {
        0.75::T => now;
        scale[ Math.random2(0,5) ] => freq;  
        Std.mtof( 43 + (Math.random2(0,1)*12 + freq) ) => s.freq;
        0.75::T => now;
    }

    // 2nd n4d of bar: n4d or n8d n8d
    theLime(lime) => l.freq;
    scale[ Math.random2(0,5) ] => freq; 
    Std.mtof( 43 + (Math.random2(0,1)*12 + freq) ) => s.freq;

    if (Math.randomf() < 0.15) 
    {
        1.5::T => now;
    }
    else
    {
        0.75::T => now;
    
        scale[ Math.random2(0,5) ] => freq;  
        Std.mtof( 43 + (Math.random2(0,1)*12 + freq) ) => s.freq;
        0.75::T => now;
    }
    
    // always end on n4
    scale[ Math.random2(1,5) ] => freq;   
    Std.mtof( 43 + (Math.random2(0,1)*12 + freq) ) => s.freq;
    1::T => now;
}

// hi-hat part
fun void hh()
{   
    // for each beat in bar
    0 => int j;
    for (j; j < 4; j++)
    {
        0 => hBuf.pos;
        0.9 => hg.gain;
        0.2 + (j * 0.1) => hBuf.gain;
        
        // choose between triplets vs. n8/n16/n32
        Math.random2(0,1) => int triplets;
        1.0 / 6.0 => float t;
        
        if(triplets == 1)
        {
            0 => hBuf.pos;
            t::T => now;
            0 => hBuf.pos;
            t::T => now;
            0 => hBuf.pos;
            t::T => now;
            0 => hBuf.pos;
            t::T => now;
            0 => hBuf.pos;
            t::T => now;
            0 => hBuf.pos;
            t::T => now;
        }
        else
        {
            // 1st half of the beat
            // n8, n16 n16, or n32 n32 n16
            Math.randomf() => float choice;
            if (choice < 0.1) 
            {
                0 => hBuf.pos;
                0.5::T => now;
            }
            else if (choice < 0.6)
            {
                0 => hBuf.pos;
                0.25::T => now;
                0 => hBuf.pos;
                0.25::T => now;
            }
            else
            {
                0 => hBuf.pos;
                0.125::T => now;
                0 => hBuf.pos;
                0.125::T => now;
                0 => hBuf.pos;
                0.25::T => now;
            }
        
            // 2nd half of the beat
            // n8, n16 n16, n32 n32 n16, or n32 n32 n32 n32
            Math.randomf() => float choice2;
            if (choice2 < 0.1) 
            {
                0 => hBuf.pos;
                0.5::T => now;
            }
            else if (choice2 < 0.6)
            {
                0 => hBuf.pos;
                0.25::T => now;
                0 => hBuf.pos;
                0.25::T => now;
            }
            else if (choice2 < 0.8)
            {
                0 => hBuf.pos;
                0.125::T => now;
                0 => hBuf.pos;
                0.125::T => now;
                0 => hBuf.pos;
                0.25::T => now;
            }
            else
            {
                0 => hBuf.pos;
                0.125::T => now;
                0 => hBuf.pos;
                0.125::T => now;
                0 => hBuf.pos;
                0.125::T => now;
                0 => hBuf.pos;
                0.125::T => now;
            }
        }
    }
}