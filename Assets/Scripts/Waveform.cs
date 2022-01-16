using System.Collections;
using System.Collections.Generic;
using UnityEngine;

//-----------------------------------------------------------------------------
// name: Waveform.cs
// desc: set up and draw the audio waveform
//-----------------------------------------------------------------------------
public class Waveform : MonoBehaviour
{
    public GameObject pfCube;
    public static int bins = 512;
    public GameObject[] cubes = new GameObject[bins];

    void Start()
    {
        float x = -bins / 2, y = 0, z = 0;
        float xIncrement = pfCube.transform.localScale.x * 1.33f;

        // initial cube placements
        for( int i = 0; i < cubes.Length; i++ )
        {
            GameObject go = Instantiate(pfCube);
            Renderer rend = go.GetComponent<Renderer>();

            // taper colour from white to black at both ends
            float[] sine = new float[cubes.Length];
            sine[i] = Mathf.Sqrt(Mathf.Sin(Mathf.PI * i / (2 * bins)));
            float val = sine[i];
            rend.material.SetColor("_BaseColor", new Color(val, val, val));

            // set default position
            go.transform.position = new Vector3(x, y, z);
            x += xIncrement;
            go.name = "cube" + i;

            // set as child of this waveform
            go.transform.parent = this.transform;
            cubes[i] = go;
        }

        // parent positioning
        this.transform.position = new Vector3(-120, 30, 0);
        this.transform.Rotate(0.0f, 0.0f, 15.0f);
        this.transform.localScale = new Vector3(0.1f, 1, 1);
    }

    void Update()
    {
        // taper waveform position fluctuation at both ends
        float[] wf = ChunityAudioInput.waveform;
        float[] sine = new float[cubes.Length];
        for (int i = 0; i < cubes.Length; i++ )
        {
            sine[i] = Mathf.Sin(Mathf.PI * i / (2 * bins));
            wf[i] *= sine[i];
        }

        // position the cubes
        for( int i = 0; i < cubes.Length; i++ )
        {
            cubes[i].transform.localPosition =
                new Vector3(cubes[i].transform.localPosition.x,
                            200 * wf[i],
                            cubes[i].transform.localPosition.z);
        }
    }
}