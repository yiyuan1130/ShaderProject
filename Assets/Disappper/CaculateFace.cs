using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CaculateFace : MonoBehaviour {

	public Material material;
	void Start(){
		Vector3 point = transform.position;
		Vector3 normal = transform.right;
		Debug.Log(normal);
		float angle = Vector3.Dot(point, normal);
		float length = point.magnitude * Mathf.Cos(angle);
		Debug.Log(length);
	}
}
