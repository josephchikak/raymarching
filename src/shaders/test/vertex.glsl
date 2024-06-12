
//  uniform mat4 projectionMatrix;
//  uniform mat4 viewMatrix;
//  uniform mat4 modelMatrix;
 uniform vec2 uFrequency;
 uniform float uTime;

//  attribute vec3 position;
//  attribute vec2 uv;

 varying vec2 vUv;
 varying float vElevation;
//  attribute float aRandom;

//  varying float vRandom;
 
//  //functions
//  float loremIpsum()
//  {
//     float a = 1.0;
//     float b = 2.0;

//     return a + b
//  }

//   float fooBar = 4.4;
//      float a = 1;
//      float b = 2;

//      int foo = 43;
//      int bar = -1;
     
//      //verctor 2
//      vec2 foo = vec2(1.0, 2.0);

//      //affects both x and y
//      foo *= 2.0;

//      //vector 3
//      vec3 bar = vec3(1.0, 2.0, 3.0);
//      vec3 purpleColor = vec3(0.0);
//      purpleColor.r = 0.5;
//      purpleColor.g = 1.0;

//      //vector 4
//      vec4 foo = vec4(1.0, 2.0, 3.0, 4.0);

//      float result = loremIpsum();


    //void main functions till be called automatically by the GPU
 void main()
 {
    vec4 modelPosition = modelMatrix * vec4(position, 1.0);
   
   //  float elevation = sin(modelPosition.x * uFrequency.x - uTime) * 0.1;
   //  elevation +=  sin(modelPosition.y * uFrequency.y - uTime) * 0.1;

   //  modelPosition.z += elevation;

    // modelPosition.z += aRandom * 0.1;

    vec4 viewPosition = viewMatrix * modelPosition;
    vec4 projectionPosition = projectionMatrix * viewPosition;

    gl_Position = projectionPosition; 

    vUv = uv;

   //  vElevation = elevation;
    // vRandom = aRandom;

    //  gl_Position = projectionMatrix * viewMatrix * modelMatrix * vec4(position, 1.0);
 }