#include "resources.hlsl"

struct VSInput
{
	float3 pos		: POSITION;
	float radie		: radie;
	int tex			: TEXTURE;
};

struct PS_Input
{
	float4 pos		: SV_POSITION;
	float2 texCoord	: TEXCOORD0;
	float4 screenTex: TEXCOORD1;
	float2 alphaTex : TEXCOORD2;
	int tex			: TEXTURE1;
};

[maxvertexcount(4)]
void main(point VSInput _input[1] : SV_POSITION, inout TriangleStream< PS_Input > _triStream)
{

	PS_Input output;

	float radie = _input[0].radie;


	float4 positions[4];
	positions[0] = float4(-radie, radie, 0, 1);
	positions[1] = float4(radie, radie, 0, 1);
	positions[2] = float4(-radie, -radie, 0, 1);
	positions[3] = float4(radie, -radie, 0, 1);


	/*float4 positions[4];
	positions[0] = float4(-_input[0].radie, _input[0].radie, 0, 1);
	positions[1] = float4(_input[0].radie, _input[0].radie, 0, 1);
	positions[2] = float4(-_input[0].radie, -_input[0].radie, 0, 1);
	positions[3] = float4(_input[0].radie, -_input[0].radie, 0, 1);
*/

	float2 texCoord[4] =
	{
		float2(timeofday, 0.0f),
		float2(timeofday + 0.5f, 0.0f),
		float2(timeofday , 1.0f),
		float2(timeofday + 0.5f, 1.0f)
	};

	float2 alphaTexCoord[4] =
	{
		float2( 0.0f, 0.0f ),
		float2( 1.0f, 0.0f ),
		float2( 0.0f, 1.0f ),
		float2( 1.0f, 1.0f )
	};

	float3 look = normalize(cameraPos.xyz - _input[0].pos);
	float3 right = normalize(cross(float3(0,1,0), look));
	float3 up = cross(look, right);

	float4x4 W;
	W[0] = float4(right,  0.0f);
	W[1] = float4(up,   0.0f);
	W[2] = float4(look,   0.0f);
	W[3] = float4(_input[0].pos,1);

	float4x4 wvp = mul(W,mul(mView,mProj));
	//float4x4 wvp = mul(mul(mProj,mView),W);
	//float4x4 wvp = mul(transpose(W),mul(transpose(mView),transpose(mProj)));

	[unroll]
	for(int i=0; i<4; i++)
	{
		float4 position = positions[i];
		position = mul(position,W);
		position = mul(mView,position);
		position = mul(mProj,position);
		output.pos = position;
        
		output.texCoord = texCoord[i];
		output.screenTex = output.pos;
		output.alphaTex = alphaTexCoord[i];
		output.tex = _input[0].tex;
		_triStream.Append(output);
	}
	_triStream.RestartStrip();

}