#this ImageWindow class uses the pygame library to create an image window
#and quickly draw/update images on it

import pygame
import numpy as np

class ImageWindow:

    def __init__(self, width, height, name='image'):
        # initialize a game window
        self.width = width
        self.height = height
        pygame.init()
        self.gameDisplay = pygame.display.set_mode((width, height))
        pygame.display.set_caption(name)
        black = (0, 0, 0)
        white = (255, 255, 255)
        self.gameDisplay.fill(black)
        pygame.display.update()

    def draw(self, image):
        #show an image in the game window
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False
        if len(image.shape) == 2: 
            #if this is a black/white image, expand in 3rd dimension for RGB format
            image = np.expand_dims(image, 2)
            image = image*np.ones([1, 1, 3])
        image = pygame.surfarray.make_surface(image)
        image = pygame.transform.smoothscale(image, (self.width, self.height))
        self.gameDisplay.blit(image, (0, 0)) #"blitting" is drawing
        pygame.display.update()

    def close(self):
        pygame.quit()