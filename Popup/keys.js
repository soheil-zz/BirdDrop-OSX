document.body.addEventListener('keydown', function(ev) {
  var sel;
  
  switch(String.fromCharCode(ev.keyCode)) {
    case 'H': sel = '.navbar div[tab="tweets"]'; break;
    case 'C': sel = '.navbar div[tab="connect"]'; break;
    case 'D': sel = '.navbar div[tab="discover"]'; break;
    case 'M': sel = '.navbar div[tab="account"]'; break;
  }
  console.log(sel);
  var el = document.querySelector(sel);
  console.log(el);
  if (el) {
    var evt = document.createEvent('MouseEvents');
    evt.initMouseEvent('click', true, true,
         window, 0, 0, 0, 0, 0, false,
         false, false, false, 0, null);

    el.dispatchEvent(evt);
  }
}, false);
