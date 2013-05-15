(function(){var e,t,s,n,r,i,o,h=function(e,t){return function(){return e.apply(t,arguments)}};i=function(){var e,t,s,n;return e=document.querySelector(".canvas"),t=document.createElement("div"),t.className="character",t.innerHTML="&nbsp;",e.appendChild(t),s=document.defaultView.getComputedStyle(t,""),n=t.offsetHeight+parseInt(s.getPropertyValue("margin-top"))+parseInt(s.getPropertyValue("margin-bottom")),e.removeChild(t),n},e=function(){function e(e){this.el=e,this.keypress_listener=h(this.keypress_listener,this),this.keydown_listener=h(this.keydown_listener,this),this.error=h(this.error,this),this.move_right=h(this.move_right,this),this.move_left=h(this.move_left,this),this.enter=h(this.enter,this),this["delete"]=h(this["delete"],this),this.el.style.height=i()+"px",this.pos=0,window.onkeydown=this.keydown_listener,window.onkeypress=this.keypress_listener}return e.prototype.set_canvas=function(e){this.canvas=e},e.prototype["delete"]=function(e){var t;return e.preventDefault(),t=this.canvas.children[this.pos-1],t?(this.pos-=1,this.canvas.removeChild(t)):this.error()},e.prototype.enter=function(){var e;return e=document.createElement("br"),e.className="newline",this.canvas.insertBefore(e,this.el),this.pos+=1},e.prototype.move_left=function(){var e;return this.pos>0?(e=this.canvas.children[this.pos-1],this.pos-=1,this.canvas.removeChild(this.el),this.canvas.insertBefore(this.el,e)):this.error()},e.prototype.move_right=function(){var e,t;return this.pos<=this.canvas.children.length-2?(e=this.pos===this.canvas.children.length-2,t=this.canvas.children[this.pos+2],this.pos+=1,this.canvas.removeChild(this.el),e?this.canvas.appendChild(this.el):this.canvas.insertBefore(this.el,t)):this.error()},e.prototype.error=function(){var e;return this.el.className="cursor error",e=this.el,setTimeout(function(){return e.className="cursor"},500)},e.prototype.keydown_listener=function(e){switch(e.which){case 8:return this["delete"](e);case 37:return this.move_left();case 39:return this.move_right();case 13:return this.enter()}},e.prototype.keypress_listener=function(e){var t;return e.which!==13?(t=document.createElement("div"),t.className="character",t.innerHTML=String.fromCharCode(e.which),t.innerHTML===" "&&(t.innerHTML="&nbsp;"),this.canvas.insertBefore(t,this.el),this.pos+=1):void 0},e}(),t=function(){function e(e){this.canvas=e,this.onchange_listener=h(this.onchange_listener,this),this.canvas.onchange=this.onchange_listener}return e.prototype.onchange_listener=function(){return console.log("Change")},e}(),s=document.querySelector(".canvas"),n=document.querySelector(".char-counter"),r=document.querySelector(".cursor"),r=new e(r),r.set_canvas(s),o=new t(s)}).call(this);