import { Controller } from "@hotwired/stimulus"
import mapboxgl from "mapbox-gl"
import MapboxGeocoder from "@mapbox/mapbox-gl-geocoder"
import Supercluster from "supercluster"

export default class extends Controller {
  static targets = ["map", "searchFilters", "distanceInfo", "routeInfo"]
  static values = { 
    apiKey: String,
    listings: Array,
    userLocation: Array,
    autoCenter: Boolean,
    showRoute: Boolean,
    enableDrawing: Boolean
  }

  connect() {
    // Initialize Mapbox
    mapboxgl.accessToken = this.apiKeyValue
    
    this.initializeMap()
    this.setupGeocoder()
    this.initializeClustering()
    this.getUserLocation()
    this.setupEventListeners()
    
    if (this.enableDrawingValue) {
      this.setupDrawingTools()
    }
  }

  disconnect() {
    if (this.map) {
      this.map.remove()
    }
  }

  initializeMap() {
    // Default to France center
    const defaultCenter = [2.2137, 46.2276]
    const center = this.userLocationValue.length > 0 ? this.userLocationValue : defaultCenter

    this.map = new mapboxgl.Map({
      container: this.mapTarget,
      style: 'mapbox://styles/mapbox/streets-v12',
      center: center,
      zoom: this.userLocationValue.length > 0 ? 10 : 6,
      pitch: 0,
      bearing: 0
    })

    // Add navigation controls
    this.map.addControl(new mapboxgl.NavigationControl(), 'top-right')
    
    // Add fullscreen control
    this.map.addControl(new mapboxgl.FullscreenControl(), 'top-right')

    // Add geolocate control
    this.geolocateControl = new mapboxgl.GeolocateControl({
      positionOptions: {
        enableHighAccuracy: true
      },
      trackUserLocation: true,
      showUserHeading: true
    })
    this.map.addControl(this.geolocateControl, 'top-right')

    this.map.on('load', () => {
      this.addDataSources()
      this.addLayers()
      this.loadListings()
    })
  }

  setupGeocoder() {
    this.geocoder = new MapboxGeocoder({
      accessToken: mapboxgl.accessToken,
      mapboxgl: mapboxgl,
      placeholder: 'Rechercher une adresse...',
      countries: 'fr',
      language: 'fr'
    })

    this.map.addControl(this.geocoder, 'top-left')

    this.geocoder.on('result', (e) => {
      this.userLocation = e.result.center
      this.updateDistances()
    })
  }

  initializeClustering() {
    this.cluster = new Supercluster({
      radius: 40,
      maxZoom: 16,
      minZoom: 0,
      minPoints: 2
    })
  }

  getUserLocation() {
    if (navigator.geolocation && this.autoCenterValue) {
      navigator.geolocation.getCurrentPosition(
        (position) => {
          this.userLocation = [position.coords.longitude, position.coords.latitude]
          this.map.setCenter(this.userLocation)
          this.map.setZoom(12)
          this.updateDistances()
          this.addUserLocationMarker()
        },
        (error) => {
          console.warn('Géolocalisation non autorisée:', error)
        }
      )
    }
  }

  addUserLocationMarker() {
    if (this.userLocationMarker) {
      this.userLocationMarker.remove()
    }

    const el = document.createElement('div')
    el.className = 'user-location-marker'
    el.innerHTML = `
      <div class="w-4 h-4 bg-blue-500 rounded-full border-2 border-white shadow-lg animate-pulse"></div>
    `

    this.userLocationMarker = new mapboxgl.Marker(el)
      .setLngLat(this.userLocation)
      .addTo(this.map)
  }

  addDataSources() {
    // Source for vehicle listings
    this.map.addSource('listings', {
      type: 'geojson',
      data: {
        type: 'FeatureCollection',
        features: []
      },
      cluster: true,
      clusterMaxZoom: 14,
      clusterRadius: 50
    })

    // Source for service providers
    this.map.addSource('services', {
      type: 'geojson',
      data: {
        type: 'FeatureCollection',
        features: []
      }
    })

    // Source for routes
    this.map.addSource('route', {
      type: 'geojson',
      data: {
        type: 'Feature',
        properties: {},
        geometry: {
          type: 'LineString',
          coordinates: []
        }
      }
    })

    // Source for custom drawn areas
    this.map.addSource('search-areas', {
      type: 'geojson',
      data: {
        type: 'FeatureCollection',
        features: []
      }
    })
  }

  addLayers() {
    // Cluster layer
    this.map.addLayer({
      id: 'clusters',
      type: 'circle',
      source: 'listings',
      filter: ['has', 'point_count'],
      paint: {
        'circle-color': [
          'step',
          ['get', 'point_count'],
          '#51bbd3',
          10,
          '#f1c40f',
          30,
          '#e74c3c'
        ],
        'circle-radius': [
          'step',
          ['get', 'point_count'],
          20,
          10,
          30,
          30,
          40
        ]
      }
    })

    // Cluster count layer
    this.map.addLayer({
      id: 'cluster-count',
      type: 'symbol',
      source: 'listings',
      filter: ['has', 'point_count'],
      layout: {
        'text-field': '{point_count_abbreviated}',
        'text-font': ['DIN Offc Pro Medium', 'Arial Unicode MS Bold'],
        'text-size': 12
      },
      paint: {
        'text-color': '#ffffff'
      }
    })

    // Individual listing layer
    this.map.addLayer({
      id: 'unclustered-listings',
      type: 'circle',
      source: 'listings',
      filter: ['!', ['has', 'point_count']],
      paint: {
        'circle-color': [
          'case',
          ['==', ['get', 'type'], 'vehicle'], '#3b82f6',
          ['==', ['get', 'type'], 'part'], '#10b981',
          '#6b7280'
        ],
        'circle-radius': 8,
        'circle-stroke-width': 2,
        'circle-stroke-color': '#ffffff'
      }
    })

    // Service providers layer
    this.map.addLayer({
      id: 'service-providers',
      type: 'symbol',
      source: 'services',
      layout: {
        'icon-image': 'car-15',
        'icon-size': 1.5,
        'text-field': ['get', 'name'],
        'text-offset': [0, 1.25],
        'text-anchor': 'top',
        'text-size': 10
      },
      paint: {
        'text-color': '#374151',
        'text-halo-color': '#ffffff',
        'text-halo-width': 1
      }
    })

    // Route layer
    this.map.addLayer({
      id: 'route',
      type: 'line',
      source: 'route',
      layout: {
        'line-join': 'round',
        'line-cap': 'round'
      },
      paint: {
        'line-color': '#3b82f6',
        'line-width': 5,
        'line-opacity': 0.8
      }
    })

    // Search areas layer
    this.map.addLayer({
      id: 'search-areas',
      type: 'fill',
      source: 'search-areas',
      paint: {
        'fill-color': '#3b82f6',
        'fill-opacity': 0.2
      }
    })

    this.map.addLayer({
      id: 'search-areas-outline',
      type: 'line',
      source: 'search-areas',
      paint: {
        'line-color': '#3b82f6',
        'line-width': 2,
        'line-dasharray': [2, 2]
      }
    })
  }

  setupEventListeners() {
    // Click on clusters to zoom
    this.map.on('click', 'clusters', (e) => {
      const features = this.map.queryRenderedFeatures(e.point, {
        layers: ['clusters']
      })
      const clusterId = features[0].properties.cluster_id
      this.map.getSource('listings').getClusterExpansionZoom(
        clusterId,
        (err, zoom) => {
          if (err) return

          this.map.easeTo({
            center: features[0].geometry.coordinates,
            zoom: zoom
          })
        }
      )
    })

    // Click on individual listings
    this.map.on('click', 'unclustered-listings', (e) => {
      this.showListingPopup(e)
    })

    // Hover effects
    this.map.on('mouseenter', 'clusters', () => {
      this.map.getCanvas().style.cursor = 'pointer'
    })

    this.map.on('mouseleave', 'clusters', () => {
      this.map.getCanvas().style.cursor = ''
    })

    this.map.on('mouseenter', 'unclustered-listings', () => {
      this.map.getCanvas().style.cursor = 'pointer'
    })

    this.map.on('mouseleave', 'unclustered-listings', () => {
      this.map.getCanvas().style.cursor = ''
    })

    // Listen for search filter events
    this.element.addEventListener('search:filter', (event) => {
      console.log("Received search:filter event", event.detail)
      this.handleSearchFilter(event.detail)
    })
  }

  setupDrawingTools() {
    // Add drawing controls for custom search areas
    this.drawingMode = false
    this.currentDrawing = []

    const drawButton = document.createElement('button')
    drawButton.className = 'btn btn-primary btn-sm'
    drawButton.innerHTML = '📍 Dessiner une zone'
    drawButton.addEventListener('click', () => this.toggleDrawingMode())

    const controlContainer = document.createElement('div')
    controlContainer.className = 'mapboxgl-ctrl mapboxgl-ctrl-group'
    controlContainer.appendChild(drawButton)

    this.map.addControl({
      onAdd: () => controlContainer,
      onRemove: () => controlContainer.remove()
    }, 'top-left')

    this.map.on('click', (e) => {
      if (this.drawingMode) {
        this.addPointToDrawing(e.lngLat)
      }
    })
  }

  toggleDrawingMode() {
    this.drawingMode = !this.drawingMode
    if (this.drawingMode) {
      this.map.getCanvas().style.cursor = 'crosshair'
      this.currentDrawing = []
    } else {
      this.map.getCanvas().style.cursor = ''
      this.finishDrawing()
    }
  }

  addPointToDrawing(lngLat) {
    this.currentDrawing.push([lngLat.lng, lngLat.lat])
    
    if (this.currentDrawing.length >= 3) {
      this.updateDrawingPreview()
    }
  }

  updateDrawingPreview() {
    const coordinates = [...this.currentDrawing, this.currentDrawing[0]] // Close the polygon
    
    this.map.getSource('search-areas').setData({
      type: 'FeatureCollection',
      features: [{
        type: 'Feature',
        geometry: {
          type: 'Polygon',
          coordinates: [coordinates]
        },
        properties: {
          id: 'preview'
        }
      }]
    })
  }

  finishDrawing() {
    if (this.currentDrawing.length >= 3) {
      this.saveSearchArea(this.currentDrawing)
      this.filterListingsByArea(this.currentDrawing)
    }
    this.currentDrawing = []
  }

  saveSearchArea(coordinates) {
    // Save to localStorage or send to server
    const savedAreas = JSON.parse(localStorage.getItem('savedSearchAreas') || '[]')
    savedAreas.push({
      id: Date.now(),
      name: `Zone ${savedAreas.length + 1}`,
      coordinates: coordinates,
      createdAt: new Date()
    })
    localStorage.setItem('savedSearchAreas', JSON.stringify(savedAreas))
  }

  filterListingsByArea(coordinates) {
    // Filtre les listings qui se trouvent dans le polygone dessiné
    if (!this.listingsValue || coordinates.length < 3) return

    const polygon = coordinates.map(coord => ({ x: coord[0], y: coord[1] }))
    
    const filteredListings = this.listingsValue.filter(listing => {
      const point = { x: parseFloat(listing.longitude), y: parseFloat(listing.latitude) }
      return this.isPointInPolygon(point, polygon)
    })

    this.updateMapWithFilteredListings(filteredListings)
  }

  isPointInPolygon(point, polygon) {
    let inside = false
    for (let i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
      if (((polygon[i].y > point.y) !== (polygon[j].y > point.y)) &&
          (point.x < (polygon[j].x - polygon[i].x) * (point.y - polygon[i].y) / (polygon[j].y - polygon[i].y) + polygon[i].x)) {
        inside = !inside
      }
    }
    return inside
  }

  updateMapWithFilteredListings(filteredListings) {
    const features = filteredListings.map(listing => ({
      type: 'Feature',
      geometry: {
        type: 'Point',
        coordinates: [parseFloat(listing.longitude), parseFloat(listing.latitude)]
      },
      properties: {
        id: listing.id,
        title: listing.title,
        price: listing.price,
        make: listing.make,
        model: listing.model,
        year: listing.year,
        kilometers: listing.kilometers,
        type: listing.type || 'vehicle',
        image: listing.image_url,
        url: listing.url
      }
    })).filter(feature => 
      feature.geometry.coordinates[0] && feature.geometry.coordinates[1]
    )

    this.map.getSource('listings').setData({
      type: 'FeatureCollection',
      features: features
    })
  }

  loadListings() {
    if (!this.listingsValue || this.listingsValue.length === 0) return

    const features = this.listingsValue.map(listing => ({
      type: 'Feature',
      geometry: {
        type: 'Point',
        coordinates: [parseFloat(listing.longitude), parseFloat(listing.latitude)]
      },
      properties: {
        id: listing.id,
        title: listing.title,
        price: listing.price,
        make: listing.make,
        model: listing.model,
        year: listing.year,
        kilometers: listing.kilometers,
        type: listing.type || 'vehicle',
        image: listing.image_url,
        url: listing.url
      }
    })).filter(feature => 
      feature.geometry.coordinates[0] && feature.geometry.coordinates[1]
    )

    this.map.getSource('listings').setData({
      type: 'FeatureCollection',
      features: features
    })

    if (features.length > 0 && this.autoCenterValue) {
      this.fitMapToListings(features)
    }
  }

  fitMapToListings(features) {
    const bounds = new mapboxgl.LngLatBounds()
    features.forEach(feature => {
      bounds.extend(feature.geometry.coordinates)
    })

    this.map.fitBounds(bounds, {
      padding: 50,
      maxZoom: 12
    })
  }

  showListingPopup(e) {
    const feature = e.features[0]
    const properties = feature.properties
    
    const distance = this.userLocation ? 
      this.calculateDistance(
        this.userLocation[1], this.userLocation[0],
        feature.geometry.coordinates[1], feature.geometry.coordinates[0]
      ) : null

    const popupContent = `
      <div class="listing-popup max-w-sm">
        ${properties.image ? `<img src="${properties.image}" alt="${properties.title}" class="w-full h-32 object-cover rounded-t-lg">` : ''}
        <div class="p-4">
          <h3 class="font-bold text-lg mb-2">${properties.title}</h3>
          <p class="text-gray-600 mb-2">${properties.make} ${properties.model} - ${properties.year}</p>
          <p class="text-xl font-bold text-blue-600 mb-2">${new Intl.NumberFormat('fr-FR', {style: 'currency', currency: 'EUR'}).format(properties.price)}</p>
          <p class="text-sm text-gray-500 mb-3">${properties.kilometers ? properties.kilometers.toLocaleString() + ' km' : 'Kilométrage non spécifié'}</p>
          ${distance ? `<p class="text-sm text-green-600 mb-3">📍 À ${distance.toFixed(1)} km de vous</p>` : ''}
          <div class="flex gap-2">
            <a href="${properties.url}" class="btn btn-primary btn-sm flex-1">Voir l'annonce</a>
            ${this.showRouteValue ? `<button class="btn btn-outline btn-sm" onclick="this.closest('[data-controller=\"map\"]').dispatchEvent(new CustomEvent('map:showRoute', {detail: {coordinates: [${feature.geometry.coordinates}]}}))">🗺️ Itinéraire</button>` : ''}
          </div>
        </div>
      </div>
    `

    new mapboxgl.Popup({
      closeButton: true,
      closeOnClick: false,
      maxWidth: '300px'
    })
      .setLngLat(feature.geometry.coordinates)
      .setHTML(popupContent)
      .addTo(this.map)
  }

  showRoute(event) {
    const { coordinates } = event.detail
    if (!this.userLocation) {
      alert('Géolocalisation nécessaire pour calculer l\'itinéraire')
      return
    }

    this.getRoute(this.userLocation, coordinates)
  }

  async getRoute(start, end) {
    const query = await fetch(
      `https://api.mapbox.com/directions/v5/mapbox/driving/${start[0]},${start[1]};${end[0]},${end[1]}?steps=true&geometries=geojson&access_token=${mapboxgl.accessToken}&language=fr`,
      { method: 'GET' }
    )

    const json = await query.json()
    const data = json.routes[0]
    const route = data.geometry.coordinates

    this.map.getSource('route').setData({
      type: 'Feature',
      properties: {},
      geometry: {
        type: 'LineString',
        coordinates: route
      }
    })

    // Show route information
    if (this.hasRouteInfoTarget) {
      this.routeInfoTarget.innerHTML = `
        <div class="alert alert-info">
          <div>
            <h4 class="font-bold">Itinéraire calculé</h4>
            <p>Distance: ${(data.distance / 1000).toFixed(1)} km</p>
            <p>Durée: ${Math.round(data.duration / 60)} minutes</p>
          </div>
        </div>
      `
    }

    // Fit map to route
    const bounds = new mapboxgl.LngLatBounds()
    route.forEach(coord => bounds.extend(coord))
    this.map.fitBounds(bounds, { padding: 50 })
  }

  calculateDistance(lat1, lon1, lat2, lon2) {
    const R = 6371 // Radius of the Earth in km
    const dLat = this.deg2rad(lat2 - lat1)
    const dLon = this.deg2rad(lon2 - lon1)
    const a =
      Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos(this.deg2rad(lat1)) * Math.cos(this.deg2rad(lat2)) *
      Math.sin(dLon / 2) * Math.sin(dLon / 2)
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
    const d = R * c // Distance in km
    return d
  }

  deg2rad(deg) {
    return deg * (Math.PI / 180)
  }

  updateDistances() {
    if (!this.userLocation) return

    const features = this.map.querySourceFeatures('listings')
    features.forEach(feature => {
      if (feature.geometry.type === 'Point') {
        const distance = this.calculateDistance(
          this.userLocation[1], this.userLocation[0],
          feature.geometry.coordinates[1], feature.geometry.coordinates[0]
        )
        feature.properties.distance = distance
      }
    })

    // Update distance info display
    if (this.hasDistanceInfoTarget) {
      this.distanceInfoTarget.innerHTML = `
        <div class="badge badge-info">
          📍 Position utilisateur mise à jour
        </div>
      `
    }
  }

  handleSearchFilter(eventDetail) {
    const { filters } = eventDetail
    this.filterListings(filters)
  }

  filterListings(filters) {
    // If filters is an event (old behavior), extract form data
    if (filters && filters.target && filters.preventDefault) {
      const form = filters.target
      const formData = new FormData(form)
      filters = {}
      for (let [key, value] of formData.entries()) {
        filters[key] = value
      }
    }
    
    console.log("Filtering listings with:", filters)
    
    if (!this.listingsValue || this.listingsValue.length === 0) {
      console.warn("No listings available to filter")
      return
    }
    
    const filteredListings = this.listingsValue.filter(listing => {
      let matches = true

      // Filter by make
      if (filters.make && filters.make !== '') {
        matches = matches && listing.make.toLowerCase().includes(filters.make.toLowerCase())
      }

      // Filter by model
      if (filters.model && filters.model !== '') {
        matches = matches && listing.model.toLowerCase().includes(filters.model.toLowerCase())
      }

      // Filter by price range
      if (filters.min_price) {
        matches = matches && listing.price >= parseInt(filters.min_price)
      }
      if (filters.max_price) {
        matches = matches && listing.price <= parseInt(filters.max_price)
      }

      // Filter by year range
      if (filters.min_year) {
        matches = matches && listing.year >= parseInt(filters.min_year)
      }
      if (filters.max_year) {
        matches = matches && listing.year <= parseInt(filters.max_year)
      }

      // Filter by fuel type
      if (filters.fuel_type && filters.fuel_type !== '') {
        matches = matches && listing.fuel_type === filters.fuel_type
      }

      // Filter by transmission
      if (filters.transmission && filters.transmission !== '') {
        matches = matches && listing.transmission === filters.transmission
      }

      // Filter by kilometers
      if (filters.max_kilometers) {
        matches = matches && listing.kilometers <= parseInt(filters.max_kilometers)
      }

      // Filter by distance if user location is available and radius is specified
      if (this.userLocation && filters.radius && filters.radius !== '') {
        const distance = this.calculateDistance(
          this.userLocation[1], this.userLocation[0],
          parseFloat(listing.latitude), parseFloat(listing.longitude)
        )
        matches = matches && distance <= parseInt(filters.radius)
      }

      return matches
    })

    console.log(`Filtered ${filteredListings.length} listings out of ${this.listingsValue.length}`)

    // Update map with filtered listings
    const features = filteredListings.map(listing => ({
      type: 'Feature',
      geometry: {
        type: 'Point',
        coordinates: [parseFloat(listing.longitude), parseFloat(listing.latitude)]
      },
      properties: {
        id: listing.id,
        title: listing.title,
        price: listing.price,
        make: listing.make,
        model: listing.model,
        year: listing.year,
        kilometers: listing.kilometers,
        type: listing.type || 'vehicle',
        image: listing.image_url,
        url: listing.url
      }
    })).filter(feature => 
      feature.geometry.coordinates[0] && feature.geometry.coordinates[1]
    )

    // Ensure map and source are available
    if (this.map && this.map.getSource('listings')) {
      this.map.getSource('listings').setData({
        type: 'FeatureCollection',
        features: features
      })

      // Update the count display
      if (this.hasDistanceInfoTarget) {
        this.distanceInfoTarget.innerHTML = `
          <div class="alert alert-success">
            <div>
              <h4 class="font-bold">Résultats filtrés</h4>
              <p>${filteredListings.length} annonce(s) trouvée(s)</p>
            </div>
          </div>
        `
      }

      // Optionally fit the map to the filtered results
      if (features.length > 0) {
        this.fitMapToListings(features)
      }
    } else {
      console.error("Map or listings source not available")
    }
  }

  // Method to load service providers
  loadServiceProviders(providers) {
    const features = providers.map(provider => ({
      type: 'Feature',
      geometry: {
        type: 'Point',
        coordinates: [parseFloat(provider.longitude), parseFloat(provider.latitude)]
      },
      properties: {
        id: provider.id,
        name: provider.name,
        type: provider.service_type,
        rating: provider.rating,
        address: provider.address
      }
    })).filter(feature => 
      feature.geometry.coordinates[0] && feature.geometry.coordinates[1]
    )

    this.map.getSource('services').setData({
      type: 'FeatureCollection',
      features: features
    })
  }

  // Méthodes pour gérer les options de la carte
  toggleAutoCenter(event) {
    this.autoCenterValue = event.target.checked
    if (this.autoCenterValue && this.listingsValue.length > 0) {
      this.fitMapToListings(this.getListingFeatures())
    }
  }

  toggleRoutes(event) {
    this.showRouteValue = event.target.checked
    if (!this.showRouteValue) {
      // Effacer la route actuelle
      this.map.getSource('route').setData({
        type: 'Feature',
        properties: {},
        geometry: {
          type: 'LineString',
          coordinates: []
        }
      })
      if (this.hasRouteInfoTarget) {
        this.routeInfoTarget.classList.add('hidden')
      }
    }
  }

  toggleDrawing(event) {
    this.enableDrawingValue = event.target.checked
    if (this.enableDrawingValue && !this.drawingMode) {
      this.setupDrawingTools()
    }
  }

  getListingFeatures() {
    return this.listingsValue.map(listing => ({
      type: 'Feature',
      geometry: {
        type: 'Point',
        coordinates: [parseFloat(listing.longitude), parseFloat(listing.latitude)]
      },
      properties: {
        id: listing.id,
        title: listing.title,
        price: listing.price,
        make: listing.make,
        model: listing.model,
        year: listing.year,
        kilometers: listing.kilometers,
        type: listing.type || 'vehicle',
        image: listing.image_url,
        url: listing.url
      }
    })).filter(feature => 
      feature.geometry.coordinates[0] && feature.geometry.coordinates[1]
    )
  }

  // Gestionnaire d'événement pour charger une zone sauvegardée
  loadArea(event) {
    const { coordinates } = event.detail
    if (coordinates && coordinates.length >= 3) {
      this.filterListingsByArea(coordinates)
      
      // Centrer la carte sur la zone
      const bounds = new mapboxgl.LngLatBounds()
      coordinates.forEach(coord => bounds.extend(coord))
      this.map.fitBounds(bounds, { padding: 50 })
    }
  }
} 