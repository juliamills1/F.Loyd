// synchronized triangle bassline

// synchronize to period
0.8::second => dur T;
T - (now % T) => now;

TriOsc s => dac;
0.25 => s.gain;

// pitch classes to choose from
[ 0, 1, 4, 7, 8, 11] @=> int scale[];

// infinite loop
while( true )
{
    // always start on low tonic
    scale[0] => float freq;   
    Std.mtof(43) => s.freq;

    // 1st n4d of bar: n4d or n8d n8d
    if (Math.randomf() < 0.3) 
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
    scale[ Math.random2(0,5) ] => freq; 
    Std.mtof( 43 + (Math.random2(0,1)*12 + freq) ) => s.freq;
    
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
    
    // always end on n4
    scale[ Math.random2(1,5) ] => freq;   
    Std.mtof( 43 + (Math.random2(0,1)*12 + freq) ) => s.freq;
    1::T => now;
}