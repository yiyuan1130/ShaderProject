Shader "Learning/disapper"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_NoiseTex ("Noise", 2D) = "white" {}
		_Strength ("Strength", range(0, 1)) = 0.1
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "Queue"="Transparent" }
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

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
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _NoiseTex;
			float4 _NoiseTex_ST;
			float _Strength;
			float4 _Plane;
			
			v2f vert (a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.pos);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.pos).xyz;
				o.uv = v.uv;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_NoiseTex, TRANSFORM_TEX(i.uv, _NoiseTex));
				float offset = (col.r * 2 - 1) * _Strength;
				float3 w_pos = float3(i.worldPos.xy + float2(offset, offset), i.worldPos.z);
				float3 face_normal = _Plane.xyz;
				float target_dis = _Plane.w;
				float dis = dot(w_pos, normalize(face_normal));
				clip(dis - target_dis);

				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed4 texColor = tex2D(_MainTex, i.uv);
				fixed3 albedo = texColor.rgb;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));
				texColor.rgb = ambient + diffuse;
				return texColor;
			}
			ENDCG
		}
	}
}
