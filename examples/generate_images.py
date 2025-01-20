from PIL import Image, ImageDraw, ImageFont
import os

# Define popular web image sizes
sizes = [
    (1920, 1080), (1280, 720), (1024, 768),
    (800, 600), (640, 480), (320, 240),
    (1600, 1200), (1366, 768), (2560, 1440), (3840, 2160),
]

output_dir = "generated_files/images"
os.makedirs(output_dir, exist_ok=True)

text_content = "Optimized Image"
font_path = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"
font_size = 40

for width, height in sizes:
    for format in ['JPEG', 'PNG', 'WEBP', 'GIF']:
        image = Image.new('RGB', (width, height), (255, 255, 255))
        draw = ImageDraw.Draw(image)
        try:
            font = ImageFont.truetype(font_path, font_size)
        except IOError:
            font = ImageFont.load_default()
        bbox = draw.textbbox((0, 0), text_content, font=font)
        text_width, text_height = bbox[2] - bbox[0], bbox[3] - bbox[1]
        text_x = (width - text_width) // 2
        text_y = (height - text_height) // 2
        draw.text((text_x, text_y), text_content, fill="black", font=font)
        filename = f"{width}x{height}.{format.lower()}"
        save_path = os.path.join(output_dir, filename)
        image.save(save_path, format=format, optimize=True)
