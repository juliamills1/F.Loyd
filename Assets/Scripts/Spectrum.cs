using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

//-----------------------------------------------------------------------------
// name: Spectrum.cs
// desc: set up and draw the spectrum
//-----------------------------------------------------------------------------
public class Spectrum : MonoBehaviour
{
    public GameObject pfCube;
    public static int rows = 8, cols = 256;
    public GameObject[,] cubes = new GameObject[rows, cols];
    public float[,] history = new float[rows, cols];
    public float[] hueHistory = new float[rows];

    void Start()
    {
        float x = -cols, y = 0, z = 0;
        float xIncrement = pfCube.transform.localScale.x * 1.34f;
        float zIncrement = pfCube.transform.localScale.z * 30;

        // initial cube placements
        for( int i = 0; i < cubes.GetLength(0); i++)
        {
            // increase z to create a new row
            z += zIncrement;

            for ( int j = 0; j < cubes.GetLength(1); j++ )
            {
                GameObject go = Instantiate(pfCube);
                go.transform.position = new Vector3(x, y, z);
                x += xIncrement;

                // scale it to be 2x wider
                go.transform.localScale = new Vector3(2, 0, 1);
                go.name = "bin" + i + "." + j;

                // set this as a child of this spectrum
                go.transform.parent = this.transform;
                cubes[i,j] = go;
            }

            // reset x to original starting point
            x = -cols;
        }

        // parent positioning
        this.transform.position = new Vector3(40.0f, 13.5f, 0);
        this.transform.Rotate(0.0f, 42.0f, -53.4f);
        this.transform.localScale = new Vector3(0.4f, 0.2f, 0.4f);
    }

    void Update()
    {
        float[] spectrum = ChunityAudioInput.spectrum;

        // average spectrum with more weight for lower frequencies
        float[] avgSpectrum = new float[cols];
        for (int i = 0; i < cols; i++)
        {
            int q1 = cols / 4;
            int q3 = (cols * 3) / 4;

            if (i < q1)
            {
                avgSpectrum[i] = spectrum[i];
            }
            else if (i < q3 && i >= q1)
            {
                avgSpectrum[i] = (spectrum[(2*i)-q1]
                                + spectrum[(2*i)-q1+1]) / 2;
            }
            else
            {
                avgSpectrum[i] = (spectrum[(3*i)-cols]
                                + spectrum[(3*i)-cols+1]
                                + spectrum[(3*i)-cols+2]) / 3;
            }
        }

        // find approximate centroid
        float maxSpec = Mathf.Max(avgSpectrum);
        int maxIndex = Array.IndexOf(avgSpectrum, maxSpec);

        // translate centroid location into hue
        float hueLerp = Mathf.InverseLerp(0, cubes.GetLength(1)-1, maxIndex);

        // scale, colour, and position cubes throughout history
        for(int i = cubes.GetLength(0)-1; i >= 0; i--)
        {
            // translate row # into value
            float valueLerp = Mathf.InverseLerp(cubes.GetLength(0)-1, 0, i);

            for(int j = 0; j < cubes.GetLength(1); j++)
            {
                GameObject thisCube = cubes[i,j];
                Renderer rend = thisCube.GetComponent<Renderer>();

                // spectral magnitude as y coordinate
                float y = 600 * Mathf.Sqrt(avgSpectrum[j]);

                // get newest spectrum info
                if (i == 0)
                {
                    history[i,j] = y;
                    hueHistory[i] = hueLerp;
                }
                else
                {
                    // bump spectral history back one row
                    history[i,j] = history[i-1,j];
                    hueHistory[i] = hueHistory[i-1];
                }

                // change hue according to approximate centroid
                Color colorFunc = Color.HSVToRGB(hueHistory[i], 1.0f, valueLerp);
                rend.material.SetColor("_BaseColor", colorFunc);

                // transform position and scale according to waveform magnitude
                thisCube.transform.localScale =
                    new Vector3(thisCube.transform.localScale.x,
                                history[i,j],
                                Mathf.Clamp(history[i,j], 0.0f, 30.0f));
                thisCube.transform.localPosition =
                    new Vector3(thisCube.transform.localPosition.x,
                                history[i,j]/2,
                                thisCube.transform.localPosition.z);
            }
        }
    }
}