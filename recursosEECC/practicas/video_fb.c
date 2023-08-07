/*
  URL     : http://betteros.org/tut/graphics1.php
  Programa: upna_prac.c
  Descripción: make the entire screen bright with differente colors:  
  Ejecución: En una consola modo TEXTO y con permisos de ROOT para abrir el fichero framebuffer


*/

#include <stdlib.h>


#include <linux/fb.h>
#include <stdio.h>
#include <stdint.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <sys/ioctl.h>
#include <unistd.h>        // incluyo sleep()

__attribute__((always_inline)) inline uint32_t pixel_color(uint8_t r, uint8_t g, uint8_t b, struct fb_var_screeninfo *vinfo)
{
  return (r<<vinfo->red.offset) | (g<<vinfo->green.offset) | (b<<vinfo->blue.offset);
}

int main()
{
  struct fb_fix_screeninfo finfo;
  struct fb_var_screeninfo vinfo;
  long location;
  
  int fb_fd = open("/dev/fb0",O_RDWR);
  if (fb_fd == -1) {
    perror("Error: cannot open framebuffer device, posible need on text console (C-M F1) and root permission (sudo su)  \n");
    exit(1);
  }
  //Get variable screen information
 
  if (ioctl(fb_fd, FBIOGET_VSCREENINFO, &vinfo) == -1) {
    perror("Error reading variable information");
    exit(2);
  }
  if (ioctl(fb_fd, FBIOGET_FSCREENINFO, &finfo) == -1) {
    perror("Error reading fixed information");
    exit(3);
  }
  
  vinfo.grayscale=0;
  vinfo.bits_per_pixel=32;
  ioctl(fb_fd, FBIOPUT_VSCREENINFO, &vinfo);
  ioctl(fb_fd, FBIOGET_VSCREENINFO, &vinfo);

  printf("%dx%d, %dbpp\n", vinfo.xres, vinfo.yres, vinfo.bits_per_pixel);

  
  long screensize = vinfo.yres_virtual * finfo.line_length;

  uint8_t *fbp = mmap(0, screensize, PROT_READ | PROT_WRITE, MAP_SHARED, fb_fd, (off_t)0);

  int x,y;

  for (x=0;x<vinfo.xres;x++)
    for (y=0;y<vinfo.yres;y++)
      {
	location = (x+vinfo.xoffset) * (vinfo.bits_per_pixel/8) + (y+vinfo.yoffset) * finfo.line_length;
	if (0 <= y && y < vinfo.yres/4)        
	  *((uint32_t*)(fbp + location)) = pixel_color(0xFF,0x00,0x00, &vinfo);
	else if (vinfo.yres/4 <= y && y < vinfo.yres/2)        
	  *((uint32_t*)(fbp + location)) = pixel_color(0x00,0xFF,0x00, &vinfo);
	else if (vinfo.yres/2 <= y && y < vinfo.yres*3/4)        
	  *((uint32_t*)(fbp + location)) = pixel_color(0x00 ,0x00,0xFF, &vinfo);
	else
	  *((uint32_t*)(fbp + location)) = pixel_color(0x0FF,0xFF,0x00, &vinfo);
    
	  
      }


    
  sleep(3);

  x = 100; y = 100;       // Where we are going to put the pixel

  // Figure out where in memory to put the pixel
  for (y = 100; y < 300; y++)
    for (x = 100; x < 300; x++) {

      location = (x+vinfo.xoffset) * (vinfo.bits_per_pixel/8) +
	(y+vinfo.yoffset) * finfo.line_length;

      if (vinfo.bits_per_pixel == 32) {
	*(fbp + location) = 100;        // Some blue
	*(fbp + location + 1) = 15+(x-100)/2;     // A little green
	*(fbp + location + 2) = 200-(y-100)/5;    // A lot of red
	*(fbp + location + 3) = 0;      // No transparency
        //location += 4;
      } else  { //assume 16bpp
	int b = 10;
	int g = (x-100)/6;     // A little green
	int r = 31-(y-100)/16;    // A lot of red
	unsigned short int t = r<<11 | g << 5 | b;
	*((unsigned short int*)(fbp + location)) = t;
      }

    }

  munmap(fbp, screensize);
  close(fb_fd);

  sleep (3);
  
  return 0;
}
