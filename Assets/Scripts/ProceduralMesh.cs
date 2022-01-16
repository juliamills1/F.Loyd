using System;
using System.Collections;
using System.Linq;
using UnityEngine;


//-----------------------------------------------------------------------------
// name: ProceduralMesh.cs
// desc: generate tetrahedron; change shader graph according to sound magnitude
//-----------------------------------------------------------------------------
public class ProceduralMesh : MonoBehaviour
{
    Mesh m;
    MeshFilter filt;
    Material mat;
    private bool rotateOn = false;

    // initialization
    void Start()
    {
        filt = GetComponent<MeshFilter>();
        mat = GetComponent<Renderer>().material;
        m = new Mesh();
        filt.mesh = m;
        DrawMesh();
    }

    // generate faces between vertices
    void DrawMesh()
    {
        Vector3 p0 = new Vector3(0, 0, 0);
        Vector3 p1 = new Vector3(1, 0, 0);
        Vector3 p2 = new Vector3(0.5f, 0, Mathf.Sqrt(0.75f));
        Vector3 p3 = new Vector3(0.5f, Mathf.Sqrt(0.75f), Mathf.Sqrt(0.75f)/3);

        m.vertices = new Vector3[]{
            p0,p1,p2
           ,p0,p2,p3
           ,p2,p1,p3
           ,p0,p3,p1
        };

        m.triangles = new int[]{
            0,1,2
           ,3,4,5
           ,6,7,8
           ,9,10,11
        };

        m.RecalculateNormals();
        m.RecalculateBounds();
        m.Optimize();
    }

    void Update()
    {
        // map waveform magnitude to outline thickness
        float mag = GetMagnitude();
        float scaledMag = Mathf.Clamp(Mathf.Abs(0.032f * mag * Mathf.Log(mag)),
                          0.001f,
                          0.32f);

        // set shader graph parameter "thickness"
        mat.SetFloat("Vector1_8d8d0cbf741142ed9451d2bff3ca3040", scaledMag);

        // rotate according to waveform magnitude
        Vector3 rotateAmount = new Vector3(mag * -6, 0, 0);

        // spacebar toggles rotation on/off
        if (Input.GetKey(KeyCode.Space))
        {
            rotateOn = !rotateOn;
        }

        if (rotateOn)
        {
            transform.Rotate(rotateAmount);
        }
    }

    // sum waveform values to get approximate magnitude
    public float GetMagnitude()
    {
        float[] wf = ChunityAudioInput.waveform;
        float magnitude = 0.0f;
        for (int i = 0; i < wf.Length; i++)
        {
            magnitude += Mathf.Abs(wf[i]);
        }

        if (magnitude <= 0.0f)
        {
            magnitude = 0.001f;
        }
        return Mathf.Sqrt(magnitude);
    }
}