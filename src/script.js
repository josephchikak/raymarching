import * as THREE from 'three'
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js'
import * as dat from 'lil-gui'
import testVertextShader from './shaders/test/vertex.glsl'
import testFragmentShader from './shaders/test/fragment.glsl'

import matcap from './matcaps/C1AA92_AD6E29_737889_CED1D7.jpg'


/**
 * Base
 */
// Debug
const gui = new dat.GUI()

// Canvas
const canvas = document.querySelector('canvas.webgl')

// Scene
const scene = new THREE.Scene()

/**
 * Textures
 */
const textureLoader = new THREE.TextureLoader()
const matcapTexture = textureLoader.load(matcap)

/**
 * Test mesh
 */
// Geometry
const geometry = new THREE.PlaneGeometry(1,1,1,1)

// const count = geometry.attributes.position.count
// const randoms = new Float32Array(count)

// for (let i = 0; i < count; i++) {
//      randoms[i] = Math.random();
// }

// geometry.setAttribute('aRandom', new THREE.BufferAttribute(randoms, 1))


    const mouse = new THREE.Vector2();
    document.addEventListener('mousemove', (e)=> {
        mouse.x =  e.pageX/ sizes.width - 0.5
        mouse.y =  -e.pageY/ sizes.width + 0.5

    })
 

 

/**
 * Sizes
 */
const sizes = {
    width: window.innerWidth,
    height: window.innerHeight
}

// Material
const material = new THREE.ShaderMaterial({
    vertexShader: testVertextShader,
    fragmentShader: testFragmentShader,
    uniforms:
    {
        uFrequency: {value: new THREE.Vector2(10,5)},
        uTime: {value: 0},
        resolution: {value: new THREE.Vector2(sizes.width, sizes.height)},
        uColor: {value: new THREE.Color('orange')},
        matcap: {value: matcapTexture},
        mouse: {value : new THREE.Vector2(0,0)}
        // uTexture: {value: flagTexture}
    }
})

gui.add(material.uniforms.uFrequency.value, 'x').min(0).max(20).step(0.01).name('frequencyX')
gui.add(material.uniforms.uFrequency.value, 'y').min(0).max(20).step(0.01).name('frequencyY')


// Mesh
const mesh = new THREE.Mesh(geometry, material)
// mesh.scale.y = 2/3
scene.add(mesh)



window.addEventListener('resize', () =>
{
    // Update sizes
    sizes.width = window.innerWidth
    sizes.height = window.innerHeight

    // Update camera
    camera.aspect = sizes.width / sizes.height
    camera.updateProjectionMatrix()

    // Update renderer
    renderer.setSize(sizes.width, sizes.height)
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))
})
 

/**
 * Camera
 */
// Base camera
const frustumSize = 1;
const camera = new THREE.OrthographicCamera(1/-2, 1/2, 1/2, 1/-2 , -1000, 1000)
camera.position.set(0, 0, 2)
scene.add(camera)

// Controls
const controls = new OrbitControls(camera, canvas)
controls.enableDamping = true

/**
 * Renderer
 */
const renderer = new THREE.WebGLRenderer({
    canvas: canvas
})
renderer.setSize(sizes.width, sizes.height)
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))

/**
 * Animate
 */
const clock = new THREE.Clock()

const tick = () =>
{
    const elapsedTime = clock.getElapsedTime()

    //update material
    material.uniforms.uTime.value = elapsedTime
    material.uniforms.mouse.value = mouse
    // console.log(mouse)

    // Update controls
    controls.update()

    // Render
    renderer.render(scene, camera)

    // Call tick again on the next frame
    window.requestAnimationFrame(tick)
}

tick()