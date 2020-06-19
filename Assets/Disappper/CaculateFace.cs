using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CaculateFace : MonoBehaviour {

	public Material material;
	void Update(){
		Vector3 point = transform.position;
		Vector3 normal = transform.forward;
		float dis = Vector3.Dot(point, normal.normalized);
		Debug.Log(normal);
		Debug.Log(dis);
		material.SetVector("_Plane", new Vector4(normal.x, normal.y, normal.z, dis));
	}
}
