Shader "Learning/glass"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_AlphaScale ("Alpha Scale", range(0, 1)) = 1
		_Color ("Color", color) = (1, 1, 1, 1)
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue"="Transparent" }
		LOD 100
		Blend SrcAlpha OneMinusSrcAlpha
		ZWrite Off
		Cull Off
		// Depth peeling
		// order independent transparent - oir
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			// #pragma multi_compile_fog
			#pragma target 3.0
			
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
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				float2 uv : TEXCOORD2;
				// float face : VFACE;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _AlphaScale;
			fixed4 _Color;
			
			v2f vert (a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.pos);
				o.worldPos = mul(unity_ObjectToWorld, v.pos);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
		

			fixed4 frag (v2f i, fixed facing : VFACE) : SV_Target
			{
				fixed3 worldNormal = normalize(i.worldNormal);
				float n_scale = facing > 0 ? 1 : -1;
				worldNormal *= n_scale;
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed4 texColor = tex2D(_MainTex, i.uv);
				fixed3 albedo = texColor.rgb * _Color.rgb;
				fixed3 ambinet = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				fixed3 diffuse = _LightColor0 * albedo * max(0, dot(worldNormal, worldLightDir));
				return fixed4(ambinet + diffuse, texColor.a * _AlphaScale);
			}
			ENDCG
		}
	}
}
