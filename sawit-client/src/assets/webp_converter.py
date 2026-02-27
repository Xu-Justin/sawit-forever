import os
from PIL import Image

# Define the input folder (change this path)
input_folder = input("Input folder: ")

# Desired width
target_width = int(input("Target width: "))

# Supported formats (Pillow can read)
supported_exts = ('.webp', '.jpg', '.jpeg', '.png', '.bmp', '.tiff')

for filename in os.listdir(input_folder):
    if filename.lower().endswith(supported_exts):
        img_path = os.path.join(input_folder, filename)

        try:
            with Image.open(img_path) as img:

                # Calculate new height maintaining aspect ratio
                w_percent = target_width / float(img.width)
                target_height = int(float(img.height) * w_percent)

                # Resize the image
                resized_img = img.resize((target_width, target_height), Image.LANCZOS)

                # Overwrite as WebP
                output_path = os.path.join(
                    input_folder, os.path.splitext(filename)[0] + ".webp"
                )
                resized_img.save(output_path, "WEBP", quality=80, method=6)

                # If original was not .webp, remove it
                if not filename.lower().endswith(".webp"):
                    os.remove(img_path)

                print(f"Resized & saved as WebP: {output_path}")
        except Exception as e:
            print(f"❌ Failed to process {filename}: {e}")

print(f"✅ All images resized to width {target_width}px and saved as WebP.")

