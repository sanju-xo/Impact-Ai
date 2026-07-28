import customtkinter as ctk
import matplotlib
matplotlib.use("TkAgg")  # Ensure Tkinter backend
import matplotlib.pyplot as plt
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
import threading
import os
import numpy as np
from firebase_admin import firestore
from collections import Counter
import datetime

class HomePage(ctk.CTkFrame):
    def __init__(self, parent, is_dark_mode):
        super().__init__(parent, fg_color="#1E1E1E" if is_dark_mode else "white", corner_radius=0)
        self.is_dark_mode = is_dark_mode

        self.title_label = ctk.CTkLabel(self, text="Welcome Back, Admin", font=("Arial", 30, "bold"))
        self.title_label.place(relx=0.01, rely=0.07, anchor="w")
        self.after(100, self.load_data_from_firestore)

    def load_data_from_firestore(self):
        db = firestore.client()
        crashes = list(db.collection("crash").stream())

        self.crash_docs = [c.to_dict() for c in crashes]

        self.total_count = len(self.crash_docs)
        self.resolved_count = sum(1 for c in self.crash_docs if c.get("resolved") == "yes")
        self.unresolved_count = sum(1 for c in self.crash_docs if c.get("resolved") == "no")

        self.monthly_counts = self.get_monthly_counts()
        self.recent_range_counts = self.get_range_counts()
        self.top_location = self.get_top_location()

        self.after(0, self.refresh_ui)

    def refresh_ui(self):
        self.create_stat_cards()
        self.display_crash_donut_chart()
        self.display_monthly_trend()
        self.display_most_frequent_location()

    def get_monthly_counts(self):
        counts = {"Jan": 0, "Feb": 0, "Mar": 0, "Apr": 0, "May": 0,
                  "Jun": 0, "Jul": 0, "Aug": 0, "Sep": 0, "Oct": 0, "Nov": 0, "Dec": 0}
        for doc in self.crash_docs:
            date_str = doc.get("crash_date")  # format: YYYY-MM-DD
            if date_str:
                try:
                    month = datetime.datetime.strptime(date_str, "%Y-%m-%d").strftime("%b")
                    if month in counts:
                        counts[month] += 1
                except:
                    pass
        return counts

    def get_range_counts(self):
        now = datetime.datetime.now()
        counts = [0, 0, 0]  # 7 days, 1 month, 1 year
        for doc in self.crash_docs:
            date_str = doc.get("crash_date")
            if date_str:
                try:
                    d = datetime.datetime.strptime(date_str, "%Y-%m-%d")
                    delta = (now - d).days
                    if delta <= 7: counts[0] += 1
                    if delta <= 30: counts[1] += 1
                    if delta <= 365: counts[2] += 1
                except:
                    pass
        return counts

    def get_top_location(self):
        locations = []
        for doc in self.crash_docs:
            addr = doc.get("crash_address")
            if isinstance(addr, str):
                locations.append(addr.strip())
            elif isinstance(addr, dict):
                formatted = addr.get("formatted")
                if formatted:
                    locations.append(formatted.strip())
        return Counter(locations).most_common(1)[0][0] if locations else "N/A"

    def create_stat_cards(self):
        # 📌 Stats Frame
        frame_color = "#1E1E1E" if self.is_dark_mode else "#FFFFFF"
        self.stats_frame = ctk.CTkFrame(self, width=1380, height=100, fg_color=frame_color, corner_radius=10)
        self.stats_frame.place(relx=0.517, rely=0.18, anchor="center")

        # Stats Data
        stats = [
            ("Total Crashes", str(self.total_count), "#4C78B5"),
            ("Resolved Crashes", str(self.resolved_count), "#42A047"),
            ("Unresolved Crashes", str(self.unresolved_count), "#E63946")
        ]

        for i, (title, value, color) in enumerate(stats):
            card = ctk.CTkFrame(self.stats_frame, width=350, height=90, fg_color="#2C2F36", corner_radius=8)
            card.place(relx=0.05 + (i * 0.28), rely=0.5, anchor="w")

            ctk.CTkLabel(card, text=title, font=("Arial", 14, "bold"), text_color="white").place(relx=0.05, rely=0.2)
            ctk.CTkLabel(card, text=value, font=("Arial", 24, "bold"), text_color=color).place(relx=0.05, rely=0.6)

    def display_crash_donut_chart(self):
        self.stats_container = ctk.CTkFrame(self, width=500, height=300,
                                            fg_color="#2C2F36" if self.is_dark_mode else "#E5E5E5",
                                            corner_radius=20)
        self.stats_container.place(relx=0.24, rely=0.4, anchor="center")

        self.crash_report_title = ctk.CTkLabel(self.stats_container, text="Crash Report",
                                               font=("Arial", 24, "bold"),
                                               text_color="white" if self.is_dark_mode else "black")
        self.crash_report_title.place(relx=0.5, rely=0.06, anchor="center")

        crash_data = self.recent_range_counts
        labels = ["Last 7 Days", "Last 1 Month", "Last 1 Year"]
        colors = ["#4C78B5", "#4CAF50", "#E74C3C"]
        bg = "#2C2F36" if self.is_dark_mode else "#E5E5E5"
        label_color = "white" if self.is_dark_mode else "black"

        fig, ax = plt.subplots(figsize=(5, 3))
        fig.patch.set_facecolor(bg)
        ax.set_facecolor(bg)

        wedges, texts = ax.pie(crash_data, colors=colors, startangle=100,
                               wedgeprops={"edgecolor": "#2C2F36" if self.is_dark_mode else "#F0F0F0", "linewidth": 1.5}                               )

        for i, text in enumerate(texts):
            text.set_color(label_color)
            text.set_text(f"{labels[i]}\n{crash_data[i]}")

        ax.set_xticks([])
        ax.set_yticks([])
        for spine in ax.spines.values():
            spine.set_visible(False)

        canvas = FigureCanvasTkAgg(fig, master=self.stats_container)
        canvas.draw()
        canvas.get_tk_widget().place(relx=0.5, rely=0.6, anchor="center")


    def display_monthly_trend(self):
        self.trend_container = ctk.CTkFrame(self, width=500, height=300,
                                            fg_color="#2C2F36" if self.is_dark_mode else "#F0F0F0",
                                            corner_radius=20)
        self.trend_container.place(relx=0.7, rely=0.4, anchor="center")

        self.trend_title = ctk.CTkLabel(self.trend_container, text="Monthly Crash Trend",
                                        font=("Arial", 24, "bold"),
                                        text_color="white" if self.is_dark_mode else "black")
        self.trend_title.place(relx=0.5, rely=0.06, anchor="center")

        x = list(self.monthly_counts.keys())
        y = list(self.monthly_counts.values())

        fig, ax = plt.subplots(figsize=(4.5, 2))
        bg = "#1E1E1E" if self.is_dark_mode else "#FFFFFF"
        label_color = "white" if self.is_dark_mode else "black"

        fig.patch.set_facecolor(bg)
        ax.set_facecolor(bg)
        ax.bar(x, y, color="#4C78B5", alpha=0.8)
        ax.grid(axis="y", linestyle="--", alpha=0.5, color=label_color)
        ax.set_axisbelow(True)
        ax.set_xlabel("Month", fontsize=10, color=label_color)
        ax.set_ylabel("Crashes", fontsize=10, color=label_color)
        ax.tick_params(colors=label_color, labelsize=10)
        ax.spines["top"].set_visible(False)
        ax.spines["right"].set_visible(False)
        ax.spines["left"].set_color(label_color)
        ax.spines["bottom"].set_color(label_color)

        canvas = FigureCanvasTkAgg(fig, master=self.trend_container)
        canvas.draw()
        canvas.get_tk_widget().place(relx=0.5, rely=0.6, anchor="center")


    def display_most_frequent_location(self):
        self.location_container = ctk.CTkFrame(self, width=1120, height=100, fg_color="#2C2F36", corner_radius=10)
        self.location_container.place(relx=0.47, rely=0.63, anchor="center")

        self.location_title = ctk.CTkLabel(self.location_container, text="Most Frequent Crash Location",
                                           font=("Arial", 18, "bold"), text_color="white")
        self.location_title.place(relx=0.5, rely=0.3, anchor="center")

        # Placeholder for actual location (fetch from Firebase later)
        self.location_value = ctk.CTkLabel(self.location_container, text=self.top_location,
                                           font=("Arial", 16), text_color="white")
        self.location_value.place(relx=0.5, rely=0.7, anchor="center")

    def toggle_dark_mode(self, is_dark):
        self.is_dark_mode = is_dark
        self.configure(fg_color="#1E1E1E" if is_dark else "white")
        if hasattr(self, "stats_frame"):
            self.stats_frame.destroy()
        self.create_stat_cards()

        bg = "#2C2F36" if is_dark else "#F0F0F0"
        text = "white" if is_dark else "black"
        if hasattr(self, "stats_container"):
            for widget in self.stats_container.winfo_children():
                widget.destroy()
            self.stats_container.configure(fg_color=bg)
        if hasattr(self, "trend_container"):
            self.trend_container.configure(fg_color=bg)

        if hasattr(self, "location_container"):
            self.location_container.configure(fg_color=bg)

        self.display_crash_donut_chart()
        self.display_monthly_trend()

        self.title_label.configure(text_color=text)
        self.crash_report_title.configure(text_color=text)
        self.trend_title.configure(text_color=text)
        self.location_title.configure(text_color=text)
        self.location_value.configure(text_color=text)

        for card in self.stats_frame.winfo_children():
            card.configure(fg_color=bg)
            for c in card.winfo_children():
                if isinstance(c, ctk.CTkLabel):
                    if c.cget("text").isdigit():
                        continue  # ❌ Skip number color change
                    c.configure(text_color=text)





