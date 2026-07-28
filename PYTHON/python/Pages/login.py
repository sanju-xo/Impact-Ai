import customtkinter as ctk
from tkinter import messagebox
from PIL import Image, ImageTk, ImageSequence
import os
import webbrowser
import tkinter as tk

from python.Authentication.firebase_auth import login_user  # Firebase login function

# Detect Screen Resolution
root = tk.Tk()
screen_width = root.winfo_screenwidth()
screen_height = root.winfo_screenheight()
root.destroy()

# Reference Resolution (1440p)
BASE_WIDTH = 2560
BASE_HEIGHT = 1440

# Scaling Factor (Ensures UI is usable on both 1080p and 1440p)
scaling_factor = max(0.8, min(screen_width / BASE_WIDTH, screen_height / BASE_HEIGHT))
ctk.set_widget_scaling(scaling_factor)
ctk.set_window_scaling(scaling_factor)


class LoginGUI:
    def __init__(self, root, switch_to_home):
        self.root = root
        self.switch_to_home = switch_to_home
        self.root.geometry(f"{int(1600 * scaling_factor)}x{int(1000 * scaling_factor)}")
        self.root.title("Crash Detection AI - Login")
        self.root.resizable(False, False)
        self.root.overrideredirect(True)

        self.gif_label = None
        self.gif_frames = []
        self.gif_index = 0
        self.error_label = None
        self.password_visible = False

        self.create_window_controls()
        self.create_login_ui()

    def create_window_controls(self):
        control_frame = ctk.CTkFrame(self.root, width=int(1600 * scaling_factor), height=int(30 * scaling_factor),
                                     fg_color="white", corner_radius=0)
        control_frame.place(relx=0, rely=0)
        control_frame.lift()

        button_size = int(30 * scaling_factor)

        minimize_button = ctk.CTkButton(control_frame, text="—", width=button_size, height=button_size,
                                        command=self.minimize_window, fg_color="transparent",
                                        text_color="black", hover_color="#E0E0E0", border_width=0)
        minimize_button.place(relx=0.93, rely=0.5, anchor="center")

        maximize_button = ctk.CTkButton(control_frame, text="□", width=button_size, height=button_size,
                                        command=self.maximize_window, fg_color="transparent",
                                        text_color="black", hover_color="#E0E0E0", border_width=0)
        maximize_button.place(relx=0.96, rely=0.5, anchor="center")

        close_button = ctk.CTkButton(control_frame, text="×", width=button_size, height=button_size,
                                     command=self.close_window, fg_color="white",
                                     text_color="red", hover_color="#FFCCCC", border_width=0)
        close_button.place(relx=0.99, rely=0.5, anchor="center")

    def minimize_window(self):
        self.root.iconify()

    def maximize_window(self):
        is_fullscreen = self.root.attributes("-fullscreen")
        self.root.attributes("-fullscreen", not is_fullscreen)

    def close_window(self):
        self.root.destroy()

    def create_login_ui(self):
        self.clear_screen()

        frame_width = int(800 * scaling_factor)
        frame_height = int(1000 * scaling_factor)

        # Left Frame (Login UI)
        left_frame = ctk.CTkFrame(self.root, width=frame_width, height=frame_height, fg_color="white", corner_radius=30)
        left_frame.place(relx=0, rely=0)

        left_frame_image = ctk.CTkImage(Image.open(os.path.join(os.path.dirname(__file__), "../../Images/white_frame.png")),
                                        size=(frame_width, frame_height))
        left_frame_label = ctk.CTkLabel(left_frame, image=left_frame_image, text="")
        left_frame_label.place(relx=0.5, rely=0.5, anchor="center")

        entry_width = int(330 * scaling_factor)
        font_size = int(18 * scaling_factor)
        button_height = int(50 * scaling_factor)

        username_label = ctk.CTkLabel(left_frame, text="Email address",
                                      font=ctk.CTkFont(size=font_size, weight="bold"), text_color="grey")
        username_label.place(relx=0.2, rely=0.337, anchor="w")

        self.username_entry = ctk.CTkEntry(left_frame, width=entry_width, placeholder_text="Enter your email address",
                                           border_width=0, fg_color="white", text_color="black")
        self.username_entry.place(relx=0.2, rely=0.3745, anchor="w")

        password_label = ctk.CTkLabel(left_frame, text="Password",
                                      font=ctk.CTkFont(size=font_size, weight="bold"), text_color="grey")
        password_label.place(relx=0.2, rely=0.4337, anchor="w")

        self.password_entry = ctk.CTkEntry(left_frame, width=entry_width, placeholder_text="Enter your password",
                                           show="*", border_width=0, fg_color="white", text_color="black")
        self.password_entry.place(relx=0.2, rely=0.47, anchor="w")

        # Password toggle images
        icon_size = int(24 * scaling_factor)
        self.show_password_icon = ctk.CTkImage(Image.open(os.path.join(os.path.dirname(__file__), "../../Images/eye-open.png")), size=(icon_size, icon_size))
        self.hide_password_icon = ctk.CTkImage(Image.open(os.path.join(os.path.dirname(__file__), "../../Images/eye-close.png")), size=(icon_size, icon_size))

        self.password_toggle_button = ctk.CTkButton(left_frame, image=self.hide_password_icon, text="",
                                                    width=button_height, height=button_height,
                                                    command=self.toggle_password_visibility,
                                                    fg_color="white", hover_color="#E0E0E0", border_width=0)
        self.password_toggle_button.place(relx=0.65, rely=0.47, anchor="w")

        forgot_password = ctk.CTkLabel(left_frame, text="Forgot Password?", font=ctk.CTkFont(size=int(12 * scaling_factor)),
                                       text_color="#3498DB", cursor="hand2")
        forgot_password.place(relx=0.2, rely=0.52, anchor="w")
        forgot_password.bind("<Button-1>", lambda e: self.open_email_support())

        self.error_label = ctk.CTkLabel(left_frame, text="", font=ctk.CTkFont(size=int(12 * scaling_factor)), text_color="red")
        self.error_label.place(relx=0.47, rely=0.52, anchor="w")

        login_button = ctk.CTkButton(left_frame, text="LOG IN",
                                     width=int(300 * scaling_factor), height=button_height,
                                     font=ctk.CTkFont(size=font_size, weight="bold"),
                                     fg_color="#3D9970", text_color="white",
                                     hover_color="#34A853", border_width=0, command=self.login)
        login_button.place(relx=0.2, rely=0.6, anchor="w")

        # Right Frame (GIF Animation)
        right_frame = ctk.CTkFrame(self.root, width=frame_width, height=frame_height, fg_color="white", corner_radius=30)
        right_frame.place(relx=1.0, rely=0.5, anchor="e")  # Align to the right edge
        gif_path = os.path.join(os.path.dirname(__file__), "../../Images/yolo.gif")

        try:
            gif = Image.open(gif_path)
            self.gif_frames = [ImageTk.PhotoImage(frame.copy().resize((frame_width, frame_height)))
                               for frame in ImageSequence.Iterator(gif)]
        except Exception as e:
            print(f"⚠ Error loading GIF: {e}")
            self.gif_frames = []

        if self.gif_frames:
            self.gif_label = ctk.CTkLabel(right_frame, image=self.gif_frames[0], text="")
            self.gif_label.place(relx=0.5, rely=0.5, anchor="center")
            self.animate_gif()

    def animate_gif(self):
        if self.gif_frames:
            self.gif_label.configure(image=self.gif_frames[self.gif_index])
            self.gif_index = (self.gif_index + 1) % len(self.gif_frames)
            self.root.after(50, self.animate_gif)

    def stop_animations(self):
        """Cancel all scheduled Tkinter `after()` animations before switching pages."""
        try:
            if hasattr(self, "gif_label") and self.gif_label:
                self.root.after_cancel(self.gif_index)
        except Exception as e:
            print(f"⚠️ Error stopping animations: {e}")

    def toggle_password_visibility(self):
        self.password_visible = not self.password_visible
        self.password_entry.configure(show="" if self.password_visible else "*")
        self.password_toggle_button.configure(image=self.show_password_icon if self.password_visible else self.hide_password_icon)

    def login(self):
        email = self.username_entry.get()
        password = self.password_entry.get()
        user_data = login_user(email, password)

        if user_data:
            self.stop_animations()  # ✅ Stop running animations before switching pages
            self.switch_to_home()
        else:
            self.error_label.configure(text="Invalid credentials.")

    def open_email_support(self):
        webbrowser.open("mailto:ImpactAI@support.com")

    def clear_screen(self):
        for widget in self.root.winfo_children():
            widget.destroy()
