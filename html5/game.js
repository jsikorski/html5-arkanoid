//the canvas
var canvas;
var canvasContext;

//the graphic
var bg = {
	ready: false,
	img: null
};
var pad = {
	ready: false,
	img: null
};
var ball = {
	ready: false,
	img: null
};

//game data
var pad = {
	x: 250,
	y: 700
};
var ball = {
	x: 200,
	y: 200
};
var then = Date.now();

//keyboard data
var keysDown = {};

addEventListener("keydown", function (e) {
	keysDown[e.keyCode] = true;
}, false);

addEventListener("keyup", function (e) {
	delete keysDown[e.keyCode];
}, false);

//game functions
function createCanvas(){
	canvas = document.createElement("canvas");
	canvasContext = canvas.getContext("2d");
	
	canvas.width = 498;
	canvas.height = 750;
	document.body.appendChild(canvas);
}

function loadGraphics(){
	// load background image
	bg.img = new Image();
	bg.img.src = "background.png";
	bg.img.onload = function () {
		bg.ready = true;
	};
	
	// load pad
	pad.img = new Image();
	pad.img.src = "pad.png";
	pad.img.onload = function () {
		pad.ready = true;
	};
	
	// load ball
	ball.img = new Image();
	ball.img.src = "ball.png";
	ball.img.onload = function () {
		ball.ready = true;
	};
}

// Update game objects
function update(modifier) {
	if (37 in keysDown) { // Player holding left
		pad.x -= 255 * modifier;
	}
	if (39 in keysDown) { // Player holding right
		pad.x += 255 * modifier;
	}
};

function render() {
	if (bg.ready) {
		canvasContext.drawImage(bg.img, 0, 0);
	}

	if (pad.ready) {
		canvasContext.drawImage(pad.img, pad.x, pad.y);
	}

	if (ball.ready) {
		canvasContext.drawImage(ball.img, ball.x, ball.y);
	}
};

// The main game loop
function mainLoop() {
	var now = Date.now();
	var delta = now - then;

	update(delta / 1000);
	render();

	then = now;
};

function init(){
	createCanvas();
	loadGraphics();
	
	setInterval(mainLoop, 1); // Execute as fast as possible
}