from shiny import App, ui, render, reactive
from PIL import Image
import io
import base64
import tempfile

# Helper function to resize the image while preserving the aspect ratio.
def resize_image(img, percentage=None, new_width=None):
    original_width, original_height = img.size
    # Use the percentage if provided (any positive value, e.g. 150 enlarges the image by 50%)
    if percentage is not None and percentage > 0:
        calc_width = int(original_width * percentage / 100)
        calc_height = int(original_height * percentage / 100)
        return img.resize((calc_width, calc_height), Image.Resampling.LANCZOS)
    # Otherwise, if a new width is provided, compute the new height.
    elif new_width is not None and new_width > 0:
        ratio = new_width / original_width
        calc_height = int(original_height * ratio)
        return img.resize((new_width, calc_height), Image.Resampling.LANCZOS)
    else:
        return None

# Define the UI.
app_ui = ui.page_fluid(
    ui.h2("Image Resizer (enlarges or shrinks it proportionally)"),
    ui.input_file("image_file", "Upload your image:"),
    ui.output_text_verbatim("original_dimensions"),
    ui.input_numeric("percentage", "Resize Percentage (can be decimals):", value=0, min=1, step=1),
    ui.input_numeric("new_width", "New Width (integar; in px):", value=0, min=1),
    ui.input_action_button("resize", "Resize!"),
    ui.output_text_verbatim("warning_message"),
    ui.output_text_verbatim("priority_message"),
    ui.output_image("resized_image")
)

# Define the server logic.
def server(input, output, session):
    @reactive.Calc
    def img_obj():
        file_info = input.image_file()
        if file_info is None or len(file_info) == 0:
            return None
        try:
            # Attempt to open and verify the image.
            img = Image.open(file_info[0]["datapath"])
            img.verify()  # This will raise an exception if the file is not a valid image.
            # Reopen the image for processing.
            img = Image.open(file_info[0]["datapath"])
            return img
        except Exception as e:
            return "not_an_image"

    @output
    @render.text
    def original_dimensions():
        img = img_obj()
        if img is None:
            return "No image uploaded yet."
        if img == "not_an_image":
            return "Warning: uploaded file is not a valid image."
        width, height = img.size
        return f"Current image dimensions: {width} x {height} px"

    @output
    @render.text
    @reactive.event(input.resize)
    def warning_message():
        img = img_obj()
        if img is None:
            return "No image uploaded yet."
        if img == "not_an_image":
            return "Warning: please make sure to upload an image in JPEG, GIF, BMP, TIFF, or PNG."
        
        allowed_formats = ["JPEG", "GIF", "BMP", "TIFF", "PNG"]
        original_format = img.format
        if original_format is None or original_format.upper() not in allowed_formats:
            return "Warning: please make sure to upload an image in JPEG, GIF, BMP, TIFF, or PNG."

        # Now valid numeric inputs: percentage must be > 0 and/or new_width must be > 0.
        perc = input.percentage()
        new_w = input.new_width()
        valid_perc = perc is not None and perc > 0
        valid_width = new_w is not None and new_w > 0
        if not (valid_perc or valid_width):
            return "Warning: please enter either a percentage greater than 0 or a width greater than 0."
        return ""

    @output
    @render.text
    @reactive.event(input.resize)
    def priority_message():
        perc = input.percentage()
        new_w = input.new_width()
        if (perc is not None and perc > 0) and (new_w is not None and new_w > 0):
            return "Both percentage and new width are provided; using percentage for resizing."
        return ""

    @output
    @render.image
    @reactive.event(input.resize)
    def resized_image():
        img = img_obj()
        if img is None or img == "not_an_image":
            return None

        allowed_formats = ["JPEG", "GIF", "BMP", "TIFF", "PNG"]
        original_format = img.format
        if original_format is None or original_format.upper() not in allowed_formats:
            return None

        perc = input.percentage()
        new_w = input.new_width()
        valid_perc = perc is not None and perc > 0
        valid_width = new_w is not None and new_w > 0

        if valid_perc:
            new_img = resize_image(img, percentage=perc)
        elif valid_width:
            new_img = resize_image(img, new_width=new_w)
        else:
            return None

        # Save the resized image to a temporary file using the original format.
        tmp = tempfile.NamedTemporaryFile(delete=False, suffix="." + original_format.lower())
        new_img.save(tmp, format=original_format)
        tmp.close()

        return {"src": tmp.name, "alt": "Resized Image"}

# Create and run the app.
app = App(app_ui, server)

if __name__ == "__main__":
    app.run()
