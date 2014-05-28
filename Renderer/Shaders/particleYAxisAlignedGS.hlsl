#include "resources.hlsl"

struct GS_Input
{
	float3		pos				: POS;
	float2		size			: SIZE;
	float		alpha			: ALPHA;
};

struct PS_Input
{
	float4		pos				: SV_Position;
	float2		tex				: TEXCOORD0;
	float		alpha			: ALPHA;
	float4		screenTex		: TEXCOORD1;
	float4		worldPos		: TEXCOORD2;
};

[maxvertexcount(4)]
void main( point GS_Input input[1], inout TriangleStream<PS_Input> triStream )
{
	float2 quadTexCoords[4] =
	{
		float2( 0.0f, 0.0f ),
		float2(1.0f, .0f ),
		float2( .0f,  1.0f ),
		float2(1.0f,  1.0f )
	};

	float3 look		= normalize( cameraPos.xyz - input[0].pos );
	float3 right	= normalize( cross( float3( 0, 1, 0 ), look ) );	
	float3 up		= cross( right, look );

	//create a new world matrix that makes the to-be-generated billboard face the camera
	float4x4 pWorld;
	pWorld[0] = float4( right.x,	up.x,	look.x,	input[0].pos.x );
	pWorld[1] = float4( right.y,	up.y,	look.y,	input[0].pos.y );
	pWorld[2] = float4( right.z,	up.z,	look.z,	input[0].pos.z );
	pWorld[3] = float4( 0,			0,		0,		1.0 );

	float halfWidth		= .5f*input[0].size.x;
	float halfHeight	= .5f*input[0].size.y;

	float4 positions[4];
	positions[0] = float4(	-halfWidth,	-halfHeight,	0, 1 );
	positions[1] = float4(	halfWidth,	-halfHeight,	0, 1 );
	positions[2] = float4(	-halfWidth,	halfHeight,		0, 1 );
	positions[3] = float4(	halfWidth,	halfHeight,		0, 1 );

	PS_Input output;
	float4x4 tempMatrix = mul( mProj, mul( mView, pWorld ) );

	[unroll]
	for(unsigned int i = 0; i < 4; i++)
	{
		output.pos			= mul( tempMatrix, positions[i] );
		output.tex			= quadTexCoords[i];						//predetermined texture corrdinates for a square
		output.alpha		= input[0].alpha;
		output.screenTex	= output.pos;
		output.worldPos		= mul( pWorld, positions[i] );
		triStream.Append(output);
	}
}