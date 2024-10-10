# Python程序从Intel HEX文件中读取RISC-V指令并列出a
def parse_hex_line(line):
    """
    解析一行Intel HEX文件 ， 返回一个元组 (数据长度, 地址, 记录类型, 数据)。，，，，，，，，，，，，
    """
    line = line.strip()
    if line[0] != ':':
        raise ValueError("Invalid HEX line")

    byte_count = int(line[1:3], 16)
    address = int(line[3:7], 16)
    record_type = int(line[7:9], 16)
    data = line[9:9 + byte_count * 2]
    checksum = int(line[9 + byte_count * 2:], 16)

    return address, record_type, data

def extract_code(file_path):
    """
    从Intel HEX文件中读取数据，并返回包含RISC-V程序指令的列表。
    """
    instructions = []

    with open(file_path, 'r') as file:
        for line in file:
            try:
                address, record_type, data = parse_hex_line(line)
                # 我们只关心数据记录类型（通常为0）
                if record_type == 0:
                    # 将16进制数据分成4字节的RISC-V指令
                    for i in range(0, len(data), 8):  # 8个字符是4字节（32位）的指令
                        instruction = data[i:i+8]
                        instructions.append((hex(address), instruction))
                        address += 4  # RISC-V指令是32位(4字节)，地址每次增加4

            except ValueError as e:
                print(f"Skipping invalid line: {line}")

    return instructions

# def save_bytes_to_files(instructions, output_dir):
#     """
#     将每条指令的每个字节保存到四个不同的文件中。
#     """
#     file_names = [output_dir, f'{output_dir}0', f'{output_dir}1', f'{output_dir}2', f'{output_dir}3']

#     # 打开文件进行写入
#     with open(file_names[0], 'w') as f0, \
#          open(file_names[1], 'w') as f1, \
#          open(file_names[2], 'w') as f2, \
#          open(file_names[3], 'w') as f3, \
#          open(file_names[4], 'w') as f4:

#         for address, instruction in instructions:
#             # 将每个字节写入相应的文件
#             f0.write(f'{instruction}\n')  # 全部字节
#             f1.write(f'{instruction[0:2]}\n')  # 第一个字节
#             f2.write(f'{instruction[2:4]}\n')  # 第二个字节
#             f3.write(f'{instruction[4:6]}\n')  # 第三个字节
#             f4.write(f'{instruction[6:8]}\n')  # 第四个字节

def save_bytes_to_files(instructions, output_dir):
    """
    将每条指令的每个字节保存到四个不同的文件中，确保每个文件写入1024字节数据。
    """
    file_names = [output_dir, f'{output_dir}0', f'{output_dir}1', f'{output_dir}2', f'{output_dir}3']

    # 每个文件的最大字节数
    max_bytes = 1024

    # 记录每个文件的字节内容
    bytes_content = [[] for _ in range(5)]

    # 收集每个字节的内容
    for address, instruction in instructions:
        bytes_content[0].append(instruction)  # 全部字节
        bytes_content[1].append(instruction[0:2])  # 第一个字节
        bytes_content[2].append(instruction[2:4])  # 第二个字节
        bytes_content[3].append(instruction[4:6])  # 第三个字节
        bytes_content[4].append(instruction[6:8])  # 第四个字节
        # bytes_content[1].append(instruction[6:8])  # 第一个字节
        # bytes_content[2].append(instruction[4:6])  # 第二个字节
        # bytes_content[3].append(instruction[2:4])  # 第三个字节
        # bytes_content[4].append(instruction[0:2])  # 第四个字节

    # 将字节内容写入文件，并确保文件大小为1024字节
    for i in range(5):
        with open(file_names[i], 'w') as file:
            # 写入实际字节
            for byte in bytes_content[i]:
                file.write(byte + '\n')

            # 填充0到1024字节
            if len(bytes_content[i]) < max_bytes:
                # 计算需要填充的零数量
                padding_size = max_bytes - len(bytes_content[i])
                if i == 0:
                    file.writelines(['00000000\n'] * padding_size)  # 填充零
                else:
                    file.writelines(['00\n'] * padding_size)  # 填充零
    
    print(f"Saved {len(instructions)} instructions to {output_dir}")



if __name__ == '__main__':
    input_file_path = 'F:/Project/Sipeed/FPGA/Tang_Mega/Riscv-SoC/tool/gpio.hex'
    output_file_path = 'ram'
    instructions = extract_code(input_file_path)

    # for instr in instructions:
    #     print(instr)    # 打印提取的RISC-V程序指令

    # 将每个字节保存到不同的文件中
    save_bytes_to_files(instructions, output_file_path)
