Shader "Learning/disapper"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Val ("Value", range(0, 1)) = 0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "Queue"="Transparent" }
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha
		LOD 100
		GrabPass{
			"_GrabTex"
		}
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			struct a2v
			{
				float4 pos : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 worldPos : TEXCOORD0;
				float3 worldNormal : TEXCOORD1;
				float2 uv : TEXCOORD2;
				float4 grabPos : TEXCOORD3;
			};

			sampler2D _GrabTex;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Val;
			
			v2f vert (a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.pos);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.pos).xyz;
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.grabPos = ComputeGrabScreenPos(o.pos);
				
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// fixed3 worldNormal = normalize(i.worldNormal);
				// fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed4 texColor = tex2Dproj(_GrabTex, i.grabPos);
				// fixed3 albedo = texColor.rgb;
				// fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				// fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));
				// return fixed4(ambient + diffuse, texColor.a);
				clip(i.uv.y - _Val);
				return fixed4(texColor.rgb, 0.5);
			}
			ENDCG
		}
	}
}
