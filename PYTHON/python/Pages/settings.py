import customtkinter as ctk
import os
import json
import shutil
from datetime import datetime
from firebase_admin import firestore, auth


class SettingsPage(ctk.CTkFrame):
    def __init__(self, parent, is_dark_mode):
        super().__init__(parent, width=1350, height=1000, fg_color="#1E1E1E" if is_dark_mode else "white",
                         corner_radius=0)

        self.settings_file = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../json/settings.json"))
        self.load_settings()

        self.is_dark_mode = True
        self.text_color = "white" if self.is_dark_mode else "black"
        self.button_color = "#4C78B5"
        self.button_text_color = "white"
        self.red_button_color = "#B54848"
        self.dropdown_bg = "#3A3B3C" if self.is_dark_mode else "#EDEDED"
        self.dropdown_width = 250
        self.title_label = ctk.CTkLabel(self, text="Settings", font=("Arial", 30, "bold"))
        self.title_label.place(relx=0.01, rely=0.07, anchor="w")

        self.logout_button = ctk.CTkButton(self, text="Log Out", width=200, height=50,
                                           fg_color=self.red_button_color, text_color="white",
                                           font=ctk.CTkFont(size=18), command=self.logout)
        self.logout_button.place(relx=0.98, rely=0.07, anchor="e")

        spacing_y = 0.13

        self.debug_toggle = ctk.CTkCheckBox(self, text="Enable Debug Mode", text_color=self.text_color,
                                            font=ctk.CTkFont(size=18), command=self.toggle_debug_mode)
        self.debug_toggle.place(relx=0.05, rely=spacing_y)
        self.debug_toggle.select() if self.settings.get("debug_mode", False) else self.debug_toggle.deselect()

        spacing_y += 0.07
        self.gpu_toggle = ctk.CTkCheckBox(self, text="Enable GPU Acceleration", text_color=self.text_color,
                                          font=ctk.CTkFont(size=18), command=self.toggle_gpu_acceleration)
        self.gpu_toggle.place(relx=0.05, rely=spacing_y)
        self.gpu_toggle.select() if self.settings.get("gpu_acceleration", False) else self.gpu_toggle.deselect()

        spacing_y += 0.07
        self.notifications_toggle = ctk.CTkCheckBox(self, text="Enable Crash Notifications", text_color=self.text_color,
                                                    font=ctk.CTkFont(size=18), command=self.toggle_crash_notifications)
        self.notifications_toggle.place(relx=0.05, rely=spacing_y)
        self.notifications_toggle.select() if self.settings.get("crash_notifications",
                                                                False) else self.notifications_toggle.deselect()

        self.map_view_var = ctk.StringVar(value=self.settings.get("map_view", "City View"))
        self.map_theme_var = ctk.StringVar(value=self.settings.get("map_theme", "Light"))
        self.font_var = ctk.StringVar(value=self.settings.get("font_size", "Small"))

        spacing_y += 0.07
        self.map_view_label = ctk.CTkLabel(self, text="Default Map View:", font=ctk.CTkFont(size=18),
                                           text_color=self.text_color)
        self.map_view_label.place(relx=0.05, rely=spacing_y)
        self.map_view_dropdown = ctk.CTkComboBox(self, variable=self.map_view_var,
                                                 values=["City View", "Satellite View", "Hybrid View"],
                                                 width=self.dropdown_width, height=40, font=ctk.CTkFont(size=16),
                                                 fg_color=self.dropdown_bg, text_color=self.text_color,
                                                 command=self.update_map_view)
        self.map_view_dropdown.place(relx=0.25, rely=spacing_y)

        spacing_y += 0.07
        self.map_theme_label = ctk.CTkLabel(self, text="Map Theme:", font=ctk.CTkFont(size=18),
                                            text_color=self.text_color)
        self.map_theme_label.place(relx=0.05, rely=spacing_y)
        self.map_theme_dropdown = ctk.CTkComboBox(self, variable=self.map_theme_var,
                                                  values=["Light", "Dark", "Satellite"],
                                                  width=self.dropdown_width, height=40, font=ctk.CTkFont(size=16),
                                                  fg_color=self.dropdown_bg, text_color=self.text_color,
                                                  command=self.update_map_theme)
        self.map_theme_dropdown.place(relx=0.25, rely=spacing_y)

        spacing_y += 0.07
        self.font_label = ctk.CTkLabel(self, text="Font Size:", font=ctk.CTkFont(size=18),
                                       text_color=self.text_color)
        self.font_label.place(relx=0.05, rely=spacing_y)
        self.font_dropdown = ctk.CTkComboBox(self, variable=self.font_var,
                                             values=["Small", "Medium", "Large"],
                                             width=self.dropdown_width, height=40, font=ctk.CTkFont(size=16),
                                             fg_color=self.dropdown_bg, text_color=self.text_color,
                                             command=self.update_font_size)
        self.font_dropdown.place(relx=0.25, rely=spacing_y)

        spacing_y += 0.12
        self.clear_cache_button = ctk.CTkButton(self, text="Clear Cache", width=self.dropdown_width, height=50,
                                                fg_color=self.button_color, text_color=self.button_text_color,
                                                font=ctk.CTkFont(size=18), command=self.clear_cache)
        self.clear_cache_button.place(relx=0.05, rely=spacing_y)
        self.export_reports_button = ctk.CTkButton(self, text="Export Reports", width=self.dropdown_width, height=50,
                                                   fg_color=self.button_color, text_color=self.button_text_color,
                                                   font=ctk.CTkFont(size=18), command=self.export_reports)
        self.export_reports_button.place(relx=0.25, rely=spacing_y)

        self.update_colors()
        self.apply_font_size()

    def toggle_dark_mode(self):
        self.is_dark_mode = not self.is_dark_mode
        self.settings["dark_mode"] = self.is_dark_mode
        self.save_settings()
        self.update_colors()
        self.apply_font_size()

    def update_colors(self):
        self.bg_color = "#1E1E1E" if self.is_dark_mode else "#FFFFFF"
        self.text_color = "white" if self.is_dark_mode else "black"
        self.button_color = "#4C78B5"
        self.button_text_color = "white"
        self.red_button_color = "#B54848"
        self.dropdown_bg = "#3A3B3C" if self.is_dark_mode else "#EDEDED"
        self.dropdown_width = 250

        self.configure(fg_color=self.bg_color)
        self.title_label.configure(text_color=self.text_color)
        self.map_view_label.configure(text_color=self.text_color)
        self.map_theme_label.configure(text_color=self.text_color)
        self.font_label.configure(text_color=self.text_color)
        self.debug_toggle.configure(text_color=self.text_color)
        self.gpu_toggle.configure(text_color=self.text_color)
        self.notifications_toggle.configure(text_color=self.text_color)

        self.map_view_dropdown.configure(fg_color=self.dropdown_bg, text_color=self.text_color)
        self.map_theme_dropdown.configure(fg_color=self.dropdown_bg, text_color=self.text_color)
        self.font_dropdown.configure(fg_color=self.dropdown_bg, text_color=self.text_color)

    def update_map_view(self, choice):
        self.settings["map_view"] = choice
        self.save_settings()

    def update_map_theme(self, choice):
        self.settings["map_theme"] = choice
        self.save_settings()

    def update_font_size(self, choice):
        self.settings["font_size"] = choice
        self.save_settings()
        self.apply_font_size()

    def apply_font_size(self):
        font_sizes = {"Small": 14, "Medium": 18, "Large": 22}
        selected_size = font_sizes.get(self.settings.get("font_size", "Small"), 14)

        self.title_label.configure(font=ctk.CTkFont(size=selected_size + 16, weight="bold"))
        self.map_view_label.configure(font=ctk.CTkFont(size=selected_size))
        self.map_theme_label.configure(font=ctk.CTkFont(size=selected_size))
        self.font_label.configure(font=ctk.CTkFont(size=selected_size))
        self.debug_toggle.configure(font=ctk.CTkFont(size=selected_size))
        self.gpu_toggle.configure(font=ctk.CTkFont(size=selected_size))
        self.notifications_toggle.configure(font=ctk.CTkFont(size=selected_size))
        self.logout_button.configure(font=ctk.CTkFont(size=selected_size))
        self.clear_cache_button.configure(font=ctk.CTkFont(size=selected_size))
        self.export_reports_button.configure(font=ctk.CTkFont(size=selected_size))

        self.map_view_dropdown.configure(font=ctk.CTkFont(size=selected_size))
        self.map_theme_dropdown.configure(font=ctk.CTkFont(size=selected_size))
        self.font_dropdown.configure(font=ctk.CTkFont(size=selected_size))

    def toggle_debug_mode(self):
        self.settings["debug_mode"] = self.debug_toggle.get()
        self.save_settings()

    def toggle_gpu_acceleration(self):
        self.settings["gpu_acceleration"] = self.gpu_toggle.get()
        self.save_settings()

    def toggle_crash_notifications(self):
        self.settings["crash_notifications"] = self.notifications_toggle.get()
        self.save_settings()

    def clear_cache(self):
        cache_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../cache"))
        if os.path.exists(cache_dir):
            shutil.rmtree(cache_dir)
        os.makedirs(cache_dir)
        print("✔ Cache Cleared Successfully!")

    def export_reports(self):
        reports_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../reports"))
        if not os.path.exists(reports_dir):
            os.makedirs(reports_dir)

        report_file = os.path.join(reports_dir, f"report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.txt")

        try:
            db = firestore.client()

            crashes = db.collection("crash").stream()
            crash_data = [crash.to_dict() for crash in crashes]

            user = auth.get_user(
                self.settings.get("current_user_id", "")) if "current_user_id" in self.settings else None
            user_info = f"Logged-in User: {user.email} (UID: {user.uid})" if user else "No user logged in"

            software_settings = json.dumps(self.settings, indent=4)

            with open(report_file, "w", encoding="utf-8") as f:
                f.write(f"🚨 Crash Detection Report\n")
                f.write(f"Generated on: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
                f.write("=" * 50 + "\n\n")

                f.write("👤 User Information\n")
                f.write(user_info + "\n\n")

                f.write("⚙️ Software Settings\n")
                f.write(software_settings + "\n\n")

                f.write("🚗 Crash Reports\n")
                for crash in crash_data:
                    f.write(json.dumps(crash, indent=4) + "\n\n")

            print(f"✔ Report exported successfully: {report_file}")

        except Exception as e:
            print(f"⚠️ Error exporting report: {e}")

    def logout(self):
        print("Logging out...")
        os._exit(0)

    def save_settings(self):
        with open(self.settings_file, "w") as f:
            json.dump(self.settings, f, indent=4)

    def load_settings(self):
        if os.path.exists(self.settings_file):
            with open(self.settings_file, "r") as f:
                self.settings = json.load(f)
