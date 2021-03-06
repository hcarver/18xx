if (typeof setTimeout === 'undefined') { function setTimeout(func) { func() } }

if (typeof EventSource === 'undefined') { function EventSource(path) { } }

if (typeof window == 'undefined') {
  window = {
    requestAnimationFrame: function() {},
    addEventListener: function() {},
    location: {
      pathname: ''
    },
    history: {
      pushState: function() {}
    }
  }
}

if (typeof localStorage == 'undefined') {
  localStorage = {
    getItem: function() {},
    setItem: function() {}
  }
}
