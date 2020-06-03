Shader "Learning/baiyechuang"
{
	Properties
	{
		_TopTex ("TopTexture", 2D) = "white" {}
		_BottomTex ("BottomTexture", 2D) = "white" {}
		_ColumnCount("ColumnCount", int) = 3
		_RowCount("RowCount", int) = 3
		_ShowPercent_Col("ShowPercent_Col", range(0, 1)) = 0.5
		_ShowPercent_Row("ShowPercent_Row", range(0, 1)) = 0.5
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

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _TopTex;
			sampler2D _BottomTex;
			int _ColumnCount;
			int _RowCount;
			float _ShowPercent_Col;
			float _ShowPercent_Row;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float2 nuv = frac(i.uv * float2(_ColumnCount, _RowCount));
				int col_show = step(_ShowPercent_Col, nuv.x);
				int row_show = step(_ShowPercent_Row, nuv.y);
				int show_tex = step(col_show + row_show, 0.5);
				fixed4 col = 0;
				col = lerp(tex2D(_TopTex, i.uv), tex2D(_BottomTex, i.uv), show_tex);
				return col;
			}
			ENDCG
		}
	}
}
