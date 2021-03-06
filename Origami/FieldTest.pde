import java.util.concurrent.*;

public class Field implements Runnable{
  int numNeighbors = 5;
  int numNodes = 10;
  float xOffset, yOffset;
  float xMax = 200;
  float yMax = 200;
  float speedDif = 16;
  float speedScale = 10;
  Particle[] particles = new Particle[numNodes];
  //might change
  Thread[] threads = new Thread[numNodes];
  int maxDist = 1000;
  boolean sameDir;
  
  public Field(float xOffset, float yOffset, float xMax, float yMax, boolean sameDir){
    this.xOffset = xOffset;
    this.yOffset = yOffset;
    this.xMax = xMax;
    this.yMax = yMax;
    this.sameDir = sameDir;
    for(int i = 0; i < numNodes; i ++){
      particles[i] = new Particle(xMax, yMax, speedDif, speedScale, numNeighbors, sameDir, numNodes, particles);
    }
  }
  
  void drawLines(){
    for(int i = 0; i < numNodes; i++){
      for(int j = 0; j < numNeighbors; j++){
        line(particles[i].x + xOffset, particles[i].y + yOffset, particles[i].neighbors[j].x + xOffset, particles[i].neighbors[j].y + yOffset);
      }
    }
  }
  
  void drawTriangles(){
    float x1, y1, x2, y2;
    for(int i = 0; i < numNodes; i++){
      x1 = particles[i].neighbors[0].x;
      x2 = particles[i].neighbors[1].x;
      y1 = particles[i].neighbors[0].y;
      y2 = particles[i].neighbors[1].y;
      fill((float)(255/(i+1)));
      triangle(particles[i].x + xOffset, particles[i].y + yOffset, x1 + xOffset, y1 + yOffset, x2 + xOffset, y2 + yOffset);
    }
  }
  
  void drawSquares(){
    float x1, y1, x2, y2, x3, y3;
    for(int i = 0; i < numNodes; i++){
      x1 = particles[i].neighbors[0].x;
      x2 = particles[i].neighbors[1].x;
      x3 = particles[i].neighbors[2].x;
      y1 = particles[i].neighbors[0].y;
      y2 = particles[i].neighbors[1].y;
      y3 = particles[i].neighbors[2].y;
      quad(particles[i].x + xOffset, particles[i].y + yOffset, x1 + xOffset, y1 + yOffset, x2 + xOffset, y2 + yOffset, x3 + xOffset, y3 + yOffset);
    }
  }
  
  void drawTriangleFan(){
    float x1, y1, x2, y2, x3, y3, x4, y4;
    int r, g, b;
    for(int i = 0; i < numNodes; i++){
      x1 = particles[i].neighbors[0].x + xOffset;
      y1 = particles[i].neighbors[0].y + yOffset;
      x2 = particles[i].neighbors[1].x + xOffset;
      y2 = particles[i].neighbors[1].y + yOffset;
      x3 = particles[i].neighbors[2].x + xOffset;
      y3 = particles[i].neighbors[2].y + yOffset;
      x4 = particles[i].neighbors[3].x + xOffset;
      y4 = particles[i].neighbors[3].y + yOffset;
      
      beginShape (TRIANGLE_FAN);
      fill((float)(255/(i+1)));
      vertex(particles[i].x + xOffset, particles[i].y + yOffset);
      vertex(x1, y1);
      vertex(x2, y2);
      vertex(x3, y3);
      vertex(x4, y4);
      endShape();
    }
  }
  
  void draw(){
    //quad(xOffset, yOffset, xOffset, yOffset + yMax, xOffset + xMax,  xOffset + yMax, xOffset + xMax, yOffset);
    //drawLines();
    drawTriangles();
    //drawSquares();
    //drawTriangleFan();
  }
  
  void step(){
    for(int i = 0; i < numNodes; i++){
      //particles[i].applyMovement();
      //particles[i].getNeighbors(numNeighbors, numNodes, particles);
      //threads[i] = new Thread(particles[i]);
      //threads[i].start();
      particles[i].run();
    }
    /*
    for(int i = 0; i < numNodes; i++){
      try {
        threads[i].join();
      } catch (InterruptedException e) {
        e.printStackTrace();
      }
    }
    */
    
  }
  
  public void run(){
    step();
    synchronized(m){
      while(true){
        try {
          m.wait();
          getSem();
          step();
          s.release();
        }catch(InterruptedException e){
          e.printStackTrace();
        }
      }
    }
  }
}
Field fs[] = new Field[4];
Thread ts[] = new Thread[4];
Semaphore s = new Semaphore(4);
Object m = new Object();

void setup(){
  size(500, 500);
  background(255,0,0);
  fs[0] = new Field(50, 50, 200, 200, true);
  fs[1] = new Field(50, 250, 200, 200, false);
  fs[2] = new Field(250, 50, 200, 200, false);
  fs[3] = new Field(250, 250, 200, 200, true);
  
  for(int i = 0; i < fs.length; i++){
    ts[i] = new Thread(fs[i]);
    ts[i].start();
  }
}

void getSem(){
  try{
      s.acquire();
    } catch(InterruptedException exc){
      System.out.println(exc); 
    }
}

void draw(){
  clear();
  background(255,0,0);
  synchronized(m){
    for(int i = 0; i < 4; i++){
      getSem();
    }
    for(int i = 0; i < fs.length; i++){
      fs[i].draw();
    }
    m.notifyAll();
    for(int i = 0; i < 4; i++){
      s.release();
    }
  }
}

void mousePressed(){
  fs[0].xMax = 1000;
  fs[1].xMax = 1000;
}

void mouseReleased(){
  fs[0].xMax = 200;
  fs[1].xMax = 200;
}
