from reportlab.pdfgen import canvas
from reportlab.lib.pagesizes import letter

from reportlab.platypus import SimpleDocTemplate, Image, Paragraph
from reportlab.lib.styles import getSampleStyleSheet
import os

output_dir = "generated_files/pdfs"
os.makedirs(output_dir, exist_ok=True)


# 1. Multiple Pages PDF
def create_multiple_pages_pdf(output_path):
    c = canvas.Canvas(output_path, pagesize=letter)
    for i in range(5):
        c.drawString(100, 750, f"This is page {i + 1}")
        c.showPage()
    c.save()

# 2. Image-only PDF
def create_image_only_pdf(output_path, images_dir):
    doc = SimpleDocTemplate(output_path, pagesize=letter)
    elements = []
    for img_file in os.listdir(images_dir):
        if img_file.endswith(('.jpg', '.png', '.webp')):
            img_path = os.path.join(images_dir, img_file)
            elements.append(Image(img_path, width=400, height=200))
    doc.build(elements)

# 3. Text-only PDF
def create_text_only_pdf(output_path):
    doc = SimpleDocTemplate(output_path, pagesize=letter)
    styles = getSampleStyleSheet()
    text = "\n".join([f"Sample text line {i}" for i in range(1, 51)])
    elements = [Paragraph(text, styles['BodyText'])]
    doc.build(elements)

# 4. Form PDF with Inputs
def create_form_pdf(output_path):
    c = canvas.Canvas(output_path, pagesize=letter)
    c.drawString(100, 750, "Sample Form with Inputs")
    form = c.acroForm
    form.textfield(name='name', tooltip='Enter your name', x=100, y=700, width=300)
    form.textfield(name='email', tooltip='Enter your email', x=100, y=650, width=300)
    c.save()

# Generate PDFs
create_multiple_pages_pdf(os.path.join(output_dir, "multiple_pages.pdf"))
create_image_only_pdf(os.path.join(output_dir, "image_only.pdf"), "generated_files/images")
create_text_only_pdf(os.path.join(output_dir, "text_only.pdf"))
create_form_pdf(os.path.join(output_dir, "form_with_inputs.pdf"))

print("PDFs generated successfully!")
