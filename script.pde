//Food Configuration
var FOOD_SIZE = 10;
var FOOD_QUANTITY = 10;

//Critter Configuration
var CRITTER_QUANTITY = 15;
var CRITTER_STARTING_MASS = 60;
var CRITTER_COUNTER = 0;
var CRITTER_DECAY_SPEED = 0.25;
var CRITTER_AVG_RANGE = 4;
var CRITTER_AVG_EATSPEED = 2;
var CRITTER_AVG_ACCSPEED = 0.5;
var CRITTER_AVG_MAXSPEED = 2;
var CRITTER_RANGE_DEVIATION = 2;
var CRITTER_EATSPEED_DEVIATION = 0.5;
var CRITTER_DECAY_DEVIATION = 0.5;
var CRITTER_ACCSPEED_DEVIATION = 0.5;
var CRITTER_MAXSPEED_DEVIATION = 0.5;

//Predator Configuration    
var PREDATOR_STARTING_MASS = 60;
var PREDATOR_AVG_ACCSPEED = 1;
var PREDATOR_AVG_MAXSPEED = 4;
var PREDATOR_COUNTER = 0;

//Setup
size(750,750);
fill(0,0,0);
rectMode(CENTER);


//Create Critters
var Critter = function(){
    this.pos = new PVector(Math.random() * width,Math.random() * height);
    this.vel = new PVector();
    this.acc = new PVector();
    this.target = null;
    this.status = 0;  // 0 = Looking for Food   |   1 = Eating Food |   2 = Fleeing
    this.generation = CRITTER_COUNTER;
    this.mass = CRITTER_STARTING_MASS;
    CRITTER_COUNTER++;
    
    this.range    = CRITTER_AVG_RANGE    + (randomGaussian() * CRITTER_RANGE_DEVIATION);
    this.eatSpeed = CRITTER_AVG_EATSPEED + (randomGaussian() * CRITTER_EATSPEED_DEVIATION);
    this.accSpeed = CRITTER_AVG_ACCSPEED + (randomGaussian() * CRITTER_ACCSPEED_DEVIATION);
    this.maxSpeed = CRITTER_AVG_MAXSPEED + (randomGaussian() * CRITTER_MAXSPEED_DEVIATION);

    Critter.prototype.draw = function(){
        this.update();
        stroke(0,0,0);
        fill(30,30,30,150);
        stroke(0,0,0);
        if(this.status == 0){stroke(0,0,0);
        }else if(this.status == 1){ 
            line(this.pos.x, this.pos.y, this.target.pos.x, this.target.pos.y);
            stroke(200,0,0);  }
        ellipse(this.pos.x, this.pos.y, this.mass/3,this.mass/3); 
    };
    
    Critter.prototype.update = function(){
        this.mass -= CRITTER_DECAY_SPEED;
        if(this.mass <= 0){ this.die(); }
        if(this.target == null){    this.getTarget(); }
        if(this.status == 0){   this.moveToFood();  }
        if(this.status == 1){   this.eatFood();     }
        this.vel.add(this.acc);
        this.vel.limit(this.maxSpeed);
        this.pos.add(this.vel);
        this.acc = new PVector();
    } 
    Critter.prototype.moveToFood = function(){
        var dif = PVector.sub(this.pos, this.target.pos);
        var dist = dif.mag();
        if(dist < this.range){
            this.status = 1;
            this.vel = new PVector(0,0);
        }else{
            var dir = PVector.normalize(dif);
            dir.mult(-1*this.accSpeed);
            this.acc = dir;
        }
    };
    Critter.prototype.getTarget = function(){
        this.target = foodList[0];
        var mag = (PVector.sub(this.pos, foodList[0].pos).mag());
        for(var i = 1; i < foodList.length;i++){
            var tempMag = PVector.sub(this.pos, foodList[i].pos).mag();
            if(tempMag < mag){
                this.target = foodList[i];
                mag = tempMag;
            } 
        }
        this.target.occupants.push(this);
    }
    Critter.prototype.eatFood = function(){
        this.mass += this.eatSpeed;
        this.target.size -= this.eatSpeed;
        if(this.target.size <= 0){
            this.target.remove();
        }
    }
    Critter.prototype.die = function(){
        var dyingCritter = critterList.indexOf(this);
        
        var sumRange = 0;
        var sumEatSpeed = 0;
        var sumAccSpeed = 0;
        var sumMaxSpeed = 0;
        var critListLength = critterList.length - 1;
        for(var i = 0; i < critterList.length; i++){
            if(i != dyingCritter){
            sumRange+= critterList[i].range;
            sumEatSpeed+= critterList[i].eatSpeed;
            sumAccSpeed+= critterList[i].accSpeed;
            sumMaxSpeed+= critterList[i].maxSpeed;
            }

        }
        CRITTER_AVG_RANGE = sumRange/critListLength;
        CRITTER_AVG_EATSPEED = sumEatSpeed/critListLength;
        CRITTER_AVG_ACCSPEED = sumAccSpeed/critListLength;
        CRITTER_AVG_MAXSPEED = sumMaxSpeed/critListLength;
        critterList[dyingCritter] = new Critter();
    }
};

var Predator = function(){
    this.pos = new PVector(Math.random() * width,Math.random() * height);
    this.vel = new PVector();
    this.acc = new PVector();
    this.target = null;
    this.status = 0;  // 0 = Looking for Food   |   1 = Eating Food 
    this.generation = PREDATOR_COUNTER;
    this.mass = PREDATOR_STARTING_MASS;
    PREDATOR_COUNTER++;
    

    this.eatSpeed = PREDATOR_AVG_EATSPEED + (randomGaussian() * PREDATOR_EATSPEED_DEVIATION);
    this.accSpeed = PREDATOR_AVG_ACCSPEED + (randomGaussian() * PREDATOR_ACCSPEED_DEVIATION);
    this.maxSpeed = PREDATOR_AVG_MAXSPEED + (randomGaussian() * PREDATOR_MAXSPEED_DEVIATION);
    
}

var Food = function(){
    this.pos = new PVector(Math.random() * width,Math.random() * height); 
    this.size = 50 * Math.random();
    this.occupants = [];
    Food.prototype.draw = function(){
        noStroke();
        fill(50,50,50);
        rect(this.pos.x, this.pos.y, this.size, this.size);
    };
    Food.prototype.remove = function(){
        var index = foodList.indexOf(this);
        foodList[index] = new Food();
        for(var i = 0; i < this.occupants.length;i++){
            this.occupants[i].target = null;
            this.occupants[i].status = 0;
            this.occupants[i].update();
        }
        
    };
}

var bubbleSortCritters = function(input[]){
    var swapped = false;
    for(var i = 0; i < input.length - 1;i++){
       if(input[i].mass < input[i+1].mass){    
           swap(i, i+1, input);
           swapped = true;
       }
    }
 if(swapped){ bubbleSortCritters(input);}
}

var swap = function(var first, var second, input[]){
    var holdFirst = input[first];
    input[first] = input[second];
    input[second] = holdFirst;
}


//Storage
var critterList = [];
for(var i = 0; i < CRITTER_QUANTITY; i++){
    critterList.push(new Critter());
}

var foodList = [];
for(var i = 0; i < FOOD_QUANTITY; i++){
    foodList.push(new Food());
}


void draw(){
    //Creating Background
    
    
    var infoBar = $("#info");
    infoBar.text("");
    
   
    bubbleSortCritters(critterList);
    infoBar.append("<table align='center'> <tbody id='infoBody'> </table>")
    var body = $('#infoBody');
    body.html("<tr><th>Critters</th></tr>");
    body.append("<tr'><th>Rank</th><th>Mass</th><th>Range</th><th>Eat Speed</th><th>Acc Speed</th><th>Max Speed</th><th>Gen</th></tr>");
    for(var i = 0; i < critterList.length;i++){
       
        body.append("<tr'><td>" + (i+1) 
                       + "</td><td>" + Math.round(critterList[i].mass)
                       + "</td><td>" + Math.round(critterList[i].range) 
                       + "</td><td>" + Math.round(critterList[i].eatSpeed)
                       + "</td><td>" + Math.round(critterList[i].accSpeed)
                       + "</td><td>" + Math.round(critterList[i].maxSpeed)
                       + "</td><td>" + Math.round(critterList[i].generation)
                       + "</tr>"); 
    }

    
    body.append("<tr><th>" + "Avg:" 
                       + "</th><th>" + " "
                       + "</th><th>" + Math.round(CRITTER_AVG_RANGE)
                       + "</th><th>" + Math.round(CRITTER_AVG_EATSPEED)
                       + "</th><th>" + Math.round(CRITTER_AVG_ACCSPEED)
                       + "</th><th>" + Math.round(CRITTER_AVG_MAXSPEED)
                       + "</th><th>" + " "
                       + "</tr>"); 
      
    background(200,200,190);
    for(var i = 0; i < width; i+=20){
       stroke(150,150,150);
       line(i,0,i,height);
       line(0,i,width,i);
    }
    for(int i = 0; i < foodList.length;i++){
        foodList[i].draw();
    }
    for(var i = 0; i < critterList.length; i++){
        critterList[i].draw();
    }


}

