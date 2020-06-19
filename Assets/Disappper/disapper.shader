Shader "Learning/disapper"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_NoiseTex ("Noise", 2D) = "white" {}
		_Val ("Value", range(-2, 2)) = 0
		_Strength ("Strength", range(0, 1)) = 0.1
		_ClipPartColor ("ClipPartColor", Color) = (1, 1, 1, 1)
		_Plane("Plane", Vector) = (1, 1, 1, 1)
        [KeywordEnum(U2D, D2U, L2R, R2L)] _Direction ("Direction", Float) = 0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "Queue"="Transparent" }
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha
		LOD 100
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile _DIRECTION_U2D _DIRECTION_D2U _DIRECTION_L2R _DIRECTION_R2L

			
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
			float _Val;
			float _Strength;
			fixed4 _ClipPartColor;
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
				// float3 w_pos = i.worldPos.xyz;
				float3 face_normal = _Plane.xyz;
				float target_dis = _Plane.w;
				float dis = dot(w_pos, normalize(face_normal));
				clip(dis - target_dis);

				float compare_value = 0;
				#if _DIRECTION_D2U
				compare_value = w_pos.y;
				// clip(w_pos.y - _Val);
				#elif _DIRECTION_U2D
				compare_value = w_pos.y;
				// clip(_Val - w_pos.y);
				#elif _DIRECTION_L2R
				compare_value = w_pos.x;
				// clip(w_pos.x - _Val);
				#elif _DIRECTION_R2L
				compare_value = w_pos.x;
				// clip(_Val - w_pos.x);
				#endif
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed4 texColor = tex2D(_MainTex, i.uv);
				fixed3 albedo = texColor.rgb;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));
				texColor.rgb = ambient + diffuse;
				texColor = abs(_Val - compare_value) < _Strength ? _ClipPartColor : texColor;
				return texColor;

				// return fixed4(1, 0, 0, 1);
			}
			ENDCG
		}
	}
}
