Shader "Learning/rekongqi"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_NoiseTex ("NoiseTextrue", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "Queue"="AlphaTest" "IgnoreProjector"="true" "RenderType"="TransparentCutout" }
		Blend SrcAlpha oneMinusSrcAlpha
		// Cull Off
		ZWrite Off
		// LOD 100
		GrabPass
		{
			//此处给出一个抓屏贴图的名称，抓屏的贴图就可以通过这张贴图来获取，而且每一帧不管有多个物体使用了该shader，只会有一个进行抓屏操作
			//如果此处为空，则默认抓屏到_GrabTexture中，但是据说每个用了这个shader的都会进行一次抓屏！
			"_GrabTempTex"
		}
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 grabPos : TEXCOORD1;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _NoiseTex_ST;
			sampler2D _NoiseTex;
			sampler2D _GrabTempTex;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				// o.uv = v.uv;
				o.uv = TRANSFORM_TEX(v.uv, _NoiseTex);
				o.grabPos = ComputeGrabScreenPos(o.vertex);
				return o;
			}
			


			fixed4 frag (v2f i) : SV_Target
			{
				// TEXT_TRANSFORM
				float4 noise = tex2D(_NoiseTex, i.uv - _Time.xy * 0.1);
				float2 offset = float2(0.1, 0.1);
				// i.grabPos.xy += sin(_Time.w * noise.x * 100) / 10 + offset;
				i.grabPos.xy += (noise.xy * 2 - 1) * 0.1;

				half4 grabCol = tex2Dproj(_GrabTempTex, i.grabPos);
				return grabCol;
			}
			ENDCG
		}
	}
}
