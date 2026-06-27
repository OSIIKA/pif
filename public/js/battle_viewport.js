const container = document.getElementById('battle-3d-stage');
const dataNode = document.getElementById('battle-viewport-data');

if (!container || !dataNode) {
  // 戦術フェーズ以外では何もしない
} else {
  const viewportData = JSON.parse(dataNode.textContent);
  const overlay = document.createElement('div');
  overlay.className = 'battle-viewport-label-layer';
  container.appendChild(overlay);
  const fallbackLayer = document.createElement('div');
  fallbackLayer.className = 'battle-viewport-fallback-layer';
  container.appendChild(fallbackLayer);

  const hexRadius = 1.35;
  const xSpacing = hexRadius * 1.65;
  const zSpacing = hexRadius * 1.92;

  const worldWidth = (viewportData.cols - 1) * xSpacing;
  const worldHeight = (viewportData.rows - 1) * zSpacing + zSpacing * 0.5;

  const toWorldPosition = (col, row) => {
    const x = col * xSpacing - worldWidth / 2;
    const z = row * zSpacing - worldHeight / 2 + (col % 2 === 1 ? zSpacing * 0.5 : 0);
    return { x, z };
  };

  const updateStatus = (message) => {
    // UIへは表示しない。必要時のデバッグ用フック。 
    container.dataset.viewportState = message;
  };

  const createViewportLabel = (unit) => {
    const label = document.createElement('div');
    label.className = `battle-viewport-label battle-viewport-label-${unit.side}`;
    label.innerHTML = `<strong>${unit.name || (unit.side === 'ally' ? `第${unit.fleet_number}艦隊` : `敵艦隊${unit.fleet_number}`)}</strong><span>HP ${unit.hp}/${unit.max_hp}</span>`;
    overlay.appendChild(label);
    return label;
  };

  const renderFallbackLayout = () => {
    fallbackLayer.innerHTML = '';
    overlay.innerHTML = '';

    const width = container.clientWidth || 620;
    const height = container.clientHeight || 420;
    const scaleX = width / (worldWidth + xSpacing * 2.2);
    const scaleZ = height / (worldHeight + zSpacing * 2.4);

    viewportData.units.forEach((unit, index) => {
      const position = toWorldPosition(unit.col, unit.row);
      const x = width * 0.5 + position.x * scaleX;
      const y = height * 0.5 + position.z * scaleZ;

      const ship = document.createElement('div');
      ship.className = `battle-viewport-fallback-ship battle-viewport-fallback-ship-${unit.side}`;
      ship.style.left = `${x}px`;
      ship.style.top = `${y}px`;
      ship.style.transform = `translate(-50%, -50%) rotate(${unit.side === 'ally' ? 180 : 0}deg)`;
      ship.style.animationDelay = `${index * 0.08}s`;
      fallbackLayer.appendChild(ship);

      const label = createViewportLabel(unit);
      label.style.opacity = '1';
      label.style.transform = `translate(-50%, -50%) translate(${x}px, ${y - 34}px)`;
    });
  };

  renderFallbackLayout();
  updateStatus(`FALLBACK_READY_${viewportData.units.length}`);
  window.addEventListener('resize', renderFallbackLayout);

  const bootThreeViewport = async () => {
    try {
      const THREE = await import('https://esm.sh/three@0.166.1');
      const { GLTFLoader } = await import('https://esm.sh/three@0.166.1/examples/jsm/loaders/GLTFLoader.js');

      const scene = new THREE.Scene();
      scene.background = new THREE.Color(0x000000);

      const renderer = new THREE.WebGLRenderer({ antialias: true, alpha: false });
      renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, 2));
      renderer.outputColorSpace = THREE.SRGBColorSpace;
      renderer.shadowMap.enabled = true;
      renderer.shadowMap.type = THREE.PCFSoftShadowMap;
      renderer.domElement.className = 'battle-viewport-canvas';
      container.insertBefore(renderer.domElement, overlay);

      const camera = new THREE.OrthographicCamera(-8, 8, 8, -8, 0.1, 100);
      camera.position.set(0, 14, 0.01);
      camera.lookAt(0, 0, 0);

      const ambientLight = new THREE.AmbientLight(0xbfd7ff, 2.2);
      scene.add(ambientLight);

      const directionalLight = new THREE.DirectionalLight(0xffffff, 1.4);
      directionalLight.position.set(4, 16, 4);
      directionalLight.castShadow = true;
      directionalLight.shadow.mapSize.set(1024, 1024);
      scene.add(directionalLight);

      const gridGroup = new THREE.Group();
      scene.add(gridGroup);

      const shipGroup = new THREE.Group();
      scene.add(shipGroup);
      const labelEntries = [];

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
        const material = new THREE.LineBasicMaterial({ color: 0x133a6a, transparent: true, opacity: 0.7 });
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
        const material = new THREE.MeshBasicMaterial({ color: 0x07111e, transparent: true, opacity: 0.92, side: THREE.DoubleSide });
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

      const floorGeometry = new THREE.CircleGeometry(Math.max(worldWidth, worldHeight) * 1.05, 64);
      const floorMaterial = new THREE.MeshPhongMaterial({ color: 0x000000, side: THREE.DoubleSide });
      const floorMesh = new THREE.Mesh(floorGeometry, floorMaterial);
      floorMesh.rotation.x = -Math.PI / 2;
      floorMesh.position.y = -0.02;
      scene.add(floorMesh);

      const resizeRenderer = () => {
        const width = container.clientWidth;
        const height = container.clientHeight;
        renderer.setSize(width, height);

        const aspect = width / Math.max(height, 1);
        const cameraSize = 6.8;
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
          node.material.emissive = new THREE.Color(colorHex).multiplyScalar(0.08);
        });
      };

      const buildFallbackShip = (unit) => {
        const group = new THREE.Group();
        const body = new THREE.Mesh(
          new THREE.BoxGeometry(1.7, 0.52, 0.95),
          new THREE.MeshPhongMaterial({ color: unit.side === 'ally' ? 0x55dfff : 0xff7373 })
        );
        group.add(body);

        const nose = new THREE.Mesh(
          new THREE.ConeGeometry(0.36, 0.7, 4),
          body.material.clone()
        );
        nose.rotation.z = -Math.PI / 2;
        nose.position.x = 1;
        group.add(nose);
        return group;
      };

      const placeUnit = (baseModel, unit) => {
        const instance = baseModel ? baseModel.clone(true) : buildFallbackShip(unit);
        tintModel(instance, unit.side === 'ally' ? 0x7af3ff : 0xff8d8d);

        const position = toWorldPosition(unit.col, unit.row);
        instance.position.set(position.x, 0.38, position.z);
        instance.rotation.y = unit.side === 'ally' ? Math.PI : 0;

        const hpRatio = unit.max_hp > 0 ? unit.hp / unit.max_hp : 1;
        const scale = 1.35 + Math.max(0.2, hpRatio) * 0.45;
        instance.scale.setScalar(scale);
        shipGroup.add(instance);

        const label = createViewportLabel(unit);
        labelEntries.push({ label, target: instance });

        const marker = new THREE.Mesh(
          new THREE.RingGeometry(0.72, 0.92, 32),
          new THREE.MeshBasicMaterial({
            color: unit.side === 'ally' ? 0x00ffbc : 0xff4a4a,
            transparent: true,
            opacity: 0.82,
            side: THREE.DoubleSide
          })
        );
        marker.rotation.x = -Math.PI / 2;
        marker.position.set(position.x, 0.03, position.z);
        shipGroup.add(marker);
      };

      const normalizeModel = (modelRoot) => {
        modelRoot.updateMatrixWorld(true);
        const bounds = new THREE.Box3().setFromObject(modelRoot);
        const size = new THREE.Vector3();
        bounds.getSize(size);
        const maxSize = Math.max(size.x, size.y, size.z, 0.01);
        const normalizeScale = 2.4 / maxSize;
        modelRoot.scale.setScalar(normalizeScale);

        const centeredBounds = new THREE.Box3().setFromObject(modelRoot);
        const center = new THREE.Vector3();
        centeredBounds.getCenter(center);
        modelRoot.position.sub(center);
        return modelRoot;
      };

      const populateShips = (modelRoot) => {
        overlay.innerHTML = '';
        viewportData.units.forEach((unit) => {
          placeUnit(modelRoot, unit);
        });
      };

      const response = await fetch(viewportData.modelUrl, { cache: 'no-store' });
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}`);
      }

      const buffer = await response.arrayBuffer();
      const loader = new GLTFLoader();
      const gltf = await new Promise((resolve, reject) => {
        loader.parse(buffer, window.location.origin + '/object/', resolve, reject);
      });

      const modelRoot = normalizeModel(gltf.scene);
      populateShips(modelRoot);

      const updateLabels = () => {
        const width = container.clientWidth;
        const height = container.clientHeight;
        const projected = new THREE.Vector3();

        labelEntries.forEach(({ label, target }) => {
          projected.copy(target.position);
          projected.y += 1.05;
          projected.project(camera);

          const x = (projected.x * 0.5 + 0.5) * width;
          const y = (-projected.y * 0.5 + 0.5) * height;
          const visible = projected.z >= -1 && projected.z <= 1;

          label.style.opacity = visible ? '1' : '0';
          label.style.transform = `translate(-50%, -50%) translate(${x}px, ${y}px)`;
        });
      };

      const clock = new THREE.Clock();
      const animate = () => {
        const elapsed = clock.getElapsedTime();

        shipGroup.children.forEach((child, index) => {
          if (child.type === 'Group') {
            child.position.y = 0.38 + Math.sin(elapsed * 1.2 + index * 0.5) * 0.05;
          }
          if (child.geometry && child.geometry.type === 'RingGeometry') {
            child.material.opacity = 0.58 + Math.sin(elapsed * 1.5 + index) * 0.14;
          }
        });

        updateLabels();
        renderer.render(scene, camera);
        requestAnimationFrame(animate);
      };

      resizeRenderer();
      window.addEventListener('resize', resizeRenderer);
      fallbackLayer.style.display = 'none';
      updateStatus(`GLTF_READY_${viewportData.units.length}`);
      animate();
    } catch (error) {
      updateStatus(`FALLBACK_ERROR_${error.message || 'LOAD_ERROR'}`);
      renderFallbackLayout();
    }
  };

  bootThreeViewport();
}