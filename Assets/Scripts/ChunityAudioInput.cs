using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;


//-----------------------------------------------------------------------------
// name: ChunityAudioInput.cs
// desc: listens to Chunity/Unity audio; end up with waveform and spectrum data
//       to access...
//       waveform: "ChunityAudioInput.waveform" (see Waveform.cs)
//       spectrum: "ChunityAudioInput.spectrum" (see Spectrum.cs)
//-----------------------------------------------------------------------------
public class ChunityAudioInput : MonoBehaviour
{
    // time domain samples
    public static float[] waveform;
    // waveform, windowed
    public static float[] waveformWindowed = new float[1024];
    // number of samples used to represent time amplitude (power of 2) => can be changed
    public static int waveformSize;
    // max number of samples
    public static int waveformMax;

    // window
    float[] window = new float[1024];
    // window size
    int windowSize;

    // freq domain bins
    public static Complex[] spectrumComplex = new Complex[1024];
    // magnitude spectrums (bins)
    public static float[] spectrum = new float[512];
    // number of bins to represent frequency magnitude (power of 2) => can be changed
    public static int spectrumSize;

    void Awake()
    {
        // You can change these number (but should be a power of 2)
        waveformSize = 1024;
        waveformMax = 1024;
        windowSize = 1024;
        spectrumSize = 512;

        // allocate waveform (real)
        waveform = new float[waveformMax];
        // allocate waveform (windowed)
        waveformWindowed = new float[waveformMax];
        // allocate window
        window = Windowing.Hanning(windowSize);
        // FFT bins (complex); making as long as waveform
        spectrumComplex = new Complex[waveformMax];
        // FFT magnitude bins (real)
        spectrum = new float[spectrumSize];
    }

    // Called every audio block
    private void OnAudioFilterRead(float[] data, int channels)
    {
        // get the number of frames
        int numFrames = data.Length / channels;
        // number of samples to copy, whichever is shorter
        waveformSize = Math.Min(waveformMax, numFrames);
        // zero pad if necessary
        if (waveformSize < waveformMax)
        { for (int i = waveformSize; i < waveformMax; i++) waveform[i] = 0; }
        // copy data
        for (int i = 0; i < waveformSize; i++)
        {
            // copy the first channel into waveform
            waveform[i] = data[i * channels + 0];
            waveformWindowed[i] = waveform[i];
        }

        // regenerate window if needed
        if (waveformSize < windowSize)
        {
            windowSize = waveformSize;
            window = Windowing.Hanning(windowSize);
        }
        // apply our window
        Windowing.Apply(waveformWindowed, window);
        // convert float to complex
        Complex.Float2Complex(waveformWindowed, spectrumComplex);
        // calc freq domain
        ChunityFFT.ComputeFFT(spectrumComplex, false, spectrum);
    }

    // Update is called once per frame
    void Update()
    {
    }
}
