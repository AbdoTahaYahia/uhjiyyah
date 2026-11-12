import math
from PIL import Image, ImageDraw, ImageFilter

def create_square_maze_icon():
    # Render at 4096 x 4096 for ultra-crisp supersampling anti-aliasing
    SIZE = 4096
    CENTER = SIZE // 2
    
    # Color palette
    BG_COLOR = (8, 8, 12, 255)       # #08080C deep cosmic dark
    WHITE = (255, 255, 255, 255)     # #FFFFFF crisp bright
    GLOW_STAR = (160, 200, 255, 120) # Soft blue-white celestial glow
    STAR_CORE = (255, 255, 255, 255)
    
    # 1. Base canvas for full app icon
    img = Image.new("RGBA", (SIZE, SIZE), BG_COLOR)
    
    # Radial ambient glow behind the star
    glow_img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    glow_draw = ImageDraw.Draw(glow_img)
    for r in range(550, 40, -25):
        alpha = int(40 * (1.0 - (r / 550.0)**1.4))
        glow_draw.ellipse(
            (CENTER - r, CENTER - r, CENTER + r, CENTER + r),
            fill=(140, 185, 255, alpha)
        )
    glow_img = glow_img.filter(ImageFilter.GaussianBlur(radius=50))
    img = Image.alpha_composite(img, glow_img)
    draw = ImageDraw.Draw(img)
    
    # Maze specifications:
    # Outer square: half-size = 960 (total size = 1920 in 4096, downsampled = 480x480 in 1024)
    # Fits safely inside Android's 682px diameter circle safe-zone without any corner clipping!
    # Rings half-sizes:
    # R5: 960
    # R4: 800
    # R3: 640
    # R2: 480
    # R1: 320
    # Sanctuary (Center): 200 (size 400x400)
    
    STROKE = 48  # Wall stroke width (12px in 1024)
    
    # Line segments: (x1, y1, x2, y2) relative to CENTER
    lines = []
    
    def line(x1, y1, x2, y2):
        lines.append((CENTER + x1, CENTER + y1, CENTER + x2, CENTER + y2))
        
    # --- R5 (Outer Square: 960) ---
    # Entrance at Top center (-120 to +120 open)
    line(-960, -960, -120, -960) # Top Left
    line(120, -960, 960, -960)   # Top Right
    line(960, -960, 960, 960)    # Right
    line(960, 960, -960, 960)    # Bottom
    line(-960, 960, -960, -960)  # Left
    
    # Barriers in Corridor 5 (between 960 and 800):
    line(-960, -300, -800, -300) # Left upper divider
    line(960, 400, 800, 400)     # Right lower divider
    
    # --- R4 (800) ---
    # Gates on Right (-120 to +120 open) and Left (300 to 540 open)
    line(-800, -800, 800, -800)  # Top
    line(800, -800, 800, -120)   # Right Top
    line(800, 120, 800, 800)     # Right Bottom
    line(800, 800, -800, 800)    # Bottom
    line(-800, 800, -800, 540)   # Left Bottom
    line(-800, 300, -800, -800)  # Left Top
    
    # Barriers in Corridor 4 (between 800 and 640):
    line(0, 800, 0, 640)         # Bottom divider
    line(-800, -400, -640, -400) # Left divider
    line(640, -400, 800, -400)   # Right upper divider
    
    # --- R3 (640) ---
    # Gates on Bottom (-120 to +120 open) and Top (300 to 500 open)
    line(-640, -640, 300, -640)  # Top Left
    line(500, -640, 640, -640)   # Top Right
    line(640, -640, 640, 640)    # Right
    line(640, 640, 120, 640)     # Bottom Right
    line(-120, 640, -640, 640)   # Bottom Left
    line(-640, 640, -640, -640)  # Left
    
    # Barriers in Corridor 3 (between 640 and 480):
    line(-640, 200, -480, 200)   # Left divider
    line(480, 0, 640, 0)         # Right divider
    line(-200, -640, -200, -480) # Top divider
    
    # --- R2 (480) ---
    # Gates on Left (-100 to +100 open) and Top (-100 to +100 open)
    line(-480, -480, -100, -480) # Top Left
    line(100, -480, 480, -480)   # Top Right
    line(480, -480, 480, 480)    # Right
    line(480, 480, -480, 480)    # Bottom
    line(-480, 480, -480, 100)   # Left Bottom
    line(-480, -100, -480, -480) # Left Top
    
    # Barriers in Corridor 2 (between 480 and 320):
    line(0, 480, 0, 320)         # Bottom divider
    line(480, -200, 320, -200)   # Right divider
    
    # --- R1 (320 - Sanctuary Enclosure) ---
    # Sanctuary Gates: Open at Top (-90 to +90) and Bottom (-90 to +90)
    line(-320, -320, -90, -320)  # Top Left
    line(90, -320, 320, -320)    # Top Right
    line(320, -320, 320, 320)    # Right
    line(320, 320, 90, 320)      # Bottom Right
    line(-90, 320, -320, 320)    # Bottom Left
    line(-320, 320, -320, -320)  # Left
    
    # Draw all labyrinth walls with rounded joints
    def draw_maze_lines(canvas_draw):
        r_cap = STROKE // 2
        for x1, y1, x2, y2 in lines:
            canvas_draw.line([(x1, y1), (x2, y2)], fill=WHITE, width=STROKE, joint="round")
            canvas_draw.ellipse((x1 - r_cap, y1 - r_cap, x1 + r_cap, y1 + r_cap), fill=WHITE)
            canvas_draw.ellipse((x2 - r_cap, y2 - r_cap, x2 + r_cap, y2 + r_cap), fill=WHITE)
            
    draw_maze_lines(draw)
    
    # 2. Central Radiant 8-Pointed Star (The Heart of the Labyrinth)
    # Radii:
    # Major cardinal rays (Top, Right, Bottom, Left): 210
    # Minor diagonal rays (45 deg): 115
    # Inner valley radius: 40
    star_points = []
    for i in range(16):
        angle = i * (2 * math.pi / 16) - math.pi / 2
        if i % 2 == 0:
            ray_idx = i // 2
            r = 210 if (ray_idx % 2 == 0) else 115
        else:
            r = 40
        px = CENTER + r * math.cos(angle)
        py = CENTER + r * math.sin(angle)
        star_points.append((px, py))
        
    # Star glow
    sg = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    sgd = ImageDraw.Draw(sg)
    sgd.polygon(star_points, fill=GLOW_STAR)
    sg = sg.filter(ImageFilter.GaussianBlur(radius=30))
    img = Image.alpha_composite(img, sg)
    draw = ImageDraw.Draw(img)
    
    # Crisp star polygon
    draw.polygon(star_points, fill=STAR_CORE)
    
    # Central sparkling diamond
    dr = 22
    diamond_pts = [
        (CENTER, CENTER - dr),
        (CENTER + dr, CENTER),
        (CENTER, CENTER + dr),
        (CENTER - dr, CENTER),
    ]
    draw.polygon(diamond_pts, fill=(210, 230, 255, 255))
    
    # Downsample to 1024x1024
    icon_1024 = img.resize((1024, 1024), Image.Resampling.LANCZOS)
    
    # 3. Create transparent foreground for Android adaptive icon
    fg_img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    fg_img = Image.alpha_composite(fg_img, glow_img)
    fg_draw = ImageDraw.Draw(fg_img)
    draw_maze_lines(fg_draw)
    fg_img = Image.alpha_composite(fg_img, sg)
    fg_draw = ImageDraw.Draw(fg_img)
    fg_draw.polygon(star_points, fill=STAR_CORE)
    fg_draw.polygon(diamond_pts, fill=(210, 230, 255, 255))
    
    fg_1024 = fg_img.resize((1024, 1024), Image.Resampling.LANCZOS)
    
    # Save master assets
    icon_1024.save("D:/uhjiyyah/assets/icon/app_icon.png", "PNG")
    icon_1024.save("D:/uhjiyyah/assets/icon/app_icon.webp", "WEBP")
    fg_1024.save("D:/uhjiyyah/assets/icon/app_icon_foreground.png", "PNG")
    
    # Save preview in artifacts
    icon_1024.save("C:/Users/abdot/.gemini/antigravity/brain/3a838564-cb95-4e51-9de6-a732fc59f248/square_maze_icon.png", "PNG")
    print("Successfully generated high-definition square maze icon with central star!")

if __name__ == "__main__":
    create_square_maze_icon()
