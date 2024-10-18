import sys, serial, serial.tools.list_ports
from PyQt5.QtWidgets import  QVBoxLayout, QSplitter, QGridLayout, QTableWidget, QLabel, QTableWidgetItem, QHBoxLayout, QMessageBox, QFormLayout, QComboBox
from PyQt5.QtWidgets import QApplication, QMainWindow, QTextEdit, QAction, QFileDialog, QTabWidget, QWidget, QPushButton, QTabBar, QLineEdit, QDialog
from PyQt5.QtCore import Qt
from PyQt5.QtGui import QIcon, QTransform, QColor


class IDE(QMainWindow):
    def __init__(self):
        super().__init__()
        self.Serial = Serial()
        self.init_ui()

    def init_ui(self):
        # 设置应用图标
        self.setWindowIcon(QIcon('icons/app.svg'))

        # 设置主窗口属性
        self.setGeometry(200, 200, 1600, 900)
        self.setWindowTitle('IDE')
        self.showMaximized()

        # 创建菜单栏
        menubar = self.menuBar()

        # 文件菜单
        file_Menu = menubar.addMenu('File')

        new_Action = QAction(QIcon('icons/new.svg'), 'New', self) # 新建文件
        new_Action.setToolTip('New')
        new_Action.setShortcut('Ctrl+N') # 设置快捷键
        new_Action.triggered.connect(self.newFile)
        file_Menu.addAction(new_Action)

        open_Action = QAction(QIcon('icons/open.svg'), 'Open', self) # 打开动作
        open_Action.setToolTip('Open')
        open_Action.setShortcut('Ctrl+O')  # 设置快捷键
        open_Action.triggered.connect(self.openFile)
        file_Menu.addAction(open_Action)

        close_Action = QAction(QIcon('icons/close.svg'), 'Close', self) # 关闭动作
        close_Action.setToolTip('Close')
        close_Action.setShortcut('Ctrl+W') # 设置快捷键
        close_Action.triggered.connect(self.closeFile)
        file_Menu.addAction(close_Action)

        closeall_Action = QAction('Close All', self) # 关闭所有动作
        # closeall_Action.setShortcut('Ctrl+Shift+W') # 设置快捷键
        closeall_Action.triggered.connect(self.closeAllFiles)
        file_Menu.addAction(closeall_Action)

        file_Menu.addSeparator()  # 分隔线

        save_Action = QAction(QIcon('icons/save.svg'), 'Save', self) # 保存动作
        save_Action.setToolTip('Save')
        save_Action.setShortcut('Ctrl+S')  # 设置快捷键
        save_Action.triggered.connect(self.saveFile)
        file_Menu.addAction(save_Action)

        saveas_Action = QAction('Save As...', self) # 另存动作
        # saveas_Action.setShortcut('Ctrl+Shift+S') # 设置快捷键
        saveas_Action.triggered.connect(self.saveasFile)
        file_Menu.addAction(saveas_Action)

        saveall_Action = QAction('Save All', self) # 全部保存
        # saveall_Action.setShortcut('Ctrl+Alt+S') # 设置快捷键
        saveall_Action.triggered.connect(self.saveAllFiles)
        file_Menu.addAction(saveall_Action)

        file_Menu.addSeparator()  # 分隔线

        exit_Action = QAction(QIcon('icons/exit.svg'), 'Exit', self) # 退出动作
        exit_Action.setToolTip('Exit')
        exit_Action.setShortcut('Ctrl+Q')  # 设置快捷键
        exit_Action.triggered.connect(self.close)
        file_Menu.addAction(exit_Action)

        # 编辑菜单
        edit_Menu = menubar.addMenu('Edit')

        undo_Action = QAction(QIcon('icons/undo.svg'), 'Undo', self) # 撤销操作
        undo_Action.setToolTip('Undo')
        undo_Action.setShortcut('Ctrl+Z')  # 设置快捷键
        undo_Action.triggered.connect(self.undo)
        edit_Menu.addAction(undo_Action)

        redo_Action = QAction(QIcon('icons/redo.svg'), 'Redo', self) # 重做操作
        redo_Action.setToolTip('Redo')
        redo_Action.setShortcut('Ctrl+Y')  # 设置快捷键
        redo_Action.triggered.connect(self.redo)
        edit_Menu.addAction(redo_Action)

        edit_Menu.addSeparator()  # 分隔线

        cut_Action = QAction(QIcon('icons/cut.svg'), 'Cut', self) # 剪切操作
        cut_Action.setToolTip('Cut')
        cut_Action.setShortcut('Ctrl+X')  # 设置快捷键
        cut_Action.triggered.connect(self.cut)
        edit_Menu.addAction(cut_Action)

        copy_Action = QAction(QIcon('icons/copy.svg'), 'Copy', self) # 复制操作
        copy_Action.setToolTip('Copy')
        copy_Action.setShortcut('Ctrl+C')  # 设置快捷键
        copy_Action.triggered.connect(self.copy)
        edit_Menu.addAction(copy_Action)

        paste_Action = QAction(QIcon('icons/paste.svg'), 'Paste', self) # 粘贴操作
        paste_Action.setToolTip('Paste')
        paste_Action.setShortcut('Ctrl+V')  # 设置快捷键
        paste_Action.triggered.connect(self.paste)
        edit_Menu.addAction(paste_Action)

        # 运行菜单
        run_Menu = menubar.addMenu('Run')

        # self.assembled = False
        # assemble_Action = QAction(QIcon('icons/assemble.svg'), 'Assemble', self) # 编译
        # assemble_Action.setToolTip('Assemble')
        # assemble_Action.triggered.connect(self.assemble)
        # run_Menu.addAction(assemble_Action)

        self.run_Action = QAction(QIcon('icons/run.svg'), 'Run', self) # 运行代码
        self.run_Action.setToolTip('Run')
        self.run_Action.triggered.connect(self.run)
        self.run_Action.setEnabled(False)
        run_Menu.addAction(self.run_Action)

        self.run_step_Action = QAction(QIcon(QIcon('icons/run_step.svg').pixmap(22, 22)), 'Run step', self) # 单步运行
        self.run_step_Action.setToolTip('Run step')
        self.run_step_Action.triggered.connect(self.run_step)
        self.run_step_Action.setEnabled(False)
        run_Menu.addAction(self.run_step_Action)

        self.run_undo_Action = QAction(QIcon(QIcon('icons/run_step.svg').pixmap(22, 22).transformed(QTransform().scale(-1, 1))), 'Run undo', self) # 单步退回
        self.run_undo_Action.setToolTip('Run undo')
        self.run_undo_Action.triggered.connect(self.run_undo)
        self.run_undo_Action.setEnabled(False)
        run_Menu.addAction(self.run_undo_Action)

        self.reset_Action = QAction(QIcon('icons/reset.svg'), 'Reset', self) # 重启
        self.reset_Action.setToolTip('Reset')
        self.reset_Action.triggered.connect(self.reset)
        self.reset_Action.setEnabled(False)
        run_Menu.addAction(self.reset_Action)

        self.stop_Action = QAction(QIcon('icons/stop.svg'), 'Stop', self) # 停止运行
        self.stop_Action.setToolTip('Stop')
        self.stop_Action.triggered.connect(self.stop)
        self.stop_Action.setEnabled(False)
        run_Menu.addAction(self.stop_Action)

        self.download_Action = QAction(QIcon('icons/download.svg'), 'Download', self) # 烧录
        self.download_Action.setToolTip('Download')
        self.download_Action.triggered.connect(self.download)
        self.download_Action.setEnabled(False)
        run_Menu.addAction(self.download_Action)

        # 帮助菜单
        help_Menu = menubar.addMenu('Help')

        about_Action = QAction('About', self) # 关于
        about_Action.setToolTip('About')
        about_Action.triggered.connect(self.about)
        help_Menu.addAction(about_Action)


        # 工具栏
        toolbar1 = self.addToolBar('Toolbar1')
        toolbar1.addAction(new_Action)
        toolbar1.addAction(open_Action)
        toolbar1.addAction(close_Action)
        toolbar1.addAction(save_Action)

        toolbar2 = self.addToolBar('Toolbar2')
        toolbar2.addAction(undo_Action)
        toolbar2.addAction(redo_Action)
        toolbar2.addAction(cut_Action)
        toolbar2.addAction(copy_Action)
        toolbar2.addAction(paste_Action)

        toolbar3 = self.addToolBar('Toolbar3')
        # toolbar3.addAction(assemble_Action)
        toolbar3.addAction(self.run_Action)
        toolbar3.addAction(self.run_step_Action)
        toolbar3.addAction(self.run_undo_Action)
        toolbar3.addAction(self.reset_Action)
        toolbar3.addAction(self.stop_Action)
        toolbar3.addAction(self.download_Action)
        # 添加其他工具栏项...


        # 创建主窗口
        main_widget = QWidget(self)
        self.setCentralWidget(main_widget)

        # 创建QSplitter
        splitter = QSplitter(main_widget)

        # 创建主窗格
        main_pane = QTabWidget(splitter)
        file_tab = QWidget()
        execute_tab = QWidget()
        main_pane.addTab(file_tab, "File")
        main_pane.addTab(execute_tab, "Execute")

        # 创建水平布局
        file_tab_layout = QHBoxLayout(file_tab)

        # 创建左侧的编辑区域
        self.edit_area = QTabWidget(file_tab)
        file_tab_layout.addWidget(self.edit_area, stretch=4)

        # 创建右侧的文本编辑区域
        compile_result_layout = QVBoxLayout() # 创建垂直布局
        self.assemble_code_area = QTextEdit()
        self.machine_code_area = QTextEdit()
        self.assemble_code_area.setReadOnly(True)
        self.machine_code_area.setReadOnly(True)
        compile_result_layout.addWidget(self.assemble_code_area)
        compile_result_layout.addWidget(self.machine_code_area)

        file_tab_layout.addLayout(compile_result_layout, stretch=1)

        # 在 execute_tab 中创建一个 QGridLayout
        execute_layout = QGridLayout(execute_tab)

        # 创建四个表格 设置每个表格的行列数
        self.code_table = QTableWidget(32, 4)
        self.label_table = QTableWidget(8, 2)
        self.data_table = QTableWidget(32, 9)
        self.register_table = QTableWidget(8, 3)

        # 表格初始化
        self.table_init()

        # 创建标签
        text_label = QLabel(" Text")
        label_label = QLabel(" Label")
        data_label = QLabel(" Data")
        register_label = QLabel(" Register")

        # 将小部件添加到 execute_layout 中
        execute_layout.addWidget(text_label, 0, 0)
        execute_layout.addWidget(self.code_table, 1, 0)
        execute_layout.addWidget(label_label, 0, 1)
        execute_layout.addWidget(self.label_table, 1, 1)
        execute_layout.addWidget(data_label, 2, 0)
        execute_layout.addWidget(self.data_table, 3, 0)
        execute_layout.addWidget(register_label, 2, 1)
        execute_layout.addWidget(self.register_table, 3, 1)

        # 设置 execute_layout 中四个区域的大小比例
        execute_layout.setRowStretch(0, 1)    # 设置第一行的伸展因子
        execute_layout.setRowStretch(1, 10)   # 设置第二行的伸展因子
        execute_layout.setRowStretch(2, 1)    # 设置第三行的伸展因子
        execute_layout.setRowStretch(3, 10)   # 设置第四行的伸展因子
        execute_layout.setColumnStretch(0, 3) # 设置第一列的伸展因子
        execute_layout.setColumnStretch(1, 1) # 设置第二列的伸展因子

        # 创建消息窗格
        messages_pane = QTabWidget(splitter)
        self.message_tab = QTextEdit()
        self.serial_tab = QTextEdit()
        messages_pane.addTab(self.message_tab, "Message  ")
        messages_pane.addTab(self.serial_tab, "Serial  ")

        # Message窗口添加按钮
        message_clear_bottom = QPushButton(QIcon(QIcon("icons/clear.svg").pixmap(15, 15)), '')
        message_clear_bottom.setFlat(True)
        message_clear_bottom.setFixedHeight(22)
        message_clear_bottom.setFixedWidth(22)
        message_clear_bottom.clicked.connect(self.message_clear)
        messages_pane.tabBar().setTabButton(0, QTabBar.RightSide, message_clear_bottom)

        # Serial窗口添加按钮
        button_layout = QHBoxLayout()

        serial_setting_bottom = QPushButton(QIcon(QIcon("icons/setting.svg").pixmap(15, 15)), '')
        serial_setting_bottom.setFlat(True)
        serial_setting_bottom.setFixedHeight(22)
        serial_setting_bottom.setFixedWidth(22)
        serial_setting_bottom.clicked.connect(self.serial_setting)
        button_layout.addWidget(serial_setting_bottom)

        self.serial_connect_bottom = QPushButton(QIcon(QIcon("icons/connect.svg").pixmap(15, 15)), '')
        self.serial_connect_bottom.setFlat(True)
        self.serial_connect_bottom.setFixedHeight(22)
        self.serial_connect_bottom.setFixedWidth(22)
        self.serial_connect_bottom.clicked.connect(self.serial_connect)
        button_layout.addWidget(self.serial_connect_bottom)

        self.serial_disconnect_bottom = QPushButton(QIcon(QIcon("icons/disconnect.svg").pixmap(15, 15)), '')
        self.serial_disconnect_bottom.setFlat(True)
        self.serial_disconnect_bottom.setFixedHeight(22)
        self.serial_disconnect_bottom.setFixedWidth(22)
        self.serial_disconnect_bottom.clicked.connect(self.serial_disconnect)
        self.serial_disconnect_bottom.setEnabled(False)
        button_layout.addWidget(self.serial_disconnect_bottom)

        serial_clear_bottom = QPushButton(QIcon(QIcon("icons/clear.svg").pixmap(15, 15)), '')
        serial_clear_bottom.setFlat(True)
        serial_clear_bottom.setFixedHeight(22)
        serial_clear_bottom.setFixedWidth(22)
        serial_clear_bottom.clicked.connect(self.serial_clear)
        button_layout.addWidget(serial_clear_bottom)

        button_layout.setContentsMargins(0, 3, 0, 3)

        container = QWidget()
        container.setLayout(button_layout)
        messages_pane.tabBar().setTabButton(1, QTabBar.RightSide, container)


        # 设置布局
        splitter_layout = QVBoxLayout(main_widget)
        splitter_layout.addWidget(splitter)  # 将QSplitter添加到布局中
        main_widget.setLayout(splitter_layout)

        # 设置分隔窗格
        splitter.setOrientation(Qt.Vertical)
        # splitter.setStyleSheet("QSplitter::handle { background: qlineargradient(x1:0, y1:0, x2:1, y2:0, stop:0 #a9a9a9, stop:1 #a9a9a9); border: 1px dashed #000000; }")
        # splitter.setHandleWidth(1)
        splitter.setSizes([445, 100]) # 设置 edit_tab 和 execute_tab 的大小比例

    def table_init(self):
        # 设置表格只读
        self.code_table.setEditTriggers(QTableWidget.NoEditTriggers)
        self.label_table.setEditTriggers(QTableWidget.NoEditTriggers)
        self.data_table.setEditTriggers(QTableWidget.NoEditTriggers)
        self.register_table.setEditTriggers(QTableWidget.NoEditTriggers)

        # 设置表头
        self.code_table.setHorizontalHeaderLabels(["Address", "Code", "Basic", "Source"])
        self.label_table.setHorizontalHeaderLabels(["Label", "Address"])
        self.data_table.setHorizontalHeaderLabels(["Address", "Value(+0)", "Value(+1)", "Value(+2)", "Value(+3)", "Value(+4)", "Value(+5)", "Value(+6)", "Value(+7)"])
        self.register_table.setHorizontalHeaderLabels(["Register", "Name", "Value"])

        # 设置表格不显示行号
        self.code_table.verticalHeader().setVisible(False)
        self.label_table.verticalHeader().setVisible(False)
        self.data_table.verticalHeader().setVisible(False)
        self.register_table.verticalHeader().setVisible(False)

        # 设置表格列宽
        self.set_ColumnWidth(self.code_table, 9)
        self.set_ColumnWidth(self.label_table, 8)
        self.set_ColumnWidth(self.data_table, 8)
        self.set_ColumnWidth(self.register_table, 8)

        # 设置表格行高
        self.set_RowWidth()

        # 设置 code_table 表格初值
        for row in range(self.code_table.rowCount()):
            for col in range(self.code_table.columnCount()):
                item = QTableWidgetItem('-')
                item.setTextAlignment(Qt.AlignCenter)
                self.code_table.setItem(row, col, item)

        # 设置 label_table 表格初值
        for row in range(self.label_table.rowCount()):
            for col in range(self.label_table.columnCount()):
                item = QTableWidgetItem('-')
                item.setTextAlignment(Qt.AlignCenter)
                self.label_table.setItem(row, col, item)

        # 设置 data_table 表格初值
        data_index = 0
        for row in range(self.data_table.rowCount()):
            for col in range(self.data_table.columnCount()):
                if col == 0:
                    address = "0x{:04X}".format(data_index*8)
                    item = QTableWidgetItem(address)
                    item.setTextAlignment(Qt.AlignCenter)
                    self.data_table.setItem(row, col, item)
                    data_index += 1
                else:
                    item = QTableWidgetItem('0x0000')
                    item.setTextAlignment(Qt.AlignCenter)
                    self.data_table.setItem(row, col, item)

        # 设置 register_table 表格初值
        register_init = [
            ["r0", "s0", "0x0000"],
            ["r1", "a1", "0x0000"],
            ["r2", "a2", "0x0000"],
            ["r3", "a3", "0x0000"],
            ["r4", "a4", "0x0000"],
            ["r5", "a5", "0x0000"],
            ["r6", "sp", "0x0000"],
            ["r7", "ra", "0x0000"],
        ]
        for row in range(self.register_table.rowCount()):
            for col in range(self.register_table.columnCount()):
                item = QTableWidgetItem(register_init[row][col])
                item.setTextAlignment(Qt.AlignCenter)
                self.register_table.setItem(row, col, item)

        # 设置奇数行背景颜色为浅灰色，偶数行背景颜色为深灰色
        for tabel in [self.code_table, self.label_table, self.data_table, self.register_table]:
            for row in range(self.code_table.rowCount()):
                self.setRowBackgroundColor(tabel, row, None)

    def setRowBackgroundColor(self, tabel, row, color):
        if row % 2 == 0:
            for col in range(tabel.columnCount()):
                item = tabel.item(row, col)
                if item is not None:
                    if color:
                        item.setBackground(color)
                    else:
                        item.setBackground(QColor(220, 220, 220)) # Light gray
        else:
            for col in range(tabel.columnCount()):
                item = tabel.item(row, col)
                if item is not None:
                    if color:
                        item.setBackground(color)
                    else:
                        item.setBackground(QColor(200, 200, 200)) # Darker gray

    def set_RowWidth(self):
        for table_widget in [self.label_table, self.register_table, self.code_table, self.data_table]:
            for row in range(table_widget.rowCount()):
                table_widget.setRowHeight(row, 32)

    def set_ColumnWidth(self, table, line_num):
        if table == self.code_table:
            self.code_table.setColumnWidth(0, 134)  # Address
            self.code_table.setColumnWidth(1, 413)  # Code
            self.code_table.setColumnWidth(2, 413)  # Basic
            self.code_table.setColumnWidth(3, 413)  # Source
        elif table == self.label_table:
            if line_num > 8:
                self.label_table.setColumnWidth(0, 230)  # Label
                self.label_table.setColumnWidth(1, 230)  # Address
            else:
                self.label_table.setColumnWidth(0, 232)  # Label
                self.label_table.setColumnWidth(1, 232)  # Address
        elif table == self.data_table:
            self.data_table.setColumnWidth(0, 134)  # Address
            for row in range(self.data_table.rowCount()-1):
                self.data_table.setColumnWidth(row+1, 155)  # Address
        elif table == self.register_table:
            self.register_table.setColumnWidth(0, 154)  # Register
            self.register_table.setColumnWidth(1, 155)  # Name
            self.register_table.setColumnWidth(2, 155)  # Value

    def findCodetablerow(self, data):
        for row in range(self.code_table.rowCount()):
            item = self.code_table.item(row, 0)  # 第一列的item
            if item and item.text() == str(data):  # 判断item存在且文本与data相等
                return row  # 返回找到的行数
        return -1  # 未找到返回-1

    def newFile(self):
        # 创建新的文本编辑器选项卡
        text_edit = QTextEdit(self)
        self.edit_area.addTab(text_edit, "Untitled*")

        # 切换到新创建的选项卡
        index = self.edit_area.indexOf(text_edit)
        self.edit_area.setCurrentIndex(index)

    def openFile(self):
        # 打开文件对话框
        options = QFileDialog.Options()
        file_paths, _ = QFileDialog.getOpenFileNames(self, "Open Files", "", "Text Files (*.txt);;All Files (*)", options=options)

        for file_path in file_paths:
            if file_path:
                # 创建新的文本编辑器选项卡
                text_edit = QTextEdit(self)
                text_edit.file_path = file_path  # 设置文件路径属性
                self.edit_area.addTab(text_edit, file_path.split("/")[-1])
                # 读取文件内容并显示在文本编辑器中
                with open(file_path, 'r') as file:
                    text_edit.setPlainText(file.read())

    def closeFile(self):
        # 获取当前活动的选项卡索引
        current_index = self.edit_area.currentIndex()

        # 关闭当前选项卡
        if current_index != -1:
            self.edit_area.removeTab(current_index)

    def closeAllFiles(self):
        # 关闭所有选项卡
        self.edit_area.clear()

    def saveFile(self):
        # 获取当前活动的选项卡
        current_index = self.edit_area.currentIndex()
        current_tab = self.edit_area.widget(current_index)

        # 获取当前文件路径
        file_path = getattr(current_tab, 'file_path', None)
        # 如果没有文件路径，则调用另存为逻辑
        if not file_path:
            self.saveasFile()
            return

        # 将当前选项卡的文本编辑器内容保存到文件中
        if current_tab and file_path:
            with open(file_path, 'w') as file:
                file.write(current_tab.toPlainText())

    def saveasFile(self):
        # 获取当前活动的选项卡
        current_index = self.edit_area.currentIndex()
        current_tab = self.edit_area.widget(current_index)

        # 处理另存为文件逻辑
        if current_tab:
            options = QFileDialog.Options()
            fileName, _ = QFileDialog.getSaveFileName(self, "Save As", "", "Text Files (*.txt);;All Files (*)", options=options)
            if fileName:
                with open(fileName, 'w') as file:
                    file.write(current_tab.toPlainText())

    def saveAllFiles(self):
        # 迭代所有已打开的文件并保存它们
        for index in range(self.edit_area.count()):
            current_tab = self.edit_area.widget(index)
            file_path = getattr(current_tab, 'file_path', None)

            if current_tab and file_path:
                with open(file_path, 'w') as file:
                    file.write(current_tab.toPlainText())

    def undo(self):
        # 处理撤销逻辑
        current_index = self.edit_area.currentIndex()
        current_tab = self.edit_area.widget(current_index)

        if current_tab:
            current_tab.undo()

    def redo(self):
        # 处理重做逻辑
        current_index = self.edit_area.currentIndex()
        current_tab = self.edit_area.widget(current_index)

        if current_tab:
            current_tab.redo()

    def cut(self):
        # 处理剪切逻辑
        current_index = self.edit_area.currentIndex()
        current_tab = self.edit_area.widget(current_index)

        if current_tab:
            current_tab.cut()

    def copy(self):
        # 处理复制逻辑
        current_index = self.edit_area.currentIndex()
        current_tab = self.edit_area.widget(current_index)

        if current_tab:
            current_tab.copy()

    def paste(self):
        # 处理粘贴逻辑
        current_index = self.edit_area.currentIndex()
        current_tab = self.edit_area.widget(current_index)

        if current_tab:
            current_tab.paste()

    def run(self):
        # 运行程序
        self.Simulator.run()
        self.fillRegister(self.Simulator.registers)
        self.fillData(self.Simulator.data_mem)
        self.setRowBackgroundColor(self.code_table, self.findCodetablerow(self.Simulator.next_pc), None)

    def run_step(self):
        # 单步运行程序
        self.Simulator.run_step()
        self.fillRegister(self.Simulator.registers)
        self.fillData(self.Simulator.data_mem)

        # 将运行到的行标红
        self.setRowBackgroundColor(self.code_table, self.findCodetablerow(self.Simulator.next_pc), QColor(255, 0, 0))
        self.setRowBackgroundColor(self.code_table, self.findCodetablerow(self.Simulator.last_pc), None)

    def run_undo(self):
        # 单步返回程序
        self.Simulator.run_undo()
        self.fillRegister(self.Simulator.registers)
        self.fillData(self.Simulator.data_mem)
        # 将运行到的行标红
        self.setRowBackgroundColor(self.code_table, self.findCodetablerow(self.Simulator.next_pc), QColor(255, 0, 0))
        self.setRowBackgroundColor(self.code_table, self.findCodetablerow(self.Simulator.last_pc), None)

    def reset(self):
        # 将表格颜色恢复到初值
        self.setRowBackgroundColor(self.code_table, self.findCodetablerow(self.Simulator.next_pc), None)
        self.setRowBackgroundColor(self.code_table, self.findCodetablerow(self.Simulator.next_pc), QColor(255, 0, 0))

        # 清空寄存器
        self.fillRegister([0, 0, 0, 0, 0, 0, 0, 0])

        # 清空数据表
        data_mem_temp = self.Simulator.data_mem
        for key in data_mem_temp:
            data_mem_temp[key] = 0
        self.fillData(data_mem_temp)

        # 模拟器初始化
        self.Simulator.reset()

    def stop(self):
        # 停止运行程序
        pass

    def download(self):
        # 下载
        self.Downloader.download(self.machine_code_area.toPlainText())

    def about(self):
        # 关于
        about_text = "简单IDE v1.0\n\n一个基于PyQt的简单集成开发环境。\n\n作者: Moon"
        QMessageBox.about(self, '关于', about_text)

    def message_showmessage(self, message):
        # 将内容添加到messages
        current_content = self.message_tab.toPlainText()
        updated_content = current_content + message
        self.message_tab.setPlainText(updated_content)

    def message_clear(self):
        # 清除message
        self.message_tab.setPlainText('')

    def serial_showmessage(self, message):
        # 将内容添加到messages
        current_content = self.message_tab.toPlainText()
        updated_content = current_content + message
        self.serial_tab.setPlainText(updated_content)

    def serial_setting(self):
        # 打开串口配置窗口
        if self.Serial.exec_() == QDialog.Accepted:
            # 配置串口
            self.Downloader.serial_init(self.Serial.get_config())
            self.serial_connect()

    def serial_connect(self):
        # 连接串口
        if self.Downloader.serial_open():
            # self.Downloader.start_receiving()
            if self.machine_code_area.toPlainText():
                self.download_Action.setEnabled(True)
            self.serial_connect_bottom.setEnabled(False)
            self.serial_disconnect_bottom.setEnabled(True)
            self.message_showmessage("Port open successful\n")
        else:
            self.message_showmessage("Port occupied\n")

    def serial_disconnect(self):
        # 断开连接
        self.Downloader.serial_close()
        # self.Downloader.stop_receiving()
        self.download_Action.setEnabled(False)
        self.serial_connect_bottom.setEnabled(True)
        self.serial_disconnect_bottom.setEnabled(False)
        self.message_showmessage("Port  closed\n")

    def serial_clear(self):
        # 清除 serial message
        self.serial_tab.setPlainText('')

    def fillCode(self, assembly_code, machine_code, basic_code):
        # 按行分割文本
        lines_assembly = list(filter(lambda line: line.strip() != "", assembly_code.split('\n'))) # 去除空行
        lines_machine = machine_code.split('\n')
        lines_basic = basic_code.split('\n')

        # 设置表格的行数
        self.code_table.setRowCount(len(lines_assembly))

        # 填入数据
        line_index = 0
        for row_index in range(len(lines_assembly)):
            if not lines_assembly[row_index].endswith(':') and lines_machine[line_index] and lines_basic[line_index]:
                # 填入程序行数
                self.code_table.item(row_index, 0).setText(str(line_index))
                # 填入机械码
                self.code_table.item(row_index, 1).setText(lines_machine[line_index])
                # 填入处理后的汇编码
                self.code_table.item(row_index, 2).setText(lines_basic[line_index])
                self.code_table.item(row_index, 2).setTextAlignment(Qt.AlignLeft | Qt.AlignVCenter)
                line_index += 1
            # 填入汇编码
            self.code_table.item(row_index, 3).setText(lines_assembly[row_index].expandtabs(4))
            self.code_table.item(row_index, 3).setTextAlignment(Qt.AlignLeft | Qt.AlignVCenter)

    def fillLabel(self, data):
        # 设置表格的行数
        self.label_table.setRowCount(max(len(data), 8))

        # 填充表格
        for row, (key, value) in enumerate(data.items()):
            self.label_table.item(row, 0).setText(key)
            self.label_table.item(row, 1).setText(str(value))

    def fillData(self, data):
        # 根据字典填充数据到表格
        for address, value in data.items():
            self.data_table.item(address // 8, address % 8).setText("0x{:04X}".format(value))

    def fillRegister(self, data):
        # 确保数据和表格行数匹配
        if len(data) != self.register_table.rowCount():
            raise ValueError("Data dimensions do not match table dimensions.")

        for row in range(len(data)):
            self.register_table.item(row, 2).setText("0x{:04X}".format(data[row]))

class Serial(QDialog):
    def __init__(self):
        super().__init__()
        # self.serial_com = serial.Serial()
        self.init_ui()

    def init_ui(self):
        # 设置主窗口属性
        self.setGeometry(200, 200, 200, 200)
        self.setWindowTitle('Serial')

        layout = QFormLayout()
        self.setWindowIcon(QIcon('icons/serial.svg'))

        # COM端口选择
        self.com_line_edit = QComboBox()
        self.com_line_edit.addItems([])
        layout.addRow('COM Port:', self.com_line_edit)

        # 波特率选择
        self.baud_combo_box = QComboBox()
        self.baud_combo_box.addItems(['4800', '9600', '19200', '115200', '230400'])  # Add your desired baud rates
        self.baud_combo_box.setCurrentText('115200')  # Default value
        layout.addRow('Baud Rate:', self.baud_combo_box)

        # 数据位选择
        self.data_bits_combo_box = QComboBox()
        self.data_bits_combo_box.addItems(['5', '6', '7', '8', '9', '10'])  # Add your desired data bits
        self.data_bits_combo_box.setCurrentText('8')  # Default value
        layout.addRow('Data Bits:', self.data_bits_combo_box)

        # 校验位选择
        self.parity_combo_box = QComboBox()
        self.parity_combo_box.addItems(['None', 'Odd', 'Even', 'Mark'])  # Add your desired parity options
        self.parity_combo_box.setCurrentText('None')  # Default value
        layout.addRow('Parity:', self.parity_combo_box)

        # 停止位选择
        self.stop_bit_combo_box = QComboBox()
        self.stop_bit_combo_box.addItems(['1', '1.5', '2'])  # Add your desired stop bits
        self.stop_bit_combo_box.setCurrentText('1')  # Default value
        layout.addRow('Stop Bit:', self.stop_bit_combo_box)

        # 确定按钮
        ok_button = QPushButton('确定')
        ok_button.clicked.connect(self.accept)

        # 刷新按钮
        refresh_button = QPushButton('刷新')
        refresh_button.clicked.connect(self.refresh_ports)
        self.refresh_ports()

        layout.addRow(refresh_button, ok_button)

        self.setLayout(layout)

    def get_config(self):
        # 获取串口设置
        return {
            'port': self.com_line_edit.currentText(),
            'baud_rate': int(self.baud_combo_box.currentText()),
            'data_bits': int(self.data_bits_combo_box.currentText()),
            'parity': self.parity_combo_box.currentText(),
            'stop_bit': float(self.stop_bit_combo_box.currentText())
        }

    def refresh_ports(self):
        # 清除 com_line_edit 下拉框中的现有项
        self.com_line_edit.clear()
        # 使用 pyserial 的 list_ports 获取可用的 COM 端口列表
        ports = [port.device for port in serial.tools.list_ports.comports()]
        # 将端口添加到下拉框中
        self.com_line_edit.addItems(ports)

if __name__ == '__main__':
    app = QApplication(sys.argv)
    ide = IDE()
    sys.exit(app.exec_())

