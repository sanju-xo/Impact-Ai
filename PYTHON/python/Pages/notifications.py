from PIL import Image, ImageTk
import firebase_admin
from firebase_admin import firestore
from firebase_admin import credentials
import os
import customtkinter as ctk
from datetime import datetime
from tkinter import messagebox
from geopy.geocoders import Nominatim
from tkintermapview import TkinterMapView


if not firebase_admin._apps:
    config_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../json/firebase_config.json"))
    cred = credentials.Certificate(config_path)
    firebase_admin.initialize_app(cred)
class NotificationsPage(ctk.CTkFrame):
    def __init__(self, parent, is_dark_mode):
        super().__init__(parent, width=1350, height=1000, fg_color="#1E1E1E" if is_dark_mode else "white",
                         corner_radius=0)
        self.is_dark_mode = is_dark_mode
        self.db = firestore.client()

        self.create_ui()
        self.load_notifications()

    def create_ui(self):
        self.title_label = ctk.CTkLabel(self, text="Recent Notifications", font=("Arial", 30, "bold"))
        self.title_label.place(relx=0.01, rely=0.07, anchor="w")

        self.notification_frame = ctk.CTkFrame(self, width=1400, height=750, fg_color="transparent")
        self.notification_frame.place(relx=0.5, rely=0.5, anchor="center")

        self.scrollable_frame = ctk.CTkScrollableFrame(self.notification_frame, width=1380, height=780)
        self.scrollable_frame.pack(pady=10, padx=10)

        refresh_icon_path = os.path.abspath(os.path.join(os.path.dirname(__file__),
                                                          "../../Images/refresh_dark.png" if self.is_dark_mode else "../../Images/refresh_light.png"))
        refresh_icon = ctk.CTkImage(Image.open(refresh_icon_path), size=(30, 30))
        self.refresh_button = ctk.CTkButton(self, image=refresh_icon, text="", width=40, height=40,
                                            fg_color="transparent", command=self.load_notifications)
        self.refresh_button.place(relx=0.98, rely=0.07, anchor="center")

        self.send_notification_button = ctk.CTkButton(self, text="Send Notification", width=180, height=50,
                                                       font=("Arial", 16), corner_radius=10,
                                                       command=self.open_notification_form)
        self.send_notification_button.place(relx=0.92, rely=0.94, anchor="center")

    def apply_theme(self):
        bg_color = "#1E1E1E" if self.is_dark_mode else "#FFFFFF"
        text_color = "white" if self.is_dark_mode else "black"
        button_color = "#1F6AA5" if self.is_dark_mode else "#1F6AA5"
        hover_color = "#292929" if self.is_dark_mode else "#D0D0D0"
        notification_bg = "#2C2C2C" if self.is_dark_mode else "#F0F0F0"
        divider_color = "#FFFFFF" if not self.is_dark_mode else "#1E1E1E"

        refresh_icon_path = os.path.abspath(os.path.join(os.path.dirname(__file__),
                                                         "../../Images/refresh_light.png" if self.is_dark_mode else "../../Images/refresh_dark.png"))

        self.configure(fg_color=bg_color)
        self.notification_frame.configure(fg_color="transparent")
        self.scrollable_frame.configure(fg_color="transparent")
        self.send_notification_button.configure(fg_color=button_color, text_color="white", hover_color=hover_color)
        self.refresh_button.configure(image=ctk.CTkImage(Image.open(refresh_icon_path), size=(30, 30)))

        self.title_label.configure(text_color=text_color)

        for notification in self.scrollable_frame.winfo_children():
            if isinstance(notification, ctk.CTkFrame):
                notification.configure(fg_color=notification_bg)

            for widget in notification.winfo_children():
                if isinstance(widget, ctk.CTkLabel):
                    if "address_label" in widget._name:
                        continue
                    widget.configure(text_color=text_color)

        for widget in self.scrollable_frame.winfo_children():
            if isinstance(widget, ctk.CTkFrame) and widget["height"] == 2:
                widget.configure(fg_color=divider_color)

    def update_theme(self, is_dark_mode):
        self.is_dark_mode = is_dark_mode
        self.apply_theme()

    def load_notifications(self):
        for widget in self.scrollable_frame.winfo_children():
            widget.destroy()

        crashes = (
            self.db.collection("crash")
            .order_by("crash_date", direction=firestore.Query.DESCENDING)
            .order_by("crash_time", direction=firestore.Query.DESCENDING)
            .order_by("__name__", direction=firestore.Query.ASCENDING)
            .limit(10)
            .stream()
        )

        for crash in crashes:
            data = crash.to_dict()

            status_icon_path = os.path.abspath(os.path.join(os.path.dirname(__file__),
                                                            "../../Images/no.png" if data[
                                                                                         "resolved"] == "no" else "../../Images/yes.png"))
            status_color = "#ff5757" if data["resolved"] == "no" else "#7ed957"

            notification_container = ctk.CTkFrame(self.scrollable_frame, width=1360, height=150, fg_color="#2C2C2C")
            notification_container.pack(pady=5, padx=10, fill="x")

            status_icon = ctk.CTkImage(Image.open(status_icon_path), size=(25, 25))
            status_label = ctk.CTkLabel(notification_container, image=status_icon, text="")
            status_label.place(relx=0.015, rely=0.15, anchor="w")

            address_label = ctk.CTkLabel(notification_container, text=data['crash_address'],
                                         font=("Arial", 18, "bold"), text_color=status_color)
            address_label.place(relx=0.042, rely=0.15, anchor="w")

            info_text = (
                f"Crash ID: {data.get('crash_id', 'N/A')}\n"
                f"Crash Date: {data.get('crash_date', 'N/A')}\n"
                f"Crash Time: {data.get('crash_time', 'N/A')}\n"
                f"Latitude: {data.get('latitude', 'N/A')}\n"
                f"Longitude: {data.get('longitude', 'N/A')}\n"
                f"Address: {data.get('crash_address', 'N/A')}\n"
                f"Resolved: {data.get('resolved', 'no')}\n"
            )

            info_label = ctk.CTkLabel(notification_container, text=info_text, wraplength=900, justify="left")
            info_label.place(relx=0.02, rely=0.6, anchor="w")

            divider = ctk.CTkFrame(self.scrollable_frame, width=1340, height=2,
                                   fg_color="#1E1E1E")
            divider.pack(pady=5, padx=10)

    def open_notification_form(self):
        self.map_window = ctk.CTkToplevel(self)
        self.map_window.title("Select Crash Location")
        self.map_window.geometry("800x600")
        self.map_window.lift()
        self.map_window.attributes('-topmost', True)

        default_location = [10.0480, 76.3149]
        self.selected_location = {"latitude": default_location[0], "longitude": default_location[1]}

        self.map_widget = TkinterMapView(self.map_window, width=800, height=600)
        self.map_widget.pack()
        self.map_widget.set_position(*default_location)
        self.map_widget.set_zoom(15)

        pin_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../Images/pin.png"))
        pin_image = Image.open(pin_path)
        small_pin = pin_image.resize((20, 20))
        self.marker_icon = ImageTk.PhotoImage(small_pin)

        self.marker = self.map_widget.set_marker(
            default_location[0], default_location[1],
            text="Right click", icon=self.marker_icon
        )

        def on_map_click(coords):
            lat, lng = coords
            self.selected_location = {"latitude": lat, "longitude": lng}
            self.marker.set_position(lat, lng)
            self.marker.set_text("Select Here")
            print(f"✔ Selected Location: {lat}, {lng}")

        self.map_widget.add_right_click_menu_command(
            label="Select this location",
            command=on_map_click,
            pass_coords=True
        )

        self.map_window.protocol("WM_DELETE_WINDOW", self.send_notification)

    def send_notification(self):
        if not self.selected_location:
            print("⚠️ Error: No coordinates received from map.")
            return

        lat = round(self.selected_location["latitude"], 5)
        lng = round(self.selected_location["longitude"], 5)

        print(f"✔ Final Location Confirmed: {lat}, {lng}")

        geolocator = Nominatim(user_agent="geoapiExercises")
        try:
            location = geolocator.reverse((lat, lng), language="en", exactly_one=True, timeout=10)
            if location:
                self.selected_address = location.address
            else:
                self.selected_address = f"Coordinates: ({lat}, {lng})"
        except Exception as e:
            print(f"⚠️ Geocoding Error: {e}")
            self.selected_address = f"Coordinates: ({lat}, {lng})"

        crash_id = f"crash_{int(datetime.timestamp(datetime.now()))}"
        crash_date = datetime.now().strftime("%Y-%m-%d")
        crash_time = datetime.now().strftime("%H:%M:%S")

        data = {
            "crash_id": crash_id,
            "crash_address": self.selected_address,
            "latitude": lat,
            "longitude": lng,
            "crash_date": crash_date,
            "crash_time": crash_time,
            "resolved": "no",
            "crash_pic": "",
            "crash_description": "None"
        }

        self.db.collection("crash").document(crash_id).set(data)
        messagebox.showinfo("Success", "Notification has been sent!.")

        self.map_window.destroy()

    def submit_notification(self):
        crash_id = f"crash_{int(datetime.timestamp(datetime.now()))}"
        crash_date = datetime.now().strftime("%Y-%m-%d")
        crash_time = datetime.now().strftime("%H:%M:%S")

        data = {
            "crash_id": crash_id,
            "crash_address": self.address_entry.get(),
            "latitude": float(self.latitude_entry.get()),
            "longitude": float(self.longitude_entry.get()),
            "crash_date": crash_date,
            "crash_time": crash_time,
            "resolved": "no",
            "crash_pic": "",
            "crash_description": self.description_entry.get()
        }

        self.db.collection("crash").document(crash_id).set(data)
        messagebox.showinfo("Success", "Notification has been sent!.")
        self.form_window.destroy()
        self.load_notifications()
