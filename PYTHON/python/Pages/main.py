import customtkinter as ctk
from PIL import Image, ImageTk
import os
import sys

sys.path.append(os.path.abspath(os.path.dirname(__file__)))

from prompts import PromptsPage
from notifications import NotificationsPage
from settings import SettingsPage
from home import HomePage


class HomeGUI:
    def __init__(self, root):
        self.root = root
        self.root.geometry("1600x1000")
        self.root.title("")
        self.root.resizable(False, False)
        self.root.overrideredirect(False)

        self.is_dark_mode = True
        self.nav_buttons = []
        self.pages = {}

        self.create_sidebar()
        self.create_pages()
        self.show_page("home")

    def load_mode_icons(self):
        light_icon_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../Images/light_mode_light.png"))
        dark_icon_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../Images/dark_mode_dark.png"))

        if os.path.exists(light_icon_path) and os.path.exists(dark_icon_path):
            self.light_mode_icon = ctk.CTkImage(Image.open(light_icon_path), size=(20, 20))
            self.dark_mode_icon = ctk.CTkImage(Image.open(dark_icon_path), size=(20, 20))
        else:
            self.light_mode_icon = None
            self.dark_mode_icon = None

    def create_pages(self):
        self.pages["home"] = ctk.CTkFrame(self.root, width=1350, height=1000,
                                          fg_color="#1E1E1E" if self.is_dark_mode else "#FFFFFF")
        self.pages["prompts"] = ctk.CTkFrame(self.root, width=1350, height=1000,
                                          fg_color="#1E1E1E" if self.is_dark_mode else "#FFFFFF")
        self.pages["notifications"] = ctk.CTkFrame(self.root, width=1350, height=1000,
                                             fg_color="#1E1E1E" if self.is_dark_mode else "#FFFFFF")
        self.pages["settings"] = ctk.CTkFrame(self.root, width=1350, height=1000,
                                              fg_color="#1E1E1E" if self.is_dark_mode else "#FFFFFF")

        for page in self.pages.values():
            page.place(relx=0.16, rely=0, relwidth=0.84, relheight=1)
            page.lower()

        self.pages["home"].lift()

    def create_sidebar(self):
        self.sidebar_bg = "#242529" if self.is_dark_mode else "#EDEDED"
        self.highlight_bg = "#363538" if self.is_dark_mode else "#C0C0C0"
        self.text_color = "white" if self.is_dark_mode else "black"

        self.sidebar = ctk.CTkFrame(self.root, width=258, height=1000, fg_color=self.sidebar_bg, corner_radius=0)
        self.sidebar.place(relx=0, rely=0)

        self.logo_label = ctk.CTkLabel(self.sidebar, text="")
        self.logo_label.place(relx=0.5, rely=0.06, anchor="center")
        self.update_logo()

        profile_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../Images/profile.png"))
        if os.path.exists(profile_path):
            profile_img = ctk.CTkImage(Image.open(profile_path), size=(90, 90))
        else:
            profile_img = None

        profile_label = ctk.CTkLabel(self.sidebar, image=profile_img, text="")
        profile_label.place(relx=0.5, rely=0.17, anchor="center")

        self.username_label = ctk.CTkLabel(self.sidebar, text="Louis Carter",
                                           font=ctk.CTkFont(size=18, weight="bold"),
                                           text_color=self.text_color)
        self.username_label.place(relx=0.5, rely=0.23, anchor="center")

        self.edit_button = ctk.CTkButton(self.sidebar, text="Edit", width=80, height=30,
                                         fg_color="transparent", hover_color=self.highlight_bg,
                                         text_color=self.text_color, border_width=1.2, corner_radius=20,
                                         command=lambda: self.show_page("edit"))
        self.edit_button.place(relx=0.5, rely=0.27, anchor="center")

        self.create_nav_button("Home", "home", 0.38, self.sidebar, active=True)
        self.create_nav_button("Prompts", "prompts", 0.46, self.sidebar)
        self.create_nav_button("Notifications", "notifications", 0.54, self.sidebar)
        self.create_nav_button("Settings", "settings", 0.62, self.sidebar)

        self.create_dark_mode_toggle()

    def create_nav_button(self, text, page_name, rel_y, parent, active=False):
        icon_path = os.path.abspath(os.path.join(os.path.dirname(__file__),
                    f"../../Images/{page_name}_{'dark' if self.is_dark_mode else 'light'}.png"))
        if os.path.exists(icon_path):
            icon = ctk.CTkImage(Image.open(icon_path), size=(26, 26))
        else:
            icon = None

        button_bg = self.highlight_bg if active else "transparent"
        button = ctk.CTkButton(parent, text=text, width=200, height=50, image=icon,
                               fg_color=button_bg, text_color=self.text_color,
                               hover_color=self.highlight_bg, font=ctk.CTkFont(size=18),
                               anchor="w", command=lambda: self.show_page(page_name))
        button.place(relx=0.1, rely=rel_y)
        self.nav_buttons.append((button, icon, page_name, active))

    def create_pages(self):
        self.pages["home"] = HomePage(self.root, self.is_dark_mode)
        self.pages["prompts"] = PromptsPage(self.root, self.is_dark_mode)
        self.pages["notifications"] = NotificationsPage(self.root, self.is_dark_mode)
        self.pages["settings"] = SettingsPage(self.root, self.is_dark_mode)

        for page in self.pages.values():
            page.place(relx=0.16, rely=0, relwidth=0.84, relheight=1)
            page.lower()

        self.pages["home"].lift()

    def show_page(self, page_name):
        if page_name in self.pages:
            self.pages[page_name].lift()

        for button, icon, name, _ in self.nav_buttons:
            is_active = name == page_name
            button.configure(fg_color=self.highlight_bg if is_active else "transparent")

    def create_dark_mode_toggle(self):
        self.toggle_frame = ctk.CTkFrame(self.sidebar, width=180, height=50,
                                         fg_color=self.highlight_bg, corner_radius=10)
        self.toggle_frame.place(relx=0.5, rely=0.94, anchor="center")

        self.load_mode_icons()

        self.mode_icon_label = ctk.CTkLabel(self.toggle_frame,
                                            image=self.dark_mode_icon if self.is_dark_mode else self.light_mode_icon,
                                            text="")
        self.mode_icon_label.place(relx=0.15, rely=0.5, anchor="center")

        self.mode_label = ctk.CTkLabel(self.toggle_frame, text="Dark Mode",  # ✅ Always show "Dark Mode"
                                       font=ctk.CTkFont(size=16), text_color=self.text_color)
        self.mode_label.place(relx=0.25, rely=0.5, anchor="w")

        self.mode_switch = ctk.CTkSwitch(self.toggle_frame, text="", command=self.toggle_mode,
                                         fg_color="grey", button_color="white", progress_color="grey")
        self.mode_switch.place(relx=1.28, rely=0.5, anchor="e")
        self.mode_switch.select() if self.is_dark_mode else self.mode_switch.deselect()

    def toggle_mode(self):
        current_page = None
        for button, _, page_name, active in self.nav_buttons:
            if active:
                current_page = page_name
                break

        self.is_dark_mode = not self.is_dark_mode
        self.create_sidebar()

        # ✅ Dynamically update PromptsPage
        if "prompts" in self.pages and hasattr(self.pages["prompts"], "toggle_dark_mode"):
            self.pages["prompts"].toggle_dark_mode(self.is_dark_mode)

        if "notifications" in self.pages and hasattr(self.pages["notifications"], "update_theme"):
            self.pages["notifications"].update_theme(self.is_dark_mode)

        if "settings" in self.pages and hasattr(self.pages["settings"], "toggle_dark_mode"):
            self.pages["settings"].toggle_dark_mode()

        if "home" in self.pages and hasattr(self.pages["home"], "toggle_dark_mode"):
            self.pages["home"].toggle_dark_mode(self.is_dark_mode)

        if current_page and current_page in self.pages:
            self.show_page(current_page)

    def update_theme(self):
        self.sidebar.configure(fg_color="#242529" if self.is_dark_mode else "#EDEDED")
        for page in self.pages.values():
            page.configure(fg_color="#1E1E1E" if self.is_dark_mode else "#FFFFFF")

        self.mode_label.configure(text="Dark Mode" if self.is_dark_mode else "Light Mode", text_color="white" if self.is_dark_mode else "black")
        self.edit_button.configure(text_color="white" if self.is_dark_mode else "black", hover_color=self.highlight_bg)

        for button, icon, page_name, active in self.nav_buttons:
            button.configure(text_color="white" if self.is_dark_mode else "black",
                             fg_color=self.highlight_bg if active else "transparent")
            icon_path = os.path.abspath(os.path.join(os.path.dirname(__file__), f"../../Images/{page_name}_{'dark' if self.is_dark_mode else 'light'}.png"))
            if os.path.exists(icon_path):
                new_icon = ctk.CTkImage(Image.open(icon_path), size=(26, 26))
                button.configure(image=new_icon)
                button.image = new_icon

    def update_logo(self):
        logo_filename = "logo_dark.png" if self.is_dark_mode else "logo_light.png"
        logo_path = os.path.abspath(os.path.join(os.path.dirname(__file__), f"../../Images/{logo_filename}"))

        if os.path.exists(logo_path):
            logo_img = ctk.CTkImage(Image.open(logo_path), size=(180, 100))
            self.logo_label.configure(image=logo_img)
            self.logo_label.image = logo_img

if __name__ == "__main__":
    root = ctk.CTk()
    app = HomeGUI(root)
    root.mainloop()