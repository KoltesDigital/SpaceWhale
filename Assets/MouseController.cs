using UnityEngine;

public class MouseController : MonoBehaviour
{
	[SerializeField]
	private float moveFactor;

	[SerializeField]
	private float lerpFactor;

	[SerializeField]
	private Transform targetTransform;

	private float Normalize(float xy, float wh)
	{
		return (xy - wh * .5f) / (wh * .5f);
	}

	void Update()
	{
		var x = Normalize(Input.mousePosition.x, Screen.width);
		var y = Normalize(Input.mousePosition.y, Screen.height);

		transform.localPosition = Vector3.Lerp(transform.localPosition, new Vector3(x, y, 0f) * moveFactor, Time.deltaTime * lerpFactor);

		transform.LookAt(targetTransform);
	}
}
