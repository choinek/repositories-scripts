import os
import subprocess
from PIL import Image, ImageOps

input_dir = "generated_files/images"
optimized_dir = "generated_files/optimized_images"
os.makedirs(optimized_dir, exist_ok=True)

def optimize_with_tool(file_path, output_path):
    ext = os.path.splitext(file_path)[1].lower()
    temp_output = f"{output_path}.temp"

    if ext in [".jpg", ".jpeg"]:
        subprocess.run(["jpegtran", "-optimize", "-progressive", "-outfile", temp_output, file_path], check=True)
        os.replace(temp_output, output_path)
    elif ext == ".png":
        subprocess.run(["pngquant", "--quality=65-80", "--output", temp_output, file_path], check=True)
        subprocess.run(["optipng", "-o7", temp_output], check=True)
        os.replace(temp_output, output_path)
    elif ext == ".webp":
        subprocess.run(["cwebp", "-q", "75", file_path, "-o", temp_output], check=True)
        os.replace(temp_output, output_path)
    elif ext == ".gif":
        subprocess.run(["gifsicle", "--optimize=3", "--colors", "256", file_path, "-o", temp_output], check=True)
        os.replace(temp_output, output_path)
    else:
        print(f"Unsupported file type: {file_path}")

for filename in os.listdir(input_dir):
    input_path = os.path.join(input_dir, filename)
    optimized_path = os.path.join(optimized_dir, filename)

    try:
        with Image.open(input_path) as img:
            img = ImageOps.exif_transpose(img)
            img.save(optimized_path, optimize=True)

        optimize_with_tool(optimized_path, optimized_path)
    except subprocess.CalledProcessError as e:
        print(f"Failed to process {filename}: {e}")
    except Exception as e:
        print(f"Unexpected error for {filename}: {e}")

print(f"Optimized images saved to {optimized_dir}")
