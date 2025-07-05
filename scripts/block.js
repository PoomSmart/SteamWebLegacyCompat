(function() {
    console.log('Steam Chunk Blocker: Injecting chunk blocking code');

    const originalXHROpen = XMLHttpRequest.prototype.open;
    XMLHttpRequest.prototype.open = function(method, url, ...args) {
        if (url.includes('chunk~07d43922c') || url.includes('events.js') || url.includes('2538.js')) {
            console.warn('Steam Chunk Blocker: Blocked XHR request for:', url);
            // Create a fake request, as blank JS
            url = 'data:text/javascript,console.warn("Steam Chunk Blocker: Blocked request")';
        }
        return originalXHROpen.call(this, method, url, ...args);
    };

    console.log('Steam Chunk Blocker: Blocking mechanisms installed');
})();
