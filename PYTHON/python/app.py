import customtkinter as ctk
from python.Pages.login import LoginGUI
from python.Pages.main import HomeGUI

def switch_to_home():
    root.destroy()
    new_root = ctk.CTk()
    HomeGUI(new_root)
    new_root.mainloop()

root = ctk.CTk()
app = LoginGUI(root, switch_to_home)
root.mainloop()