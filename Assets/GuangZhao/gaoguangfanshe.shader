// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'


Shader "Learning/guangzhao/gaoguangfanshe"
{
	Properties
	{
		_Diffuse("Diffuse", color) = (1, 1, 1, 1)
		_Specular("Specular", color) = (1, 1, 1, 1) // 高光反射颜色
		_Gloss("Gloss", range(8.0, 256)) = 20 // 反射区域
	}
	SubShader
	{
		Tags { "LightMode"="ForwardBase" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			fixed4 _Diffuse; // 反射系数
			fixed4 _Specular;
			float _Gloss;

			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 wordPos : TEXCOORD1;
			};

			v2f vert(a2v v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
				o.wordPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				return o;
			}

			fixed4 frag(v2f i) : SV_Target{
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				fixed3 reflectDir = normalize(reflect(-worldLightDir, worldNormal));
				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.wordPos);
				// phong模型
				// fixed3 specular = _LightColor0.rgb * _Specular * pow(saturate(dot(reflectDir, viewDir)), _Gloss);

				// blinn-phong模型
				fixed3 halfDir = normalize(worldLightDir + viewDir);
				fixed3 specular = _LightColor0.rgb * _Specular * pow(saturate(dot(reflectDir, halfDir)), _Gloss); 

				float3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));
				return fixed4(ambient + diffuse + specular, 1.0);
			}

			ENDCG
		}
	}
}
