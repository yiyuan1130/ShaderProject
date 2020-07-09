// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Learning/rim_light"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_RimColor ("RimColor", Color) = (1, 1, 1, 1)
		_RimPower ("RimPower", range(0, 1)) = 0.5
		_RimWidth ("RimWidth", range(0, 10)) = 5
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
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			struct a2v {
				float4 pos : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float2 uv : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				// float3 worldViewDir : TEXCOORD3;
			};

			sampler2D _MainTex;
			float _RimPower;
			fixed4 _RimColor;
			float _RimWidth;

			v2f vert(a2v v){
				v2f o;
				o.pos = UnityObjectToClipPos(v.pos);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.uv = v.uv;
				o.worldPos = mul(unity_ObjectToWorld, v.pos).xyz;
				return o;
			}

			fixed4 frag(v2f i) : SV_Target{
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = -normalize(_WorldSpaceLightPos0.xyz);
				fixed4 texColor = fixed4(0,0,0,1);
				texColor += tex2D(_MainTex, i.uv);
				fixed3 diffuse = _LightColor0.rgb * saturate(dot(worldNormal, worldLightDir)) + ambient;
				 texColor.rgb *= diffuse;

				float3 worldViewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);
				float rimVal =  pow(1 - max(0, dot(worldViewDir, worldNormal)), _RimWidth);
				texColor.rgb += _RimColor.rgb * rimVal *_RimPower;

				return texColor;
			}

			ENDCG
		}
	}
}
