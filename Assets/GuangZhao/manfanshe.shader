
Shader "Learning/manfanshe"
{
	Properties
	{
		_Diffuse("Diffuse", color) = (1, 1, 1, 1)
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			fixed4 _Diffuse; // 反射系数

			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
			};

			v2f vert(a2v v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target{
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				fixed3 worldNormal = normalize(i.worldNormal);
				// fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				// fixed3 diffuse = saturate(dot(worldNormal, worldLightDir)) * _Diffuse.rgb; // 普通漫反射光照模型
				fixed3 diffuse = (dot(worldNormal, worldLightDir) * 0.5 + 0.5) * _Diffuse.rgb; //半兰伯特漫反射模型
				diffuse.rgb *= _LightColor0.rgb;
				return fixed4(diffuse.rgb, 1);
			}

			ENDCG
		}
	}
}
