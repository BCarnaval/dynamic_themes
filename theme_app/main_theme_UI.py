import sys
import getpass
import subprocess
from datetime import datetime
from _theme_UI import Ui_MainWindow
from qt_material import apply_stylesheet
from PyQt5.QtWidgets import QApplication, QMainWindow, QFileDialog, QMessageBox


# Themes from 'qt-material' library
themes = ['dark_amber.xml', 'dark_blue.xml', 'dark_cyan.xml',
          'dark_lightgreen.xml', 'dark_pink.xml', 'dark_purple.xml',
          'dark_red.xml', 'dark_teal.xml', 'dark_yellow.xml' 'light_amber.xml',
          'light_blue.xml', 'light_cyan.xml', 'light_cyan_500.xml',
          'light_lightgreen.xml', 'light_pink.xml', 'light_purple.xml',
          'light_red.xml', 'light_teal.xml', 'light_yellow.xml']


class Window(QMainWindow, Ui_MainWindow):
    """Docs
    """

    def __init__(self, parent=None):
        super().__init__(parent)
        self.setupUi(self)
        self.connect_signals_slots()

    def connect_signals_slots(self):
        """Connects user events to functions when a window is created.
        """
        # Connects browse button to method browse
        self.browse_directory.clicked.connect(self.browse)

        # Connects sliders to their methods
        self.start_slider.sliderMoved.connect(self.start_slider_func)
        self.stop_slider.sliderMoved.connect(self.stop_slider_func)

        # Connects clear button to clear method
        self.clear.clicked.connect(self.clear_inputs)

        # Connects start program button to start method
        self.start_program.clicked.connect(self.start)

        # Connects now button to live time setting method
        self.now_setting.clicked.connect(self.set_now)

        # Connects in 16h button to method
        self.in_16h_setting.clicked.connect(self.in_16_hours)
        return

    def browse(self):
        """Opens a directory selector tab in which user must
        choose a folder containing images to generate .css.
        """
        self.display_directory.clear()  # Initialise chosen directory display
        dialog = QFileDialog()  # Creating QFile browser widget
        dir = dialog.getExistingDirectory(
            dialog, "Open a folder", f"/Users/{getpass.getuser()}/",
            dialog.ShowDirsOnly)

        # Display directory in existing widget
        self.display_directory.append(dir)

        # Progressbar settings
        if self.display_directory.toPlainText() == '' \
                and self.progressBar.value() == 0:
            self.progressBar.setValue(0)
        elif self.display_directory.toPlainText() == '' \
                and self.progressBar.value() != 0:
            self.progressBar.setValue(self.progressBar.value() - 100)
        elif self.display_directory.toPlainText() != '':
            self.progressBar.setValue(self.progressBar.value() + 100)
        return

    def start_slider_func(self):
        """Computes start slider's value and outputs it.
        """
        self.start_slider.setMinimum(0)  # Set minimum value
        self.start_slider.setMaximum(25)  # Set maximum value
        self.start_slider.setSingleStep(1)  # Set slider's step

        # Display slider's value
        self.start_display.display(self.start_slider.value())
        return

    def stop_slider_func(self):
        """Computes stop slider's value and outputs it.
        """
        self.stop_slider.setMinimum(0)  # Set minimum value
        self.stop_slider.setMaximum(25)  # Set maximum value
        self.stop_slider.setSingleStep(1)  # Set slider's step

        # Display slider's value
        self.stop_display.display(self.stop_slider.value())
        return

    def clear_inputs(self):
        """Clears all inputs and sets them up to defaults.
        """
        self.display_directory.clear()  # Clear browser display

        self.start_slider.setValue(1)  # Set slider's defaults (1)
        self.stop_slider.setValue(1)

        self.stop_display.display(1)  # Display slider's defaults (1)
        self.start_display.display(1)

        self.shift_choice.setValue(0)  # Set shift to default (0)
        self.errors_display.clear()  # Clear errors display box
        self.progressBar.setValue(0)
        return

    def set_now(self):
        """Sets the start slider to current hour using datetime librairy.
        """
        now = datetime.now()  # Live clock
        hour = now.strftime("%H")
        self.start_slider.setValue(int(hour))
        self.start_display.display(int(hour))
        return

    def in_16_hours(self):
        """Sets the stop slider to 16h after the start slider.
        """
        if 16 + self.start_display.value() > 24:  # Condition working with %24
            self.stop_display.display(self.start_display.value() + 16 - 24)
            self.stop_slider.setValue(self.start_display.value() + 16 - 24)
        else:  # Add the classic +16h to the schedule
            self.stop_slider.setValue(16 + self.start_display.value())
            self.stop_display.display(16 + self.start_display.value())
        return

    def start(self):
        """Calls subprocess module to call test.sh bash function
        and its dependencies to dynamise wallpaper/themes.
        """
        self.errors_display.clear()  # Initialise errors display
        path = self.display_directory.toPlainText()  # Get directory text as str
        if path == '':  # Condition verifying if directory has been chosen
            self.errors_display.append("Please choose directory!")
        else:
            path += '/'
            command = f"bash /Users/{getpass.getuser()}/dynamic_themes/"
            f"test.sh {path} {self.start_display.value()} "
            f"{self.stop_display.value()} {self.shift_choice.value()}"

            # Confirmation window
            msg = QMessageBox()
            msg.setIcon(QMessageBox.Information)
            msg.setText("Verify Permissions")
            msg.setInformativeText(
                "This program will modify some of your computer's "
                "services, allow those changes?"
            )
            msg.setStandardButtons(QMessageBox.Ok | QMessageBox.Cancel)
            returned = msg.exec()
            if returned == QMessageBox.Ok:
                subprocess.run(command, shell=True, check=True,
                               text=True)  # Run process in terminal
                self.close()  # Close the app. after running programm
            else:
                msg.close()
        return


if __name__ == "__main__":
    app = QApplication(sys.argv)
    win = Window()
    apply_stylesheet(app, theme='dark_blue.xml')
    win.show()
    sys.exit(app.exec())
