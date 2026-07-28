import customtkinter as ctk
from PIL import Image, ImageTk
import os
import cv2
import folium
import time
from ultralytics import YOLO
from threading import Thread
from tkinter import filedialog
from geopy.geocoders import Nominatim
import tkintermapview
from tkinterweb import HtmlFrame
import psutil
import GPUtil
import threading

class PromptsPage(ctk.CTkFrame):
    def __init__(self, parent, is_dark_mode):
        super().__init__(parent, fg_color="#1E1E1E" if is_dark_mode else "white", corner_radius=0)
        self.upload_local_button = None
        self.upload_ip_button = None
        self.is_dark_mode = is_dark_mode
        self.upload_location = None
        self.selected_location = None

        self.button_bg = "#2C2C2C" if self.is_dark_mode else "white"
        self.plus_bg = "#2C2C2C" if self.is_dark_mode else "#F0F0F0"
        self.text_color = "white" if self.is_dark_mode else "black"

        self.plus_icon_path = os.path.abspath(os.path.join(os.path.dirname(__file__),
                               "../../Images/add_dark.png" if self.is_dark_mode else "../../Images/add_light.png"))

        self.video_path = None
        base_dir = os.path.dirname(os.path.abspath(__file__))
        model_path = os.path.join(base_dir, "../../crash-detection.pt")

        if not os.path.exists(model_path):
            raise FileNotFoundError(f"🚨 Model file not found: {model_path}")

        self.yolo_model = YOLO(model_path)

        self.conf_threshold = 0.5
        self.iou_threshold = 0.5
        self.max_detections = 10
        self.object_tracker = {}

        self.create_ui()

    def create_ui(self):
        self.create_top_bar()
        self.create_footage_rectangle()

    def create_top_bar(self):
        self.top_bar = ctk.CTkFrame(self, width=1300, height=60, fg_color=self.button_bg, corner_radius=30)
        self.top_bar.place(relx=0.5, rely=0.06, anchor="center")

        self.search_entry = ctk.CTkEntry(self.top_bar, placeholder_text="Search for footage...",
                                         width=350, height=35, fg_color=self.button_bg,
                                         text_color=self.text_color, border_width=0, corner_radius=20)
        self.search_entry.place(relx=0.02, rely=0.5, anchor="w")

        search_icon_path = os.path.abspath(os.path.join(os.path.dirname(__file__),
                              "../../Images/search_light.png" if self.is_dark_mode else "../../Images/search_light.png"))

        search_icon = ctk.CTkImage(Image.open(search_icon_path), size=(20, 20))
        self.search_icon_label = ctk.CTkLabel(self.top_bar, image=search_icon, text="")
        self.search_icon_label.place(relx=0.22, rely=0.5, anchor="w")
        self.view_toggle = ctk.CTkFrame(self.top_bar, width=150, height=35, fg_color=self.button_bg, corner_radius=20)
        self.view_toggle.place(relx=0.98, rely=0.5, anchor="e")

        card_icon_path = os.path.abspath(os.path.join(os.path.dirname(__file__),
                              "../../Images/cards_light.png" if self.is_dark_mode else "../../Images/cards_light.png"))
        list_icon_path = os.path.abspath(os.path.join(os.path.dirname(__file__),
                              "../../Images/list_light.png" if self.is_dark_mode else "../../Images/list_light.png"))

        card_icon = ctk.CTkImage(Image.open(card_icon_path), size=(20, 20))
        list_icon = ctk.CTkImage(Image.open(list_icon_path), size=(20, 20))

        self.card_view_button = ctk.CTkButton(self.view_toggle, text="Card", image=card_icon,
                                              width=50, height=30, fg_color="transparent",
                                              hover_color=self.button_bg, text_color=self.text_color)
        self.card_view_button.place(relx=0.05, rely=0.5, anchor="w")

        self.list_view_button = ctk.CTkButton(self.view_toggle, text="List", image=list_icon,
                                              width=50, height=30, fg_color="transparent",
                                              hover_color=self.button_bg, text_color=self.text_color)
        self.list_view_button.place(relx=0.95, rely=0.5, anchor="e")

    def create_footage_rectangle(self):
        if not hasattr(self, "footage_frames"):
            self.footage_frames = []

        y_offset = 0.3 + (len(self.footage_frames) * 0.42)  # More spacing

        footage_frame = ctk.CTkFrame(self, width=650, height=400, fg_color=self.button_bg, corner_radius=30)
        footage_frame.place(relx=0.26, rely=y_offset, anchor="center")

        footage_frame.bind("<Button-1>", lambda event: self.open_upload_popup(footage_frame))

        plus_icon = ctk.CTkImage(Image.open(self.plus_icon_path), size=(40, 40))
        plus_button = ctk.CTkButton(
            footage_frame,
            image=plus_icon,
            text="",
            fg_color=self.plus_bg,
            hover_color=self.plus_bg,
            border_width=0,  # 🚫 remove border
            corner_radius=0,  # 🔲 match sharpness if needed
            width=50,
            height=50,
            command=lambda: self.open_upload_popup(footage_frame)
        )

        plus_button.place(relx=0.5, rely=0.5, anchor="center")

        footage_frame.plus_button = plus_button
        footage_frame.video_label = None  # Will be created later after upload
        self.footage_frames.append(footage_frame)
        return footage_frame

    def open_upload_popup(self, footage_frame=None):
        if hasattr(self, "popup_frame"):
            self.popup_frame.destroy()

        y_offset = 0.28 if len(self.footage_frames) == 1 else 0.4  # Lower position on second upload

        self.popup_frame = ctk.CTkFrame(self, width=250, height=140, fg_color=self.button_bg, corner_radius=0)
        self.popup_frame.place(relx=0.25, rely=y_offset, anchor="center")

        close_button = ctk.CTkButton(self.popup_frame, text="X", width=20, height=20,
                                     fg_color="red", text_color="white", corner_radius=3,
                                     command=self.popup_frame.destroy)
        close_button.place(relx=0.95, rely=0.1, anchor="center")

        ip_icon_path = os.path.abspath(os.path.join(os.path.dirname(__file__),
                                                    "../../Images/ip_dark.png" if self.is_dark_mode else "../../Images/ip_light.png"))
        ip_icon = ctk.CTkImage(Image.open(ip_icon_path), size=(20, 20))
        self.upload_ip_button = ctk.CTkButton(self.popup_frame, text="Upload IP Footage", image=ip_icon,
                                              fg_color=self.button_bg, hover_color="#363538",
                                              text_color=self.text_color, width=200, height=40)
        self.upload_ip_button.place(relx=0.5, rely=0.4, anchor="center")

        local_icon_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../Images/local_dark.png"))
        local_icon = ctk.CTkImage(Image.open(local_icon_path), size=(20, 20))
        self.upload_local_button = ctk.CTkButton(self.popup_frame, text="Upload Local Data", image=local_icon,
                                                 fg_color=self.button_bg, hover_color="#363538",
                                                 text_color=self.text_color, width=200, height=40,
                                                 command=self.open_location_picker)
        self.upload_local_button.place(relx=0.5, rely=0.75 if len(self.footage_frames) == 1 else 0.85, anchor="center")

    def open_location_picker(self):
        default_location = [10.0480, 76.3149]
        self.selected_location = {"latitude": default_location[0], "longitude": default_location[1]}

        self.location_window = ctk.CTkToplevel(self)
        self.location_window.title("Select Location")
        self.location_window.geometry("800x600")

        # Ensure the window appears in front
        self.location_window.lift()
        self.location_window.attributes('-topmost', True)

        self.map_widget = tkintermapview.TkinterMapView(self.location_window, width=800, height=600)
        self.map_widget.pack()

        self.map_widget.set_position(*default_location)
        self.map_widget.set_zoom(15)

        pin_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../Images/pin.png"))
        pin_image = Image.open(pin_path)
        small_pin = pin_image.resize((20, 20))

        self.marker_icon = ImageTk.PhotoImage(small_pin)

        self.marker = self.map_widget.set_marker(
            default_location[0], default_location[1],
            text="Select Here", icon=self.marker_icon
        )

        def on_map_click(lat, lng):  # ✅ Accepts lat, lng directly
            self.selected_location = {"latitude": lat, "longitude": lng}
            self.marker.set_position(lat, lng)
            self.marker.set_text("Select Here")
            print(f"✔ Selected Location: {lat}, {lng}")  # Log selection

        # ✅ Pass `lat, lng` as separate arguments to `on_map_click`
        self.map_widget.add_right_click_menu_command(
            label="Move Pin Here",
            command=lambda coords: on_map_click(*coords),  # ✅ Fix: Unpacking tuple
            pass_coords=True
        )

        def save_and_close():
            self.location_window.destroy()
            self.save_location_and_proceed()

        self.location_window.protocol("WM_DELETE_WINDOW", save_and_close)

    def save_location_and_proceed(self):
        if not self.selected_location:
            print("⚠️ Error: No coordinates received from map.")
            return

        lat, lng = self.selected_location["latitude"], self.selected_location["longitude"]
        print(f"✔ Location Confirmed: {lat}, {lng}")

        self.location_window.destroy()
        self.proceed_to_upload()

    def on_marker_drag(self, marker):
        lat, lng = marker.position
        self.selected_location = {"latitude": lat, "longitude": lng}
        print(f"Marker moved to: {lat}, {lng}")

    def update_location(self, lat, lng):
        self.marker.set_position(lat, lng)
        self.marker.set_text(f"Location: {lat:.4f}, {lng:.4f}")
        self.selected_location = {"latitude": lat, "longitude": lng}
        print(f"✅ Updated Location: {lat:.4f}, {lng:.4f}")

    def proceed_to_upload(self):
        file_path = filedialog.askopenfilename(filetypes=[("MP4 Files", "*.mp4"), ("PNG Images", "*.png")])

        if file_path:
            self.video_path = file_path

            if hasattr(self, "popup_frame"):
                self.popup_frame.destroy()

            last_frame = self.footage_frames[-1]

            # ⛔ Remove plus button
            if hasattr(last_frame, "plus_button"):
                last_frame.plus_button.destroy()

            self.process_video(last_frame)
            self.create_settings_panel()

            # ✅ Add new empty upload rectangle
            self.create_footage_rectangle()

    def generate_map(self):
        default_location = [10.0480, 76.3149]  # Might change to like tamil nadu cuz funny
        folium_map = folium.Map(location=default_location, zoom_start=15)

        map_html = folium_map._repr_html_()

        self.map_frame = ctk.CTkFrame(self.location_window, width=500, height=400)
        self.map_frame.pack(pady=10)

        self.map_widget = HtmlFrame(self.map_frame)
        self.map_widget.pack(fill="both", expand=True)

        self.map_widget.load_html(map_html)

    def search_location(self):
        geolocator = Nominatim(user_agent="geoapiExercises")
        location = geolocator.geocode(self.search_entry.get())

        if location:
            self.map_widget.set_position(location.latitude, location.longitude)
            self.selected_location = (location.latitude, location.longitude, location.address)

    def save_location(self):
        if hasattr(self, "selected_location"):
            self.upload_location = self.selected_location
            self.location_window.destroy()
            self.upload_file()



    def upload_file(self):
        file_path = filedialog.askopenfilename(filetypes=[("MP4 Files", "*.mp4"), ("PNG Images", "*.png")])
        if file_path:
            self.video_path = file_path
            self.popup_frame.destroy()
            self.create_settings_panel()
            if file_path.endswith(".mp4"):
                Thread(target=self.process_video).start()

    def create_settings_panel(self):
        self.settings_panel = ctk.CTkFrame(self, width=300, height=250, fg_color=self.button_bg, corner_radius=10)
        self.settings_panel.place(relx=0.67, rely=0.3, anchor="center")

        location_text = "Selected Location: --" if not self.selected_location else \
            f"Location: {self.selected_location['latitude']}, {self.selected_location['longitude']}"

        self.location_title = ctk.CTkLabel(self.settings_panel, text=location_text, text_color="white",
                                           font=("Arial", 16, "bold"))
        self.location_title.pack(pady=5)

        def add_slider(label_text, from_, to_, command, default_value):
            frame = ctk.CTkFrame(self.settings_panel, fg_color="transparent")
            frame.pack(pady=(5, 2), fill="x")

            value_label = ctk.CTkLabel(frame, text=f"{default_value:.2f}", text_color=self.text_color, width=40,
                                       font=("Arial", 14))
            value_label.pack(side="left", padx=5)

            title_label = ctk.CTkLabel(frame, text=label_text, text_color=self.text_color,
                                       font=("Arial", 14))
            title_label.pack(side="left", padx=15)

            slider = ctk.CTkSlider(frame, from_=from_, to=to_,
                                   command=lambda v: [value_label.configure(text=f"{float(v):.2f}"), command(v)])
            slider.set(default_value)
            slider.pack(fill="x", expand=True)

        add_slider("Item Amount (Max 30):", 1, 30, self.update_max_detections, self.max_detections)
        add_slider("Confidence Threshold", 0.1, 1.0, self.update_conf_threshold, self.conf_threshold)
        add_slider("IoU Threshold", 0.1, 1.0, self.update_iou_threshold, self.iou_threshold)

        self.notifications_frame = ctk.CTkFrame(self.settings_panel, fg_color="transparent")
        self.notifications_frame.pack(pady=5, fill="x")

        self.notifications_label = ctk.CTkLabel(self.notifications_frame, text="Send Notifications",
                                                text_color="white", font=("Arial", 14))
        self.notifications_label.pack(side="left", padx=15)

        self.notifications_toggle = ctk.CTkCheckBox(self.notifications_frame, text="", width=20)
        self.notifications_toggle.pack(side="right", padx=10)
        self.notifications_toggle.select()  # Default checked

        # 🔄 Update crash_notifications_single in settings.json when toggled
        def on_toggle():
            import json
            settings_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../json/settings.json"))
            try:
                with open(settings_path, "r") as f:
                    settings = json.load(f)
            except:
                settings = {}

            settings["crash_notifications_single"] = 1 if self.notifications_toggle.get() == 1 else 0

            with open(settings_path, "w") as f:
                json.dump(settings, f, indent=4)

        self.notifications_toggle.configure(command=on_toggle)

        def create_info_block(parent, icon_name, text):
            frame = ctk.CTkFrame(parent, width=180, height=40, fg_color="#363538", corner_radius=10)
            frame.pack_propagate(False)

            icon_path = os.path.abspath(os.path.join(os.path.dirname(__file__),
                                                     f"../../Images/{icon_name}_dark.png" if self.is_dark_mode else f"../../Images/{icon_name}_light.png"))
            icon = ctk.CTkImage(Image.open(icon_path), size=(18, 18))

            label = ctk.CTkLabel(frame, text=f"  {text}", text_color="white", image=icon, compound="left",
                                 font=("Arial", 14))
            label.pack(padx=10)
            return frame, label

        system_grid = ctk.CTkFrame(self.settings_panel, fg_color="transparent")
        system_grid.pack(pady=15)

        row1 = ctk.CTkFrame(system_grid, fg_color="transparent")
        row1.pack(pady=8)
        self.cpu_frame, self.cpu_label = create_info_block(row1, "cpu", "CPU Usage: --")
        self.gpu_frame, self.gpu_label = create_info_block(row1, "gpu", "GPU Usage: --")
        self.cpu_frame.pack(side="left", padx=5)
        self.gpu_frame.pack(side="left", padx=5)

        row2 = ctk.CTkFrame(system_grid, fg_color="transparent")
        row2.pack(pady=8)
        self.ram_frame, self.ram_label = create_info_block(row2, "ram", "RAM Usage: --")
        self.network_frame, self.network_label = create_info_block(row2, "network", "Network: --")
        self.ram_frame.pack(side="left", padx=5)
        self.network_frame.pack(side="left", padx=5)

        row3 = ctk.CTkFrame(system_grid, fg_color="transparent")
        row3.pack(pady=8)
        self.uptime_frame, self.uptime_label = create_info_block(row3, "uptime", "Uptime: 0s")
        self.status_frame, self.status_label = create_info_block(row3, "status", "Status:")
        self.uptime_frame.pack(side="left", padx=5)
        self.status_frame.pack(side="left", padx=5)

        self.start_time = time.time()
        self.prev_net_io = psutil.net_io_counters()
        self.update_system_usage()

    def update_system_usage(self):
        import json
        threading.Thread(target=self._fetch_system_usage, daemon=True).start()

        settings_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../json/settings.json"))
        status_text = "No"
        try:
            with open(settings_path, "r") as f:
                settings = json.load(f)
                if settings.get("crash_notifications", 0) == 1 and settings.get("crash_notifications_single", 0) == 1:
                    status_text = "Yes"
        except:
            pass

        self.status_label.configure(text=f"Status: {status_text}")

        ram_usage = psutil.virtual_memory().percent
        cpu_usage = psutil.cpu_percent(interval=0.5)
        gpus = GPUtil.getGPUs()
        gpu_usage = gpus[0].load * 100 if gpus else "N/A"
        net_io = psutil.net_io_counters()
        download_speed = (net_io.bytes_recv - self.prev_net_io.bytes_recv) / 1024
        upload_speed = (net_io.bytes_sent - self.prev_net_io.bytes_sent) / 1024
        self.prev_net_io = net_io

        elapsed_time = int(time.time() - self.start_time)
        uptime_str = f"{elapsed_time // 60}m {elapsed_time % 60}s"

        self.ram_label.configure(text=f"RAM Usage: {ram_usage:.1f}%")
        self.cpu_label.configure(text=f"CPU Usage: {cpu_usage:.1f}%")
        self.gpu_label.configure(
            text=f"GPU Usage: {gpu_usage:.1f}%" if gpu_usage != "N/A" else "GPU Monitoring Unavailable")
        self.network_label.configure(text=f"Network: ↓ {download_speed:.1f} KB/s ↑ {upload_speed:.1f} KB/s")
        self.uptime_label.configure(text=f"Uptime: {uptime_str}")

        self.after(5000, self.update_system_usage)

    def _fetch_system_usage(self):
        cpu_usage = psutil.cpu_percent(interval=0)
        self.cpu_label.configure(text=f"CPU Usage: {cpu_usage}%")

        try:
            import GPUtil
            gpus = GPUtil.getGPUs()
            if gpus:
                gpu_usage = gpus[0].load * 100
                self.gpu_label.configure(text=f"GPU Usage: {gpu_usage:.1f}%")
            else:
                self.gpu_label.configure(text="GPU Usage: N/A")
        except:
            self.gpu_label.configure(text="GPU Monitoring Unavailable")

    def update_system_usage(self):
        ram_usage = psutil.virtual_memory().percent

        cpu_usage = psutil.cpu_percent(interval=0.5)

        gpus = GPUtil.getGPUs()
        gpu_usage = gpus[0].load * 100 if gpus else "N/A"

        net_io = psutil.net_io_counters()
        download_speed = (net_io.bytes_recv - self.prev_net_io.bytes_recv) / 1024  # KB/s
        upload_speed = (net_io.bytes_sent - self.prev_net_io.bytes_sent) / 1024  # KB/s
        self.prev_net_io = net_io

        elapsed_time = int(time.time() - self.start_time)
        uptime_str = f"{elapsed_time // 60}m {elapsed_time % 60}s"

        self.ram_label.configure(text=f"RAM Usage: {ram_usage:.1f}%")
        self.cpu_label.configure(text=f"CPU Usage: {cpu_usage:.1f}%")
        self.gpu_label.configure(
            text=f"GPU Usage: {gpu_usage:.1f}%" if gpu_usage != "N/A" else "GPU Monitoring Unavailable")
        self.network_label.configure(text=f"Network: ↓ {download_speed:.1f} KB/s ↑ {upload_speed:.1f} KB/s")
        self.uptime_label.configure(text=f"Uptime: {uptime_str}")

        self.after(5000, self.update_system_usage)

    def close_settings_panel(self):
        self.settings_panel.destroy()
        self.footage_frame.destroy()
        self.create_footage_rectangle()

    def update_max_detections(self, value):
        self.max_detections = int(value)

    def update_conf_threshold(self, value):
        self.conf_threshold = float(value)

    def update_iou_threshold(self, value):
        self.iou_threshold = float(value)

    def process_video(self, footage_frame):
        if not footage_frame.video_label:
            video_label = ctk.CTkLabel(footage_frame, text="")
            video_label.place(relx=0.5, rely=0.5, anchor="center")
            footage_frame.video_label = video_label
        else:
            video_label = footage_frame.video_label

        cap = cv2.VideoCapture(self.video_path)
        if not cap.isOpened():
            return

        base_dir = os.path.dirname(os.path.abspath(__file__))
        crash_model = YOLO(os.path.join(base_dir, "../../crash.pt"))
        crash_frame_counter = 0
        crash_triggered = False

        self.custom_ids = {}
        self.id_counter = 10

        def update_ui():
            nonlocal crash_frame_counter, crash_triggered

            ret, frame = cap.read()
            if not ret:
                cap.release()
                return

            # Run both models
            track_result = self.yolo_model.track(frame, persist=True, conf=self.conf_threshold,
                                                 iou=self.iou_threshold, max_det=self.max_detections)[0]
            crash_result = crash_model.predict(source=frame, conf=0.5, iou=0.5)[0]

            # Manual drawing instead of .plot()
            draw_tracked_boxes(frame, track_result)
            draw_crash_boxes(frame, crash_result)

            # Count accident frames
            cls_names = crash_result.names
            detected = crash_result.boxes.cls.tolist()
            if any("accident" in cls_names[int(c)].lower() for c in detected):
                crash_frame_counter += 1
            else:
                crash_frame_counter = max(0, crash_frame_counter - 1)

            if crash_frame_counter >= 10 and not crash_triggered:
                crash_triggered = True
                print("💥 Crash Detected (model)")
                self.after(10, lambda: [
                    self.show_crash_popup("Crash", "Detected"),
                    self.upload_crash_to_firebase(),
                    self.send_crash_notification()
                ])

            # Display
            frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            img = Image.fromarray(frame)
            ctk_img = ctk.CTkImage(img, size=(650, 400))
            video_label = footage_frame.winfo_children()[-1]
            video_label.configure(image=ctk_img)
            video_label.image = ctk_img

            self.after(10, update_ui)

        def draw_tracked_boxes(frame, result):
            for box in result.boxes:
                try:
                    track_id = int(box.id)
                except:
                    continue
                x1, y1, x2, y2 = map(int, box.xyxy[0])
                label = self.custom_ids.get(track_id)
                if label is None:
                    self.custom_ids[track_id] = self.id_counter
                    label = self.id_counter
                    self.id_counter += 1
                cv2.rectangle(frame, (x1, y1), (x2, y2), (255, 0, 0), 2)  # Blue
                cv2.putText(frame, f"ID {label}", (x1, y1 - 10),
                            cv2.FONT_HERSHEY_SIMPLEX, 0.7, (255, 0, 0), 2)

        def draw_crash_boxes(frame, result):
            for box in result.boxes:
                cls_id = int(box.cls[0])
                label = result.names[cls_id]
                if "accident" in label.lower():
                    x1, y1, x2, y2 = map(int, box.xyxy[0])
                    cv2.rectangle(frame, (x1, y1), (x2, y2), (0, 0, 255), 2)  # Red
                    cv2.putText(frame, label, (x1, y1 - 10),
                                cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 0, 255), 2)

        update_ui()

    def upload_crash_to_firebase(self):
        import datetime
        import uuid
        import firebase_admin
        from firebase_admin import credentials, firestore, messaging

        # Init Firebase (once)
        if not firebase_admin._apps:
            cred_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../firebase_config.json"))
            cred = credentials.Certificate(cred_path)
            firebase_admin.initialize_app(cred)

        db = firestore.client()
        now = datetime.datetime.now()
        crash_id = str(uuid.uuid4())

        data = {
            "crash_id": crash_id,
            "crash_address": {
                "latitude": self.selected_location["latitude"],
                "longitude": self.selected_location["longitude"]
            },
            "crash_date": now.strftime("%Y-%m-%d"),
            "crash_time": now.strftime("%H:%M:%S"),
            "resolved": "no",
            "crash_pic": None,
            "crash_description": None
        }

        db.collection("crash").document(crash_id).set(data)
        print("📡 Crash uploaded to Firebase")

    def send_crash_notification(self):
        from firebase_admin import messaging

        message = messaging.Message(
            notification=messaging.Notification(
                title="Crash Alert ⚠️",
                body="A crash has been detected! Check the app for details!"
            ),
            topic="crash_alerts"  # You must subscribe mobile app to this topic
        )

        try:
            response = messaging.send(message)
            print(f"📲 Push notification sent: {response}")
        except Exception as e:
            print(f"❌ Failed to send FCM notification: {e}")

    def toggle_dark_mode(self, new_mode: bool):
        self.is_dark_mode = new_mode
        self.button_bg = "#2C2C2C" if self.is_dark_mode else "#F0F0F0"
        self.plus_bg = "#2C2C2C" if self.is_dark_mode else "#F0F0F0"
        self.text_color = "white" if self.is_dark_mode else "black"
        self.configure(fg_color="#1E1E1E" if self.is_dark_mode else "white")

        self.plus_icon_path = os.path.abspath(os.path.join(os.path.dirname(__file__),
                                                           "../../Images/add_dark.png" if self.is_dark_mode else "../../Images/add_dark.png"))

        # Update top bar
        if hasattr(self, "top_bar"):
            self.top_bar.configure(fg_color=self.button_bg)
            self.search_entry.configure(fg_color=self.button_bg, text_color=self.text_color)
            self.card_view_button.configure(hover_color=self.button_bg, text_color=self.text_color)
            self.list_view_button.configure(hover_color=self.button_bg, text_color=self.text_color)
            self.view_toggle.configure(fg_color=self.button_bg)

        # Update all footage frames
        if hasattr(self, "footage_frames"):
            for frame in self.footage_frames:
                frame.configure(fg_color=self.button_bg)
                if hasattr(frame, "plus_button"):
                    plus_icon = ctk.CTkImage(Image.open(self.plus_icon_path), size=(40, 40))
                    frame.plus_button.configure(image=plus_icon, fg_color=self.plus_bg, hover_color=self.plus_bg)
                    frame.plus_button.image = plus_icon

        # Recreate settings panel
        if hasattr(self, "video_path") and self.video_path:
            self.settings_panel.destroy()
            self.create_settings_panel()

    def show_crash_popup(self, id1, id2):
        popup = ctk.CTkToplevel(self)
        popup.geometry("300x150")
        popup.title("Crash Alert")

        label = ctk.CTkLabel(popup, text=f"💥 Crash Detected!\n Notification has been sent", font=("Arial", 16, "bold"))
        label.pack(pady=20)

        close_btn = ctk.CTkButton(popup, text="Close", command=popup.destroy)
        close_btn.pack(pady=5)

    def update_notification_setting(self):
        import json
        settings_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../json/settings.json"))

        try:
            with open(settings_path, "r") as f:
                settings = json.load(f)
        except:
            settings = {}

        settings["crash_notifications_single"] = 1 if self.notifications_toggle.get() == 1 else 0

        with open(settings_path, "w") as f:
            json.dump(settings, f, indent=4)



