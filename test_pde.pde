PImage img = loadImage("a.jpg");
size(600, 400);
loadPixels(); 
img.loadPixels();
for (int y = 0; y < img.height; y++)
  for (int x = 0; x < img.width; x++) {
    int index = x + y * img.width;
    float r = red (img.pixels[index]);
    float g = green(img.pixels[index]);
    float b = blue(img.pixels[index]);      
    pixels[index] =  color(0.21*r + 0.72*g + 0.07*b);
  }
updatePixels();
