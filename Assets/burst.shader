Shader "Custom/burst"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "Queue" = "Transparent" "RenderType"="Transparent" }
		LOD 100
		Blend SrcAlpha OneMinusSrcAlpha


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
			float _StartTime;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
	
				half burstSpeed = 3.;
				half ball = smoothstep(.4,0., length(i.uv - .5));
				half burst = smoothstep(.45+ burstSpeed*_StartTime, 0., length(i.uv - .5));
				
				half ResonanceStartTime = 0.4;
				half startResonance = 1.-step(-ResonanceStartTime + _StartTime, 0.);
				
				half Resonance = floor(10.*sin(length((i.uv - .5)*(1.-_StartTime*1.5))*30.));
				// separate events according to time startResonance

				// the following line includes burst
				//half finalAlpha = (1. - startResonance)*burst + startResonance*Resonance*step(_StartTime, ResonanceStartTime+0.5);
				// the following line does not
				half finalAlpha = Resonance*step(_StartTime, ResonanceStartTime );

				return half4(1.,1.,1.,finalAlpha*ball);
			}
			ENDCG
		}
	}
}
