
varying vec2 vUv;
uniform float uTime;
uniform vec2 resolution;
uniform sampler2D matcap;
uniform vec2 mouse;


#ifdef GL_ES
precision mediump float;
#endif

#define PI 3.141592653589793
#define HALF_PI 1.5707963267948966
#define TWO_PI 6.28318530718




// Paint colors.
    vec3 red    = vec3(0.725, 0.141, 0.149);
    vec3 blue   = vec3(0.012, 0.388, 0.624);
    vec3 yellow = vec3(0.988, 0.784, 0.173);
    vec3 beige  = vec3(.976, .949, .878);
    vec3 black  = vec3(0.078, 0.09, 0.114);
    vec3 green = vec3(0.09,0.169,0.035);

vec3 mod289(vec3 x) {
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec2 mod289(vec2 x) {
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec3 permute(vec3 x) {
    return mod289(((x*34.0)+1.0)*x);
}

float noise(vec2 v)
{
    const vec4 C = vec4(0.211324865405187,  // (3.0-sqrt(3.0))/6.0
                      0.366025403784439,  // 0.5*(sqrt(3.0)-1.0)
                     -0.577350269189626,  // -1.0 + 2.0 * C.x
                      0.024390243902439); // 1.0 / 41.0
    // First corner
    vec2 i  = floor(v + dot(v, C.yy) );
    vec2 x0 = v -   i + dot(i, C.xx);

    // Other corners
    vec2 i1;
    //i1.x = step( x0.y, x0.x ); // x0.x > x0.y ? 1.0 : 0.0
    //i1.y = 1.0 - i1.x;
    i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
    // x0 = x0 - 0.0 + 0.0 * C.xx ;
    // x1 = x0 - i1 + 1.0 * C.xx ;
    // x2 = x0 - 1.0 + 2.0 * C.xx ;
    vec4 x12 = x0.xyxy + C.xxzz;
    x12.xy -= i1;

    // Permutations
    i = mod289(i); // Avoid truncation effects in permutation
    vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 ))
        + i.x + vec3(0.0, i1.x, 1.0 ));

    vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), 0.0);
    m = m*m ;
    m = m*m ;

    // Gradients: 41 points uniformly over a line, mapped onto a diamond.
    // The ring size 17*17 = 289 is close to a multiple of 41 (41*7 = 287)

    vec3 x = 2.0 * fract(p * C.www) - 1.0;
    vec3 h = abs(x) - 0.5;
    vec3 ox = floor(x + 0.5);
    vec3 a0 = x - ox;

    // Normalise gradients implicitly by scaling m
    // Approximation of: m *= inversesqrt( a0*a0 + h*h );
    m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );

    // Compute final noise value at P
    vec3 g;
    g.x  = a0.x  * x0.x  + h.x  * x0.y;
    g.yz = a0.yz * x12.xz + h.yz * x12.yw;
    return 130.0 * dot(m, g);
}

vec3 curl(float	x,	float	y,	float	z)
{

    float	eps	= 1., eps2 = 2. * eps;
    float	n1,	n2,	a,	b;

   //  x += uTime * .05;
   //  y += uTime * .05;
   //  z += uTime * .05;

    vec3	curl = vec3(0.);

    n1	=	noise(vec2( x,	y	+	eps ));
    n2	=	noise(vec2( x,	y	-	eps ));
    a	=	(n1	-	n2)/eps2;

    n1	=	noise(vec2( x,	z	+	eps));
    n2	=	noise(vec2( x,	z	-	eps));
    b	=	(n1	-	n2)/eps2;

    curl.x	=	a	-	b;

    n1	=	noise(vec2( y,	z	+	eps));
    n2	=	noise(vec2( y,	z	-	eps));
    a	=	(n1	-	n2)/eps2;

    n1	=	noise(vec2( x	+	eps,	z));
    n2	=	noise(vec2( x	+	eps,	z));
    b	=	(n1	-	n2)/eps2;

    curl.y	=	a	-	b;

    n1	=	noise(vec2( x	+	eps,	y));
    n2	=	noise(vec2( x	-	eps,	y));
    a	=	(n1	-	n2)/eps2;

    n1	=	noise(vec2(  y	+	eps,	z));
    n2	=	noise(vec2(  y	-	eps,	z));
    b	=	(n1	-	n2)/eps2;

    curl.z	=	a	-	b;

    return	curl;
}

mat4 rotationMatrix(vec3 axis, float angle) {
    axis = normalize(axis);
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1.0 - c;
    
    return mat4(oc * axis.x * axis.x + c,           oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s,  0.0,
                oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.y + c,           oc * axis.y * axis.z - axis.x * s,  0.0,
                oc * axis.z * axis.x - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c,           0.0,
                0.0,                                0.0,                                0.0,                                1.0);
}

vec3 rotate(vec3 v, vec3 axis, float angle) {
	mat4 m = rotationMatrix(axis, angle);
	return (m * vec4(v, 1.0)).xyz;
}

float smin (float a, float b, float k){
  float h = clamp(0.5 + 0.5 * (b-a)/ k, 0.0, 1.0);
  return mix(b, a, h) - k*h*(1.0 -h);
}

float sdSphere( vec3 p, float r )
{
  return length(p)-r;
}

float sdBox( vec3 p, vec3 b )
{
  vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float sdRoundBox( vec3 p, vec3 b, float r )
{
  vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0) - r;
}

float sdDeathStar( vec3 p2, float ra, float rb, float d )
{
  // sampling independent computations (only depend on shape)
  float a = (ra*ra - rb*rb + d*d)/(2.0*d);
  float b = sqrt(max(ra*ra-a*a,0.0));
	
  // sampling dependant computations
  vec2 p = vec2( p2.x, length(p2.yz) );
  if( p.x*b-p.y*a > d*max(b-p.y,0.0) )
    return length(p-vec2(a,b));
  else
    return max( (length(p            )-ra),
               -(length(p-vec2(d,0.0))-rb));
}

float smoothDifferenceSDF(float distA, float distB, float k) {
    float h = clamp(0.5 - 0.5*(distA+distB)/k, 0., 1.);
    return mix(distA, -distB, h ) + k*h*(1.-h); 
}

float sdf(vec3 p){
  vec3 p1 = rotate(p, vec3(1.0), uTime/2.);
  vec3 p2 = rotate(p, vec3(0.4,0.9,0.), 5. );
  float box = sdRoundBox(p1, vec3(0.2), 0.1);
  float star = sdDeathStar(p2 - vec3(mouse * vUv, 0.) , 0.4, 0.7, 0.8);
  float sphere = sdSphere(p - vec3((mouse) * 2.0 , 0.), 0.2); 
// return star;
   float mix1 = smin(star, sphere, 0.2);
  return mix1;
  }

vec3 calcNormal( in vec3 p ) // for function f(p)
{
    const float eps = 0.0001; // or some other value
    const vec2 h = vec2(eps,0);
    return normalize( vec3(sdf(p+h.xyy) - sdf(p-h.xyy),
                           sdf(p+h.yxy) - sdf(p-h.yxy),
                           sdf(p+h.yyx) - sdf(p-h.yyx) ));
  }

  vec2 getmatcap(vec3 eye, vec3 normal) {
  vec3 reflected = reflect(eye, normal);
  float m = 2.8284271247461903 * sqrt( reflected.z+1.0 );
  return reflected.xy / m + 0.5;
}





// float opDisplace( in sdf primitive, in vec3 p )
// {
//     float d1 = primitive(p);
//     float d2 = displacement(p);
//     return d1+d2;
// }



void main() {

   // vec2 fragCoord = gl_FragCoord.xy / uResolution;

  vec2 uv = (gl_FragCoord.xy / resolution.xy) * 1.0 - 0.5;
//   vec2 uv = vUv;



  uv.x *= resolution.x / resolution.y;
//   uv.y *= resolution.y / resolution.x;


  // vec2 sts = vUv/uResolution.zw;

  // vec2 newUresolution  =   uResolution.zw ;


  vec2 st = vUv;
  vec2 newUv = vec2(vUv.x - 0.5, vUv.y - 0.5);
//   vec2 newUv2 = vec2(vUv - vec2(0.5)) * uResolution*aspectRatio + vec2(0.5);


  //camera postion
  vec3 camPos =  vec3(0.,0.,2.);

  vec3 ray = normalize(vec3(uv - vec2(0.5, 0.5) , -1.0));

  vec3 rayPos = camPos;

  float t = 0.;
  float tMax = 5.;

  for(int i= 0; i<32; i++){
      vec3 pos =camPos + t*ray;
      float h = sdf(pos);
      if(h< 0.01) break;
      t += h;
  }


  vec3 color = green;
  if(t <tMax){
    vec3 pos = camPos + t* ray;
    color = vec3(1.);
    vec3 normal = calcNormal(pos);
    color = normal;


    //light
    float difference = dot(vec3(1.0), normal);
    vec2 matcapUV = getmatcap(ray, normal);
    color = vec3(difference);
    color = texture2D(matcap, matcapUV).rgb;
  }


    // Apply the scaled radius to the circle




  // vec3 color = vec3(0.0);
 
  
  gl_FragColor = vec4(color, 1.0);

}