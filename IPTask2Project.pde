int n = 9; // number of orientation bins
int M = 8; // number of cells in x-direction
int N = 8; // number of cells in y-direction
float [] gradvector1 = {};
float [] gradvector2 = {};
PImage img;

void setup() {
PImage img1 = loadImage("image1.jpg");
PImage img2 = loadImage("image2.jpg");
size(800, 600);

img1 = grayscale(img1);
image(img1, 0, 0);
img1 = sobel(img1);
image(img1, 200, 300);
img2 = grayscale(img2);
image(img2, 500, 600);
img2 = sobel(img2);
image(img2, 600, 700);

float[][] hog1 = computeHOG(img1, M, N, n);
float[][] hog2 = computeHOG(img2, M, N, n);

noFill();
drawgrid(img1, M, N, n);
noFill();
drawgrid(img2, M, N, n);
 
float dot_product = 0;
float norm1 = 0;
float norm2 = 0;
for (int i = 0; i < hog1.length; i++) {
for (int j = 0; j < n; j++) {
dot_product += hog1[i][j] * hog2[i][j];
norm1 += hog1[i][j] * hog1[i][j];
norm2 += hog2[i][j] * hog2[i][j];
}
}
float cosine_similarity = dot_product / (sqrt(norm1) * sqrt(norm2));
println("Cosine similarity: " + cosine_similarity);
}

PImage grayscale(PImage img) {
img.loadPixels(); 
int[] pixels = img.pixels;
for (int y = 0; y < img.height; y++)
 for (int x = 0; x < img.width; x++) {
  int index = x + y * img.width;
  float r = red (pixels[index]);
  float g = green(pixels[index]);
  float b = blue(pixels[index]);      
  pixels[index] =  color(0.21*r + 0.72*g + 0.07*b);
 }
img.updatePixels();
return img;
}

PImage sobel(PImage img) {
PImage imga = createImage(img.width - 2, img.height - 2, RGB);
img.loadPixels();
imga.loadPixels();
float[][] filter1 = {{-1, 0, 1}, 
                {-2, 0, 2}, 
                {-1, 0, 1}};
float[][] filter2 = {{-1, -2, -1}, 
                { 0,  0,  0}, 
                { 1,  2,  1}};
for (int y = 1; y < img.height - 1; y++) 
 for (int x = 1; x < img.width - 1; x++) {
  float gx = 0, gy = 0;
   for (int ky = -1; ky <= 1; ky++) 
    for (int kx = -1; kx <= 1; kx++) {
     int index = (y + ky) * img.width + (x + kx);
     float r = brightness(img.pixels[index]);
     gx += filter1[ky+1][kx+1] * r;
     gy += filter2[ky+1][kx+1] * r;
      float mag = sqrt(gx * gx + gy * gy);
float theta = 0;
if (gx > 0)
 theta = atan(gy / gx);
else if (gx < 0)
 theta = atan(gy / gx) + PI;
else if (gy > 0) 
 theta = PI  / 2;
else if (gy < 0)
 theta = - PI / 2;
else 
 theta = 0;
if (theta < 0)
 theta += 2 * PI;
 //println("magnitude = " + mag + ", orientation = " + theta);
  theta = atan2(gy, gx);
 if (gy < 0) 
  theta += 2 * PI;
  //println("magnitude = " + mag + ", orientation = " + theta);
  if (gx > 0)
 theta = atan(gy / gx);
else if (gx < 0)
 theta = atan(gy / gx) + PI;
else if (gy > 0) 
 theta = PI  / 2;
else if (gy < 0)
 theta = - PI / 2;
else 
 theta = 0;
if (theta < 0)
 theta += 2 * PI;
float[] d = new float[n];
d[int(theta * n / TWO_PI)] = mag;
gradvector1 = d;
theta = atan2(gy, gx);
if (gy < 0) 
 theta += 2 * PI;
 index = int(theta * n / TWO_PI); 
d = new float[n];
d[int(theta * n / TWO_PI)] = mag;
gradvector1 = d;
     }
imga.pixels[(y-1) * imga.width + (x-1)] = color(sqrt(gx * gx + gy * gy));
   }
imga.updatePixels();
return imga;
}

void drawgrid(PImage img, int M, int N, int n) {   
for(int i = 0; i < img.width; i = i + img.width / M)
 for(int j = 0; j < img.height; j = j + img.height / N){
 PImage temp = img.get(i, j, img.width / M, img.height / n);
 image(temp, i, j);
 rect(i, j, img.width / M, img.height / N);
 } 
}

float[][] computeHOG(PImage img, int M, int N, int n) {
float[][] hog = new float[M * N][n];
for (int i = 0; i < img.width - img.width % M; i += img.width / M) {
for (int j = 0; j < img.height - img.height % N; j += img.height / N) {
// compute HOG for each cell
float[] cell_hist = new float[n];
for (int y = j; y < j + img.height / N; y++) {
for (int x = i; x < i + img.width / M; x++) {
float theta = atan2(img.pixels[y * img.width + x] & 0xFF, 255);
int bin = int(n * ((theta + PI) / (2 * PI)));
cell_hist[bin]++;
}
}
// normalize cell histogram
float cell_norm = 0;
for (int k = 0; k < n; k++) {
cell_norm += cell_hist[k] * cell_hist[k];
//print(cell_norm);
}
cell_norm = sqrt(cell_norm) + 0.0001;
for (int k = 0; k < n; k++) {
cell_hist[k] /= cell_norm;
}
// store cell histogram in HOG feature vector
int idx = j / (img.height / N) * M + i / (img.width / M);
for (int k = 0; k < n; k++) {
hog[idx][k] = cell_hist[k];
//print(cell_hist[k]);
// print(hog1[idx][(k)]);
}
}
}
return hog;
}
