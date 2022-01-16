using UnityEngine;
using System.Collections;

//-----------------------------------------------------------------------------
// name: CameraRotate.cs
// desc: uses keyboard input to toggle camera rotation on/off, change speed and
//       direction, and reset to origin
//-----------------------------------------------------------------------------
public class CameraRotate : MonoBehaviour
{
    public float speed;
    int rotateRate = 0;
    int rotateSign = 0;

    void Update()
    {
        // camera rotation controls
        // F = "fast-forward", R = "rewind"
        // 0 = off, 1 = play, 2 = x2 fast, 3 = x3
        if (Input.GetKey(KeyCode.F) || Input.GetKey(KeyCode.R))
        {
            rotateRate++;
            if (rotateRate > 3)
            {
                rotateRate = 0;
            }

            if (Input.GetKey(KeyCode.F))
            {
                rotateSign = 1;
            }
            else if (Input.GetKey(KeyCode.R))
            {
                rotateSign = -1;
            }
        }

        float timeRate = rotateSign * rotateRate * Time.deltaTime;
        transform.Rotate((speed * 2) * timeRate,
                          speed * timeRate,
                         (speed / 3) * timeRate);

        // O = reset view
        if (Input.GetKey(KeyCode.O))
        {
            rotateRate = 0;
            this.transform.rotation = Quaternion.Slerp(this.transform.rotation,
                                                       Quaternion.Euler(0,0,0),
                                                       0.6f);
        }
    }
}