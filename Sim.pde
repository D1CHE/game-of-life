///////////////////////////START Sim////////////////////////////

public class Sim
{
  int grid[];
  int tempGrid[];
  int w, h;
  int arraySize;
  int readP;
 
  Sim(int w_, int h_)
  {
    w = w_;
    h = h_;
    readP = 0;
    arraySize = (w_+2) * (h_+2);
    grid = new int[arraySize];
    tempGrid = new int[arraySize];
    clearPixels();
  }
  
  void clearPixels()
  {
    for (int i=0; i<arraySize; i++)
    {
      grid[i] = -1;
      tempGrid[i] = -1;
    }
  }
  
  void setPixels(PImage img, int x, int y)
  {
    for (int i=0; i<img.height; i++)
    {
      for (int j=0; j<img.width; j++)
      {
        grid[((w*x)+y)+((w*j)+i)] = img.pixels[(img.width*i)+j];
      }
    }
  }
  
  void calculatePixels()
  {
    int state = -1;
    int totalgrid = 0;
    int random = int(random(-16777261, -1));
    for (int i=1; i<h; i++)
    {
      for (int j=1; j<w; j++)
      {
        state = grid[(w*j)+i];
        totalgrid = 0;
        if (grid[((w*j)+i)-(w-1)] < -1) totalgrid++; // left upper box
        if (grid[((w*j)+i)-w]< -1) totalgrid++; // upper box
        if (grid[((w*j)+i)-(w+1)]< -1) totalgrid++; // right upper box
        if (grid[((w*j)+i)-1]< -1) totalgrid++; // left box
        if (grid[((w*j)+i)+1]< -1) totalgrid++; // right box
        if (grid[((w*j)+i)+(w-1)]< -1) totalgrid++; // left lower box
        if (grid[((w*j)+i)+w]< -1) totalgrid++; // lower box
        if (grid[((w*j)+i)+(w+1)]< -1) totalgrid++;  // right lower box
        
        if (grid[(w*j)+i] < -1 && totalgrid<2) state = -1;
        else if (grid[(w*j)+i] < -1 && totalgrid>3) state = -1;
        else if (grid[(w*j)+i] < -1 && (totalgrid==2 || totalgrid==3)) state = random;
        else if (grid[(w*j)+i] == -1 && totalgrid==3) state = random;
        tempGrid[(w*j)+i] = state;
      }
    }
      
    for (int i=0; i<arraySize; i++)
    {
      grid[i] = tempGrid[i];
    }
  }
  
  void resetIndex()
  {
    readP = 0;
  }
  
  int getPixel()
  {
    if (readP >= arraySize) return -1;
    else return grid[readP++];
  }
}///////////////////////////END Sim////////////////////////////
