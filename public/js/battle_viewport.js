import * as THREE from 'https://unpkg.com/three@0.166.1/build/three.module.js';
import { GLTFLoader } from 'https://unpkg.com/three@0.166.1/examples/jsm/loaders/GLTFLoader.js';

const container = document.getElementById('battle-3d-stage');
const dataNode = document.getElementById('battle-viewport-data');
const statusNode = document.getElementById('battle-viewport-status');

if (!container || !dataNode) {
  // 戦術フェーズ以外では何もしない
} else {
  const viewportData = JSON.parse(dataNode.textContent);

  const scene = new THREE.Scene();
  scene.background = new THREE.Color(0x06101c);
  scene.fog = new THREE.Fog(0x06101c, 18, 38);

  const renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });
  renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, 2));
  renderer.outputColorSpace = THREE.SRGBColorSpace;
  renderer.shadowMap.enabled = true;
  renderer.shadowMap.type = THREE.PCFSoftShadowMap;
  renderer.domElement.className = 'battle-viewport-canvas';
  container.appendChild(renderer.domElement);

  const camera = new THREE.OrthographicCamera(-8, 8, 8, -8, 0.1, 100);
  camera.position.set(0, 18, 0.01);
  camera.lookAt(0, 0, 0);

  const ambientLight = new THREE.AmbientLight(0x9ad8ff, 1.9);
  scene.add(ambientLight);

  const directionalLight = new THREE.DirectionalLight(0xd7f7ff, 1.2);
  directionalLight.position.set(8, 16, 6);
  directionalLight.castShadow = true;
  directionalLight.shadow.mapSize.set(1024, 1024);
  scene.add(directionalLight);

  const rimLight = new THREE.PointLight(0x00ffbc, 16, 50, 2);
  rimLight.position.set(0, 6, 0);
  scene.add(rimLight);

  const gridGroup = new THREE.Group();
  scene.add(gridGroup);

  const shipGroup = new THREE.Group();
  scene.add(shipGroup);

  const hexRadius = 1.35;
  const xSpacing = hexRadius * 1.65;
  const zSpacing = hexRadius * 1.92;

  const worldWidth = (viewportData.cols - 1) * xSpacing;
  const worldHeight = (viewportData.rows - 1) * zSpacing + zSpacing * 0.5;

  const toWorldPosition = (col, row) => {
    const x = col * xSpacing - worldWidth / 2;
    const z = row * zSpacing - worldHeight / 2 + (col % 2 === 1 ? zSpacing * 0.5 : 0);
    return new THREE.Vector3(x, 0, z);
  };

  const createHexOutline = (center) => {
    const points = [];
    for (let index = 0; index <= 6; index += 1) {
      const angle = (Math.PI / 180) * (60 * index + 30);
      points.push(new THREE.Vector3(
        center.x + Math.cos(angle) * hexRadius,
        0.02,
        center.z + Math.sin(angle) * hexRadius
      ));
    }
    const geometry = new THREE.BufferGeometry().setFromPoints(points);
    const material = new THREE.LineBasicMaterial({ color: 0x1b87ff, transparent: true, opacity: 0.5 });
    return new THREE.Line(geometry, material);
  };

  const createHexFill = (center) => {
    const shape = new THREE.Shape();
    for (let index = 0; index < 6; index += 1) {
      const angle = (Math.PI / 180) * (60 * index + 30);
      const x = Math.cos(angle) * hexRadius;
      const y = Math.sin(angle) * hexRadius;
      if (index === 0) {
        shape.moveTo(x, y);
      } else {
        shape.lineTo(x, y);
      }
    }
    shape.closePath();

    const geometry = new THREE.ShapeGeometry(shape);
    const material = new THREE.MeshBasicMaterial({ color: 0x0d3561, transparent: true, opacity: 0.18, side: THREE.DoubleSide });
    const mesh = new THREE.Mesh(geometry, material);
    mesh.rotation.x = -Math.PI / 2;
    mesh.position.set(center.x, 0.01, center.z);
    return mesh;
  };

  for (let col = 0; col < viewportData.cols; col += 1) {
    for (let row = 0; row < viewportData.rows; row += 1) {
      const center = toWorldPosition(col, row);
      gridGroup.add(createHexFill(center));
      gridGroup.add(createHexOutline(center));
    }
  }

  const floorGeometry = new THREE.CircleGeometry(Math.max(worldWidth, worldHeight) * 0.9, 64);
  const floorMaterial = new THREE.MeshPhongMaterial({
    color: 0x082038,
    transparent: true,
    opacity: 0.55,
    emissive: 0x05111e,
    side: THREE.DoubleSide
  });
  const floorMesh = new THREE.Mesh(floorGeometry, floorMaterial);
  floorMesh.rotation.x = -Math.PI / 2;
  floorMesh.position.y = -0.02;
  scene.add(floorMesh);

  const resizeRenderer = () => {
    const width = container.clientWidth;
    const height = container.clientHeight;
    renderer.setSize(width, height);

    const aspect = width / Math.max(height, 1);
    const cameraSize = 9;
    camera.left = -cameraSize * aspect;
    camera.right = cameraSize * aspect;
    camera.top = cameraSize;
    camera.bottom = -cameraSize;
    camera.updateProjectionMatrix();
  };

  const tintModel = (root, colorHex) => {
    root.traverse((node) => {
      if (!node.isMesh) return;
      node.castShadow = true;
      node.receiveShadow = true;
      node.material = node.material.clone();
      node.material.color = new THREE.Color(colorHex);
      node.material.emissive = new THREE.Color(colorHex).multiplyScalar(0.18);
      node.material.emissiveIntensity = 0.7;
      node.material.metalness = 0.2;
      node.material.roughness = 0.55;
    });
  };

  const buildFallbackShip = (unit) => {
    const group = new THREE.Group();
    const body = new THREE.Mesh(
      new THREE.CylinderGeometry(0.4, 0.7, 2.2, 6),
      new THREE.MeshPhongMaterial({
        color: unit.side === 'ally' ? 0x4fd6ff : 0xff7b7b,
        emissive: unit.side === 'ally' ? 0x0e6d8c : 0x7a1717,
        transparent: true,
        opacity: 0.9
      })
    );
    body.rotation.z = Math.PI / 2;
    group.add(body);

    const wingGeometry = new THREE.BoxGeometry(1.8, 0.14, 0.5);
    const wing = new THREE.Mesh(wingGeometry, body.material.clone());
    wing.position.set(0, 0.12, 0);
    group.add(wing);

    return group;
  };

  const placeUnit = (baseModel, unit) => {
    const instance = baseModel ? baseModel.clone(true) : buildFallbackShip(unit);
    tintModel(instance, unit.side === 'ally' ? 0x7af3ff : 0xff8d8d);

    const position = toWorldPosition(unit.col, unit.row);
    instance.position.copy(position);
    instance.position.y = 0.4;
    instance.rotation.x = 0;
    instance.rotation.y = unit.side === 'ally' ? Math.PI : 0;

    const hpRatio = unit.max_hp > 0 ? unit.hp / unit.max_hp : 1;
    const scale = 0.85 + Math.max(0.16, hpRatio) * 0.4;
    instance.scale.setScalar(scale);

    shipGroup.add(instance);

    const marker = new THREE.Mesh(
      new THREE.RingGeometry(0.55, 0.7, 32),
      new THREE.MeshBasicMaterial({
        color: unit.side === 'ally' ? 0x00ffbc : 0xff4a4a,
        transparent: true,
        opacity: 0.7,
        side: THREE.DoubleSide
      })
    );
    marker.rotation.x = -Math.PI / 2;
    marker.position.set(position.x, 0.03, position.z);
    shipGroup.add(marker);
  };

  const loader = new GLTFLoader();

  const updateStatus = (message) => {
    if (statusNode) statusNode.textContent = message;
  };

  const populateShips = (modelRoot) => {
    viewportData.units.forEach((unit) => {
      placeUnit(modelRoot, unit);
    });
  };

  loader.load(
    viewportData.modelUrl,
    (gltf) => {
      const modelRoot = gltf.scene;
      modelRoot.updateMatrixWorld(true);

      const bounds = new THREE.Box3().setFromObject(modelRoot);
      const size = new THREE.Vector3();
      bounds.getSize(size);
      const maxSize = Math.max(size.x, size.y, size.z, 0.01);
      const normalizeScale = 1.8 / maxSize;
      modelRoot.scale.setScalar(normalizeScale);

      // モデル中心を原点に寄せて、真上視点でヘックス配置しやすくする
      const centeredBounds = new THREE.Box3().setFromObject(modelRoot);
      const center = new THREE.Vector3();
      centeredBounds.getCenter(center);
      modelRoot.position.sub(center);

      populateShips(modelRoot);
      updateStatus(`GLTF READY : ${viewportData.units.length} UNITS`);
    },
    undefined,
    () => {
      populateShips(null);
      updateStatus(`FALLBACK VIEW : ${viewportData.units.length} UNITS`);
    }
  );

  const clock = new THREE.Clock();
  const animate = () => {
    const elapsed = clock.getElapsedTime();

    shipGroup.children.forEach((child, index) => {
      if (child.type === 'Group') {
        child.position.y = 0.35 + Math.sin(elapsed * 1.4 + index * 0.45) * 0.06;
      }
      if (child.geometry && child.geometry.type === 'RingGeometry') {
        child.material.opacity = 0.42 + Math.sin(elapsed * 1.8 + index) * 0.18;
      }
    });

    renderer.render(scene, camera);
    requestAnimationFrame(animate);
  };

  resizeRenderer();
  window.addEventListener('resize', resizeRenderer);
  animate();
}