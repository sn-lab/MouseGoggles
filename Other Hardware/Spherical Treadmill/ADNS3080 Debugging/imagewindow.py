import pygame
import numpy as np


class ImageWindow:

    def __init__(self, width, height, name='image'):
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
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False
        if len(image.shape) == 2:
            image = np.expand_dims(image, 2)
            image = image*np.ones([1, 1, 3])
        image = pygame.surfarray.make_surface(image)
        image = pygame.transform.smoothscale(image, (self.width, self.height))
        self.gameDisplay.blit(image, (0, 0))
        pygame.display.update()

    def close(self):
        pygame.quit()

# a = ImageWindow(400, 400)
# for i in range(200):
#     a.draw((np.random.uniform(size=[400, 400])*255).astype(np.uint8))
# time.sleep(10)
# print('yo')